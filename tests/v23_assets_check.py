"""Validação estrutural dos recursos v23; requer Pillow. Não valida estilo ou gameplay."""
from pathlib import Path
from PIL import Image, ImageStat
import json
ROOT = Path(__file__).resolve().parents[1]
SPECS = {'assets/close/close_01_mascarado.png': ((512,512),False), 'assets/animation/onda_grito.png': ((1536,512),True), 'assets/rachadura_chao.png': ((512,128),True)}
results=[]
for name,(size,transparent) in SPECS.items():
    im=Image.open(ROOT/name)
    assert im.format=='PNG' and im.size==size, (name, im.size)
    alpha=im.convert('RGBA').getchannel('A')
    low,high=alpha.getextrema()
    assert high>0, name
    assert (im.mode=='RGBA' and low==0) if transparent else low==255, (name,im.mode,low)
    result=dict(file=name,size=size,mode=im.mode,alpha=[low,high])
    if 'onda_grito' in name:
        rows=[]
        for row in range(2):
            frames=[]
            for col in range(6):
                a=alpha.crop((col*256,row*256,(col+1)*256,(row+1)*256))
                bounds=a.point(lambda p:255 if p>32 else 0).getbbox()
                assert bounds, (row,col,'quadro vazio')
                assert bounds[0]>0 and bounds[1]>0 and bounds[2]<256 and bounds[3]<256, (row,col,'recorte na borda')
                frames.append(dict(bounds=bounds,alpha_mass=sum(ImageStat.Stat(a).sum)))
            rows.append(frames)
        for row in rows:
            widths=[f['bounds'][2]-f['bounds'][0] for f in row]
            assert all(a<b for a,b in zip(widths,widths[1:])), widths
        assert all(b['alpha_mass']<a['alpha_mass'] for a,b in zip(*rows)), 'eco deve ser mais fraco'
        result['frames']=rows
    results.append(result)
print(json.dumps(results,indent=2))
