"""Validate exported new assets without editing game/manifest files."""
from pathlib import Path
from PIL import Image
import numpy as np, wave, hashlib,json,tempfile,shutil,subprocess,sys
ROOT=Path(__file__).resolve().parents[1]
for name in ['01_corda','02_gesto','03_imovel']:
    im=Image.open(ROOT/'assets/boss'/f'guardiao_{name}.png')
    assert im.size==(1920,1080)
    assert im.convert('RGBA').getchannel('A').getextrema()==(255,255)
    print('PASS boss',name,'opaque1920x1080')
im=Image.open(ROOT/'assets/animation/hero_memorial.png');assert im.size==(1536,1024) and im.mode=='RGBA'
a=im.getchannel('A');assert all(a.getpixel(p)==0 for p in [(0,0),(1535,0),(0,1023),(1535,1023)])
hashes=[]
for i in range(24):
    cell=im.crop((i%6*256,i//6*256,i%6*256+256,i//6*256+256));assert cell.getchannel('A').point(lambda x:255 if x>=64 else 0).getbbox()
    hashes.append(hashlib.sha256(cell.tobytes()).hexdigest())
assert len(set(hashes))==24
# Reutiliza o verificador do repositório em um cenário de teste isolado, pois o novo atlas não deve
# ser inserido no clips.json de produção protegido antes da integração por Claude.
with tempfile.TemporaryDirectory(prefix='memorial-check-',dir='/tmp') as tmp:
    tmp=Path(tmp);(tmp/'tools').mkdir();(tmp/'assets/animation').mkdir(parents=True)
    shutil.copyfile(ROOT/'tools/check_animation_atlases.py',tmp/'tools/check_animation_atlases.py')
    shutil.copyfile(ROOT/'assets/animation/hero_memorial.png',tmp/'assets/animation/hero_memorial.png')
    clips={name:{'sheet':'hero_memorial','start':i*6,'count':6,'fps':8,'loop':i==2} for i,name in enumerate(['kneel','place','hold','rise'])}
    (tmp/'assets/animation/clips.json').write_text(json.dumps({'hero_memorial':clips}))
    result=subprocess.run([sys.executable,str(tmp/'tools/check_animation_atlases.py')],stdout=subprocess.PIPE,text=True,check=True)
    assert json.loads(result.stdout)['errors']==[]
print('PASS hero_memorial:24 distinct poses, clear corners, four groups checked by original atlas checker in temporary fixture')
for name in ['ost_nave','ost_terraco','ost_patio']:
    with wave.open(str(ROOT/'assets/audio'/f'{name}.wav')) as w:
        assert (w.getnchannels(),w.getsampwidth(),w.getframerate(),w.getnframes())==(2,2,44100,705600)
        samples=np.frombuffer(w.readframes(w.getnframes()),'<i2').astype(float).reshape(-1,2)/32768
    peak=20*np.log10(max(abs(samples).ravel()));jump=max(abs(samples[0]-samples[-1]))
    assert peak< -1 and jump<.02
    print('PASS',name,'peak_dbfs',round(peak,2),'loop_jump',round(jump,6))
