"""Original deterministic creature textures, no recorded or intelligible speech."""
from pathlib import Path
import numpy as np,wave,json
ROOT=Path(__file__).resolve().parents[1];SR=22050
rng=np.random.default_rng(1501)
def timeline(d):return np.arange(round(d*SR))/SR
def smooth(x,hz):
    f=np.fft.rfftfreq(len(x),1/SR)
    return np.fft.irfft(np.fft.rfft(x)/(1+(f/hz)**6),n=len(x))
def env(n,attack=.004,release=.03):
    e=np.ones(n);a=max(2,round(attack*SR));b=max(2,round(release*SR))
    e[:a]=np.sin(np.linspace(0,np.pi/2,a))**2;e[-b:]=np.cos(np.linspace(0,np.pi/2,b))**2
    return e
def noise(n,hz):return smooth(rng.normal(0,1,n),hz)
def impact(t,low=65):
    return (np.sin(2*np.pi*low*t)+.45*np.sin(2*np.pi*low*1.71*t))*np.exp(-t/.10)+noise(len(t),2200)*np.exp(-t/.008)*.6
def shifted(total,start,sound):
    result=np.zeros(total);i=round(start*SR);length=min(len(sound),total-i);result[i:i+length]=sound[:length];return result
sounds={}
t=timeline(1.2);phase=2*np.pi*np.cumsum(82-24*t/1.2)/SR
voice=sum(np.sin(phase*h)/h**1.1 for h in range(1,12))
breath=noise(len(t),650);grow=np.clip((t-.16)/.4,0,1)
sounds['devorador_rugido']=(.6*breath*(1-grow)+smooth(np.tanh(voice*2),1700)*grow*(.7+.3*np.sin(2*np.pi*23*t)))*env(len(t),.008,.09)
t=timeline(.5);sounds['devorador_bote']=impact(t)*env(len(t),.002,.04)
t=timeline(.4);swish=noise(len(t),4500)-noise(len(t),600)
crack=shifted(len(t),.21,impact(timeline(.19),440))
sounds['flagelante_chicote']=(swish*(.05+.6*np.sin(np.pi*t/.4)**4)+crack*1.2)*env(len(t),.005,.02)
t=timeline(.6);sounds['flagelante_investida']=sum(shifted(len(t),s,impact(timeline(.25),88)*g) for s,g in [(0,.8),(.18,1),(.38,.9),(.53,.65)])*env(len(t),.002,.015)
t=timeline(1.5);whisper=np.zeros(len(t))
for i in range(7):
    hiss=noise(len(t),3300)-noise(len(t),340)
    whisper+=hiss*(.3+.3*np.sin(2*np.pi*(2.1+i*.17)*t+i)**2)
whisper+=.08*np.sin(2*np.pi*94*t)*(1+.4*np.sin(2*np.pi*13*t))
sounds['bruxa_sussurro']=whisper*env(len(t),.01,.08)
t=timeline(.5);fan=np.zeros(len(t))
for i,start in enumerate([0,.15,.30]):
    age=timeline(.2);phase=2*np.pi*(1600*age-1000*age**2)
    fan+=shifted(len(t),start,(np.sin(phase)+.15*noise(len(age),4000))*env(len(age),.008,.05))
sounds['bruxa_leque']=fan*env(len(t),.003,.01)
t=timeline(.9);phase=2*np.pi*(850*t+700*t*t)
sounds['asmodeia_aviso']=(np.sin(phase)+.18*np.sin(phase*1.997)+.09*noise(len(t),4200))*(.13+.87*(t/.9)**1.4)*env(len(t),.008,.05)
t=timeline(.4);glass=np.zeros(len(t))
for start,gain in [(0,1),(.07,.65),(.16,.45),(.27,.25)]:
    a=timeline(.4-start)
    ring=sum(np.sin(2*np.pi*f*a)*np.exp(-a/(.025+50/f)) for f in [1800,2741,4213,5899])
    glass+=shifted(len(t),start,ring*gain+.08*noise(len(a),7000)*np.exp(-a/.006))
sounds['asmodeia_estilhaco']=glass*env(len(t),.001,.02)
t=timeline(.35);wood=sum(a*np.sin(2*np.pi*f*t)*np.exp(-t/dec) for f,a,dec in [(180,1,.07),(390,.5,.045),(780,.22,.025)])
sounds['duelista_cacete']=(wood+.5*noise(len(t),2400)*np.exp(-t/.008))*env(len(t),.001,.025)
rows=[]
for name,x in sounds.items():
    x=(x-x.mean())*env(len(x),.001,.003);x*=.8/max(abs(x));pcm=np.round(x*32767).astype('<i2');x=pcm.astype(float)/32768
    with wave.open(str(ROOT/'assets/audio'/f'{name}.wav'),'wb') as w:
        w.setnchannels(1);w.setsampwidth(2);w.setframerate(SR);w.writeframes(pcm.tobytes())
    peak=float(20*np.log10(max(abs(x))));onset=float(np.flatnonzero(abs(x)>max(abs(x))*.001)[0]/SR*1000)
    f=np.fft.rfftfreq(len(x),1/SR);p=abs(np.fft.rfft(x*np.hanning(len(x))))**2
    bands=[float(p[(f>=a)&(f<b)].sum()/p.sum()*100) for a,b in [(0,200),(200,1000),(1000,4000),(4000,11026)]]
    assert peak< -1 and onset<50,(name,peak,onset)
    rows.append({'file':name+'.wav','seconds':len(x)/SR,'peak_dbfs':peak,'onset_ms':onset,'centroid_hz':float((f*p).sum()/p.sum()),'bands_percent':bands})
(ROOT/'docs/sfx-criaturas-medidas.json').write_text(json.dumps(rows,indent=2))
text='# Sons das criaturas\n\nNove WAVs sintetizados originais, mono22050Hz/PCM16bits. Sem gravações nem frases inteligíveis; o rugido usa registro grave e o sussurro é ruído filtrado com uma camada adulta grave. Não há fonte de voz infantil. Não estão ligados ao jogo.\n\nDevorador: respiração que passa a rugido rouco e impacto grave. Flagelante: fricção de cordas/estalo e passos pesados. Bruxa: sussurro seco em camadas e três silvos distintos. Asmodeia: aviso ascendente e estilhaços de vidro. Duelista: ressonâncias curtas de madeira, sem cauda metálica. Esses são objetivos de desenho, não realismo comprovado.\n\n| Arquivo | s | Pico dBFS | Início ms | Centroide Hz | Energia<200 /200–1000 /1–4k />4k (%) |\n|---|---:|---:|---:|---:|---|\n'
for r in rows:text+=f"| {r['file']} | {r['seconds']:.3f} | {r['peak_dbfs']:.2f} | {r['onset_ms']:.1f} | {r['centroid_hz']:.0f} | "+' / '.join(f'{b:.1f}' for b in r['bands_percent'])+' |\n'
text+='\nConferência no PCM exportado: pico inferior a−1dBFS, entrada detectável abaixo de50ms (limiar−60dB relativo ao pico) e distribuição espectral por FFT/Hann. Dados completos em sfx-criaturas-medidas.json. A duração de0,35s é arredondada ao quadro de amostra mais próximo.\n\nRegerar: `python3 tools/make_creature_sfx.py` (numpy); a semente fixa torna a geração reprodutível. Falta audição crítica em fones/caixas, comparação dos níveis com a mixagem e sincronização com os ataques. Medidas não provam que os sons comuniquem bem o perigo, tenham impacto ou sejam acessíveis a todas as pessoas. O Claude integra.\n'
(ROOT/'docs/sfx-criaturas.md').write_text(text)
print('CREATURE_SFX:9 exported files; peak/onset checks passed')
