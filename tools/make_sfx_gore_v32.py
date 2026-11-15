"""Síntese física/orgânica e validação dos 20 efeitos sonoros de gore e combate (prompts-sons-gore-argon.md).
Formato: WAV PCM 16 bits, 44,1 kHz, mono, pico < -1 dBFS, início < 50 ms, sem zumbido contínuo,
planura espectral >= 0.08 (150-8000 Hz) e sem subida tonal estilo cartoon."""
import os
import sys
import wave
import numpy as np

SR = 44100


def bandnoise(n: int, lo: float, hi: float, rng: np.random.Generator) -> np.ndarray:
    spec = np.fft.rfft(rng.standard_normal(n))
    f = np.fft.rfftfreq(n, 1.0 / SR)
    spec[(f < lo) | (f > hi)] = 0.0
    y = np.fft.irfft(spec, n)
    return y / (np.abs(y).max() + 1e-9)


def env(n: int, attack: float, decay: float, delay: float = 0.0) -> np.ndarray:
    t = np.arange(n) / SR - delay
    act = np.maximum(t, 0.0)
    up = np.where(t >= 0.0, np.minimum(act / max(attack, 1e-5), 1.0), 0.0)
    return up * np.exp(-np.maximum(act - attack, 0.0) / max(decay, 1e-5))


def grains(n: int, count: int, t_min: float, t_max: float, f_lo: float, f_hi: float, dec_min: float, dec_max: float, rng: np.random.Generator) -> np.ndarray:
    out = np.zeros(n)
    for _ in range(count):
        st = float(rng.uniform(t_min, t_max))
        dec = float(rng.uniform(dec_min, dec_max))
        amp = float(rng.uniform(0.25, 1.0))
        lo = float(rng.uniform(f_lo, f_lo * 1.35))
        hi = float(rng.uniform(max(lo + 150.0, f_hi * 0.65), f_hi))
        out += amp * bandnoise(n, lo, hi, rng) * env(n, 0.0012, dec, delay=st)
    return out / (np.abs(out).max() + 1e-9)


def wet_droplets(n: int, count: int, t_min: float, t_max: float, f_lo: float, f_hi: float, rng: np.random.Generator) -> np.ndarray:
    """Textura líquida/visceral usando micro-impulsos ressonantes curtos com leve queda de frequência (sem tom contínuo)."""
    out = np.zeros(n)
    for _ in range(count):
        st = int(rng.uniform(t_min, t_max) * SR)
        if st >= n - 64:
            continue
        dur = min(int(rng.uniform(0.006, 0.022) * SR), n - st)
        tt = np.arange(dur) / SR
        f0 = float(rng.uniform(f_lo, f_hi))
        # Queda rápida para soar como gota/impacto úmido espesso, nunca subida cartoon
        f_inst = f0 * (1.0 - 0.28 * (tt / (dur / SR)))
        ph = 2.0 * np.pi * np.cumsum(f_inst) / SR + rng.uniform(0, 2.0 * np.pi)
        window = np.sin(np.pi * np.arange(dur) / dur) * np.exp(-tt / rng.uniform(0.004, 0.012))
        out[st : st + dur] += rng.uniform(0.25, 1.0) * np.sin(ph) * window
    return out / (np.abs(out).max() + 1e-9)


def modal_hit(n: int, freqs: list, decays: list, amps: list, delay: float, rng: np.random.Generator, drop: float = 0.08) -> np.ndarray:
    out = np.zeros(n)
    idx = int(delay * SR)
    if idx >= n:
        return out
    m = n - idx
    tt = np.arange(m) / SR
    for fr, dec, amp in zip(freqs, decays, amps):
        f_inst = fr * (1.0 - drop * np.minimum(tt / 0.045, 1.0))
        ph = 2.0 * np.pi * np.cumsum(f_inst) / SR + rng.uniform(0, 2.0 * np.pi)
        out[idx:] += amp * np.sin(ph) * np.exp(-tt / dec)
    return out


def cathedral_tail(sig: np.ndarray, rng: np.random.Generator, mix: float = 0.18, rt: float = 0.12) -> np.ndarray:
    n = len(sig)
    ir = bandnoise(n, 160, 3600, rng) * env(n, 0.006, rt)
    rev = np.convolve(sig, ir)[:n]
    rev = rev / (np.abs(rev).max() + 1e-9) * (np.abs(sig).max() + 1e-9)
    return (1.0 - mix) * sig + mix * rev


def finalize(x: np.ndarray, target_db: float = -2.0) -> np.ndarray:
    n = len(x)
    fade = min(int(0.02 * SR), n // 4)
    x[-fade:] *= np.linspace(1.0, 0.0, fade)
    peak = np.abs(x).max() + 1e-9
    return (x / peak) * (10.0 ** (target_db / 20.0))


# --- Geradores dos 11 grupos (20 arquivos) ---

def make_sangue_jato(seed: int) -> np.ndarray:
    """0,4 s: jato de sangue jorrando de ferida profunda, úmido e pressurizado, pulsando uma vez."""
    rng = np.random.default_rng(seed)
    n = int(0.40 * SR)
    # Pulso principal (0.003s) e pulso secundário arterial (0.14s)
    p1 = env(n, 0.005, 0.085, 0.002)
    p2 = 0.72 * env(n, 0.008, 0.095, 0.135)
    pulse_env = p1 + p2
    x = 0.55 * bandnoise(n, 220, 2400, rng) * pulse_env
    x += 0.42 * bandnoise(n, 1400, 6800, rng) * pulse_env
    x += 0.48 * wet_droplets(n, 42, 0.003, 0.34, 320, 2900, rng)
    x += modal_hit(n, [95, 165], [0.045, 0.035], [0.35, 0.22], 0.003, rng, drop=0.22)
    return finalize(cathedral_tail(x, rng, 0.14, 0.08), -2.0)


def make_carne_rasga(seed: int) -> np.ndarray:
    """0,35 s: lâmina rasgando carne e pano, lento, pesado e úmido."""
    rng = np.random.default_rng(seed)
    n = int(0.35 * SR)
    # Fibra de tecido e carne cedendo em múltiplos micro-rasgos densos
    tear = grains(n, 38, 0.002, 0.26, 260, 6400, 0.006, 0.024, rng)
    body = bandnoise(n, 150, 1400, rng) * env(n, 0.006, 0.140, 0.002)
    wet = wet_droplets(n, 28, 0.008, 0.29, 400, 3400, rng)
    steel = modal_hit(n, [1180, 1890, 3120], [0.035, 0.028, 0.020], [0.12, 0.09, 0.07], 0.004, rng, drop=0.12)
    x = 0.52 * tear + 0.42 * body + 0.36 * wet + steel
    return finalize(cathedral_tail(x, rng, 0.15, 0.09), -1.9)


def make_osso_quebra(seed: int) -> np.ndarray:
    """0,3 s: osso partindo sob golpe pesado, estalo seco com cauda úmida."""
    rng = np.random.default_rng(seed)
    n = int(0.30 * SR)
    # Estalo seco inicial (< 4 ms) + segundo estalo de lasca (0.028 s)
    crack1 = bandnoise(n, 900, 7800, rng) * env(n, 0.0015, 0.022, 0.002)
    crack2 = 0.65 * bandnoise(n, 1100, 7400, rng) * env(n, 0.0015, 0.026, float(rng.uniform(0.022, 0.038)))
    thump = modal_hit(n, [110, 240, 1650, 2850, 4300], [0.040, 0.030, 0.018, 0.015, 0.012], [0.50, 0.35, 0.22, 0.18, 0.14], 0.002, rng, drop=0.15)
    # Cauda úmida visceral após a fratura
    wet_tail = 0.40 * wet_droplets(n, 24, 0.025, 0.24, 350, 3100, rng) + 0.32 * bandnoise(n, 200, 2200, rng) * env(n, 0.010, 0.095, 0.020)
    x = 0.65 * crack1 + 0.50 * crack2 + thump + wet_tail
    return finalize(cathedral_tail(x, rng, 0.16, 0.08), -1.8)


def make_respingo_chao(seed: int) -> np.ndarray:
    """0,2 s: gotas grossas de sangue batendo no chão de pedra, pequeno impacto úmido."""
    rng = np.random.default_rng(seed)
    n = int(0.20 * SR)
    splat = bandnoise(n, 350, 6800, rng) * env(n, 0.002, 0.032, 0.002)
    drops = wet_droplets(n, 18, 0.002, 0.15, 420, 3800, rng)
    stone_tap = modal_hit(n, [180, 720, 1950], [0.022, 0.015, 0.010], [0.30, 0.18, 0.10], 0.002, rng, drop=0.18)
    x = 0.55 * splat + 0.50 * drops + stone_tap
    return finalize(cathedral_tail(x, rng, 0.14, 0.06), -2.2)


def make_lamina_sai(seed: int = 201) -> np.ndarray:
    """0,4 s: espada arrancada de um corpo, deslize úmido de aço."""
    rng = np.random.default_rng(seed)
    n = int(0.40 * SR)
    # Arranco inicial + deslize metálico raspando osso/carne (frequências metálicas em leve queda)
    pull = bandnoise(n, 250, 5800, rng) * env(n, 0.004, 0.120, 0.002)
    scrape = grains(n, 26, 0.003, 0.24, 800, 6800, 0.005, 0.020, rng)
    steel_slide = modal_hit(n, [1420, 2280, 3540, 4920], [0.065, 0.055, 0.045, 0.035], [0.16, 0.14, 0.11, 0.08], 0.003, rng, drop=0.14)
    wet_suction = wet_droplets(n, 30, 0.010, 0.32, 300, 2800, rng)
    x = 0.48 * pull + 0.42 * scrape + steel_slide + 0.45 * wet_suction
    return finalize(cathedral_tail(x, rng, 0.18, 0.10), -2.0)


def make_corpo_cai_carne(seed: int = 211) -> np.ndarray:
    """0,7 s: corpo caindo morto na pedra sobre poça de sangue, pesado e úmido."""
    rng = np.random.default_rng(seed)
    n = int(0.70 * SR)
    # Primeiro apoio/joelhos (0.003s) e impacto principal do tronco na poça (0.13s)
    thud1 = modal_hit(n, [84, 145], [0.055, 0.040], [0.45, 0.25], 0.003, rng, drop=0.20)
    thud2 = modal_hit(n, [62, 112], [0.095, 0.065], [0.70, 0.40], 0.125, rng, drop=0.22)
    cloth = bandnoise(n, 140, 2600, rng) * (env(n, 0.004, 0.080, 0.002) + env(n, 0.005, 0.160, 0.120))
    splash = bandnoise(n, 500, 6800, rng) * env(n, 0.004, 0.110, 0.125)
    wet = wet_droplets(n, 45, 0.005, 0.55, 280, 3400, rng)
    x = thud1 + thud2 + 0.45 * cloth + 0.42 * splash + 0.45 * wet
    return finalize(cathedral_tail(x, rng, 0.24, 0.15), -1.8)


def make_corpo_cai_armadura(seed: int = 223) -> np.ndarray:
    """0,9 s: criatura de armadura caindo morta, metal e peso na pedra."""
    rng = np.random.default_rng(seed)
    n = int(0.90 * SR)
    # Queda escalonada de placas e peso bruto sobre laje de pedra
    thud1 = modal_hit(n, [78, 134, 1520, 2380], [0.065, 0.045, 0.040, 0.032], [0.50, 0.30, 0.18, 0.14], 0.003, rng, drop=0.18)
    thud2 = modal_hit(n, [58, 98, 1380, 2120, 3290, 4680], [0.110, 0.075, 0.055, 0.045, 0.038, 0.030], [0.72, 0.42, 0.22, 0.18, 0.14, 0.10], 0.180, rng, drop=0.20)
    # Placas secundárias acomodando no chão (0.38s e 0.54s)
    settle = modal_hit(n, [1680, 2640, 3920], [0.040, 0.032, 0.025], [0.14, 0.11, 0.08], 0.380, rng)
    settle += modal_hit(n, [1490, 2310], [0.035, 0.028], [0.10, 0.07], 0.540, rng)
    scrape = grains(n, 36, 0.003, 0.65, 160, 6400, 0.010, 0.038, rng)
    x = thud1 + thud2 + settle + 0.48 * scrape
    return finalize(cathedral_tail(x, rng, 0.28, 0.18), -1.8)


def make_esquiva_perfeita(seed: int = 233) -> np.ndarray:
    """0,5 s: tempo desacelerando por um instante: sopro abafado grave e batida de coração, sem synth sweep."""
    rng = np.random.default_rng(seed)
    n = int(0.50 * SR)
    # Batida dupla cardíaca profunda + sopro abafado de tecido e ar (zero varredura sintética)
    lub = modal_hit(n, [56, 94], [0.055, 0.040], [0.62, 0.32], 0.003, rng, drop=0.20)
    dub = modal_hit(n, [48, 82], [0.065, 0.045], [0.52, 0.26], 0.165, rng, drop=0.20)
    breath_lo = bandnoise(n, 160, 1250, rng) * env(n, 0.008, 0.160, 0.003)
    breath_hi = bandnoise(n, 900, 5200, rng) * env(n, 0.006, 0.110, 0.002)
    cloth_rustle = grains(n, 16, 0.002, 0.28, 220, 3600, 0.008, 0.025, rng)
    x = lub + dub + 0.45 * breath_lo + 0.32 * breath_hi + 0.30 * cloth_rustle
    return finalize(cathedral_tail(x, rng, 0.20, 0.12), -2.1)


def make_aviso_aparavel(seed: int = 241) -> np.ndarray:
    """0,25 s: brilho metálico curto e claro, luz batendo na lâmina, som físico de aço e ar."""
    rng = np.random.default_rng(seed)
    n = int(0.25 * SR)
    # Transiente metálico cristalino inarmônico + atrito rápido de aço cortando o ar (garante planura >= 0.08)
    glint = modal_hit(n, [1820, 2940, 4480, 6120], [0.042, 0.036, 0.028, 0.022], [0.28, 0.24, 0.18, 0.14], 0.002, rng, drop=0.04)
    steel_air = bandnoise(n, 600, 7600, rng) * env(n, 0.002, 0.055, 0.002)
    guard_click = grains(n, 12, 0.001, 0.09, 400, 6800, 0.004, 0.015, rng)
    x = glint + 0.52 * steel_air + 0.38 * guard_click
    return finalize(cathedral_tail(x, rng, 0.22, 0.09), -2.0)


def make_aviso_perigo(seed: int = 251) -> np.ndarray:
    """0,35 s: sibilo seco e grave de respiração e couro rangendo, aviso de golpe indefensável."""
    rng = np.random.default_rng(seed)
    n = int(0.35 * SR)
    # Sibilo áspero de expiração + estalos graves de couro retesando
    hiss_lo = bandnoise(n, 180, 1600, rng) * env(n, 0.006, 0.130, 0.002)
    hiss_hi = bandnoise(n, 1400, 6400, rng) * env(n, 0.005, 0.105, 0.002)
    leather_creak = grains(n, 28, 0.003, 0.26, 220, 2400, 0.006, 0.022, rng)
    iron_tension = modal_hit(n, [135, 980, 1760], [0.050, 0.030, 0.022], [0.35, 0.14, 0.10], 0.004, rng, drop=0.16)
    x = 0.48 * hiss_lo + 0.40 * hiss_hi + 0.48 * leather_creak + iron_tension
    return finalize(cathedral_tail(x, rng, 0.16, 0.09), -2.0)


def make_execucao_impacto(seed: int = 263) -> np.ndarray:
    """0,9 s: golpe mortal de execução: lâmina cravada, osso partindo, jorro de sangue e expiração pesada com eco de pedra."""
    rng = np.random.default_rng(seed)
    n = int(0.90 * SR)
    # 1. Entrada brutal da lâmina (0.002s)
    blade_in = bandnoise(n, 500, 7400, rng) * env(n, 0.002, 0.055, 0.002)
    heavy_slam = modal_hit(n, [64, 114, 1480, 2420, 3890], [0.100, 0.070, 0.042, 0.035, 0.026], [0.70, 0.45, 0.20, 0.16, 0.12], 0.002, rng, drop=0.20)
    # 2. Osso partindo (0.045s)
    bone_snap = bandnoise(n, 1100, 7800, rng) * env(n, 0.002, 0.030, 0.045)
    bone_snap += modal_hit(n, [185, 1780, 3150], [0.040, 0.022, 0.016], [0.40, 0.22, 0.16], 0.045, rng, drop=0.18)
    # 3. Jorro pressurizado de sangue (0.08s a 0.55s)
    blood_gush = 0.52 * wet_droplets(n, 55, 0.060, 0.62, 300, 3400, rng)
    blood_gush += 0.42 * bandnoise(n, 220, 4800, rng) * env(n, 0.012, 0.210, 0.075)
    # 4. Expiração solene final e cauda de pedra (0.22s a 0.85s)
    exhale = 0.38 * bandnoise(n, 160, 2800, rng) * env(n, 0.025, 0.280, 0.200)
    x = 0.55 * blade_in + heavy_slam + 0.60 * bone_snap + blood_gush + exhale
    return finalize(cathedral_tail(x, rng, 0.30, 0.22), -1.8)


def save_wav(path: str, x: np.ndarray) -> None:
    with wave.open(path, "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(SR)
        w.writeframes((np.clip(x, -1.0, 1.0) * 32767.0).astype(np.int16).tobytes())


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


def build_all(out_dir: str = "assets/audio_gore", doc_path: str = "docs/sons-gore-v32.md") -> int:
    os.makedirs(out_dir, exist_ok=True)
    os.makedirs(os.path.dirname(doc_path), exist_ok=True)

    specs = [
        ("sangue_jato_01.wav", 0.40, lambda: make_sangue_jato(101), "Jorro pressurizado de sangue de ferida profunda pulsando (var. 1)"),
        ("sangue_jato_02.wav", 0.40, lambda: make_sangue_jato(107), "Jorro pressurizado de sangue de ferida profunda pulsando (var. 2)"),
        ("sangue_jato_03.wav", 0.40, lambda: make_sangue_jato(113), "Jorro pressurizado de sangue de ferida profunda pulsando (var. 3)"),
        ("carne_rasga_01.wav", 0.35, lambda: make_carne_rasga(127), "Lâmina rasgando carne e pano grosso, pesado e úmido (var. 1)"),
        ("carne_rasga_02.wav", 0.35, lambda: make_carne_rasga(131), "Lâmina rasgando carne e pano grosso, pesado e úmido (var. 2)"),
        ("carne_rasga_03.wav", 0.35, lambda: make_carne_rasga(137), "Lâmina rasgando carne e pano grosso, pesado e úmido (var. 3)"),
        ("osso_quebra_01.wav", 0.30, lambda: make_osso_quebra(149), "Osso partindo sob golpe pesado, estalo seco com cauda úmida (var. 1)"),
        ("osso_quebra_02.wav", 0.30, lambda: make_osso_quebra(157), "Osso partindo sob golpe pesado, estalo seco com cauda úmida (var. 2)"),
        ("osso_quebra_03.wav", 0.30, lambda: make_osso_quebra(163), "Osso partindo sob golpe pesado, estalo seco com cauda úmida (var. 3)"),
        ("respingo_chao_01.wav", 0.20, lambda: make_respingo_chao(173), "Gotas espessas de sangue batendo na laje de pedra (var. 1)"),
        ("respingo_chao_02.wav", 0.20, lambda: make_respingo_chao(179), "Gotas espessas de sangue batendo na laje de pedra (var. 2)"),
        ("respingo_chao_03.wav", 0.20, lambda: make_respingo_chao(181), "Gotas espessas de sangue batendo na laje de pedra (var. 3)"),
        ("respingo_chao_04.wav", 0.20, lambda: make_respingo_chao(191), "Gotas espessas de sangue batendo na laje de pedra (var. 4)"),
        ("lamina_sai.wav", 0.40, make_lamina_sai, "Espada arrancada do corpo em deslize úmido de aço"),
        ("corpo_cai_carne.wav", 0.70, make_corpo_cai_carne, "Corpo caindo morto na pedra sobre poça de sangue"),
        ("corpo_cai_armadura.wav", 0.90, make_corpo_cai_armadura, "Criatura de armadura desabando morta na pedra"),
        ("esquiva_perfeita.wav", 0.50, make_esquiva_perfeita, "Tempo desacelerando: sopro abafado grave e batimento cardíaco"),
        ("aviso_aparavel.wav", 0.25, make_aviso_aparavel, "Centelha metálica curta de luz batendo na lâmina (aviso de aparo)"),
        ("aviso_perigo.wav", 0.35, make_aviso_perigo, "Sibilo seco de fôlego e couro rangendo (ataque indefensável)"),
        ("execucao_impacto.wav", 0.90, make_execucao_impacto, "Golpe mortal da execução: lâmina cravada, osso partindo, sangue e eco na pedra"),
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
        print(f"[{status}] {fname:24s} | dur={m['duration_s']:.2f}s | pico={m['peak_db']:.2f} dBFS | início={m['onset_ms']:.1f} ms | planura={m['flatness']:.2f} | sobe? {m['rising']}")

    lines = [
        "# Relatório técnico de síntese e validação — Sons de Gore e Combate (v32)",
        "",
        "Todos os 20 arquivos especificados em `prompts-sons-gore-argon.md` foram sintetizados em `tools/make_sfx_gore_v32.py` usando modelagem física/orgânica (micro-impulsos líquidos, rasgo fibroso granular, fratura óssea seca, ressonância modal metálica sem oscilador contínuo e reverberação fria de catedral).",
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
    lines.extend(["", "## Camadas acústicas", ""])
    for fname, _, _, _, desc in rows:
        lines.append(f"- **`{fname}`**: {desc}.")

    with open(doc_path, "w", encoding="utf-8") as f:
        f.write("\n".join(lines) + "\n")

    print("\nSFX_GORE_V32:", "PASS (20/20 arquivos validados)" if not failures else "FAIL: " + "; ".join(failures))
    return 0 if not failures else 1


if __name__ == "__main__":
    sys.exit(build_all())
