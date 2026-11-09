"""Checa dimensões, opacidade e contraste da faixa de legenda. Requer Pillow."""
from pathlib import Path
from PIL import Image, ImageStat
import json
root=Path(__file__).resolve().parents[1]
result=[]
for i in range(1,5):
    path=f'assets/memoria_fogo/guardiao_fogo_{i:02}.png' if i<4 else 'assets/close/close_04b_grito.png'
    im=Image.open(root/path)
    expected=(1920,1080) if i<4 else (512,512)
    assert im.format=='PNG' and im.size==expected, (path,im.size)
    assert im.convert('RGBA').getchannel('A').getextrema()==(255,255), path
    item=dict(file=path,size=im.size,opaque=True)
    if i<4:
        band=ImageStat.Stat(im.convert('L').crop((0,920,1920,1080))).mean[0]
        scene=ImageStat.Stat(im.convert('L').crop((0,0,1920,920))).mean[0]
        assert band<60 and band<scene, (path,'faixa de legenda clara',band,scene)
        item.update(subtitle_luminance=round(band,2),scene_luminance=round(scene,2))
    result.append(item)
print(json.dumps(result,indent=2))
