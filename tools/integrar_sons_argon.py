#!/usr/bin/env python3
"""Integra um pacote de sons do Argon em assets/audio/, com conferência e ajuste de volume.

O pacote chega com todo arquivo normalizado no mesmo pico (-1,2 dB). Isso desfaz a mixagem do jogo:
a música fica de 5 a 13 dB mais alta que antes, as ambiências de 2 a 10 dB, os sons de menu 10 a 13 dB.
Este script:
 1. confere cada arquivo (44,1 kHz, 16 bits, sem ceifamento, início e fim em zero, início rápido);
 2. recusa músicas repetidas (mesma onda com outro nome) e músicas sem conteúdo acima do grave;
 3. leva o volume médio de cada som ao do arquivo que ele substitui, sem nunca passar do pico de -1,2 dB.
    Sons novos (os do Vale) ficam no volume típico dos efeitos de cena;
 4. grava o relatório em docs/sons-argon-v40.json.

Uso: python3 tools/integrar_sons_argon.py <pasta com os WAV do pacote> [--so-medir]
"""
import glob, hashlib, itertools, json, os, sys, wave
import numpy as np

RAIZ = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..")
DESTINO = os.path.join(RAIZ, "assets", "audio")
PICO_MAX = 10 ** (-1.2 / 20)
VOLUME_CENA_DB = -19.0     # sons novos de cena (Vale): o volume médio típico dos efeitos de cena atuais
## Músicas aceitas do pacote. As demais ficam de fora (ver docs/sons-argon-v40.md).
MUSICAS_ACEITAS = ["ost_revelacao"]


def ler(caminho):
    with wave.open(caminho, "rb") as w:
        sr, sw, ch, n = w.getframerate(), w.getsampwidth(), w.getnchannels(), w.getnframes()
        bruto = w.readframes(n)
    if sw != 2: raise ValueError("não é 16 bits")
    return sr, ch, np.frombuffer(bruto, "<i2").astype(np.float64).reshape(-1, ch) / 32768


def gravar(caminho, sr, x):
    pcm = np.clip(np.round(x * 32768), -32767, 32767).astype("<i2")
    with wave.open(caminho, "wb") as w:
        w.setnchannels(x.shape[1]); w.setsampwidth(2); w.setframerate(sr); w.writeframes(pcm.tobytes())


def db(v): return 20 * np.log10(max(float(v), 1e-9))
def rms(x): return float(np.sqrt((x * x).mean()))


def banda_audivel(x, sr, corte=150.0):
    """Volume médio do que um alto-falante pequeno reproduz (acima de 150 Hz)."""
    m = x.mean(1)
    espectro = np.fft.rfft(m)
    f = np.fft.rfftfreq(len(m), 1 / sr)
    total = (np.abs(espectro) ** 2).sum() + 1e-20
    return rms(x) * np.sqrt((np.abs(espectro[f > corte]) ** 2).sum() / total)


def corta_grave(x, sr, corte=120.0, ganho_db=-8.0):
    """Prateleira nos graves: abaixo de `corte` o volume cai `ganho_db`, com transição suave."""
    saida = np.empty_like(x)
    for c in range(x.shape[1]):
        espectro = np.fft.rfft(x[:, c])
        f = np.fft.rfftfreq(len(x), 1 / sr)
        peso = 1.0 / (1.0 + (f / corte) ** 4)           # 1 nos graves, 0 acima
        espectro *= 10 ** (ganho_db * peso / 20)
        saida[:, c] = np.fft.irfft(espectro, len(x))
    return saida


def emendar_laco(x):
    """Laço sem emenda e com a mesma duração. As ambiências chegam com um corte de poucos milissegundos
    em cada ponta, que estala a cada volta. Aqui o som é somado a uma cópia de si mesmo adiantada meia
    volta: nas pontas toca só a cópia (que ali está no meio do som, contínua) e no meio toca só o
    original. O resultado dá a volta sem degrau e sem mudar de tamanho."""
    n = len(x)
    fase = np.pi * np.arange(n) / n
    # A emenda passa a ser um ponto do meio do som. Escolhe, perto da metade, o ponto mais calmo
    # (menor salto e menor curvatura), para que nem por acaso caia em cima de uma gota ou de um estalo.
    meio = n // 2
    trecho = x[meio - 2000:meio + 2002]
    salto = np.abs(np.diff(trecho, axis=0)).max(1)
    agitacao = salto[:-2] + salto[1:-1] + salto[2:]
    corte = meio - 2000 + 2 + int(np.argmin(agitacao))
    copia = np.roll(x, n - corte, axis=0)
    y = x * np.sin(fase)[:, None] + copia * np.abs(np.cos(fase))[:, None]
    return y - y.mean(0)


def conferir(nome, sr, ch, x):
    erros = []
    if sr != 44100: erros.append("taxa %d" % sr)
    if np.abs(x).max() >= 0.9995: erros.append("ceifado")
    laco = nome.startswith(("amb_", "ost_"))
    if np.abs(x.mean(0)).max() > 0.005: erros.append("deslocamento DC")
    if laco:
        # No laço o que importa é a emenda: o salto do último ponto para o primeiro não pode ser maior
        # que os saltos normais do próprio som.
        emenda = np.abs(x[0] - x[-1]).max()
        if emenda > np.quantile(np.abs(np.diff(x, axis=0)), 0.999) + 2 / 32768: erros.append("estalo na emenda do laço")
    elif np.abs(x[[0, -1]]).max() > 1.5 / 32768: erros.append("pontas fora de zero")
    if laco and ch != 2: erros.append("laço mono")
    if not laco:
        if ch != 1: erros.append("efeito estéreo")
        pico = np.abs(x).max()
        inicio = np.flatnonzero(np.abs(x).max(1) > pico * 0.01)[0] / sr * 1000
        if inicio > 50: erros.append("início tardio (%d ms)" % inicio)
    return erros


def main():
    origem = sys.argv[1]
    so_medir = "--so-medir" in sys.argv
    arquivos = sorted(glob.glob(os.path.join(origem, "*.wav")))
    dados = {os.path.basename(p)[:-4]: ler(p) for p in arquivos}
    relatorio = {"aceitos": {}, "recusados": {}, "metodo": "Medidas de onda (pico, volume médio, início, pontas, semelhança entre arquivos, energia por faixa). Nenhuma escuta humana."}

    # ---- músicas: repetidas e sem conteúdo acima do grave
    musicas = [n for n in dados if n.startswith("ost_")]
    for a, b in itertools.combinations(musicas, 2):
        xa, xb = dados[a][2].mean(1), dados[b][2].mean(1)
        n = min(len(xa), len(xb))
        semelhanca = abs(float(np.dot(xa[:n], xb[:n]) / (np.linalg.norm(xa[:n]) * np.linalg.norm(xb[:n]) + 1e-12)))
        if semelhanca > 0.85:
            relatorio.setdefault("musicas_repetidas", []).append([a, b, round(semelhanca, 3)])
    for n in musicas:
        sr, ch, x = dados[n]
        m = x.mean(1)
        espectro = np.abs(np.fft.rfft(m)) ** 2
        f = np.fft.rfftfreq(len(m), 1 / sr)
        grave = float(espectro[f < 200].sum() / espectro.sum())
        relatorio.setdefault("musicas_energia_abaixo_de_200hz", {})[n] = round(grave, 3)
        if n not in MUSICAS_ACEITAS:
            relatorio["recusados"][n] = "música não integrada: %d%% da energia abaixo de 200 Hz, sem notas; ver musicas_repetidas" % round(grave * 100)

    for nome, (sr, ch, x) in dados.items():
        if nome in relatorio["recusados"]: continue
        if nome.startswith("amb_"): x = emendar_laco(x)
        erros = conferir(nome, sr, ch, x)
        if erros:
            relatorio["recusados"][nome] = "; ".join(erros)
            continue
        antigo = os.path.join(DESTINO, nome + ".wav")
        volume = rms(x)
        if nome.startswith("ost_"):
            # A música nova é quase só grave. Corta 8 dB abaixo de 120 Hz e iguala a faixa audível à da música de história.
            x = corta_grave(x, sr)
            _, _, historia = ler(os.path.join(DESTINO, "ost_story.wav"))
            alvo_audivel = banda_audivel(historia, 44100)
            ganho = alvo_audivel / banda_audivel(x, sr)
            regra = "faixa audível igual à de ost_story"
        elif os.path.exists(antigo):
            _, _, velho = ler(antigo) if wave.open(antigo).getsampwidth() == 2 else (0, 0, None)
            ganho = rms(velho) / rms(x)
            regra = "volume médio do arquivo substituído"
        else:
            ganho = 10 ** (VOLUME_CENA_DB / 20) / volume
            regra = "volume típico de efeito de cena"
        limite = PICO_MAX / np.abs(x).max()
        if ganho > limite:
            # O som novo tem estalos mais altos que o antigo e ficaria mais baixo. Sobe até 8 dB e
            # arredonda só as pontas dos estalos (limitador suave), sem passar do pico.
            ganho = min(ganho, limite * 10 ** (8 / 20))
            y = x * ganho
            joelho = 0.6 * PICO_MAX
            alto = np.abs(y) > joelho
            y[alto] = np.sign(y[alto]) * (joelho + (PICO_MAX - joelho) * np.tanh((np.abs(y[alto]) - joelho) / (PICO_MAX - joelho)))
            regra += " (com limitador suave nos estalos)"
        else:
            y = x * ganho
        # as pontas voltam exatamente a zero depois do filtro
        if nome.startswith("ost_"):
            rampa = int(0.004 * sr)
            y[:rampa] *= np.linspace(0, 1, rampa)[:, None]
            y[-rampa:] *= np.linspace(1, 0, rampa)[:, None]
        # Um ponto a mais ou a menos que o arquivo antigo: iguala (as pontas são zero, não muda o som).
        if os.path.exists(antigo) and not nome.startswith(("amb_", "ost_")):
            falta = wave.open(antigo).getnframes() - len(y)
            if falta == 1: y = np.vstack([y, np.zeros((1, y.shape[1]))])
            elif falta == -1: y = y[:-1]; y[-1] = 0
        relatorio["aceitos"][nome] = {"segundos": round(len(y) / sr, 3), "canais": ch, "volume_recebido_db": round(db(volume), 1), "volume_final_db": round(db(rms(y)), 1),
            "pico_final_db": round(db(np.abs(y).max()), 1), "substitui": os.path.exists(antigo), "regra": regra}
        if not so_medir:
            gravar(antigo, sr, y)
            relatorio["aceitos"][nome]["sha256"] = hashlib.sha256(open(antigo, "rb").read()).hexdigest()
    # ---- quartas variações: "swing.wav" e "dor.wav" são sorteadas junto com _01 a _03, mas não vêm no pacote.
    # Para o golpe não alternar entre o som novo e o antigo, cada uma é derivada de uma variação nova,
    # um pouco mais grave ou mais aguda, no volume do arquivo que substitui.
    for base, fonte, altura in (("swing", "swing_02", 0.93), ("dor", "dor_02", 1.06)):
        if fonte not in relatorio["aceitos"] or so_medir: continue
        sr, ch, x = ler(os.path.join(DESTINO, fonte + ".wav"))
        alvo = os.path.join(DESTINO, base + ".wav")
        n_antigo = wave.open(alvo).getnframes() * 44100 // wave.open(alvo).getframerate()
        _, _, velho = ler(alvo)
        posicoes = np.arange(0, len(x) - 1, altura)
        y = np.interp(posicoes, np.arange(len(x)), x[:, 0])
        y = np.pad(y, (0, max(0, n_antigo - len(y))))[:n_antigo]
        fim = min(len(y), 220)
        y[-fim:] *= np.linspace(1, 0, fim)
        y *= min(rms(velho) / rms(y[:, None]), PICO_MAX / np.abs(y).max())
        gravar(alvo, 44100, y[:, None])
        relatorio["aceitos"][base] = {"segundos": round(len(y) / 44100, 3), "canais": 1, "volume_final_db": round(db(rms(y[:, None])), 1), "pico_final_db": round(db(np.abs(y).max()), 1),
            "substitui": True, "regra": "derivado de %s, altura x%.2f" % (fonte, altura), "sha256": hashlib.sha256(open(alvo, "rb").read()).hexdigest()}
    if not so_medir:
        json.dump(relatorio, open(os.path.join(RAIZ, "docs", "sons-argon-v40.json"), "w", encoding="utf-8"), ensure_ascii=False, indent=1)
    print("aceitos: %d   recusados: %d" % (len(relatorio["aceitos"]), len(relatorio["recusados"])))
    for n, motivo in relatorio["recusados"].items(): print("  recusado %-18s %s" % (n, motivo))
    limitados = [n for n, v in relatorio["aceitos"].items() if "limitador" in v["regra"]]
    print("  com limitador suave:", ", ".join(limitados))


if __name__ == "__main__":
    main()
