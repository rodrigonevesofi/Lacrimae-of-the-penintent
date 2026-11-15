"""Ambiência do Vale dos Flagelados: 30 s em estéreo, em laço. Vento em rajadas num desfiladeiro, cordas e madeira
rangendo de tempos em tempos e um sino muito distante. Sem melodia e sem tom contínuo."""
import numpy as np, wave
SR = 44100; N = SR * 30
rng = np.random.default_rng(1746)
def band(n, lo, hi, seed):
    r = np.random.default_rng(seed); spec = np.fft.rfft(r.standard_normal(n)); f = np.fft.rfftfreq(n, 1 / SR)
    spec[(f < lo) | (f > hi)] = 0; y = np.fft.irfft(spec, n); return y / (np.abs(y).max() + 1e-9)
t = np.arange(N) / SR
def gusts(seed):
    # rajadas lentas, periódicas em 30 s para o laço fechar sem emenda
    r = np.random.default_rng(seed); g = np.zeros(N)
    for k in range(1, 7): g += r.uniform(0.3, 1.0) * np.sin(2 * np.pi * k * t / 30.0 + r.uniform(0, 6.28))
    g = (g - g.min()) / (g.max() - g.min()); return 0.25 + 0.75 * g
out = np.zeros((N, 2))
for ch in range(2):
    wind = 0.55 * band(N, 90, 520, 10 + ch) * gusts(20 + ch) + 0.30 * band(N, 500, 1800, 30 + ch) * gusts(40 + ch) ** 2 + 0.10 * band(N, 1800, 5200, 50 + ch) * gusts(60 + ch) ** 3
    out[:, ch] = wind
# cordas e madeira rangendo: rajadas curtas de ruído estreito, em lados alternados
for i, at in enumerate([2.4, 6.9, 11.3, 15.2, 19.8, 23.5, 27.1]):
    n = int(0.9 * SR); s = int(at * SR); tt = np.arange(n) / SR
    creak = band(n, 320 + 40 * (i % 3), 780 + 60 * (i % 4), 100 + i) * np.exp(-((tt - 0.4) / 0.22) ** 2) * (0.6 + 0.4 * np.sin(2 * np.pi * 11 * tt))
    pan = 0.25 if i % 2 == 0 else 0.75
    out[s:s + n, 0] += 0.22 * creak * (1 - pan); out[s:s + n, 1] += 0.22 * creak * pan
# sino distante e abafado, uma vez
n = int(4.0 * SR); s = int(13.0 * SR); tt = np.arange(n) / SR
bell = sum(a * np.sin(2 * np.pi * f * tt) * np.exp(-tt / d) for f, a, d in [(196, 1.0, 1.4), (247, 0.5, 1.0), (331, 0.35, 0.8), (452, 0.2, 0.5)])
out[s:s + n, 0] += 0.05 * bell; out[s:s + n, 1] += 0.05 * bell
out = out / np.abs(out).max() * 10 ** (-6 / 20)
with wave.open("assets/audio/amb_vale.wav", "wb") as w:
    w.setnchannels(2); w.setsampwidth(2); w.setframerate(SR); w.writeframes((out * 32767).astype(np.int16).tobytes())
print("amb_vale.wav escrito")
