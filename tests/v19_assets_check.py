"""Checks the two requested exports without modifying production code or its clip catalog."""
from pathlib import Path
import hashlib,json,subprocess,sys,tempfile,shutil
import numpy as np
from PIL import Image,ImageDraw
ROOT=Path(__file__).resolve().parents[1]
CLIPS=[('parry',0,6),('parry_recoil',6,6),('strong_counter',12,6),('charged_heavy',18,6)]
def light(im):
    a=np.asarray(im.convert('RGBA'),dtype=float);alpha=a[:,:,3]/255
    y=a[:,:,:3]@np.array([.2126,.7152,.0722])
    assert alpha.sum()>0
    return {'visible_alpha_weighted_y':float((y*alpha).sum()/alpha.sum()),'canvas_y_over_black':float((y*alpha).mean()),'coverage_percent':float(alpha.mean()*100)}
def run():
    atlas=ROOT/'assets/animation/hero_combate.png'
    im=Image.open(atlas);assert im.mode=='RGBA' and im.size==(1536,1024)
    cells=[];hashes=[];boxes=[]
    for i in range(24):
        c=im.crop((i%6*256,i//6*256,i%6*256+256,i//6*256+256));cells.append(c)
        b=c.getchannel('A').point(lambda x:255 if x>40 else 0).getbbox();assert b,i
        boxes.append(b);hashes.append(hashlib.sha256(c.tobytes()).hexdigest())
    assert len(set(hashes))==24
    assert im.getpixel((0,0))[3]<=8
    with tempfile.TemporaryDirectory(prefix='lacrimae-hero-v19-',dir='/tmp') as t:
        t=Path(t);(t/'tools').mkdir();(t/'assets/animation').mkdir(parents=True)
        shutil.copyfile(ROOT/'tools/check_animation_atlases.py',t/'tools/check_animation_atlases.py')
        manifest={'hero_combate':{name:{'sheet':'hero_combate','start':start,'count':count,'fps':12,'loop':False,'anchor':[128,250]} for name,start,count in CLIPS}}
        (t/'assets/animation/clips.json').write_text(json.dumps(manifest))
        (t/'assets/animation/hero_combate.png').symlink_to(atlas)
        r=subprocess.run([sys.executable,str(t/'tools/check_animation_atlases.py')],capture_output=True,text=True)
        checker=json.loads(r.stdout);assert r.returncode==0,r.stdout+r.stderr
    gates=[]
    for name in ['arena_portao','arena_portao_aberto']:
        g=Image.open(ROOT/'assets'/f'{name}.png');assert g.mode=='RGBA' and g.size==(96,540)
        alpha=g.getchannel('A');assert alpha.getextrema()[0]==0
        b=alpha.point(lambda x:255 if x>40 else 0).getbbox();assert b
        m=light(g);assert 40<=m['visible_alpha_weighted_y']<=90,(name,m)
        if name.endswith('aberto'):assert b[3]<=32 and np.max(np.asarray(alpha)[40:])<=8,b
        else:assert b[3]>=535 and b[1]<=5,b
        gates.append({'file':name+'.png','bounds_alpha40':b,**m})
    old=Image.open(ROOT/'assets/animation/hero_combat.png').convert('RGBA')
    b=old.crop((0,0,256,256)).getchannel('A').point(lambda x:255 if x>40 else 0).getbbox()
    result={'atlas':{'size':[1536,1024],'distinct_frames':24,'bounds':boxes,'nominal_anchor':[128,250],'first_parry_height_ratio_to_original_idle':(boxes[0][3]-boxes[0][1])/(b[3]-b[1])},'original_checker_fixture':checker,'gates':gates}
    (ROOT/'docs/v19-assets-result.json').write_text(json.dumps(result,indent=2)+'\n')
    # Folha de contato diagnóstica solicitada; não altera o atlas de produção.
    contact=Image.new('RGB',(1536,4*284),(18,23,29));d=ImageDraw.Draw(contact)
    for i,c in enumerate(cells):
        x=i%6*256;y=i//6*284
        contact.paste(c,(x,y),c.getchannel('A'))
        d.line((x+128,y,x+128,y+255),fill=(45,57,65));d.line((x,y+250,x+255,y+250),fill=(112,91,55))
        d.text((x+6,y+260),f'{i:02d} {CLIPS[i//6][0]}',fill=(224,214,189))
        if i==2:d.rectangle((x+1,y+1,x+254,y+254),outline=(71,219,214),width=3)
    contact.save(ROOT/'docs/imagens/v19-hero-contato.png')
    print('PASS v19:24distinctframes; unchanged checker4clips;2RGBA96x540gates; visible-material Y40..90; open base at ceiling')
if __name__=='__main__':run()
