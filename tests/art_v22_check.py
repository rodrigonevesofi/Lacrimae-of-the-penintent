from pathlib import Path
from PIL import Image,ImageDraw
import hashlib,json
R=Path(__file__).resolve().parents[1];errors=[];rows=[]
for name,cols,cell in [('carregador_exposto',6,256),('guardiao_colosso_ataques',4,512)]:
 p=R/f'assets/animation/{name}.png'
 if not p.exists():errors.append(name+': missing');continue
 im=Image.open(p)
 if im.mode!='RGBA' or im.size!=(cols*cell,4*cell):errors.append(name+': format/size')
 hashes=[];boxes=[];corners=[]
 sheet=Image.new('RGB',(cols*256,4*280),(25,28,32));d=ImageDraw.Draw(sheet)
 for i in range(cols*4):
  x=i%cols*cell;y=i//cols*cell;f=im.crop((x,y,x+cell,y+cell));a=f.getchannel('A')
  box=a.point(lambda v:255 if v>40 else 0).getbbox();boxes.append(box)
  if box is None:errors.append(f'{name}/{i}: empty')
  corners.extend(a.getpixel(pos) for pos in [(0,0),(cell-1,0),(0,cell-1),(cell-1,cell-1)])
  bg=Image.new('RGBA',f.size,(0,0,0,255));bg.alpha_composite(f);hashes.append(hashlib.sha256(bg.tobytes()).hexdigest())
  f=f.resize((256,256),Image.Resampling.LANCZOS);px=i%cols*256;py=i//cols*280;sheet.paste(f,(px,py),f);d.text((px+8,py+260),str(i),fill='white')
 if len(set(hashes))!=cols*4:errors.append(name+': duplicates')
 if max(corners)>8:errors.append(name+': opaque corners')
 sheet.save(R/f'docs/imagens/v22-{name}-contato.png')
 rows.append(dict(file=str(p.relative_to(R)),bounds=boxes,distinct=len(set(hashes)),corner_alpha=max(corners)))
p=R/'assets/detritos_caixao.png'
if p.exists():
 im=Image.open(p)
 if im.mode!='RGBA' or im.size!=(256,128):errors.append('debris: format/size')
 a=im.getchannel('A');b=a.point(lambda v:255 if v>40 else 0).getbbox()
 if not b:errors.append('debris: empty')
 if max(a.getpixel(q) for q in [(0,0),(255,0),(0,127),(255,127)])>8:errors.append('debris: corners')
 bg=Image.new('RGBA',im.size,(25,28,32,255));bg.alpha_composite(im);bg.resize((1024,512)).convert('RGB').save(R/'docs/imagens/v22-detritos-contato.png')
 rows.append(dict(file='assets/detritos_caixao.png',bounds=b))
else:errors.append('debris missing')
report=dict(assets=rows,errors=errors,limits='Dimensions, alpha, nonempty distinct frames only. No proof of pose continuity, gameplay, hitboxes or fluidity.')
(R/'docs/v22-arte-medidas.json').write_text(json.dumps(report,indent=2)+'\n');print(json.dumps({'errors':errors}));raise SystemExit(bool(errors))
