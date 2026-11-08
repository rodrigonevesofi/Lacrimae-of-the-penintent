"""Inspect animation assets without modifying generated art (requires Pillow).
Checks real nonempty distinct frames after alpha compositing and reports boundaries.
"""
from pathlib import Path
import hashlib,json,sys
from PIL import Image,ImageChops
root=Path(__file__).resolve().parents[1]
manifest=json.loads((root/'assets/animation/clips.json').read_text())
if '--bestiary' in sys.argv:
 for name in ['devorador','flagelante','bruxa','asmodeia','duelista']:
  manifest[name]={clip:{'sheet':name+'_executado' if clip=='executed' else name,'start':start,'count':count,'fps':12} for clip,start,count in [('idle',0,6),('walk',6,6),('attack',12,6),('hurt',18,3),('death',21,3),('executed',12,12)]}
report={};errors=[]
for actor, clips in manifest.items():
 for clip,d in clips.items():
  path=root/'assets/animation'/(d['sheet']+'.png')
  if not path.exists():errors.append(str(path)+' missing');continue
  im=Image.open(path).convert('RGBA');w,h=im.size
  if im.getpixel((0,0))[3]>8:errors.append(d['sheet']+': nontransparent background corner')
  hashes=[];boxes=[]
  for index in range(d['start'],d['start']+d['count']):
   col,row=index%6,index//6
   frame=im.crop((round(col*w/6),round(row*h/4),round((col+1)*w/6),round((row+1)*h/4)))
   alpha=frame.getchannel('A');box=alpha.point(lambda a:255 if a>40 else 0).getbbox()
   if box is None:errors.append(actor+'/'+clip+': empty frame '+str(index))
   visible=Image.new('RGB',frame.size);visible.paste(frame,mask=alpha)
   hashes.append(hashlib.sha256(visible.tobytes()).hexdigest());boxes.append(box)
  key=actor+'/'+clip
  if len(set(hashes))<2:errors.append(key+': repeated single image')
  report[key]={'count':d['count'],'distinct':len(set(hashes)),'fps':d['fps'],'bounds':boxes}
print(json.dumps({'clips':report,'errors':errors},ensure_ascii=False,indent=2))
raise SystemExit(bool(errors))
