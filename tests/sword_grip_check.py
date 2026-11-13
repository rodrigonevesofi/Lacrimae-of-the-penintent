"""The sword must sit in the Penitent's fist: every grip point in player.gd has to land on the drawn hand
(opaque pixels of hero_motion.png), never in the air or on another part of the body far from the fist."""
import re, sys
from PIL import Image
src = open("scripts/player.gd").read()
def table(name):
    body = re.search(name + r" := \[(.*?)\]\n", src).group(1)
    return [tuple(map(float, m)) for m in re.findall(r"Vector2\(([\d.]+),\s*([\d.]+)\)", body)]
sheet = Image.open("assets/animation/hero_motion.png").convert("RGBA")
cols = sheet.size[0] // 256
failures = []
for name, start in [("IDLE_GRIPS", 0), ("RUN_GRIPS", 6)]:
    grips = table(name)
    if len(grips) != 6: failures.append(f"{name}: {len(grips)} points, expected 6")
    for k, (x, y) in enumerate(grips):
        r, c = divmod(start + k, cols)
        cell = sheet.crop((c * 256, r * 256, (c + 1) * 256, (r + 1) * 256))
        solid = sum(1 for dx in range(-3, 4) for dy in range(-3, 4) if cell.getpixel((int(x) + dx, int(y) + dy))[3] > 200)
        if solid < 40: failures.append(f"{name}[{k}] at ({x:.0f},{y:.0f}) is not on the hand ({solid}/49 opaque)")
print("SWORD_GRIP:", "PASS" if not failures else "FAIL", *failures, sep="\n  ")
sys.exit(1 if failures else 0)
