"""Original periodic16s synthesized room cues; no game files/links are changed."""
from pathlib import Path
import numpy as np, wave, json
ROOT=Path(__file__).resolve().parents[1];SR=44100;D=16;N=SR*D;t=np.arange(N)/SR
# Célula inicial de referência, observada por volta de 0,5; 1,5; 2,5; 3,5 s de ost_exploration:
# F4,A4,F5,D4. Transcrição espectral parcial, não a partitura completa.
MOTIF=[349.228,440.0,698.456,293.665]
def osc(hz,phase=0):return np.sin(2*np.pi*(round(hz*D)/D)*t+phase)
def note(hz,start,length,phase=0):
    age=(t-start)%D;e=np.where(age<length,np.sin(np.pi*np.minimum(age/length,1))**2,0)
    return e*(osc(hz,phase)+.17*osc(2*hz,phase))
def choir(root):
    voice=np.zeros(N)
    for h in range(1,13):
        resonance=.08+.7*np.exp(-((root*h-480)/180)**2)+.2*np.exp(-((root*h-980)/260)**2)
        voice+=osc(root*h,.03*h)*resonance/h
    return voice*(.7+.2*np.sin(2*np.pi*t/D))
def pad(root,phase=0):
    return (osc(root,phase)+.22*osc(2*root,phase)+.08*osc(3*root,phase))*(.75+.15*np.sin(2*np.pi*t/D))
def bell(hz,start):
    age=(t-start)%D;e=(1-np.exp(-age/.012))*np.exp(-age/2)*np.minimum((D-age)/.4,1)
    return e*(osc(hz)+.32*osc(hz*2.76)+.12*osc(hz*4.11))
def wind(seed):
    rng=np.random.default_rng(seed);f=np.fft.rfftfreq(N,1/SR)
    spectrum=(rng.normal(size=len(f))+1j*rng.normal(size=len(f)))*np.exp(-f/600)*f/(f+70)
    spectrum[0]=0
    x=np.fft.irfft(spectrum,n=N);return x/max(abs(x))
results=[]
for index,name in enumerate(['ost_nave','ost_terraco','ost_patio']):
    melody=sum(note(f/(2 if index==2 else 1),i*4,6,.1*index)*.12 for i,f in enumerate(MOTIF))
    if index==0:
        # Órgão esparso e coro harmônico semelhante a vogais, respiração lenta.
        base=.32*pad(73.416)+.17*choir(110)+.04*pad(146.832,.12)
        left=base+melody+.03*wind(201);right=.98*base+melody*.97+.03*wind(202)
        peak=.20
    elif index==1:
        base=.28*pad(55)+melody*.65
        left=base+.14*wind(203)+.12*bell(146.832,2)
        right=base*.99+.14*wind(204)+.10*bell(146.832,10)
        peak=.40
    else:
        base=.40*pad(36.708)+.11*pad(38.89,.12)+.13*pad(55,.08)
        left=base+melody*.65;right=base*.97+melody*.7+.02*osc(73.437,.2)
        peak=.32
    x=np.stack([left,right],axis=1);x-=x.mean(axis=0);x*=peak/max(abs(x).ravel())
    pcm=np.round(x*32767).astype('<i2');x=pcm.astype(float)/32768
    with wave.open(str(ROOT/'assets/audio'/f'{name}.wav'),'wb') as w:
        w.setnchannels(2);w.setsampwidth(2);w.setframerate(SR);w.writeframes(pcm.tobytes())
    jump=float(max(abs(x[0]-x[-1])));db=float(20*np.log10(max(abs(x).ravel())))
    assert jump<.02 and db< -1,(name,jump,db)
    f=np.fft.rfftfreq(N,1/SR);power=abs(np.fft.rfft(x.mean(axis=1)*np.hanning(N)))**2
    bands=[float(power[(f>=a)&(f<b)].sum()/power.sum()*100) for a,b in [(0,200),(200,1000),(1000,4000),(4000,22051)]]
    results.append({'file':name+'.wav','seconds':D,'peak_dbfs':db,'loop_jump':jump,'rms':float(np.sqrt(np.mean(x*x))),'bands_percent':bands})
(ROOT/'docs/trilhas-secretas-medidas.json').write_text(json.dumps(results,indent=2))
text='# Trilhas das salas secretas\n\nTrês composições sintetizadas originais, estéreo44100Hz, PCM16bits,16s. Sem vozes gravadas. Nave: órgão e coro harmônico muito suaves; Terraço: vento periódico, sinos distantes e sustentação grave; Pátio: bordões e dissonância contida, sem percussão. Não estão ligadas ao jogo.\n\nMotivo comum usado: F4–A4–F5–D4, observado por picos espectrais na sequência inicial de ost_exploration.wav; transcrição parcial, não identificação integral da melodia. No Pátio aparece uma oitava abaixo. Uma nota a cada4s, com sobreposição; cada sala usa timbres e densidades próprios. Audição crítica pelo autor ainda necessária para confirmar a identidade percebida do motivo.\n\nAs frequências são quantizadas em múltiplos de1/16Hz e os envelopes se estendem circularmente pelo loop, inclusive o vento. Não se usa silêncio nas pontas para ocultar a emenda.\n\n| Arquivo | Pico dBFS | Salto na emenda | RMS | Energia<200 /200–1000 /1–4k />4k % |\n|---|---:|---:|---:|---|\n'
for r in results:text+=f"| {r['file']} | {r['peak_dbfs']:.2f} | {r['loop_jump']:.6f} | {r['rms']:.4f} | "+' / '.join(f'{v:.2f}' for v in r['bands_percent'])+' |\n'
text+='\nConferência feita no PCM exportado: formatos, duração, pico abaixo de−1dBFS, salto entre último/primeiro quadro abaixo de0,02 nos dois canais e energia por bandas via FFT/Hann. Isso não comprova mixagem adequada, ausência de todo artefato audível ou efeito emocional. Conferir o loop repetido em fones e caixas antes da integração.\n\nRegerar: `python3 tools/make_secret_music.py` (numpy). Dados em trilhas-secretas-medidas.json.\n'
(ROOT/'docs/trilhas-secretas.md').write_text(text)
print('SECRET_MUSIC:',results)
