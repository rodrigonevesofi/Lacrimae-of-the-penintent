#!/usr/bin/env python3
"""Gera as máscaras que dizem ao shader `pintura_viva` o que se move em cada pintura de sala.

Cada sala é uma pintura única. Em vez de repintar tudo em camadas, este script lê a pintura e marca,
por cor e por região, o que é pano, água, céu, chama e vitral. O shader usa essas marcas para
balançar os panos, fazer a água correr, mover as nuvens e tremer as chamas.

Saída, por sala, em assets/vivo/:
  <sala>_a.png  R = pano (balança)   G = água (corre e ondula)   B = céu (nuvens passam)
  <sala>_b.png  R = chama (tremula)  G = halo de luz das chamas  B = vitral / luz fria (cintila)

As máscaras têm metade da resolução da pintura e bordas suaves, para o movimento morrer aos poucos
na borda de cada pano em vez de rasgar a imagem.

Uso:  python3 tools/gerar_mascaras_vivas.py            (gera tudo)
      python3 tools/gerar_mascaras_vivas.py --revisar  (grava também imagens de conferência em /tmp)
"""
import colorsys
import os
import sys

import numpy as np
from PIL import Image
from scipy import ndimage

RAIZ = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..")
SAIDA = os.path.join(RAIZ, "assets", "vivo")

# Regiões em fração da imagem: (x0, y0, x1, y1). "ceu" lista as caixas onde pode haver céu e o tipo de cor.
SALAS = {
    "vespera_panorama": {
        "ceu": {"caixas": [(0.27, 0.0, 0.84, 0.50)], "tipo": "poente"},
        "agua": {"caixas": [(0.345, 0.62, 0.43, 0.97)], "tipo": "nevoa"},
    },
    "ossuary": {
        "agua": {"caixas": [(0.85, 0.50, 1.0, 1.0)], "tipo": "verde"},
    },
    "cistern": {
        "agua": {"caixas": [(0.0, 0.30, 1.0, 0.925)], "tipo": "jorro", "faixa": 0.925},
    },
    "cloister": {
        "ceu": {"caixas": [(0.0, 0.0, 1.0, 0.62)], "tipo": "poente"},
    },
    "tower": {
        "ceu": {"caixas": [(0.0, 0.0, 1.0, 0.98)], "tipo": "poente_janela"},
    },
    "gallery": {
        "vitral": {"caixas": [(0.0, 0.0, 1.0, 0.62)], "tipo": "cinza"},
    },
    "gates": {
        "ceu": {"caixas": [(0.0, 0.0, 0.37, 0.70)], "tipo": "poente_livre"},
    },
    "nave_silencio": {
        "vitral": {"caixas": [(0.0, 0.0, 1.0, 0.90)], "tipo": "azul"},
    },
    "terraco_sinos": {
        "ceu": {"caixas": [(0.0, 0.0, 1.0, 0.80)], "tipo": "azul"},
    },
    "patio_portoes": {
        "ceu": {"caixas": [(0.52, 0.0, 1.0, 0.36)], "tipo": "poente"},
    },
}


def hsv(rgb):
    """RGB (0..1) -> matiz em graus, saturação e valor."""
    r, g, b = rgb[..., 0], rgb[..., 1], rgb[..., 2]
    mx = rgb.max(axis=-1)
    mn = rgb.min(axis=-1)
    d = mx - mn
    h = np.zeros_like(mx)
    m = d > 1e-6
    rc = np.where(m, (mx - r) / np.where(m, d, 1), 0)
    gc = np.where(m, (mx - g) / np.where(m, d, 1), 0)
    bc = np.where(m, (mx - b) / np.where(m, d, 1), 0)
    h = np.where(mx == r, bc - gc, np.where(mx == g, 2.0 + rc - bc, 4.0 + gc - rc))
    h = (h / 6.0) % 1.0 * 360.0
    s = np.where(mx > 1e-6, d / np.where(mx > 1e-6, mx, 1), 0)
    return h, s, mx


def caixa(shape, caixas):
    alt, larg = shape
    m = np.zeros(shape, bool)
    for x0, y0, x1, y1 in caixas:
        m[int(y0 * alt):int(y1 * alt), int(x0 * larg):int(x1 * larg)] = True
    return m


def limpar(m, abrir=1, fechar=2, area_min=0, area_max=0):
    """Remove pontos soltos, fecha buracos e filtra manchas por área."""
    if abrir: m = ndimage.binary_opening(m, iterations=abrir)
    if fechar: m = ndimage.binary_closing(m, iterations=fechar)
    if area_min or area_max:
        rot, n = ndimage.label(m)
        if n:
            areas = ndimage.sum(m, rot, np.arange(1, n + 1))
            ok = np.ones(n + 1, bool)
            ok[0] = False
            if area_min: ok[1:] &= areas >= area_min
            if area_max: ok[1:] &= areas <= area_max
            m = ok[rot]
    return m


def suave(m, raio):
    return np.clip(ndimage.gaussian_filter(m.astype(np.float32), raio), 0, 1)


def gerar(nome, cfg, revisar=False):
    img = Image.open(os.path.join(RAIZ, "assets", nome + ".png")).convert("RGB")
    rgb = np.asarray(img, np.float32) / 255.0
    h, s, v = hsv(rgb)
    lum = rgb @ np.array([0.299, 0.587, 0.114], np.float32)
    # Textura local: céu e água lisa têm pouca variação; pedra esculpida tem muita.
    media = ndimage.uniform_filter(lum, 9)
    textura = np.sqrt(np.maximum(ndimage.uniform_filter(lum * lum, 9) - media * media, 0))
    forma = lum.shape

    # ---- céu
    ceu = np.zeros(forma, bool)
    if "ceu" in cfg:
        tipo = cfg["ceu"]["tipo"]
        dentro = caixa(forma, cfg["ceu"]["caixas"])
        if tipo == "azul":
            ceu = dentro & (h > 185) & (h < 245) & (s > 0.22) & (v > 0.30)
        elif tipo == "poente_janela":
            # Janelas altas da torre: laranja e rosa luminosos, lisos.
            ceu = dentro & (((h < 42) | (h > 300)) & (s > 0.30) & (v > 0.62) | ((h > 230) & (h < 300) & (v > 0.40) & (s > 0.15))) & (textura < 0.055)
        elif tipo == "poente_livre":
            ceu = dentro & (textura < 0.075) & (v > 0.22) & ((h < 30) | (h > 235))
        else:
            ceu = dentro & (textura < 0.06) & (((h < 45) | (h > 300)) & (v > 0.55) & (s > 0.18) | ((h > 215) & (h <= 300) & (v > 0.36) & (s > 0.10)))
        ceu = limpar(ceu, abrir=2, fechar=3, area_min=900)
        ceu = ndimage.binary_fill_holes(ceu) if tipo in ("poente", "poente_livre") else ceu

    # ---- pano: vermelho saturado (estandartes, cortinas, hera vermelha)
    pano = ((h > 340) | (h < 9)) & (s > 0.50) & (v > 0.16) & (v < 0.80) & ~ceu
    pano = limpar(pano, abrir=1, fechar=2, area_min=120)

    # ---- água
    agua = np.zeros(forma, bool)
    faixa = np.zeros(forma, bool)
    if "agua" in cfg:
        tipo = cfg["agua"]["tipo"]
        dentro = caixa(forma, cfg["agua"]["caixas"])
        if tipo == "jorro":
            # Os jorros são frios e pálidos numa parede de pedra quente e musgo verde.
            agua = dentro & (((h > 120) & (h < 235) & (s > 0.04) & (s < 0.36) & (v > 0.40)) | ((s < 0.07) & (v > 0.68)))
            agua = limpar(agua, abrir=0, fechar=2, area_min=45)
            y0 = int(cfg["agua"]["faixa"] * forma[0])
            faixa[y0:, :] = True
        elif tipo == "verde":
            agua = dentro & (h > 105) & (h < 185) & (s > 0.25) & (v > 0.22)
            agua = limpar(agua, abrir=1, fechar=3, area_min=200)
        else:
            agua = dentro & (s < 0.30) & (v > 0.42) & (textura < 0.07)
            agua = limpar(agua, abrir=2, fechar=3, area_min=300)

    # ---- vitral e luz fria
    vitral = np.zeros(forma, bool)
    if "vitral" in cfg:
        tipo = cfg["vitral"]["tipo"]
        dentro = caixa(forma, cfg["vitral"]["caixas"])
        if tipo == "azul":
            vitral = dentro & (h > 180) & (h < 235) & (s > 0.30) & (v > 0.45)
        else:
            vitral = dentro & (h > 180) & (h < 250) & (s > 0.06) & (v > 0.52)
        vitral = limpar(vitral, abrir=1, fechar=2, area_min=150)

    # ---- chamas: pequenos pontos quentes e muito claros
    # Uma chama tem miolo quase branco e é muito mais clara que o que a cerca; a pedra banhada de poente não.
    destaque = lum - ndimage.gaussian_filter(lum, 10.0)
    miolo = (rgb[..., 0] > 0.93) & (rgb[..., 1] > 0.80) & (rgb[..., 2] > 0.42) & (destaque > 0.30) & ~ceu
    miolo &= ~ndimage.binary_dilation(ceu, iterations=6)
    miolo = limpar(miolo, abrir=0, fechar=1, area_min=2, area_max=260)
    # Chamas são compactas; a aresta iluminada de um piso ou de uma corrente é comprida e fica de fora.
    rot, n = ndimage.label(miolo)
    for i, fatia in enumerate(ndimage.find_objects(rot), 1):
        alt_f = fatia[0].stop - fatia[0].start
        larg_f = fatia[1].stop - fatia[1].start
        if larg_f > 20 or alt_f > 30 or larg_f > alt_f * 2.5 + 3:
            miolo[fatia][rot[fatia] == i] = False
    # A chama inteira: o entorno quente e claro de cada miolo.
    chama = ndimage.binary_dilation(miolo, iterations=3) & (v > 0.78) & (h > 15) & (h < 65)
    halo = suave(ndimage.binary_dilation(chama, iterations=2), 9.0) * 2.4

    a = np.stack([suave(pano, 2.2), np.maximum(suave(agua, 1.6), faixa.astype(np.float32)), suave(ceu, 2.0)], -1)
    b = np.stack([suave(ndimage.binary_dilation(chama, iterations=1), 1.0), np.clip(halo, 0, 1), suave(vitral, 1.8)], -1)
    meio = (img.width // 2, img.height // 2)
    os.makedirs(SAIDA, exist_ok=True)
    Image.fromarray((np.clip(a, 0, 1) * 255).astype(np.uint8)).resize(meio, Image.BILINEAR).save(os.path.join(SAIDA, nome + "_a.png"), optimize=True)
    Image.fromarray((np.clip(b, 0, 1) * 255).astype(np.uint8)).resize(meio, Image.BILINEAR).save(os.path.join(SAIDA, nome + "_b.png"), optimize=True)
    partes = {"pano": pano.mean(), "agua": max(agua.mean(), 0), "ceu": ceu.mean(), "chama": chama.mean(), "vitral": vitral.mean()}
    print("%-18s " % nome + "  ".join("%s %.1f%%" % (k, x * 100) for k, x in partes.items()))
    if revisar:
        # Conferência: a pintura escurecida com cada marca numa cor viva.
        base = rgb * 0.35
        for mask, cor in ((a[..., 0], (1, 0, 0)), (a[..., 1], (0, 1, 0.6)), (a[..., 2], (0.2, 0.4, 1)), (b[..., 1], (1, 0.8, 0)), (b[..., 2], (1, 0, 1))):
            base = base * (1 - 0.75 * mask[..., None]) + np.array(cor, np.float32) * 0.75 * mask[..., None]
        out = Image.fromarray((np.clip(base, 0, 1) * 255).astype(np.uint8))
        out.thumbnail((1400, 700))
        out.save(os.path.join(os.environ.get("REVISAO", "/tmp"), "mascara_" + nome + ".jpg"), quality=85)


if __name__ == "__main__":
    revisar = "--revisar" in sys.argv
    for nome, cfg in SALAS.items():
        gerar(nome, cfg, revisar)
