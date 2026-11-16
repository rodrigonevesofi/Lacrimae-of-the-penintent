#!/usr/bin/env python3
"""Confere os sons do Argon integrados na v40 contra o relatório docs/sons-argon-v40.json:
arquivo presente e idêntico ao registrado, formato do jogo, sem ceifamento, volume no alvo e
nenhuma música repetida em assets/audio/. Não substitui a escuta."""
import glob, hashlib, itertools, json, os, sys, wave
import numpy as np
RAIZ = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..")
rel = json.load(open(os.path.join(RAIZ, "docs", "sons-argon-v40.json"), encoding="utf-8"))
total = falhas = 0
def confere(ok, texto):
    global total, falhas
    total += 1
    if not ok:
        falhas += 1
        print("FALHA:", texto)
def ler(p):
    w = wave.open(p); x = np.frombuffer(w.readframes(w.getnframes()), "<i2").astype(float).reshape(-1, w.getnchannels()) / 32768
    return w.getframerate(), w.getsampwidth(), x
for nome, info in rel["aceitos"].items():
    p = os.path.join(RAIZ, "assets", "audio", nome + ".wav")
    confere(os.path.exists(p), nome + ": presente")
    if not os.path.exists(p): continue
    confere(hashlib.sha256(open(p, "rb").read()).hexdigest() == info["sha256"], nome + ": é o arquivo registrado")
    sr, sw, x = ler(p)
    confere(sr == 44100 and sw == 2, nome + ": 44,1 kHz e 16 bits")
    confere(np.abs(x).max() <= 10 ** (-1.2 / 20) + 1e-3, nome + ": pico até -1,2 dB")
    volume = 20 * np.log10(np.sqrt((x * x).mean()))
    confere(abs(volume - info["volume_final_db"]) < 0.2, nome + ": volume registrado")
for nome in rel["recusados"]:
    if nome.startswith("ost_") and nome != "ost_vale":
        # as músicas recusadas não podem ter substituído as antigas: as antigas têm 16 s
        antiga = wave.open(os.path.join(RAIZ, "assets", "audio", nome + ".wav"))
        confere(abs(antiga.getnframes() / antiga.getframerate() - 16.0) < 0.01, nome + ": a música anterior foi mantida")
confere(not os.path.exists(os.path.join(RAIZ, "assets", "audio", "ost_vale.wav")), "ost_vale não integrada")
musicas = {os.path.basename(p)[:-4]: ler(p)[2].mean(1) for p in glob.glob(os.path.join(RAIZ, "assets", "audio", "ost_*.wav"))}
for a, b in itertools.combinations(sorted(musicas), 2):
    n = min(len(musicas[a]), len(musicas[b]))
    s = abs(float(np.dot(musicas[a][:n], musicas[b][:n]) / (np.linalg.norm(musicas[a][:n]) * np.linalg.norm(musicas[b][:n]) + 1e-12)))
    confere(s < 0.995, "%s e %s não são o mesmo arquivo com outro nome (semelhança %.3f)" % (a, b, s))
print("SONS_ARGON: %d checks, %d failures" % (total, falhas))
sys.exit(1 if falhas else 0)
