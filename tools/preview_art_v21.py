"""Isolated atlas preview, not gameplay or collision validation."""
from PIL import Image,ImageDraw,ImageFont
from pathlib import Path
import subprocess
R=Path(__file__).resolve().parents[1]
def font(n):return ImageFont.truetype(str(R/'assets/title_font.ttf'),n)
def frame(name,index,cols,cell,size):
 im=Image.open(R/f'assets/animation/{name}.png').convert('RGBA')
 x=index%cols*cell;y=index//cols*cell
 return im.crop((x,y,x+cell,y+cell)).resize((size,size),Image.Resampling.LANCZOS)
def paste(canvas,im,xy):canvas.paste(im,xy,im)
# Contact sheet for six close-ups and lore sample.
contact=Image.new('RGB',(1536,1104),(20,20,24));d=ImageDraw.Draw(contact)
for i,name in enumerate(['Penitente','Iria','Edran','Guardião','Sepultador','Inquisidora']):
 im=Image.open(R/f'assets/close/close_{i+1:02}.png');contact.paste(im.convert('RGB'),(i%3*512,i//3*552));d.text((i%3*512+16,i//3*552+518),f'{i+1:02} · {name}',font=font(22),fill='#c5b38d')
contact.save(R/'docs/imagens/v21-close-contato.png')
lore=Image.new('RGB',(1280,720),(18,18,22))
face=Image.open(R/'assets/boss/guardiao_rosto.png').resize((1280,720));lore.paste(face.convert('RGB'))
paste(lore,Image.open(R/'assets/ui/moldura_lore.png').convert('RGBA'),(0,550))
d=ImageDraw.Draw(lore);gothic=ImageFont.truetype(str(R/'assets/fonts/UnifrakturMaguntia-Book.ttf'),36)
d.text((640,610),'A culpa permanece onde o sino se cala.',font=gothic,anchor='mm',fill='#f5e6ca',stroke_width=1,stroke_fill='#191519')
lore.save(R/'docs/imagens/v21-rosto-lore.png')
(R/'docs/videos').mkdir(exist_ok=True)
p=subprocess.Popen(['ffmpeg','-y','-loglevel','error','-f','rawvideo','-pixel_format','rgb24','-video_size','1280x720','-framerate','30','-i','-','-an','-c:v','libx264','-crf','20','-pix_fmt','yuv420p','-movflags','+faststart',str(R/'docs/videos/v21-atlas.mp4')],stdin=subprocess.PIPE)
clips_g=[(0,4,4),(4,4,6),(8,4,4),(12,2,3),(14,2,2)]
clips_c=[(0,6,7),(6,6,8),(12,3,5),(15,3,3),(18,6,11)]
for n in range(300):
 t=n/30;part=min(4,int(t/2));local=t%2
 im=Image.new('RGB',(1280,720),(24,26,31));d=ImageDraw.Draw(im)
 d.text((32,22),'LACRIMAE · v21 · Prévia isolada dos atlas',font=font(26),fill='#d1ba85')
 d.text((32,62),'Tempos propostos; sem combate, colisões ou áudio.',font=font(19),fill='#a6a6ac')
 a,b,fps=clips_g[part];idx=a+(min(b-1,int(local*fps)) if part>=2 else int(local*fps)%b)
 paste(im,frame('guardiao_colosso',idx,4,512,480),(100,130))
 a,b,fps=clips_c[part];idx2=a+(min(b-1,int(local*fps)) if part in (2,3) else int(local*fps)%b)
 paste(im,frame('carregador',idx2,6,256,256),(625,355))
 fxrow=min(3,int(t/2.5));fi=fxrow*6+min(5,int((t%1.25)*12))
 paste(im,frame('efeitos_golpe',fi,6,256,256),(970,300))
 paste(im,frame('hero_motion',0,6,256,112),(15,489))
 d.line((0,600,900,600),fill='#685738')
 d.text((130,628),f'Guardião · quadro {idx:02}',font=font(20),fill='#dfceaf')
 d.text((625,628),f'Carregador · {idx2:02}',font=font(20),fill='#dfceaf')
 d.text((970,628),f'Efeito · {fi:02}',font=font(20),fill='#dfceaf')
 if n in [15,135,225]:im.save(R/f'docs/imagens/v21-movimento-{n}.png')
 p.stdin.write(im.tobytes())
p.stdin.close();assert p.wait()==0
