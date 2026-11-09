"""Check exported PCM, including loop value and slope continuity; no listening claims."""
from pathlib import Path
import sys, json, wave, hashlib
import numpy as np
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/'tools'))
from make_audio_v20 import EVENTS,FAMILIES,ROOMS,SR
spec={name:(d,1,False) for name,d in EVENTS.items()}
for family,(count,d) in FAMILIES.items():
    spec.update({f'{family}_{i:02}':(d,1,False) for i in range(1,count+1)})
spec.update({'amb_'+room:(30,2,True) for room in ROOMS})
rows=[]; errors=[]
for name,(duration,channels,loop) in spec.items():
    p=ROOT/'assets/audio'/f'{name}.wav'
    try:
        with wave.open(str(p),'rb') as w:
            assert (w.getframerate(),w.getsampwidth(),w.getnchannels(),w.getcomptype())==(SR,2,channels,'NONE'),'format'
            pcm=np.frombuffer(w.readframes(w.getnframes()),dtype='<i2').reshape(-1,channels)
        x=pcm.astype(float)/32768; peak=np.max(abs(x)); rms=np.sqrt(np.mean(x*x))
        peak_db=20*np.log10(max(peak,1e-12)); rms_db=20*np.log10(max(rms,1e-12))
        onset=np.flatnonzero(np.max(abs(x),axis=1)>peak*.01)[0]/SR*1000
        assert len(x)==round(duration*SR),'duration'
        assert peak_db < -1 and np.max(abs(pcm.astype(int)))<32767,'peak/clipping'
        row=dict(file=p.name,seconds=len(x)/SR,channels=channels,peak_dbfs=round(peak_db,4),rms_dbfs=round(rms_db,4),onset_ms=round(onset,4),sha256=hashlib.sha256(p.read_bytes()).hexdigest())
        if loop:
            assert -30<=rms_db<=-26,'loop RMS'
            seam=x[0]-x[-1]; differences=np.diff(x,axis=0)
            limit=np.quantile(abs(differences),.999,axis=0)
            curvature=np.diff(x,n=2,axis=0)
            seam_curvature=np.maximum(abs((x[1]-x[0])-seam),abs(seam-(x[-1]-x[-2])))
            assert np.all(abs(seam)<=limit+2/32768),'seam discontinuity'
            assert np.all(seam_curvature<=np.quantile(abs(curvature),.999,axis=0)+4/32768),'seam slope'
            assert np.max(abs(x.mean(axis=0)))<.0001,'DC'
            assert np.std(x[:,0]-x[:,1])>.001,'identical stereo channels'
            f=np.fft.rfftfreq(len(x),1/SR); power=abs(np.fft.rfft(x[:,0]))**2
            bands=[float(power[(f>=a)&(f<b)].sum()/power.sum()) for a,b in [(40,200),(200,1000),(1000,4000),(4000,16000)]]
            assert sum(v>.01 for v in bands)>=3,'narrow texture'
            row.update(seam_max=float(max(abs(seam))),seam_limit_min=float(min(limit)),bands_fraction=bands)
        else:
            assert onset<50,'late onset at -40 dB relative to peak'
            assert np.max(abs(x[[0,-1]]))<=1/32768,'nonzero endpoints'
        rows.append(row)
    except Exception as exc: errors.append(f'{name}: {exc}')
for family,(count,_) in FAMILIES.items():
    hashes=[r['sha256'] for r in rows if r['file'] in [f'{family}_{i:02}.wav' for i in range(1,count+1)]]
    if len(set(hashes))!=count: errors.append(f'{family}: duplicate or missing variations')
report={'files':len(rows),'errors':errors,'method':'Sample peaks; onset at 1% of file peak; seam first/second differences vs internal 99.9 percentile per channel. Does not certify perceptual seamlessness, true peak, or game mix.','assets':rows}
(ROOT/'docs/audio-v20-medidas.json').write_text(json.dumps(report,indent=2)+'\n')
print(json.dumps({'files':len(rows),'errors':errors},indent=2))
sys.exit(bool(errors))
