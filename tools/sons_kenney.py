#!/usr/bin/env python3
"""Monta os efeitos da v43 a partir dos pacotes Kenney (CC0): camadas, tom mais grave e escuro,
duração exata da tabela, começo e fim em zero, pico em -3 dBFS. Uso: sons_kenney.py <pasta_kenney> <saida> <pasta_antigos>"""
import subprocess, sys, os, tempfile, shutil

K, OUT, ANT = sys.argv[1], sys.argv[2], sys.argv[3]
IMP = os.path.join(K, "kenney-impact-sounds/audio/Audio")
RPG = os.path.join(K, "kenney-rpg-audio/audio/Audio")
os.makedirs(OUT, exist_ok=True)

def i(nome): return os.path.join(IMP, nome + ".ogg")
def r(nome): return os.path.join(RPG, nome + ".ogg")
def a(nome): return os.path.join(ANT, nome + ".wav")

# camada: (arquivo, atraso_ms, ganho_db, fator_de_tom, filtro_extra)
def L(f, d=0, g=0.0, t=1.0, fx=""): return (f, d, g, t, fx)

DUR = {}
SONS = {}
def som(nome, dur, camadas, grave=7000, agudo=40):
    DUR[nome] = dur
    SONS[nome] = (camadas, grave, agudo)

# --- combate
for k in range(3):
    som(f"swing_{k+1:02}", .3, [L(r(f"cloth{k+1}"), 0, 0, 1.15), L(r("knifeSlice" if k != 1 else "knifeSlice2"), 10, -10, 1.3, "highpass=f=1500")], 9000, 150)
    som(f"hit_carne_{k+1:02}", .3, [L(i(f"impactPunch_heavy_00{k}"), 0, 0, .85), L(i(f"impactSoft_heavy_00{k}"), 0, -3, .8), L(r("knifeSlice2" if k else "knifeSlice"), 0, -9, .9)], 6000)
    som(f"hit_metal_{k+1:02}", .3, [L(i(f"impactPlate_medium_00{k}"), 0, 0, .9), L(i(f"impactMetal_light_00{k}"), 0, -6, .85)], 9000)
som("aparo", .5, [L(i("impactMetal_heavy_001"), 0, 0, 1.05), L(i("impactGlass_light_002"), 0, -8, .9), L(r("drawKnife1"), 30, -8, 1.2)], 12000)
som("bloqueio", .35, [L(i("impactPlate_heavy_001"), 0, 0, .8), L(i("impactPunch_medium_001"), 0, -4, .8)], 3500)
som("investida", .45, [L(r("cloth4"), 0, 0, 1.0), L(r("cloth2"), 60, -4, 1.2), L(r("knifeSlice2"), 140, -8, 1.1)], 8000, 120)
som("corte_ascendente", .4, [L(r("cloth3"), 0, 0, 1.0, "areverse"), L(r("knifeSlice"), 180, -6, 1.2)], 9000, 150)
som("lamina_sangue", .8, [L(r("cloth1"), 0, 0, .75), L(r("knifeSlice2"), 40, -4, .7), L(i("impactSoft_medium_002"), 120, -6, .6), L(i("impactBell_heavy_002"), 0, -18, .45)], 5000)
som("esquiva_perfeita", .5, [L(r("cloth4"), 0, 0, .7, "areverse"), L(i("impactSoft_heavy_004"), 300, -8, .5)], 5000, 60)
som("aviso_aparavel", .4, [L(i("impactBell_heavy_000"), 0, 0, 1.6), L(i("impactGlass_light_000"), 0, -6, 1.1)], 12000, 400)
som("aviso_perigo", .5, [L(i("impactBell_heavy_003"), 0, 0, .55), L(i("impactPunch_heavy_003"), 0, -3, .6)], 3000)
# --- gore e execuções
for k in range(3):
    som(f"carne_rasga_{k+1:02}", .4, [L(r(["knifeSlice", "knifeSlice2", "chop"][k]), 0, 0, .7), L(i(f"impactSoft_medium_00{k}"), 40, -3, .7), L(r(f"cloth{k+2}"), 0, -10, .6)], 5000)
    som(f"osso_quebra_{k+1:02}", .3, [L(i(f"impactWood_light_00{k}"), 0, 0, .75), L(i(f"impactPlank_medium_00{k}"), 15, -4, .7), L(i(f"impactPunch_medium_00{k}"), 0, -6, .7)], 6000)
    som(f"sangue_jato_{k+1:02}", .5, [L(r(f"cloth{k+1}"), 0, 0, .6, "lowpass=f=2500"), L(i(f"impactSoft_medium_00{k+2}"), 0, -2, .7), L(i(f"impactSoft_medium_00{k}"), 140, -6, .8), L(r("knifeSlice2"), 0, -10, .5)], 4500)
for k in range(4):
    som(f"respingo_chao_{k+1:02}", .25, [L(i(f"impactSoft_medium_00{k}"), 0, 0, .75), L(i(f"impactSoft_heavy_00{k}"), 0, -8, .9)], 4000)
som("decapitacao", 1.0, [L(r("chop"), 0, 0, .75), L(i("impactPunch_heavy_004"), 0, -2, .7), L(i("impactWood_light_003"), 40, -5, .7), L(r("cloth2"), 160, -4, .6, "lowpass=f=2500"), L(i("impactSoft_medium_004"), 200, -4, .7), L(i("impactSoft_heavy_002"), 520, -4, .7)], 5500)
som("corpo_partido", 1.0, [L(r("knifeSlice2"), 0, 0, .55), L(i("impactSoft_heavy_000"), 380, -2, .65), L(i("impactSoft_heavy_003"), 560, -3, .6), L(i("impactPunch_heavy_001"), 380, -8, .6)], 5000)
som("coracao_arrancado", 1.2, [L(r("knifeSlice"), 0, -2, .55), L(i("impactSoft_medium_003"), 60, 0, .6), L(i("impactPunch_medium_002"), 450, -6, .45, "lowpass=f=300"), L(i("impactPunch_medium_003"), 700, -7, .45, "lowpass=f=300"), L(i("impactSoft_heavy_001"), 1000, -4, .7)], 4500)
som("cranio_esmagado", .8, [L(i("impactMining_002"), 0, 0, .7), L(i("impactWood_heavy_001"), 0, -2, .7), L(i("impactPunch_heavy_002"), 0, -3, .65), L(i("impactSoft_heavy_004"), 90, -5, .7)], 6000)
som("execucao", .7, [L(r("knifeSlice"), 0, 0, .7), L(i("impactPunch_heavy_000"), 60, -2, .7), L(i("impactSoft_heavy_001"), 60, -6, .7)], 5500)
som("execucao_impacto", .9, [L(i("impactPunch_heavy_003"), 0, 0, .6), L(i("impactWood_heavy_002"), 0, -4, .6), L(i("impactBell_heavy_004"), 0, -12, .4)], 4000)
som("lamina_sai", .5, [L(r("drawKnife3"), 0, 0, .7), L(i("impactSoft_medium_004"), 0, -8, .7)], 6000)
som("corpo_cai_carne", .6, [L(i("impactSoft_heavy_002"), 0, 0, .65), L(i("impactPunch_medium_004"), 30, -5, .65)], 3500)
som("corpo_cai_armadura", .6, [L(i("impactPlate_heavy_002"), 0, 0, .75), L(i("impactMetal_medium_003"), 60, -5, .8), L(i("impactSoft_heavy_003"), 0, -6, .7)], 6000)
# --- mundo
som("lagrima_coleta", .3, [L(i("impactGlass_light_003"), 0, 0, .8), L(i("impactSoft_medium_001"), 0, -12, 1.2)], 9000, 300)
som("oferenda", 1.2, [L(i("impactBell_heavy_001"), 0, 0, .6), L(r("handleCoins2"), 80, -10, .8)], 6000)
for k in range(4):
    som(f"step_pedra_{k+1:02}", .15, [L(i(f"footstep_concrete_00{k}"), 0, 0, .9), L(i(f"impactPlate_light_00{k}"), 0, -16, 1.0)], 6000, 60)
som("aterrissagem", .4, [L(i("footstep_concrete_004"), 0, 0, .75), L(i("impactPlate_light_004"), 20, -8, .9), L(i("impactSoft_heavy_004"), 0, -6, .8)], 5000)
# --- passos e pulo (v44): passos de madeira e de osso, e o pulo de armadura
for k in range(3):
    som(f"step_madeira_{k+1:02}", .15, [L(i(f"footstep_wood_00{k}"), 0, 0, .9), L(i(f"impactPlate_light_00{k}"), 0, -18, 1.0)], 6000, 60)
    som(f"step_osso_{k+1:02}", .15, [L(i(f"footstep_concrete_00{k+1}"), 0, 0, .85), L(i(f"impactWood_light_00{k}"), 0, -9, 1.2), L(i(f"impactGlass_light_00{k}"), 10, -22, .7)], 7000, 60)
    som(f"jump_{k+1:02}", .3, [L(i(f"footstep_concrete_00{k+2}"), 0, 0, .75), L(r(f"cloth{k+1}"), 20, -5, .9), L(i(f"impactPlate_light_00{k+1}"), 10, -14, .9)], 6500, 50)
som("jump", .3, [L(i("footstep_concrete_001"), 0, 0, .75), L(r("cloth4"), 20, -5, .9), L(i("impactPlate_light_000"), 10, -14, .9)], 6500, 50)
som("step", .15, [L(i("footstep_concrete_004"), 0, 0, .9), L(i("impactPlate_light_004"), 0, -16, 1.0)], 6000, 60)
# dor e morte: a Kenney não tem vozes; ficam os sons anteriores, no tamanho da tabela.
for k in range(3):
    som(f"dor_{k+1:02}", .4, [L(a(f"dor_{k+1:02}"))], 8000)
    som(f"morte_{k+1:02}", .8, [L(a(f"morte_{k+1:02}"))], 8000)

def montar(nome):
    camadas, grave, agudo = SONS[nome]
    dur = DUR[nome]
    args = ["ffmpeg", "-v", "error", "-y"]
    filtros = []
    for n, (f, d, g, t, fx) in enumerate(camadas):
        if not os.path.exists(f): raise SystemExit(f"falta {f} para {nome}")
        args += ["-i", f]
        cadeia = f"[{n}:a]aformat=sample_rates=44100:channel_layouts=mono"
        if t != 1.0: cadeia += f",asetrate={int(44100*t)},aresample=44100"
        if fx: cadeia += "," + fx
        cadeia += f",volume={g}dB,adelay={d}:all=1[c{n}]"
        filtros.append(cadeia)
    entradas = "".join(f"[c{n}]" for n in range(len(camadas)))
    fade_out = max(0.03, dur * 0.25)
    filtros.append(f"{entradas}amix=inputs={len(camadas)}:normalize=0:duration=longest,"
                   f"silenceremove=start_periods=1:start_threshold=-50dB,"
                   f"highpass=f={agudo},lowpass=f={grave},"
                   f"apad,atrim=end_sample={int(round(dur*44100))},"
                   f"afade=t=in:d=0.002,afade=t=out:st={dur-fade_out:.4f}:d={fade_out:.4f}[s]")
    tmp = os.path.join(tempfile.gettempdir(), nome + "_k.wav")
    subprocess.run(args + ["-filter_complex", ";".join(filtros), "-map", "[s]", "-ac", "1", "-ar", "44100", "-c:a", "pcm_s16le", tmp], check=True)
    # pico em -3 dBFS
    o = subprocess.run(["ffmpeg", "-nostats", "-i", tmp, "-af", "volumedetect", "-f", "null", "-"], capture_output=True, text=True).stderr
    pico = float(o.split("max_volume: ")[1].split(" dB")[0])
    subprocess.run(["ffmpeg", "-v", "error", "-y", "-i", tmp, "-af", f"volume={-3.0 - pico}dB,afade=t=out:st={dur-0.004:.4f}:d=0.004",
                    "-ac", "1", "-ar", "44100", "-c:a", "pcm_s16le", "-fflags", "+bitexact", "-map_metadata", "-1", os.path.join(OUT, nome + ".wav")], check=True)
    os.remove(tmp)

for nome in SONS: montar(nome)
print("montados", len(SONS))
