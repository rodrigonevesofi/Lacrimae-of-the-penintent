"""Technical export: resizing, atlas packing and portrait slicing; no painted pixels."""
from PIL import Image
from pathlib import Path
import json
ROOT=Path(__file__).resolve().parents[1]
SOURCE=ROOT.parent/'generated_images'
FILES={'giant':'exec-02515c6f-7c95-43db-930b-392b42270232.png','face':'exec-bdb7ecfd-9da8-4531-991d-87e66f6e0479.png','fx':'exec-da313e4e-03e1-4d2e-b99b-f321d5460a91.png','coffin':'exec-a1c3aff9-0c18-446f-8a0a-430aae4ec907.png','portraits':'exec-82142ba6-84e1-4a7b-b23b-b3571aabdc93.png','frame':'exec-502897fc-2c1c-486b-ad1c-b647e51b7d21.png'}
def load(key):return Image.open(SOURCE/FILES[key]).convert('RGBA')
def save(im,name):
 p=ROOT/name;p.parent.mkdir(parents=True,exist_ok=True);im.save(p)

def main():
 im=load('giant').resize((2048,2048),Image.Resampling.LANCZOS)
 packed=Image.new('RGBA',im.size);offsets=[]
 for i in range(16):
  x=i%4*512;y=i//4*512;f=im.crop((x,y,x+512,y+512))
  box=f.getchannel('A').point(lambda a:255 if a>40 else 0).getbbox()
  dy=501-box[3]
  tile=Image.new('RGBA',(512,512));tile.alpha_composite(f,(0,dy));packed.alpha_composite(tile,(x,y));offsets.append(dy)
 save(packed,'assets/animation/guardiao_colosso.png')
 save(load('face').resize((1920,1080),Image.Resampling.LANCZOS),'assets/boss/guardiao_rosto.png')
 for key,name in [('fx','efeitos_golpe'),('coffin','carregador')]:save(load(key).resize((1536,1024),Image.Resampling.LANCZOS),f'assets/animation/{name}.png')
 im=load('portraits');w,h=im.size
 for i in range(6):save(im.crop((round(i%3*w/3),round(i//3*h/2),round((i%3+1)*w/3),round((i//3+1)*h/2))).resize((512,512),Image.Resampling.NEAREST),f'assets/close/close_{i+1:02}.png')
 save(load('frame').crop((0,130,2172,562)).resize((1280,160),Image.Resampling.LANCZOS),'assets/ui/moldura_lore.png')
 (ROOT/'docs/v21-exportacao.json').write_text(json.dumps({'sources':FILES,'source_sizes':{k:load(k).size for k in FILES},'giant_vertical_packing_offsets':offsets,'giant_alpha40_bottom_pixel':500,'frame_crop':[0,130,2172,562],'method':'Technical resizing and cell registration; native images preserved outside repository.'},indent=2)+'\n')
if __name__=='__main__':main()
