"""Independent export checks. Does not certify artistic quality or the audio mix."""
from pathlib import Path
import wave, math, json
import numpy as np
from PIL import Image
ROOT=Path(__file__).resolve().parents[1]
DURATIONS={'devorador_rugido':1.2,'devorador_bote':.5,'flagelante_chicote':.4,'flagelante_investida':.6,'bruxa_sussurro':1.5,'bruxa_leque':.5,'asmodeia_aviso':.9,'asmodeia_estilhaco':.4,'duelista_cacete':.35}
report=[]
for name,duration in DURATIONS.items():
    with wave.open(str(ROOT/'assets/audio'/f'{name}.wav')) as wav:
        assert (wav.getnchannels(),wav.getsampwidth(),wav.getframerate(),wav.getcomptype())==(1,2,22050,'NONE'),name
        assert abs(wav.getnframes()/22050-duration)<=1/22050,name
        pcm=np.frombuffer(wav.readframes(wav.getnframes()),dtype='<i2').astype(float)/32768
    peak=float(np.max(np.abs(pcm)));db=20*math.log10(peak)
    onset=float(np.flatnonzero(np.abs(pcm)>=peak*.001)[0]/22050*1000)
    assert db < -1 and onset < 50,name
    assert max(abs(float(pcm[0])),abs(float(pcm[-1]))) < .001,name
    report.append({'file':name+'.wav','peak_dbfs':round(db,3),'onset_ms':round(onset,3)})
im=Image.open(ROOT/'assets/ending/ato1_portoes.png')
assert im.format=='PNG' and im.size==(1920,1080)
assert im.convert('RGBA').getchannel('A').getextrema()==(255,255)
# Apenas quantitativo: faixa escura inferior de legendas, sem certificar contraste de texto arbitrário.
band=np.asarray(im.convert('RGB').crop((0,920,1920,1080)),dtype=float)
luma=band@np.array([.2126,.7152,.0722]);assert luma.mean()<35
result={'audio':report,'ending':{'size':list(im.size),'opaque':True,'caption_band_mean_luma_255':round(float(luma.mean()),2)}}
(ROOT/'docs/v15-assets-result.json').write_text(json.dumps(result,indent=2)+'\n')
print('PASS: 9 WAV formats/durations/peaks/onsets/endpoints; opaque 1920x1080 PNG; dark caption band.')
