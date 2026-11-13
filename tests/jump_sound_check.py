"""The jump must not sound like a cartoon: above the low thump of the foot (below 150 Hz) it must be noisy
(armour, cloth, stone), not a pure tone, and its dominant pitch must not rise over time."""
import numpy as np, wave, sys
def load(p):
    w = wave.open(p); sr = w.getframerate(); x = np.frombuffer(w.readframes(w.getnframes()), dtype=np.int16).astype(float) / 32768
    if w.getnchannels() == 2: x = x.reshape(-1, 2).mean(axis=1)
    return x, sr
def profile(p):
    x, sr = load(p); N = 1024; flats = []; peaks = []
    for i in range(0, len(x) - N, N // 2):
        s = np.abs(np.fft.rfft(x[i:i + N] * np.hanning(N))); f = np.fft.rfftfreq(N, 1 / sr)
        band = (f >= 150) & (f <= 8000); s = s[band]; f = f[band]
        if np.sqrt(np.mean(x[i:i + N] ** 2)) < 0.02: continue
        flats.append(np.exp(np.mean(np.log(s + 1e-9))) / np.mean(s + 1e-9)); peaks.append(f[s.argmax()])
    rising = len(peaks) > 2 and all(b >= a for a, b in zip(peaks, peaks[1:])) and peaks[-1] > peaks[0] * 1.3
    return float(np.mean(flats)), rising
fails = []
for name in ["jump", "jump_01", "jump_02", "jump_03"]:
    flat, rising = profile(f"assets/audio/{name}.wav")
    if flat < 0.08: fails.append(f"{name}: tonal (flatness {flat:.2f})")
    if rising: fails.append(f"{name}: pitch rises like a cartoon jump")
    print(f"  {name}: planura {flat:.2f}, sobe? {rising}")
print("JUMP_SOUND:", "PASS" if not fails else "FAIL " + "; ".join(fails)); sys.exit(1 if fails else 0)
