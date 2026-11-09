"""Deterministic original synthesis. Run from any directory; numpy only."""
from pathlib import Path
import wave
import numpy as np
ROOT = Path(__file__).resolve().parents[1]
SR = 44100
EVENTS = dict(morte=.6, morte_grande=1.1, chefe_morte=3., chefe_pancada=.9,
              dor=.3, aterrissagem=.25, coleta=.5, porta=.8, projetil=.5,
              projetil_impacto=.3, espinho=.35, aparo=.45, execucao=.7,
              portao_fecha=1.2, portao_abre=1.4, ui_mover=.08, ui_confirmar=.25)
FAMILIES = {'step_pedra':(4,.15),'step_madeira':(3,.15),'step_agua':(3,.15),
            'step_osso':(3,.15),'swing':(3,.25),'hit_carne':(3,.2),
            'hit_metal':(3,.2),'dor':(3,.3),'morte':(3,.6)}
ROOMS = ['city','ossuary','cistern','cloister','belfry','archive','refuge','nave','terrace','court']

def noise(rng,n,lo=40,hi=7000):
    f=np.fft.rfftfreq(n,1/SR)
    filt=(1-np.exp(-(f/max(lo,1))**4))/(1+(f/hi)**4)
    x=np.fft.irfft(np.fft.rfft(rng.normal(size=n))*filt,n=n)
    return x/(np.std(x)+1e-12)

def envelope(n,attack=.002,release=.025):
    e=np.ones(n); a=min(n//2,max(2,round(attack*SR))); b=min(n//2,max(2,round(release*SR)))
    e[:a]=np.sin(np.linspace(0,np.pi/2,a))**2
    e[-b:]=np.cos(np.linspace(0,np.pi/2,b))**2
    return e

def sound(kind,duration,rng,variant=0):
    n=round(duration*SR); t=np.arange(n)/SR
    pitch=1+rng.uniform(-.09,.09)+variant*.012
    def ring(freq,decay=.12):
        return sum(np.sin(2*np.pi*freq*pitch*k*t)*np.exp(-t/(decay/(1+i*.3)))/(1+i)
                   for i,k in enumerate([1,1.483,2.317,3.81]))
    def thud(freq=80):
        return np.sin(2*np.pi*freq*pitch*t)*np.exp(-t/.055)+.4*noise(rng,n,90,2400)*np.exp(-t/.012)
    if kind in ('dor',):
        phase=2*np.pi*(100*pitch*t-25*t*t)
        x=sum(np.sin(phase*k)/k for k in range(1,12))*(.7+.3*np.sin(2*np.pi*28*t))
        x=(x+.35*noise(rng,n,100,1200))*np.exp(-t/.10)
    elif kind in ('morte','morte_grande','chefe_morte'):
        x=thud(55)+noise(rng,n,80,1800)*np.exp(-t/.17)*.35
        x+=np.roll(ring(230,.25),round(.13*SR))*.3
        if kind=='morte_grande': x+=ring(130,.6)*.7
        if kind=='chefe_morte':
            phase=2*np.pi*(170*t-16*t*t)
            x+=sum(np.sin(phase*k)/k for k in [1,2,3,5])*np.exp(-t/1.0)
            x+=noise(rng,n,250,6000)*np.exp(-t/.3)*.5
    elif kind in ('chefe_pancada','aterrissagem','step_pedra','step_madeira','step_osso','hit_carne','hit_metal','projetil_impacto'):
        x=thud(65 if kind=='chefe_pancada' else 120)
        if kind in ('chefe_pancada','hit_metal','projetil_impacto'): x+=ring(340,.3)*.7
        elif kind=='step_madeira': x+=ring(190,.035)*.7
        elif kind=='step_osso': x+=noise(rng,n,1400,6000)*np.exp(-t/.018)*.8
        elif kind=='hit_carne': x+=noise(rng,n,150,1700)*np.exp(-t/.06)*.7
        else: x+=noise(rng,n,700,6500)*np.exp(-t/.035)*.4
    elif kind in ('porta','portao_fecha','portao_abre'):
        x=noise(rng,n,80,3200)*(.3+.25*np.sin(2*np.pi*12*t)**2)*np.sin(np.pi*t/duration)**.5
        for start in np.arange(.008,duration-.08,.13):
            x+=np.roll(ring(440,.03),round(start*SR))*.18
        x+=thud(90)*.6
        if kind=='portao_fecha': x+=np.roll(thud(50),round((duration-.22)*SR))*1.2
    elif kind in ('aparo','coleta','espinho','ui_mover','ui_confirmar'):
        freq={'aparo':1100,'coleta':1700,'espinho':2300,'ui_mover':700,'ui_confirmar':880}[kind]
        x=ring(freq,duration*.45)+noise(rng,n,1800,9000)*np.exp(-t/.006)*.2
        if kind in ('coleta','ui_confirmar'): x+=np.roll(ring(freq*1.5,.10),round(duration*.22*SR))*.5
    elif kind=='projetil':
        x=np.sin(2*np.pi*(2100*t-1500*t*t))*np.exp(-t/.2)+noise(rng,n,1500,6000)*np.exp(-t/.1)*.25
    elif kind in ('swing','execucao'):
        x=noise(rng,n,250,8000)*(.15+np.sin(np.pi*t/duration)**2)*np.exp(-t/(duration*.7))
        if kind=='execucao': x+=np.roll(thud(75),round(.19*SR))+ring(650,.08)*.2
    elif kind=='step_agua':
        x=noise(rng,n,200,7000)*np.exp(-t/.055)+ring(720,.025)*.2
    else: raise ValueError(kind)
    x=(x-x.mean())*envelope(n)
    peak={'ui_mover':-14,'ui_confirmar':-12,'coleta':-8}.get(kind,-4 if kind.startswith('step') else -2)
    return x*(10**(peak/20)/max(abs(x)))

def ambient(room,seed):
    rng=np.random.default_rng(seed); n=30*SR; t=np.arange(n)/SR
    config={'city':(110,6500,10),'ossuary':(170,5400,16),'cistern':(100,9000,28),
            'cloister':(90,3800,8),'belfry':(160,7000,14),'archive':(220,5700,30),
            'refuge':(100,8500,60),'nave':(45,2800,5),'terrace':(130,8000,12),'court':(140,6500,24)}
    lo,hi,count=config[room]
    common=noise(rng,n,lo,hi)
    stereo=np.column_stack([.7*common+.45*noise(rng,n,lo,hi) for _ in range(2)])
    stereo*= (.65+.18*np.sin(2*np.pi*3*t/30)+.12*np.cos(2*np.pi*7*t/30))[:,None]
    # Ruído filtrado e modulação são periódicos; eventos e ecos dão a volta no limite do ciclo.
    kinds={'city':'step_pedra','ossuary':'step_osso','cistern':'step_agua','cloister':'dor',
           'belfry':'aparo','archive':'step_madeira','refuge':'step_osso','nave':'porta',
           'terrace':'coleta','court':'portao_abre'}
    for _ in range(count):
        d=.15 if room in ('city','ossuary','archive','refuge','cistern') else .65
        event=sound(kinds[room],d,rng)
        if room=='cloister': event=noise(rng,len(event),150,1700)*envelope(len(event),.15,.25)*.16
        start=int(rng.integers(n)); pan=rng.uniform(.15,.85); gain= rng.uniform(.15,.6)
        for delay,g in [(0,1),(.12,.25),(.31,.12)]:
            ids=(np.arange(len(event))+start+round(delay*SR))%n
            stereo[ids]+=event[:,None]*np.array([pan,1-pan])*gain*g
    stereo-=stereo.mean(axis=0)
    stereo*=10**(-28/20)/np.sqrt(np.mean(stereo**2))
    return stereo

def write(name,x):
    path=ROOT/'assets/audio'/f'{name}.wav'
    pcm=np.round(x*32767).astype('<i2')
    assert np.max(abs(x))<10**(-1/20),name
    with wave.open(str(path),'wb') as w:
        w.setparams((1 if x.ndim==1 else 2,2,SR,0,'NONE','not compressed'))
        w.writeframes(pcm.tobytes())

def main():
    rng=np.random.default_rng(200019)
    for name,d in EVENTS.items(): write(name,sound(name,d,rng))
    for family,(count,d) in FAMILIES.items():
        for i in range(1,count+1): write(f'{family}_{i:02}',sound(family,d,rng,i))
    for i,room in enumerate(ROOMS): write('amb_'+room,ambient(room,200100+i))
    print('55 original PCM16 WAV files generated at 44100 Hz')
if __name__=='__main__': main()
