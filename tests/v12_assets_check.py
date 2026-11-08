from pathlib import Path
import wave
import numpy as np
from PIL import Image
ROOT=Path(__file__).resolve().parents[1]
for name in ['nave_silencio','terraco_sinos','patio_portoes']:
    im=Image.open(ROOT/'assets'/f'{name}.png')
    assert im.size==(2172,724)
    assert im.convert('RGBA').getchannel('A').getextrema()==(255,255)
    print('PASS background',name,'opaque2172x724')
for name,duration in [('murmurio_01',3.6),('murmurio_02',3.8),('murmurio_03',4),('corrente_cede',2),('sino_surdo',4)]:
    with wave.open(str(ROOT/'assets/audio'/f'{name}.wav')) as w:
        assert (w.getnchannels(),w.getsampwidth(),w.getframerate())==(1,2,22050)
        samples=np.frombuffer(w.readframes(w.getnframes()),dtype='<i2').astype(float)/32768
    assert abs(len(samples)/22050-duration)<.001
    peak=max(abs(samples));onset=np.flatnonzero(abs(samples)>peak*.001)[0]/22050
    assert 20*np.log10(peak)<-1 and onset<=.05
    print('PASS audio',name,'peak',round(20*np.log10(peak),2),'onset_ms',round(onset*1000,1))
