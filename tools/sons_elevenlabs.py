import sys,glob,os,subprocess,numpy as np,wave
SRC,OUT=sys.argv[1],sys.argv[2]; os.makedirs(OUT,exist_ok=True)
ALVO={'dor':(.4,3),'morte':(.8,3),'sangue_jato':(.5,3),'respingo_chao':(.25,4)}
def ler(f):
    p=subprocess.run(['ffmpeg','-v','error','-i',f,'-ac','1','-ar','44100','-f','s16le','-'],capture_output=True).stdout
    return np.frombuffer(p,'<i2').astype(float)/32768
for fam,(dur,n) in ALVO.items():
    cands=[]
    for f in sorted(glob.glob(f'{SRC}/{fam}_*.wav')):
        x=ler(f); pk=np.max(abs(x)); on=max(0,np.flatnonzero(abs(x)>pk*.05)[0]-44)
        y=x[on:on+int(dur*44100)]; y=np.pad(y,(0,int(dur*44100)-len(y)))
        rms=np.sqrt(np.mean(y**2)); cands.append((rms,os.path.basename(f),y))
    cands.sort(key=lambda c:-c[0])
    for k,(rms,nome,y) in enumerate(cands[:n]):
        y=y/np.max(abs(y))*10**(-3/20); L=len(y); fo=int(L*.25)
        y[-fo:]*=np.linspace(1,0,fo)**2; y[:88]*=np.linspace(0,1,88); y[0]=y[-1]=0
        o=wave.open(f'{OUT}/{fam}_{k+1:02}.wav','wb'); o.setnchannels(1); o.setsampwidth(2); o.setframerate(44100); o.writeframes(np.round(y*32767).astype('<i2').tobytes()); o.close()
        print(f'{fam}_{k+1:02} <- {nome} rms={20*np.log10(rms):.1f}dB')
