"""Síntese procedural e validação dos 9 efeitos sonoros da v30 (11 arquivos WAV).
Segue o padrão de tools/make_jump_sfx.py e tests/jump_sound_check.py:
WAV PCM 16 bits, 44,1 kHz, mono, pico < -1 dBFS, início < 50 ms, planura espectral >= 0.08
(150–8000 Hz) e sem subida tonal estilo cartoon."""
import os
import sys
import wave
import numpy as np

SR = 44100


def bandnoise(n: int, lo: float, hi: float, rng: np.random.Generator, floor: float = 0.04) -> np.ndarray:
    spec = np.fft.rfft(rng.standard_normal(n))
    f = np.fft.rfftfreq(n, 1.0 / SR)
    mask = (f < lo) | (f > hi)
    spec[mask] *= floor
    spec[f < 30.0] = 0.0
    y = np.fft.irfft(spec, n)
    return y / (np.abs(y).max() + 1e-9)


def env(n: int, attack: float, decay: float, delay: float = 0.0) -> np.ndarray:
    t = np.arange(n) / SR - delay
    active = np.maximum(t, 0.0)
    up = np.where(t >= 0.0, np.minimum(active / max(attack, 1e-5), 1.0), 0.0)
    down = np.exp(-np.maximum(active - attack, 0.0) / max(decay, 1e-5))
    return up * down


def inharmonic_clinks(n: int, freqs: list, starts: list, decays: list, amps: list, rng: np.random.Generator) -> np.ndarray:
    out = np.zeros(n)
    for fr, st, dec, amp in zip(freqs, starts, decays, amps):
        idx = int(st * SR)
        if idx >= n:
            continue
        m = n - idx
        tt = np.arange(m) / SR
        phase = 2.0 * np.pi * fr * tt + rng.uniform(0, 2.0 * np.pi)
        out[idx:] += amp * np.sin(phase) * np.exp(-tt / dec)
    return out


def finalize(x: np.ndarray, target_db: float = -2.2) -> np.ndarray:
    n = len(x)
    fade_len = min(int(0.02 * SR), n // 4)
    tail = np.ones(n)
    tail[-fade_len:] = np.linspace(1.0, 0.0, fade_len)
    x = x * tail
    peak = np.abs(x).max() + 1e-9
    return (x / peak) * (10.0 ** (target_db / 20.0))


def make_lanca_estocada(seed: int) -> np.ndarray:
    """0.3 s: ar cortado por uma haste longa e pesada, um rangido curto de ferro e couro."""
    rng = np.random.default_rng(seed)
    n = int(0.30 * SR)
    t = np.arange(n) / SR
    out = np.zeros(n)
    # Impulso seco inicial de couro e empunhadura (< 10 ms)
    out += 0.40 * bandnoise(n, 180, 2400, rng) * env(n, 0.004, 0.055)
    # Ar cortado pela haste pesada (whoosh grave-médio + textura de ar até 7.5 kHz)
    whoosh_lo = bandnoise(n, 140, 1100, rng) * env(n, 0.012, 0.095, delay=0.004)
    whoosh_hi = bandnoise(n, 900, 7400, rng) * env(n, 0.008, 0.080, delay=0.003)
    out += 0.52 * whoosh_lo + 0.36 * whoosh_hi
    # Rangido curto de ferro e couro (modulação áspera inarmônica decrescente)
    creak_f = rng.uniform(310, 360) * (1.0 - 0.28 * np.minimum(t / 0.14, 1.0))
    creak_ph = 2.0 * np.pi * np.cumsum(creak_f) / SR
    out += 0.18 * np.sin(creak_ph + 1.5 * bandnoise(n, 120, 1800, rng)) * env(n, 0.005, 0.055, delay=0.008)
    # Ressonância metálica curta da ponta e relíquias na haste
    freqs = rng.uniform([1550, 2680, 4250, 5800], [1800, 3050, 4700, 6400])
    out += inharmonic_clinks(n, freqs, [0.006, 0.014, 0.022, 0.030], [0.032, 0.026, 0.022, 0.018], [0.11, 0.09, 0.07, 0.05], rng)
    return finalize(out, -2.0)


def make_empalar(seed: int = 41) -> np.ndarray:
    """0.5 s: ponta entrando em carne, um baque surdo."""
    rng = np.random.default_rng(seed)
    n = int(0.50 * SR)
    t = np.arange(n) / SR
    out = np.zeros(n)
    # Transiente perfurante imediato (ferro rasgando tecido/carne)
    out += 0.48 * bandnoise(n, 800, 7600, rng) * env(n, 0.003, 0.065)
    out += 0.44 * bandnoise(n, 220, 2800, rng) * env(n, 0.008, 0.130, delay=0.010)
    # Baque surdo visceral (impacto grave caindo de 115 Hz para 45 Hz)
    f_thud = 115.0 * np.exp(-t / 0.09) + 45.0
    ph_thud = 2.0 * np.pi * np.cumsum(f_thud) / SR
    out += 0.58 * np.sin(ph_thud) * env(n, 0.004, 0.115, delay=0.012)
    # Segundo assentamento úmido/orgânico da haste travando no corpo
    out += 0.36 * bandnoise(n, 200, 6400, rng) * env(n, 0.010, 0.150, delay=0.080)
    out += inharmonic_clinks(n, [1280, 2140, 3890], [0.008, 0.045, 0.085], [0.038, 0.042, 0.030], [0.10, 0.08, 0.06], rng)
    return finalize(out, -1.8)


def make_golpe_carregado_carga(seed: int = 53) -> np.ndarray:
    """0.9 s: tensão crescendo, metal sob esforço, um zumbido grave que engrossa (sem subir tom)."""
    rng = np.random.default_rng(seed)
    n = int(0.90 * SR)
    t = np.arange(n) / SR
    out = np.zeros(n)
    # Ataque imediato de empunhadura firme (< 15 ms) + envelope que engrossa
    swell = np.minimum(t / 0.010, 1.0) * (0.40 + 0.60 * np.sin(0.5 * np.pi * np.minimum(t / 0.82, 1.0)))
    # Zumbido grave sob esforço (78 Hz -> 58 Hz)
    f_drone = 78.0 - 20.0 * (t / 0.90)
    ph = 2.0 * np.pi * np.cumsum(f_drone) / SR
    drone = 0.42 * np.sin(ph) + 0.22 * np.tanh(2.4 * np.sin(ph))
    out += drone * swell
    # Atrito contínuo de couro, manopla e placas de bronze sob tensão (banda larga 180–7500 Hz)
    strain_lo = bandnoise(n, 160, 1800, rng) * swell
    strain_hi = bandnoise(n, 1200, 7600, rng) * swell
    out += 0.38 * strain_lo + 0.30 * strain_hi
    # Estalos metálicos de tensão distribuídos ao longo da carga (tons decrescentes/inarmônicos)
    starts = [0.005, 0.14, 0.29, 0.46, 0.63, 0.78]
    freqs = [3250, 2920, 2610, 2340, 2080, 1860]
    decays = [0.040] * 6
    amps = [0.11, 0.11, 0.12, 0.12, 0.13, 0.14]
    out += inharmonic_clinks(n, freqs, starts, decays, amps, rng)
    return finalize(out, -2.2)


def make_golpe_carregado_solta(seed: int = 67) -> np.ndarray:
    """0.4 s: soltura violenta, ar deslocado."""
    rng = np.random.default_rng(seed)
    n = int(0.40 * SR)
    t = np.arange(n) / SR
    out = np.zeros(n)
    # Estalo inicial de liberação da lâmina (< 5 ms)
    out += 0.46 * bandnoise(n, 600, 7800, rng) * env(n, 0.003, 0.065)
    # Deslocamento violento de ar (grave + médio + turbulência de alta frequência)
    f_air = 128.0 * np.exp(-t / 0.10) + 42.0
    ph_air = 2.0 * np.pi * np.cumsum(f_air) / SR
    out += 0.42 * np.sin(ph_air) * env(n, 0.005, 0.105)
    out += 0.55 * bandnoise(n, 120, 1800, rng) * env(n, 0.008, 0.135)
    out += 0.42 * bandnoise(n, 1200, 7600, rng) * env(n, 0.006, 0.110)
    out += inharmonic_clinks(n, [1740, 2890, 4420, 6100], [0.004, 0.012, 0.020, 0.028], [0.032, 0.026, 0.022, 0.018], [0.13, 0.10, 0.08, 0.06], rng)
    return finalize(out, -1.9)


def make_arremate(seed: int = 79) -> np.ndarray:
    """0.45 s: golpe pesado com cauda de eco de pedra."""
    rng = np.random.default_rng(seed)
    n = int(0.45 * SR)
    t = np.arange(n) / SR
    out = np.zeros(n)
    # Impacto pesado imediato (corpo blindado + lâmina)
    f_imp = 126.0 * np.exp(-t / 0.075) + 40.0
    ph_imp = 2.0 * np.pi * np.cumsum(f_imp) / SR
    out += 0.56 * np.sin(ph_imp) * env(n, 0.003, 0.095)
    out += 0.50 * bandnoise(n, 180, 7600, rng) * env(n, 0.003, 0.085)
    out += inharmonic_clinks(n, [1420, 2340, 3680, 5290], [0.003, 0.009, 0.015, 0.024], [0.042, 0.036, 0.028, 0.022], [0.15, 0.12, 0.10, 0.08], rng)
    # Cauda de eco de pedra (reflexões densas em salão de pedra)
    reverb_lo = bandnoise(n, 140, 1600, rng) * env(n, 0.020, 0.165, delay=0.025)
    reverb_hi = bandnoise(n, 1200, 7200, rng) * env(n, 0.018, 0.150, delay=0.030)
    out += 0.40 * reverb_lo + 0.32 * reverb_hi
    return finalize(out, -1.8)


def make_mergulho_impacto(seed: int = 89) -> np.ndarray:
    """0.7 s: armadura caindo do alto no chão de pedra, cascalho."""
    rng = np.random.default_rng(seed)
    n = int(0.70 * SR)
    t = np.arange(n) / SR
    out = np.zeros(n)
    # Pancada sísmica contra laje de pedra
    f_slam = 110.0 * np.exp(-t / 0.09) + 36.0
    ph_slam = 2.0 * np.pi * np.cumsum(f_slam) / SR
    out += 0.62 * np.sin(ph_slam) * env(n, 0.003, 0.130)
    out += 0.52 * bandnoise(n, 100, 1400, rng) * env(n, 0.003, 0.115)
    # Placas de armadura batendo umas nas outras após o choque
    clink_f = rng.uniform([1500, 2150, 2890, 3750, 4600, 5400], [1750, 2400, 3200, 4100, 5000, 5900])
    clink_st = [0.005, 0.018, 0.035, 0.058, 0.085, 0.120]
    clink_dec = [0.045, 0.040, 0.038, 0.035, 0.030, 0.028]
    clink_amp = [0.15, 0.14, 0.12, 0.11, 0.09, 0.08]
    out += inharmonic_clinks(n, clink_f, clink_st, clink_dec, clink_amp, rng)
    # Cascalho e fragmentos de pedra espalhando pelo chão
    gravel = bandnoise(n, 1100, 7600, rng)
    bursts = np.zeros(n)
    for st in rng.uniform(0.012, 0.48, size=30):
        bursts += env(n, 0.002, rng.uniform(0.015, 0.040), delay=float(st)) * rng.uniform(0.25, 0.85)
    out += 0.40 * gravel * (bursts / (bursts.max() + 1e-9))
    out += 0.28 * bandnoise(n, 120, 2200, rng) * env(n, 0.020, 0.220, delay=0.025)
    return finalize(out, -1.8)


def make_sangue_compartilhado(seed: int = 101) -> np.ndarray:
    """1.0 s: uma batida de coração grave e um sopro, sem melodia."""
    rng = np.random.default_rng(seed)
    n = int(1.00 * SR)
    t = np.arange(n) / SR
    out = np.zeros(n)
    # Pulso duplo cardíaco grave (LUB em 0.004s, DUB em 0.22s) abaixo de 120 Hz
    f_lub = 66.0 * np.exp(-t / 0.08) + 38.0
    ph_lub = 2.0 * np.pi * np.cumsum(f_lub) / SR
    lub = np.sin(ph_lub) * env(n, 0.005, 0.085, delay=0.003)
    t2 = np.maximum(t - 0.22, 0.0)
    f_dub = 58.0 * np.exp(-t2 / 0.07) + 34.0
    ph_dub = 2.0 * np.pi * np.cumsum(f_dub) / SR
    dub = 0.82 * np.sin(ph_dub) * env(n, 0.006, 0.095, delay=0.220)
    out += 0.56 * (lub + dub)
    # Textura orgânica e sopro solene amplo (160–7600 Hz) sem melodia
    pulse_tex = bandnoise(n, 160, 6800, rng) * (env(n, 0.004, 0.110, delay=0.003) + 0.85 * env(n, 0.006, 0.120, delay=0.220))
    breath_lo = bandnoise(n, 240, 2400, rng) * env(n, 0.020, 0.360, delay=0.012)
    breath_hi = bandnoise(n, 1400, 7600, rng) * env(n, 0.025, 0.340, delay=0.018)
    out += 0.36 * pulse_tex + 0.38 * breath_lo + 0.30 * breath_hi
    return finalize(out, -2.2)


def make_caido(seed: int = 113) -> np.ndarray:
    """0.8 s: corpo de armadura indo ao chão, um gemido abafado sem palavras."""
    rng = np.random.default_rng(seed)
    n = int(0.80 * SR)
    t = np.arange(n) / SR
    out = np.zeros(n)
    # Joelhos cedendo (0.003 s) e tronco batendo na pedra (0.18 s)
    f1 = 96.0 * np.exp(-t / 0.07) + 40.0
    out += 0.48 * np.sin(2.0 * np.pi * np.cumsum(f1) / SR) * env(n, 0.004, 0.075, delay=0.003)
    t_fall = np.maximum(t - 0.17, 0.0)
    f2 = 84.0 * np.exp(-t_fall / 0.09) + 35.0
    out += 0.56 * np.sin(2.0 * np.pi * np.cumsum(f2) / SR) * env(n, 0.005, 0.115, delay=0.170)
    # Atrito de tecido grosso, cascalho, couro e placas de armadura arriando
    impact_env = env(n, 0.004, 0.110, delay=0.003) + env(n, 0.006, 0.220, delay=0.165)
    out += 0.42 * bandnoise(n, 160, 2400, rng) * impact_env
    out += 0.34 * bandnoise(n, 1400, 7600, rng) * impact_env
    out += inharmonic_clinks(
        n,
        [1620, 2540, 3880, 1480, 2290, 4190],
        [0.008, 0.022, 0.040, 0.175, 0.195, 0.225],
        [0.032, 0.028, 0.025, 0.042, 0.038, 0.032],
        [0.12, 0.10, 0.08, 0.14, 0.11, 0.09],
        rng,
    )
    # Gemido grave abafado sob máscara/elmo (frequência fundamental <= 130 Hz em queda + sopro rouco)
    f_groan = 122.0 - 28.0 * np.minimum(np.maximum(t - 0.05, 0.0) / 0.45, 1.0)
    ph_g = 2.0 * np.pi * np.cumsum(f_groan) / SR
    out += 0.28 * np.sin(ph_g) * env(n, 0.025, 0.210, delay=0.055)
    out += 0.30 * bandnoise(n, 220, 6800, rng) * env(n, 0.020, 0.240, delay=0.050)
    return finalize(out, -2.0)


def make_levanta(seed: int = 127) -> np.ndarray:
    """0.8 s: fôlego retomado, armadura rangendo (sem subida tonal)."""
    rng = np.random.default_rng(seed)
    n = int(0.80 * SR)
    out = np.zeros(n)
    # Fôlego retomado imediato (inspiração tensa ruidosa de banda larga)
    gasp_hi = bandnoise(n, 1100, 7600, rng) * env(n, 0.006, 0.160, delay=0.003)
    gasp_lo = bandnoise(n, 200, 1800, rng) * env(n, 0.010, 0.210, delay=0.004)
    out += 0.42 * gasp_hi + 0.42 * gasp_lo
    # Apoio da bota na pedra (0.14 s) e firmeza de pé (0.40 s)
    step_env = env(n, 0.005, 0.120, delay=0.140) + 0.90 * env(n, 0.006, 0.150, delay=0.390)
    out += 0.40 * bandnoise(n, 150, 2200, rng) * step_env
    out += 0.34 * bandnoise(n, 1400, 7600, rng) * step_env
    # Placas de ferro e couro se alinhando (tons inarmônicos decrescentes)
    out += inharmonic_clinks(
        n,
        [2680, 1980, 3420, 2310, 1740, 2860],
        [0.012, 0.145, 0.168, 0.395, 0.425, 0.460],
        [0.032, 0.038, 0.028, 0.036, 0.040, 0.030],
        [0.10, 0.12, 0.09, 0.11, 0.10, 0.08],
        rng,
    )
    return finalize(out, -2.1)


def save_wav(path: str, x: np.ndarray) -> None:
    with wave.open(path, "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(SR)
        pcm = (np.clip(x, -1.0, 1.0) * 32767.0).astype(np.int16)
        w.writeframes(pcm.tobytes())


def inspect_wav(path: str) -> dict:
    with wave.open(path, "rb") as w:
        ch = w.getnchannels()
        sw = w.getsampwidth()
        sr = w.getframerate()
        n = w.getnframes()
        x = np.frombuffer(w.readframes(n), dtype=np.int16).astype(float) / 32768.0
    dur = n / float(sr)
    peak = float(np.abs(x).max())
    peak_db = 20.0 * np.log10(max(peak, 1e-9))
    thresh = peak * 0.05
    idx_onset = int(np.argmax(np.abs(x) >= thresh))
    onset_ms = (idx_onset / float(sr)) * 1000.0
    # Mesma métrica de tests/jump_sound_check.py (150–8000 Hz)
    N = 1024
    flats = []
    peaks = []
    for i in range(0, len(x) - N, N // 2):
        seg = x[i : i + N]
        if np.sqrt(np.mean(seg ** 2)) < 0.02:
            continue
        s = np.abs(np.fft.rfft(seg * np.hanning(N)))
        f = np.fft.rfftfreq(N, 1.0 / sr)
        band = (f >= 150.0) & (f <= 8000.0)
        s = s[band]
        f = f[band]
        flats.append(float(np.exp(np.mean(np.log(s + 1e-9))) / np.mean(s + 1e-9)))
        peaks.append(float(f[s.argmax()]))
    flatness = float(np.mean(flats)) if flats else 0.0
    rising = len(peaks) > 2 and all(b >= a for a, b in zip(peaks, peaks[1:])) and peaks[-1] > peaks[0] * 1.3
    return {
        "channels": ch,
        "sampwidth": sw,
        "sr": sr,
        "duration_s": dur,
        "peak_db": peak_db,
        "onset_ms": onset_ms,
        "flatness": flatness,
        "rising": rising,
    }


def build_all(out_dir: str = "assets/audio", doc_path: str = "docs/sons-v30.md") -> int:
    os.makedirs(out_dir, exist_ok=True)
    os.makedirs(os.path.dirname(doc_path), exist_ok=True)

    specs = [
        ("lanca_estocada_01.wav", 0.30, lambda: make_lanca_estocada(17), "Ar cortado por haste longa e pesada + rangido de ferro e couro (var. 1)"),
        ("lanca_estocada_02.wav", 0.30, lambda: make_lanca_estocada(29), "Ar cortado por haste longa e pesada + rangido de ferro e couro (var. 2)"),
        ("lanca_estocada_03.wav", 0.30, lambda: make_lanca_estocada(43), "Ar cortado por haste longa e pesada + rangido de ferro e couro (var. 3)"),
        ("empalar.wav", 0.50, make_empalar, "Ponta entrando em carne seguida de baque surdo"),
        ("golpe_carregado_carga.wav", 0.90, make_golpe_carregado_carga, "Tensão crescendo, metal sob esforço e zumbido grave que engrossa"),
        ("golpe_carregado_solta.wav", 0.40, make_golpe_carregado_solta, "Soltura violenta e ar deslocado"),
        ("arremate.wav", 0.45, make_arremate, "Golpe pesado com cauda de eco de pedra"),
        ("mergulho_impacto.wav", 0.70, make_mergulho_impacto, "Armadura caindo do alto no chão de pedra e cascalho espalhando"),
        ("sangue_compartilhado.wav", 1.00, make_sangue_compartilhado, "Batida de coração grave e sopro solene sem melodia"),
        ("caido.wav", 0.80, make_caido, "Corpo de armadura indo ao chão e gemido abafado sem palavras"),
        ("levanta.wav", 0.80, make_levanta, "Fôlego retomado e armadura rangendo"),
    ]

    failures = []
    rows = []

    for fname, expected_dur, fn, desc in specs:
        fpath = os.path.join(out_dir, fname)
        sig = fn()
        save_wav(fpath, sig)
        m = inspect_wav(fpath)

        ok_fmt = (m["channels"] == 1 and m["sampwidth"] == 2 and m["sr"] == SR)
        ok_dur = abs(m["duration_s"] - expected_dur) < 0.015
        ok_peak = -6.0 <= m["peak_db"] < -1.0
        ok_onset = m["onset_ms"] < 50.0
        ok_flat = m["flatness"] >= 0.08
        ok_rise = not m["rising"]
        passed = ok_fmt and ok_dur and ok_peak and ok_onset and ok_flat and ok_rise

        if not passed:
            failures.append(f"{fname}: fmt={ok_fmt}, dur={m['duration_s']:.2f}s, peak={m['peak_db']:.2f}dBFS, onset={m['onset_ms']:.1f}ms, flat={m['flatness']:.2f}, rising={m['rising']}")

        rows.append((fname, expected_dur, m, passed, desc))
        status = "PASS" if passed else "FAIL"
        print(f"[{status}] {fname:28s} | dur={m['duration_s']:.2f}s | pico={m['peak_db']:.2f} dBFS | início={m['onset_ms']:.1f} ms | planura={m['flatness']:.2f} | sobe? {m['rising']}")

    lines = [
        "# Relatório técnico de síntese e validação — Sons v30",
        "",
        "Todos os arquivos foram gerados proceduralmente em Python (`tools/make_sfx_v30.py`) com `numpy`, seguindo o padrão de `tools/make_jump_sfx.py`: WAV PCM 16 bits, 44,1 kHz, mono, pico abaixo de −1 dBFS, início imediato (< 50 ms), camadas de ruído filtrado, transientes curtos e impactos inarmônicos sem subida tonal.",
        "",
        "## Medidas validadas",
        "",
        "| Arquivo (`assets/audio/`) | Duração (s) | Pico (dBFS) | Início (ms) | Planura espectral | Subida tonal? | Status |",
        "| :--- | :---: | :---: | :---: | :---: | :---: | :---: |",
    ]
    for fname, _, m, passed, _ in rows:
        lines.append(
            f"| `{fname}` | {m['duration_s']:.2f} | {m['peak_db']:.2f} | {m['onset_ms']:.1f} | {m['flatness']:.2f} | {'Sim' if m['rising'] else 'Não'} | {'PASS' if passed else 'FAIL'} |"
        )
    lines.extend([
        "",
        "## Descrição das camadas acústicas",
        "",
    ])
    for fname, _, _, _, desc in rows:
        lines.append(f"- **`{fname}`**: {desc}.")

    with open(doc_path, "w", encoding="utf-8") as f:
        f.write("\n".join(lines) + "\n")

    print("\nSFX_V30:", "PASS (11/11 arquivos validados)" if not failures else "FAIL: " + "; ".join(failures))
    return 0 if not failures else 1


if __name__ == "__main__":
    sys.exit(build_all())
