"""Acceptance criteria for the alternative ending export, not a monitor readability test."""
from pathlib import Path
import json
import numpy as np
from PIL import Image
ROOT=Path(__file__).resolve().parents[1]
rows=[]
for name in ['ato1_portoes.png','ato1_portoes_v2.png']:
    with Image.open(ROOT/'assets/ending'/name) as im:
        assert im.format=='PNG' and im.size==(1920,1080),name
        assert im.convert('RGBA').getchannel('A').getextrema()==(255,255),name
        y=np.asarray(im.convert('RGB'),dtype=float)@np.array([.2126,.7152,.0722])
        rows.append({'file':name,'mean':float(y.mean()),'p95':float(np.percentile(y,95)),
                     'below_12_percent':float(np.mean(y<12)*100),
                     'bottom_160_mean':float(y[-160:].mean()),'opaque':True,'size':list(im.size)})
assert 14<=rows[1]['mean']<=22,rows[1]
assert rows[1]['bottom_160_mean']<12,rows[1]
assert rows[1]['mean']>rows[0]['mean']
(ROOT/'docs/v16-encerramento-medidas.json').write_text(json.dumps(rows,indent=2)+'\n')
print('PASS ending v2: opaque1920x1080, mean14..22, dark bottom160px; original retained')
