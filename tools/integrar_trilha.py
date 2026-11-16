#!/usr/bin/env python3
"""Integra a trilha gerada no Lyria (Google Flow Music) em assets/audio/ como OGG em laço.

Para cada faixa (ost_<contexto>.mp3 ou .wav numa pasta):
 1. decodifica para 44,1 kHz estéreo;
 2. corta o silêncio do começo e do fim;
 3. faz a emenda do laço: os últimos 3 s (a cauda de reverberação) são fundidos sobre os primeiros 3 s,
    para a faixa dar a volta sem buraco e sem estalo;
 4. leva o volume médio ao alvo do contexto (a música de luta mais alta que a de exploração) e
    garante pico de até -1 dB;
 5. grava assets/audio/ost_<contexto>.ogg (Vorbis) e registra em docs/trilha-v41.json.

O jogo toca o .ogg quando existe; o .wav antigo do mesmo contexto fica como reserva.
Uso: python3 tools/integrar_trilha.py <pasta com as faixas>      (precisa de ffmpeg)
"""
import glob, hashlib, json, os, subprocess, sys, tempfile, wave
import numpy as np

RAIZ = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..")
DESTINO = os.path.join(RAIZ, "assets", "audio")
SR = 44100
EMENDA = 3.0
PICO = 10 ** (-1.0 / 20)
## Volume médio de cada contexto, em dB. Segue a hierarquia da mixagem anterior.
ALVOS = {"menu": -23.0, "exploration": -24.5, "combat": -20.0, "boss": -19.0, "story": -23.5, "temple": -24.5, "ending": -23.0, "vale": -19.0, "revelacao": -21.5}


def decodificar(caminho):
    with tempfile.NamedTemporaryFile(suffix=".wav", delete=False) as tmp: saida = tmp.name
    subprocess.run(["ffmpeg", "-y", "-loglevel", "error", "-i", caminho, "-ar", str(SR), "-ac", "2", "-c:a", "pcm_s16le", saida], check=True)
    with wave.open(saida) as w: x = np.frombuffer(w.readframes(w.getnframes()), "<i2").astype(np.float64).reshape(-1, 2) / 32768
    os.remove(saida)
    return x


def db(v): return 20 * np.log10(max(float(v), 1e-9))


def preparar(x, alvo_db):
    # ---- silêncio das pontas (abaixo de -50 dB)
    janela = int(0.05 * SR)
    env = np.sqrt(np.convolve(np.abs(x).max(1) ** 2, np.ones(janela) / janela, "same"))
    som = np.flatnonzero(env > 10 ** (-50 / 20))
    x = x[max(som[0] - int(0.01 * SR), 0):som[-1] + 1]
    # ---- emenda: a cauda é somada ao começo, com potência constante
    n = int(EMENDA * SR)
    t = np.linspace(0, np.pi / 2, n)[:, None]
    corpo = x[:-n].copy()
    corpo[:n] = corpo[:n] * np.sin(t) + x[-n:] * np.cos(t)
    # ---- volume
    corpo *= 10 ** (alvo_db / 20) / np.sqrt((corpo ** 2).mean())
    pico = np.abs(corpo).max()
    if pico > PICO:
        # arredonda só o que passa do joelho (limitador suave), sem baixar a faixa inteira
        joelho = 0.7 * PICO
        alto = np.abs(corpo) > joelho
        corpo[alto] = np.sign(corpo[alto]) * (joelho + (PICO - joelho) * np.tanh((np.abs(corpo[alto]) - joelho) / (PICO - joelho)))
    return corpo


def main():
    origem = sys.argv[1]
    relatorio = {"origem": "Lyria 3.5 (Google Flow Music), gerado pelo autor", "faixas": {}}
    for contexto, alvo in ALVOS.items():
        achados = [p for ext in ("wav", "mp3", "ogg", "m4a", "flac") for p in glob.glob(os.path.join(origem, "ost_%s.%s" % (contexto, ext)))]
        if not achados:
            print("  falta ost_%s" % contexto)
            continue
        bruto = decodificar(achados[0])
        y = preparar(bruto, alvo)
        with tempfile.NamedTemporaryFile(suffix=".wav", delete=False) as tmp: temp = tmp.name
        with wave.open(temp, "wb") as w:
            w.setnchannels(2); w.setsampwidth(2); w.setframerate(SR); w.writeframes(np.clip(np.round(y * 32768), -32767, 32767).astype("<i2").tobytes())
        saida = os.path.join(DESTINO, "ost_%s.ogg" % contexto)
        subprocess.run(["ffmpeg", "-y", "-loglevel", "error", "-i", temp, "-c:a", "libvorbis", "-q:a", "6", saida], check=True)
        os.remove(temp)
        relatorio["faixas"]["ost_" + contexto] = {"segundos_recebidos": round(len(bruto) / SR, 1), "segundos_em_laco": round(len(y) / SR, 1), "volume_recebido_db": round(db(np.sqrt((bruto ** 2).mean())), 1),
            "volume_final_db": round(db(np.sqrt((y ** 2).mean())), 1), "pico_final_db": round(db(np.abs(y).max()), 1), "degrau_na_emenda": round(float(np.abs(y[0] - y[-1]).max()), 4),
            "bytes": os.path.getsize(saida), "sha256": hashlib.sha256(open(saida, "rb").read()).hexdigest()}
        print("  ost_%-12s %5.1f s -> %5.1f s em laço   volume %5.1f -> %5.1f dB   pico %4.1f dB   %4.1f MB" % (contexto, len(bruto) / SR, len(y) / SR, db(np.sqrt((bruto ** 2).mean())), alvo, db(np.abs(y).max()), os.path.getsize(saida) / 1e6))
    json.dump(relatorio, open(os.path.join(RAIZ, "docs", "trilha-v41.json"), "w", encoding="utf-8"), ensure_ascii=False, indent=1)


if __name__ == "__main__":
    main()
