"""Synthesizes assets/audio/knock.wav (a fist on old wood heard through stone). Needs numpy.
The patch carries text only; run this once if assets/audio/knock.wav is missing."""
import numpy as np, wave
from pathlib import Path
sr = 22050
def tone(f, dur, decay, amp=1.0):
    t = np.arange(int(sr * dur)) / sr
    return amp * np.sin(2 * np.pi * f * t) * np.exp(-t / decay)
n = int(sr * 0.9)
sig = np.zeros(n)
sig[:int(sr * 0.6)] += tone(92, 0.6, 0.11, 1.0) + tone(148, 0.6, 0.07, 0.7) + tone(305, 0.6, 0.035, 0.5)
rng = np.random.default_rng(7)
noise = rng.normal(0, 1, int(sr * 0.02))
noise = np.convolve(noise, np.ones(6) / 6, mode="same") * np.exp(-np.arange(len(noise)) / (sr * 0.004))
sig[:len(noise)] += noise * 1.4
for d, a in [(0.045, 0.35), (0.11, 0.18), (0.21, 0.08)]:
    i = int(sr * d)
    sig[i:] += 0.6 * a * sig[:n - i]
sig /= np.max(np.abs(sig))
sig *= 0.8
out = Path(__file__).resolve().parents[1] / "assets/audio/knock.wav"
w = wave.open(str(out), "wb")
w.setnchannels(1); w.setsampwidth(2); w.setframerate(sr)
w.writeframes((sig * 32767).astype("<i2").tobytes()); w.close()
print("wrote", out)
