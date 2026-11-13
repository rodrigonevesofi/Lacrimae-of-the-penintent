"""Jump of a penitent in plate armour: no tone and no rising pitch (that reads as a cartoon).
Layers: the push-off of the foot on stone (a short low thump that falls in pitch), a scuff of grit, a whoosh of
cloth and cape, a few inharmonic clinks of armour plates, and a faint exhale. Three variations."""
import numpy as np, wave
SR = 44100
def bandnoise(n, lo, hi, rng):
    spec = np.fft.rfft(rng.standard_normal(n)); f = np.fft.rfftfreq(n, 1 / SR)
    spec[(f < lo) | (f > hi)] = 0
    return np.fft.irfft(spec, n)
def env(n, attack, decay):
    t = np.arange(n) / SR
    return np.minimum(t / attack, 1.0) * np.exp(-np.maximum(t - attack, 0) / decay)
def make(seed):
    rng = np.random.default_rng(seed); n = int(0.30 * SR); t = np.arange(n) / SR; out = np.zeros(n)
    # push-off: low thump, pitch falling (heavy body leaving the ground)
    f0 = 92 + rng.uniform(-8, 8); pitch = f0 * (1 - 0.35 * np.minimum(t / 0.08, 1)); phase = 2 * np.pi * np.cumsum(pitch) / SR
    out += 0.32 * np.sin(phase) * env(n, 0.003, 0.045)
    # grit scuff under the boot
    out += 0.35 * bandnoise(n, 120, 900, rng) * env(n, 0.002, 0.035)
    # cloth and cape whoosh, its filter closing as the body rises
    w = bandnoise(n, 350, 3200, rng) * env(n, 0.012, 0.11)
    out += 0.45 * w / (np.abs(w).max() + 1e-9)
    # armour plates: short inharmonic clinks, slightly staggered
    for k, fr in enumerate(rng.uniform([1900, 2900, 4100, 5600], [2300, 3400, 4700, 6300])):
        start = int((0.008 + 0.006 * k + rng.uniform(0, 0.004)) * SR)
        m = n - start; tt = np.arange(m) / SR
        out[start:] += rng.uniform(0.05, 0.11) * np.sin(2 * np.pi * fr * tt + rng.uniform(0, 6)) * np.exp(-tt / rng.uniform(0.018, 0.035))
    # faint exhale of effort
    out += 0.06 * bandnoise(n, 1500, 5500, rng) * env(n, 0.03, 0.09)
    out *= np.minimum(1, (n - np.arange(n)) / (0.02 * SR))  # tail fade, no click
    return out / np.abs(out).max() * 10 ** (-3 / 20)
def save(path, x):
    with wave.open(path, "wb") as w:
        w.setnchannels(1); w.setsampwidth(2); w.setframerate(SR)
        w.writeframes((np.clip(x, -1, 1) * 32767).astype(np.int16).tobytes())
if __name__ == "__main__":
    for i, seed in enumerate([11, 23, 37], start=1):
        x = make(seed); save(f"assets/audio/jump_0{i}.wav", x)
        if i == 1: save("assets/audio/jump.wav", x)
    print("jump.wav e jump_01..03.wav escritos")
