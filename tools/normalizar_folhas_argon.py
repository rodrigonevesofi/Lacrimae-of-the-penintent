"""Normaliza folhas 6 x 4 geradas pelo Argon para o formato do jogo (1536 x 1024, células de 256, pés em 128, 250).
Diferente do script do Argon, usa UMA escala para a folha inteira (medida no quadro parado), para que um quadro
agachado não saia do mesmo tamanho de um quadro em pé; remove o fundo só onde ele toca a borda do quadro (para
não apagar a capa escura); e registra cada quadro pelos pés e pelo centro do corpo, não pela ponta da arma."""
import sys
import numpy as np
from PIL import Image
import scipy.ndimage as ndi

CELL, COLS, ROWS = 256, 6, 4
FOOT = (128, 250)

def cells(path):
    im = Image.open(path).convert("RGB")
    w, h = im.size
    cw, ch = w / COLS, h / ROWS
    for k in range(COLS * ROWS):
        r, c = divmod(k, COLS)
        yield k, im.crop((int(c * cw) + 6, int(r * ch) + 6, int((c + 1) * cw) - 6, int((r + 1) * ch) - 6))

def cut(tile):
    a = np.array(tile).astype(int)
    corners = np.vstack([a[:6, :6].reshape(-1, 3), a[:6, -6:].reshape(-1, 3), a[-6:, :6].reshape(-1, 3), a[-6:, -6:].reshape(-1, 3)])
    bg = np.median(corners, axis=0)
    near = np.linalg.norm(a - bg, axis=2) < 24
    lab, n = ndi.label(near)
    border = set(np.unique(np.concatenate([lab[0], lab[-1], lab[:, 0], lab[:, -1]]))) - {0}
    background = np.isin(lab, list(border))
    figure = ~background
    figure = ndi.binary_erosion(figure, iterations=1)  # o halo do JPG
    lab2, n2 = ndi.label(figure)
    if n2:
        sizes = ndi.sum(figure, lab2, range(1, n2 + 1))
        keep = np.isin(lab2, [i + 1 for i, s in enumerate(sizes) if s >= 60])
        figure = keep
    rgba = np.dstack([a.astype(np.uint8), (figure * 255).astype(np.uint8)])
    return Image.fromarray(rgba, "RGBA"), figure

def anchor(mask):
    ys, xs = np.where(mask)
    if len(ys) == 0: return None
    top, bottom = ys.min(), ys.max()
    rows = mask.sum(axis=1)
    feet = bottom
    while feet > top and rows[feet] < 6: feet -= 1
    h = feet - top + 1
    band = (ys >= top + 0.40 * h) & (ys <= top + 0.90 * h)
    body_x = float(np.median(xs[band])) if band.any() else float(np.median(xs))
    return top, feet, body_x, h

def normalize(sources, outputs, target=236, scale_from=(0, 0)):
    cut_tiles = [[cut(t) for _, t in cells(s)] for s in sources]
    sheet_i, frame_i = scale_from
    ref = anchor(cut_tiles[sheet_i][frame_i][1])
    scale = target / ref[3]
    for tiles, out in zip(cut_tiles, outputs):
        atlas = Image.new("RGBA", (COLS * CELL, ROWS * CELL), (0, 0, 0, 0))
        for k, (img, mask) in enumerate(tiles):
            an = anchor(mask)
            if an is None: continue
            top, feet, body_x, _ = an
            small = img.resize((max(1, round(img.width * scale)), max(1, round(img.height * scale))), Image.Resampling.LANCZOS)
            ox = round(FOOT[0] - body_x * scale)
            oy = round(FOOT[1] - feet * scale)
            cell = Image.new("RGBA", (CELL, CELL), (0, 0, 0, 0))
            cell.alpha_composite(small, (0, 0)) if False else None
            canvas = Image.new("RGBA", (CELL * 3, CELL * 3), (0, 0, 0, 0))
            canvas.alpha_composite(small, (CELL + ox, CELL + oy))
            cell = canvas.crop((CELL, CELL, CELL * 2, CELL * 2))
            r, c = divmod(k, COLS)
            atlas.paste(cell, (c * CELL, r * CELL))
        atlas.save(out)
        print("salvo", out, "escala %.3f" % scale)

if __name__ == "__main__":
    # uso: normalizar_folhas_argon.py <origem_movimento> <origem_combate> <destino_movimento> <destino_combate>
    normalize(sys.argv[1:3], sys.argv[3:5])
