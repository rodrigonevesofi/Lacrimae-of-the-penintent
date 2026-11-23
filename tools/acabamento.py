import sys,glob,wave,numpy as np
for f in sorted(glob.glob(sys.argv[1]+'/*.wav')):
    w=wave.open(f); n=w.getnframes(); x=np.frombuffer(w.readframes(n),'<i2').astype(float); w.close()
    pk=np.max(abs(x)); on=np.flatnonzero(abs(x)>pk*.01)[0]; on=max(0,on-44)
    y=np.zeros(n); y[:n-on]=x[on:]
    k=88; y[:k]*=np.linspace(0,1,k); y[-k:]*=np.linspace(1,0,k); y[0]=0; y[-1]=0
    o=wave.open(f,'wb'); o.setnchannels(1); o.setsampwidth(2); o.setframerate(44100); o.writeframes(np.round(y).astype('<i2').tobytes()); o.close()
print('ok')
