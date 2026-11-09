from PIL import Image,ImageDraw,ImageFont
from pathlib import Path
import subprocess
R=Path(__file__).resolve().parents[1]
g=Image.open(R/'assets/animation/guardiao_colosso_ataques.png').convert('RGBA');c=Image.open(R/'assets/animation/carregador_exposto.png').convert('RGBA');debris=Image.open(R/'assets/detritos_caixao.png').convert('RGBA');font=ImageFont.truetype(str(R/'assets/title_font.ttf'),24)
p=subprocess.Popen(['ffmpeg','-y','-loglevel','error','-f','rawvideo','-pixel_format','rgb24','-video_size','1280x720','-framerate','30','-i','-','-an','-c:v','libx264','-crf','20','-pix_fmt','yuv420p','-movflags','+faststart',str(R/'docs/videos/v22-atlas.mp4')],stdin=subprocess.PIPE)
for n in range(300):
 t=n/30;part=min(3,int(t/2.5));gi=part*4+min(3,int(t%2.5*3));ci=(min(5,int(t*4)) if t<2.5 else 6+min(5,int((t-2.5)*4)) if t<5 else 12+min(11,int((t-5)*3)))
 im=Image.new('RGB',(1280,720),(25,28,32));d=ImageDraw.Draw(im)
 for atlas,index,cols,cell,sz,pos in [(g,gi,4,512,480,(100,120)),(c,ci,6,256,256,(700,344))]:
  x=index%cols*cell;y=index//cols*cell;f=atlas.crop((x,y,x+cell,y+cell)).resize((sz,sz),Image.Resampling.LANCZOS);im.paste(f,pos,f)
 im.paste(debris,(990,472),debris)
 d.text((24,24),'LACRIMAE · v22 · Prévia isolada dos atlas',font=font,fill='#d9c396');d.text((24,65),'Tempos propostos; sem hitboxes, combate ou áudio.',font=font,fill='#aaaab0')
 d.text((100,635),f'Guardião · quadro {gi}',font=font,fill='#d9c396');d.text((700,635),f'Exposto · quadro {ci}',font=font,fill='#d9c396')
 if n==80:im.save(R/'docs/imagens/v22-previa.png')
 p.stdin.write(im.tobytes())
p.stdin.close();assert p.wait()==0
