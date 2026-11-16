"""Chuva e trovão do Terraço dos Sinos, sintetizados (sem amostras de terceiros).
amb_chuva.wav: 12 s em estéreo, em laço sem emenda. Chuva grossa sobre pedra, sem tom contínuo.
trovao_01..03.wav: trovões distantes, graves, com estalo inicial abafado e cauda longa."""
import numpy as np, wave
SR = 44100

def faixa(n, lo, hi, seed):
    """Ruído limitado a uma faixa de frequências; periódico em n, então fecha em laço."""
    r = np.random.default_rng(seed); spec = np.fft.rfft(r.standard_normal(n)); f = np.fft.rfftfreq(n, 1 / SR)
    spec[(f < lo) | (f > hi)] = 0; y = np.fft.irfft(spec, n); return y / (np.abs(y).max() + 1e-9)

def grava(nome, som, pico_db):
    som = som / np.abs(som).max() * 10 ** (pico_db / 20)
    with wave.open("assets/audio/" + nome, "wb") as w:
        w.setnchannels(som.shape[1]); w.setsampwidth(2); w.setframerate(SR); w.writeframes((som * 32767).astype(np.int16).tobytes())
    print(nome, "escrito")

# ---- chuva
N = SR * 12; t = np.arange(N) / SR
chuva = np.zeros((N, 2))
for ch in range(2):
    # o corpo da chuva e um chiado fino; a intensidade oscila devagar, em períodos que dividem 12 s
    onda = 0.8 + 0.2 * np.sin(2 * np.pi * t / 6.0 + ch) * np.sin(2 * np.pi * t / 4.0 + 1.3 * ch)
    chuva[:, ch] = (0.6 * faixa(N, 900, 4200, 11 + ch) + 0.35 * faixa(N, 4200, 9500, 21 + ch) + 0.25 * faixa(N, 250, 900, 31 + ch)) * onda
    # gotas grossas batendo na pedra: estalos curtos espalhados
    r = np.random.default_rng(41 + ch)
    for at in r.uniform(0, 11.9, 520):
        n = int(0.012 * SR); s = int(at * SR); tt = np.arange(n) / SR
        gota = r.standard_normal(n) * np.exp(-tt / 0.0022) * r.uniform(0.15, 0.5)
        fim = min(N, s + n); chuva[s:fim, ch] += gota[:fim - s]
grava("amb_chuva.wav", chuva, -9)

# ---- trovões
for i, (dur, seed, grave) in enumerate([(4.2, 5, 70), (5.0, 9, 55), (3.6, 13, 85)], 1):
    n = int(dur * SR); tt = np.arange(n) / SR
    r = np.random.default_rng(seed)
    # ronco grave com vários rolos que se sucedem
    rolos = sum(r.uniform(0.4, 1.0) * np.exp(-((tt - c) / w) ** 2) for c, w in zip(r.uniform(0.15, dur * 0.6, 5), r.uniform(0.2, 0.6, 5)))
    env = (rolos + 0.25) * np.exp(-tt / (dur * 0.38)) * np.minimum(tt / 0.04, 1.0)
    som = np.zeros((n, 2))
    for ch in range(2):
        som[:, ch] = (faixa(n, 22, grave, seed * 3 + ch) + 0.5 * faixa(n, grave, 240, seed * 5 + ch) + 0.12 * faixa(n, 240, 900, seed * 7 + ch) * np.exp(-tt / 0.5)) * env
    som *= np.minimum((dur - tt) / 0.3, 1.0)[:, None]
    grava("trovao_0%d.wav" % i, som, -3)
