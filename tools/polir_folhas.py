#!/usr/bin/env python3
"""Polimento das folhas de animação do Penitente e de Beatriz.

Dois defeitos apareciam no jogo:
 1. Sujeira nas células: pontinhos soltos que sobraram do recorte do fundo e pedaços de arco de golpe
    que atravessavam a fronteira da célula e apareciam, cortados, no quadro vizinho.
 2. Cor diferente entre folhas: o Penitente parado é escuro, mas as folhas de combate eram até 50%
    mais claras e mais rosadas, então ele "acendia" ao aparar ou golpear.

Este script:
 - reencaixa quadros cuja lâmina ou arco passava da célula: junta o pedaço que tinha ido parar no
   quadro vizinho, desloca o desenho para caber e anota o deslocamento em clips.json
   ("deslocamentos"), para o jogo desenhar o quadro no lugar de antes, agora com a lâmina inteira;
 - apaga pontos soltos (menos de 14 pontos, longe do corpo) e fragmentos encostados na borda da
   célula que não fazem parte do corpo. Sangue (vermelho dominante) nunca é apagado;
 - iguala a luminosidade e a saturação das folhas em que o personagem aparece sozinho às da folha de
   movimento. Brancos de efeito (arcos de golpe, brilho da lâmina) ficam como estão.
As folhas de execução só são limpas, não recoloridas: nelas há vítima e sangue junto.

Uso: python3 tools/polir_folhas.py           (altera as folhas em assets/animation/)
     python3 tools/polir_folhas.py --medir   (só mostra os números, sem gravar)
"""
import json, os, sys
import numpy as np
from PIL import Image
from scipy import ndimage

PASTA = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "assets", "animation")
CELULA = 256
# referência de cor, folhas a igualar, folhas só a limpar
GRUPOS = {
    "penitente": {
        "referencia": ["hero_motion", "hero_reactions"],
        "igualar": ["hero_combat", "hero_combate", "hero_aerial", "hero_grief", "hero_memorial"],
        "limpar": ["hero_motion", "hero_reactions", "execute_devotee", "execute_mourner", "hero_executa_asmodeia", "hero_executa_bruxa",
                   "hero_executa_carregador", "hero_executa_devorador", "hero_executa_duelista", "hero_executa_flagelante"],
    },
    "beatriz": {
        "referencia": ["beatriz_movimento"],
        "igualar": ["beatriz_combate", "beatriz_reacoes", "beatriz_rituais", "beatriz_peso"],
        "limpar": ["beatriz_movimento"],
    },
}
PESO = np.array([0.299, 0.587, 0.114], np.float32)


def carregar(nome):
    return np.asarray(Image.open(os.path.join(PASTA, nome + ".png")).convert("RGBA")).astype(np.float32)


def medidas(a):
    """Luminosidade média, desvio e saturação média dos pontos opacos que não são branco de efeito."""
    rgb = a[..., :3]
    lum = rgb @ PESO
    sat = rgb.max(-1) - rgb.min(-1)
    corpo = (a[..., 3] > 128) & ~((lum > 195) & (sat < 30))
    return lum[corpo].mean(), lum[corpo].std(), sat[corpo].mean()


def reencaixar(a):
    """Devolve {índice da célula: deslocamento em pontos}. Positivo: o desenho foi movido para a esquerda."""
    alt, larg = a.shape[:2]
    colunas = larg // CELULA
    feitos = {}
    for cy in range(alt // CELULA):
        for cx in range(colunas):
            cel = a[cy * CELULA:(cy + 1) * CELULA, cx * CELULA:(cx + 1) * CELULA]
            opaco = cel[..., 3] > 24
            if opaco.sum() < 50: continue
            for lado in (1, -1):
                vx = cx + lado
                if vx < 0 or vx >= colunas: continue
                borda = opaco[:, -1] if lado == 1 else opaco[:, 0]
                if not borda.any(): continue
                viz = a[cy * CELULA:(cy + 1) * CELULA, vx * CELULA:(vx + 1) * CELULA]
                vop = viz[..., 3] > 24
                rot, n = ndimage.label(vop)
                if n == 0: continue
                areas = ndimage.sum(vop, rot, range(1, n + 1))
                principal = 1 + int(np.argmax(areas))
                linhas = ndimage.binary_dilation(borda, iterations=3)
                pedaco = np.zeros_like(vop)
                for i, fatia in enumerate(ndimage.find_objects(rot), 1):
                    if i == principal or areas[i - 1] > 4000: continue
                    encosta = fatia[1].start == 0 if lado == 1 else fatia[1].stop == CELULA
                    if not encosta: continue
                    col = (rot[:, 0] == i) if lado == 1 else (rot[:, -1] == i)
                    if (col & linhas).any(): pedaco |= rot == i
                if not pedaco.any(): continue
                xs = np.where(pedaco.any(0))[0]
                w = int(xs.max() + 1) if lado == 1 else int(CELULA - xs.min())
                # precisa haver margem vazia do outro lado para o desenho andar
                livre = np.where(opaco.any(0))[0]
                margem = int(livre.min()) if lado == 1 else int(CELULA - 1 - livre.max())
                fragmento = viz.copy()
                fragmento[~pedaco] = 0
                viz[pedaco] = 0
                if margem < w + 1: continue   # não cabe: o pedaço só deixa de sujar o quadro vizinho
                novo = np.zeros_like(cel)
                if lado == 1:
                    novo[:, :CELULA - w] = cel[:, w:]
                    novo[:, CELULA - w:] = fragmento[:, :w]
                else:
                    novo[:, w:] = cel[:, :CELULA - w]
                    novo[:, :w] = fragmento[:, CELULA - w:]
                cel[:] = novo
                opaco = cel[..., 3] > 24
                feitos[cy * colunas + cx] = feitos.get(cy * colunas + cx, 0) + lado * w
    return feitos


def emprestar_ponta(a, alvo, doador):
    """A estocada (célula alvo) foi pintada com a lâmina cortada na borda da célula e não há pedaço
    dela no quadro vizinho. Empresta a ponta da lâmina do quadro anterior (doador), que está na mesma
    pose, e desloca o desenho para ela caber. Devolve o deslocamento, ou 0 se não havia o que fazer."""
    colunas = a.shape[1] // CELULA
    def celula(i): return a[(i // colunas) * CELULA:(i // colunas + 1) * CELULA, (i % colunas) * CELULA:(i % colunas + 1) * CELULA]
    t, d = celula(alvo), celula(doador)
    top, dop = t[..., 3] > 24, d[..., 3] > 24
    faixa = np.where(top[:, -1])[0]
    if len(faixa) == 0: return 0
    centro_t = (faixa.min() + faixa.max()) / 2.0
    margem = int(np.where(top.any(0))[0].min()) - 1
    xmax = int(np.where(dop.any(0))[0].max())
    w = min(margem, 34)
    if w < 6: return 0
    # a ponta: as últimas w colunas da lâmina do doador, só na faixa de linhas da lâmina
    col0 = xmax - w + 1
    linhas = np.where(dop[:, col0])[0]
    linhas = linhas[np.abs(linhas - linhas[np.argmin(np.abs(linhas - centro_t))]) < 12]
    centro_d = (linhas.min() + linhas.max()) / 2.0
    dy = int(round(centro_t - centro_d))
    ponta = np.zeros((CELULA, w, 4), np.float32)
    y0, y1 = int(linhas.min()) - 6, int(linhas.max()) + 7
    for y in range(max(y0, 0), min(y1, CELULA)):
        if 0 <= y + dy < CELULA: ponta[y + dy] = d[y, col0:xmax + 1]
    novo = np.zeros_like(t)
    novo[:, :CELULA - w] = t[:, w:]
    novo[:, CELULA - w:] = ponta
    t[:] = novo
    return w


def anotar(manifesto, folha, feitos):
    """Grava os deslocamentos nos clipes de clips.json que usam as células reencaixadas."""
    for ator in manifesto.values():
        for clipe in ator.values():
            if clipe.get("sheet") != folha: continue
            indices = clipe.get("frames") or [int(clipe["start"]) + i for i in range(int(clipe["count"]))]
            if not any(int(i) in feitos for i in indices): continue
            atual = clipe.get("deslocamentos", [0] * len(indices))
            clipe["deslocamentos"] = [int(atual[k]) + int(feitos.get(int(i), 0)) for k, i in enumerate(indices)]


def limpar(a):
    """Apaga pontos soltos e fragmentos de borda, célula por célula. Devolve quantos pontos apagou."""
    alt, larg = a.shape[:2]
    apagados = 0
    for cy in range(alt // CELULA):
        for cx in range(larg // CELULA):
            cel = a[cy * CELULA:(cy + 1) * CELULA, cx * CELULA:(cx + 1) * CELULA]
            opaco = cel[..., 3] > 24
            if opaco.sum() < 50: continue
            rot, n = ndimage.label(opaco)
            if n <= 1: continue
            areas = ndimage.sum(opaco, rot, range(1, n + 1))
            principal = 1 + int(np.argmax(areas))
            # distância de cada ponto ao corpo principal
            dist = ndimage.distance_transform_edt(rot != principal)
            for i, fatia in enumerate(ndimage.find_objects(rot), 1):
                if i == principal: continue
                parte = rot[fatia] == i
                cores = cel[fatia][parte]
                r, g, b = cores[:, 0].mean(), cores[:, 1].mean(), cores[:, 2].mean()
                sangue = r > 40 and r > g * 1.6 and r > b * 1.6
                if sangue: continue
                na_borda = fatia[0].start == 0 or fatia[1].start == 0 or fatia[0].stop == CELULA or fatia[1].stop == CELULA
                longe = dist[fatia][parte].min()
                if (na_borda and areas[i - 1] < 1800 and longe > 3) or (areas[i - 1] < 14 and longe > 8):
                    cel[fatia][parte] = 0
                    apagados += int(areas[i - 1])
    return apagados


def igualar(a, ref):
    """Leva luminosidade e saturação para as da referência, preservando o matiz e os brancos de efeito."""
    m_ref, d_ref, s_ref = ref
    m, d, s = medidas(a)
    rgb = a[..., :3]
    lum = rgb @ PESO
    sat = rgb.max(-1) - rgb.min(-1)
    # ganho de contraste limitado: só aproxima, não achata
    ganho = np.clip(d_ref / max(d, 1e-3), 0.72, 1.15)
    nova = np.clip((lum - m) * ganho + m_ref, 0, 255)
    fator_sat = np.clip(s_ref / max(s, 1e-3), 0.6, 1.1)
    cinza = lum[..., None]
    cor = cinza + (rgb - cinza) * fator_sat
    cor = cor * (nova / np.maximum(lum, 1.0))[..., None]
    # brancos de efeito ficam intactos; a passagem é suave para não criar contorno
    branco = np.clip((lum - 185) / 40, 0, 1) * np.clip((45 - sat) / 25, 0, 1)
    a[..., :3] = np.clip(rgb * branco[..., None] + cor * (1 - branco[..., None]), 0, 255)
    return m, s


def gravar(nome, a):
    Image.fromarray(a.astype(np.uint8), "RGBA").save(os.path.join(PASTA, nome + ".png"), optimize=True)


if __name__ == "__main__":
    medir = "--medir" in sys.argv
    caminho_clipes = os.path.join(PASTA, "clips.json")
    manifesto = json.load(open(caminho_clipes, encoding="utf-8"))
    for grupo, cfg in GRUPOS.items():
        refs = [medidas(carregar(n)) for n in cfg["referencia"]]
        ref = tuple(float(np.mean([r[i] for r in refs])) for i in range(3))
        print("%s: referência luminosidade %.0f, saturação %.0f" % (grupo, ref[0], ref[2]))
        for nome in cfg["igualar"] + cfg["limpar"]:
            a = carregar(nome)
            antes = medidas(a)
            if medir:
                print("  %-26s luminosidade %.0f  saturação %.0f" % (nome, antes[0], antes[2]))
                continue
            feitos = reencaixar(a)
            # A estocada do primeiro golpe do Penitente: lâmina cortada na borda, sem pedaço no vizinho.
            if nome == "hero_combat":
                emprestado = emprestar_ponta(a, 3, 2)
                if emprestado: feitos[3] = feitos.get(3, 0) + emprestado
            if feitos: anotar(manifesto, nome, feitos)
            apagados = limpar(a)
            if nome in cfg["igualar"]: igualar(a, ref)
            depois = medidas(a)
            gravar(nome, a)
            print("  %-26s luminosidade %3.0f -> %3.0f  saturação %2.0f -> %2.0f  sujeira apagada: %d pontos  reencaixados: %s" % (nome, antes[0], depois[0], antes[2], depois[2], apagados, feitos if feitos else "-"))
    if not medir:
        json.dump(manifesto, open(caminho_clipes, "w", encoding="utf-8"), ensure_ascii=False, indent=2)
