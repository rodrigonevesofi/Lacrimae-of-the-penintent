"""Original deterministic synthesized textures, no recordings or intelligible speech."""
from pathlib import Path
import numpy as np
import wave, json
ROOT=Path(__file__).resolve().parents[1]; SR=22050
OUT=ROOT/'assets/audio'; OUT.mkdir(exist_ok=True)
def envelope(n,seconds=.4):
    e=np.ones(n);k=min(int(seconds*SR),n//2)
    e[:k]=np.sin(np.linspace(0,np.pi/2,k))**2;e[-k:]=e[:k][::-1]
    return e
def lowpass(x,hz):
    f=np.fft.rfftfreq(len(x),1/SR)
    return np.fft.irfft(np.fft.rfft(x)/(1+(f/hz)**6),n=len(x))
def murmur(seed,duration):
    rng=np.random.default_rng(seed);t=np.arange(int(duration*SR))/SR;y=np.zeros(len(t))
    for voice in range(16):
        base=rng.uniform(78,155);phase=rng.uniform(0,2*np.pi)
        f0=base*(1+.014*np.sin(2*np.pi*rng.uniform(.4,1.5)*t+phase))
        ph=np.cumsum(f0)*2*np.pi/SR
        v=np.zeros(len(t))
        # Registro adulto com ressonâncias amplas de vogais, nunca sequências de fonemas.
        for h in range(1,24):
            freq=base*h
            formant=.35*np.exp(-((freq-450)/180)**2)+.22*np.exp(-((freq-1050)/280)**2)+.09*np.exp(-((freq-1900)/350)**2)
            v+=np.sin(ph*h+phase)*(formant+.1/h)/h**.55
        v*=.45+.25*np.sin(2*np.pi*rng.uniform(.15,.45)*t+phase)**2
        shift=int(rng.uniform(.015,.065)*SR)
        y+=v+.22*np.roll(v,shift)
    breath=lowpass(rng.normal(0,1,len(t)),1000)
    return lowpass(y+.15*breath,1500)*envelope(len(t))
def chain():
    rng=np.random.default_rng(901);n=2*SR;y=np.zeros(n)
    for onset,gain in [(0,.5),(.18,.4),(.36,.42),(.58,.53),(.91,.58),(1.36,.7),(1.78,1.0)]:
        start=int(onset*SR);t=np.arange(n-start)/SR
        hit=np.zeros(len(t))
        for f in [173,281,463,719,1103,1651]:
            hit+=np.sin(2*np.pi*f*t+rng.uniform(0,6.28))*np.exp(-t/(.05+100/f))*.18
        hit+=rng.normal(0,1,len(t))*np.exp(-t/.007)*.7
        y[start:]+=gain*hit
    return lowpass(y,4200)*envelope(n,.003)
def bell():
    t=np.arange(4*SR)/SR;y=np.zeros(len(t))
    for f,a,dec in [(58,1,1.5),(116,.55,1.3),(161,.38,.95),(241,.2,.7),(337,.1,.4)]:
        y+=a*np.sin(2*np.pi*f*t)*np.exp(-t/dec)
    return lowpass(y,850)*envelope(len(t),.004)
report=[]
for name,x in [(f'murmurio_0{i}',murmur(400+i,3.4+.2*i)) for i in range(1,4)]+[('corrente_cede',chain()),('sino_surdo',bell())]:
    x=x-x.mean();x=x/max(abs(x))*.82
    pcm=np.round(x*32767).astype('<i2'); x=pcm.astype(float)/32768
    with wave.open(str(OUT/(name+'.wav')),'wb') as w:
        w.setnchannels(1);w.setsampwidth(2);w.setframerate(SR);w.writeframes(pcm.tobytes())
    peak=20*np.log10(max(abs(x))); onset=np.flatnonzero(abs(x)>max(abs(x))*.001)[0]/SR
    f=np.fft.rfftfreq(len(x),1/SR);power=abs(np.fft.rfft(x*np.hanning(len(x))))**2
    bands=[float(power[(f>=a)&(f<b)].sum()/power.sum()*100) for a,b in [(0,200),(200,1000),(1000,4000),(4000,11026)]]
    assert peak < -1 and onset<=.05,(name,peak,onset)
    report.append({'name':name,'seconds':len(x)/SR,'peak_dbfs':peak,'onset_ms':onset*1000,'centroid_hz':float((f*power).sum()/power.sum()),'bands':bands})
(ROOT/'docs/culpa-audio-medidas.json').write_text(json.dumps(report,indent=2))
text='# Áudio das cenas de culpa\n\nCinco texturas sintetizadas originais, mono22050Hz, PCM16bits. Sem gravações, palavras ou vozes de criança. Os murmúrios usam16fontes harmônicas em registro adulto, ressonâncias de vogal e ruído filtrado; não são uma multidão gravada. Fade de0,4s nas duas pontas dos murmúrios. Corrente com choques sucessivos e estalo final; sino com uma única excitação grave.\n\n| Arquivo | s | Pico dBFS | Início ms | Centroide Hz | 0–200 / 200–1000 / 1–4k / >4k (%) |\n|---|---:|---:|---:|---:|---|\n'
for r in report:text+=f"| {r['name']}.wav | {r['seconds']:.1f} | {r['peak_dbfs']:.2f} | {r['onset_ms']:.1f} | {r['centroid_hz']:.0f} | "+' / '.join(f'{b:.1f}' for b in r['bands'])+' |\n'
text+='\nMedições no PCM exportado: pico inferior a−1dBFS e entrada acima de−60dB relativo ao pico em até50ms. Espectro conferido por FFT com janela Hann e bandas acima; dados completos em culpa-audio-medidas.json. Esses testes não comprovam realismo vocal nem impacto emocional. Falta audição crítica no contexto das cenas, em fones e caixas, pelo autor e pelo responsável pela mixagem. Os sons não foram ligados ao jogo.\n\nRegerar: `python3 tools/make_culpa_audio.py` (numpy). As sementes fixas produzem os mesmos arquivos.\n'
(ROOT/'docs/audio-culpa.md').write_text(text)
print('CULPA_AUDIO:',len(report),'files; peak/onset checks passed')
