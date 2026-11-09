"""Validate v21 art without changing production clips.json. Pillow, numpy, fontTools."""
from pathlib import Path
from PIL import Image,ImageDraw,ImageFont
import numpy as np, hashlib,json
ROOT=Path(__file__).resolve().parents[1]
SHEETS={'guardiao_colosso':(2048,2048,4,4),'efeitos_golpe':(1536,1024,6,4),'carregador':(1536,1024,6,4)}
errors=[];rows=[]
output=ROOT/'docs/imagens';output.mkdir(exist_ok=True)
for name,(w,h,cols,nrows) in SHEETS.items():
 p=ROOT/'assets/animation'/f'{name}.png'
 if not p.exists():errors.append(f'{name}: missing');continue
 im=Image.open(p);cell=w//cols
 if im.mode!='RGBA' or im.size!=(w,h):errors.append(f'{name}: format or size')
 hashes=[];bounds=[];corners=[]
 contact=Image.new('RGB',(cols*256,nrows*284),(27,29,34));d=ImageDraw.Draw(contact)
 for i in range(cols*nrows):
  f=im.crop(((i%cols)*cell,(i//cols)*cell,(i%cols+1)*cell,(i//cols+1)*cell))
  a=f.getchannel('A');box=a.point(lambda v:255 if v>40 else 0).getbbox();bounds.append(box)
  if box is None:errors.append(f'{name}/{i}: empty')
  if name=='guardiao_colosso' and box and box[3]!=501:errors.append(f'{name}/{i}: base not registered at y500')
  corners.append(max(a.getpixel(q) for q in [(0,0),(cell-1,0),(0,cell-1),(cell-1,cell-1)]))
  bg=Image.new('RGBA',f.size,(0,0,0,255));bg.alpha_composite(f)
  hashes.append(hashlib.sha256(bg.convert('RGB').tobytes()).hexdigest())
  view=f.resize((256,256),Image.Resampling.LANCZOS);x=i%cols*256;y=i//cols*284
  contact.paste(view,(x,y),view)
  d.text((x+8,y+261),f'{i:02d}',fill=(228,211,164))
  if name!='efeitos_golpe':d.line((x,y+250,x+255,y+250),fill=(90,75,45))
 if len(set(hashes))!=cols*nrows:errors.append(f'{name}: duplicate frames')
 if max(corners)>8:errors.append(f'{name}: cell corners not transparent')
 rows.append({'file':str(p.relative_to(ROOT)),'size':im.size,'distinct':len(set(hashes)),'bounds_alpha40':bounds,'corners_max':max(corners)})
 contact.save(output/f'v21-{name}-contato.png')
for name,size in [('assets/boss/guardiao_rosto.png',(1920,1080)),('assets/ui/moldura_lore.png',(1280,160))]+[(f'assets/close/close_{i:02}.png',(512,512)) for i in range(1,7)]:
 p=ROOT/name
 if not p.exists():errors.append(name+': missing');continue
 im=Image.open(p)
 if im.size!=size:errors.append(name+': wrong dimensions')
 if name.endswith('moldura_lore.png'):
  if im.mode!='RGBA':errors.append(name+': no alpha')
  elif np.asarray(im)[50:110,160:1120,3].max()>8:errors.append(name+': center text zone not clear')
 rgb=np.asarray(im.convert('RGB'),dtype=float);lum=rgb@np.array([.2126,.7152,.0722])
 rows.append({'file':name,'size':size,'mean_luminance':float(lum.mean())})
fontpath=ROOT/'assets/fonts/UnifrakturMaguntia-Book.ttf'
if fontpath.exists():
 from fontTools.ttLib import TTFont
 glyphs=TTFont(fontpath).getBestCmap();required='Lágrimas Culpa Penitência Órfãos À memória ãõçáéíóúâêôà'
 missing=sorted(set(c for c in required if ord(c) not in glyphs))
 if missing:errors.append('Font missing: '+str(missing))
else:errors.append('Missing font')
report={'files':rows,'errors':errors,'limits':'Format, transparency, distinct frames and glyph coverage only. Bounds include cloth, weapon and effects; not skeleton or foot tracking. Does not certify animation fluency, gameplay, collisions, or readability in motion.'}
(ROOT/'docs/v21-arte-medidas.json').write_text(json.dumps(report,indent=2)+'\n')
print(json.dumps({'errors':errors,'sheets':rows[:3]},indent=2))
raise SystemExit(bool(errors))
