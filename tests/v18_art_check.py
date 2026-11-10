"""Read-only validation of new art. Runs the unchanged atlas checker in an isolated fixture."""
from pathlib import Path
import tempfile,subprocess,sys,shutil,json,hashlib
import numpy as np
from PIL import Image
ROOT=Path(__file__).resolve().parents[1]
CLIPS={
 'efeitos_combate': [('sparks',0,6,12),('blood',6,6,12),('parry',12,6,12),('dust',18,6,12)],
 'perigos':[('spikes',0,6,10),('falling',6,6,10),('moving',12,6,10),('pillar',18,6,10)],
 'guardiao_grande':[('idle',0,6,8),('walk',6,6,10),('attack',12,6,12),('hurt',18,3,10),('death',21,3,8)]}
def brightness(im):
 a=np.asarray(im.convert('RGBA'),dtype=float)
 y=(a[:,:,:3]@np.array([.2126,.7152,.0722]))*(a[:,:,3]/255)
 return {'mean_over_black':float(y.mean()),'p95':float(np.percentile(y,95)),'bottom160_mean':float(y[-160:].mean())}
def run():
 result={'atlases':{},'images':{},'icons':{}}
 for name in CLIPS:
  im=Image.open(ROOT/'assets/animation'/f'{name}.png')
  assert im.size==(1536,1024) and im.mode=='RGBA',name
  boxes=[];hashes=[]
  for i in range(24):
   frame=im.crop((i%6*256,i//6*256,i%6*256+256,i//6*256+256))
   box=frame.getchannel('A').point(lambda a:255 if a>40 else 0).getbbox();assert box,(name,i)
   boxes.append(box);hashes.append(hashlib.sha256(frame.tobytes()).hexdigest())
  assert len(set(hashes))==24,name
  result['atlases'][name]={'bounds':boxes,'distinct_frames':24,'size':list(im.size)}
  if name=='guardiao_grande':
   result['atlases'][name]['nominal_pivot']=[128,250]
   result['atlases'][name]['suggested_per_frame_y_registration']=[251-b[3] for b in boxes]
 with tempfile.TemporaryDirectory(prefix='lacrimae-atlas-v18-',dir='/tmp') as tmp:
  tmp=Path(tmp);(tmp/'tools').mkdir();(tmp/'assets/animation').mkdir(parents=True)
  shutil.copyfile(ROOT/'tools/check_animation_atlases.py',tmp/'tools/check_animation_atlases.py')
  manifest={n:{c:{'sheet':n,'start':s,'count':k,'fps':fps} for c,s,k,fps in clips} for n,clips in CLIPS.items()}
  (tmp/'assets/animation/clips.json').write_text(json.dumps(manifest))
  for n in CLIPS:(tmp/'assets/animation'/f'{n}.png').symlink_to(ROOT/'assets/animation'/f'{n}.png')
  check=subprocess.run([sys.executable,str(tmp/'tools/check_animation_atlases.py')],capture_output=True,text=True)
  result['original_checker']=json.loads(check.stdout);assert check.returncode==0,check.stdout+check.stderr
 for name,size,limits,opaque in [('assets/abismo_ponte.png',(270,400),(14,22),False),('assets/boss/guardiao_03_imovel_v2.png',(1920,1080),(12,18),True)]:
  im=Image.open(ROOT/name);assert im.size==size,name
  m=brightness(im);assert limits[0]<=m['mean_over_black']<=limits[1],(name,m)
  if opaque:assert im.convert('RGBA').getchannel('A').getextrema()==(255,255)
  else:assert im.mode=='RGBA' and np.min(np.asarray(im)[:25,:,3])==0
  result['images'][name]=m
 result['images']['assets/boss/guardiao_03_imovel.png']=brightness(Image.open(ROOT/'assets/boss/guardiao_03_imovel.png'))
 im=Image.open(ROOT/'assets/ui/reliquias.png');assert im.size==(1536,1024) and im.mode=='RGBA'
 icons=[]
 for i in range(24):
  f=im.crop((i%6*256,i//6*256,i%6*256+256,i//6*256+256))
  b=f.getchannel('A').point(lambda a:255 if a>40 else 0).getbbox()
  assert b and min(b[:2])>=24 and max(b[2:])<=232,(i,b)
  icons.append(b)
 result['icons']={'bounds':icons,'margin_at_alpha40':24,'count':24}
 # Compara a intensidade visível de cada par de silhuetas. Não comprova desenhos idênticos.
 means=[]
 for i in range(24):
  f=im.crop((i%6*256,i//6*256,i%6*256+256,i//6*256+256));means.append(brightness(f)['mean_over_black'])
 assert all(means[i+12]<means[i] for i in range(12)),means
 result['icons']['paired_means']=means
 (ROOT/'docs/v18-arte-medidas.json').write_text(json.dumps(result,ensure_ascii=False,indent=2)+'\n')
 print('PASS v18: 72 distinct animation frames; original checker13clips;24icons with24px margin; image brightness/size/alpha')
if __name__=='__main__':run()
