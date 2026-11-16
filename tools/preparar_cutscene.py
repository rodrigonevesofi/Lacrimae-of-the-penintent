#!/usr/bin/env python3
"""Converte os clipes da cutscene (MP4 do Veo / Flow) para o formato que o Godot toca: Ogg Theora.

Entrada: uma pasta com revelacao_01.mp4 ... revelacao_06.mp4 (qualquer subconjunto; .mov e .webm também valem).
Saída: assets/cutscene/revelacao_0N.ogv, 1280 x 720, 24 quadros por segundo, 8 s, sem som (clipes de 10 s são acelerados para caber).
O som é retirado de propósito: na cena tocam a música da revelação e os sons do jogo.
Se o clipe não for 16:9, é cortado no centro. Precisa de ffmpeg.

Uso: python3 tools/preparar_cutscene.py <pasta>
"""
import glob, os, subprocess, sys

RAIZ = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..")
DESTINO = os.path.join(RAIZ, "assets", "cutscene")


def main():
    origem = sys.argv[1]
    os.makedirs(DESTINO, exist_ok=True)
    feitos = 0
    for n in range(1, 7):
        nome = "revelacao_%02d" % n
        achados = [p for ext in ("mp4", "mov", "webm", "mkv") for p in glob.glob(os.path.join(origem, nome + "." + ext))]
        if not achados:
            print("  falta %s (o jogo mostra o close parado nesse trecho)" % nome)
            continue
        saida = os.path.join(DESTINO, nome + ".ogv")
        # Cada trecho da cena tem 8 s. Clipe mais longo (o Flow também gera 10 s) é acelerado até 1,3x
        # para caber inteiro; além disso, corta-se o fim.
        dur = float(subprocess.run(["ffprobe", "-v", "error", "-show_entries", "format=duration", "-of", "csv=p=0", achados[0]],
            capture_output=True, text=True).stdout.strip() or 8)
        ritmo = min(1.0, max(8.0 / dur, 1 / 1.3))
        subprocess.run(["ffmpeg", "-y", "-loglevel", "error", "-i", achados[0], "-an",
            "-vf", "setpts=%.4f*PTS,scale=1280:720:force_original_aspect_ratio=increase,crop=1280:720,fps=24" % ritmo, "-t", "8",
            "-c:v", "libtheora", "-q:v", "8", saida], check=True)
        feitos += 1
        print("  %s -> %s (%.1f MB)" % (os.path.basename(achados[0]), os.path.relpath(saida, RAIZ), os.path.getsize(saida) / 1e6))
    print("%d clipe(s) convertidos." % feitos)


if __name__ == "__main__":
    main()
