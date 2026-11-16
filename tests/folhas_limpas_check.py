#!/usr/bin/env python3
"""Confere que as folhas do Penitente e de Beatriz não têm fragmentos de quadros vizinhos nem pontos soltos.
Sangue (vermelho dominante) não conta. Uso: python3 tests/folhas_limpas_check.py"""
import os, sys
import numpy as np
from PIL import Image
from scipy import ndimage
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "tools"))
import polir_folhas as pf

falhas = 0
total = 0
for grupo, cfg in pf.GRUPOS.items():
    for nome in cfg["igualar"] + cfg["limpar"]:
        a = pf.carregar(nome)
        antes = a.copy()
        apagaria = pf.limpar(a)
        total += 1
        if apagaria > 0:
            falhas += 1
            print("FALHA: %s ainda tem %d pontos de sujeira" % (nome, apagaria))
    ref = np.mean([pf.medidas(pf.carregar(n))[0] for n in cfg["referencia"]])
    for nome in cfg["igualar"]:
        lum = pf.medidas(pf.carregar(nome))[0]
        total += 1
        if abs(lum - ref) > 6:
            falhas += 1
            print("FALHA: %s tem luminosidade %.0f, a referência é %.0f" % (nome, lum, ref))
print("FOLHAS_LIMPAS: %d checks, %d failures" % (total, falhas))
sys.exit(1 if falhas else 0)
