"""Check the new asset contract without editing images or shared manifests."""
from pathlib import Path
from PIL import Image
import hashlib
root=Path(__file__).resolve().parents[1]
ids=['01_maos_na_roda','02_mao_pequena','02_mao_pequena_sem_sol','03_figura_atras','04_portao_fechado']
for name in ids:
    im=Image.open(root/'assets/memory'/f'memoria_{name}.png')
    assert im.size==(1920,1080),(name,im.size)
    assert im.convert('RGBA').getchannel('A').getextrema()==(255,255),name
    print('PASS opaque1920x1080',name)
im=Image.open(root/'assets/animation/fragmento_culpa.png')
assert im.size==(1536,1024) and im.mode=='RGBA'
a=im.getchannel('A')
assert all(a.getpixel(p)==0 for p in [(0,0),(1535,0),(0,1023),(1535,1023)])
assert a.crop((0,768,1536,1024)).getextrema()[1]<=1
hashes=[]
for i in range(18):
    cell=im.crop((i%6*256,i//6*256,i%6*256+256,i//6*256+256))
    box=cell.getchannel('A').point(lambda x:255 if x>40 else 0).getbbox()
    assert box and box[0]>20 and box[1]>20 and box[2]<236 and box[3]<236,(i,box)
    hashes.append(hashlib.sha256(cell.tobytes()).hexdigest())
assert len(set(hashes))==18
print('PASS fragment: dimensions, exact clear corners,18 distinct poses, padding; unused row alpha<=1/255')
