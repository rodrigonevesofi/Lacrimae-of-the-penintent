"""Measure visible lower silhouettes. --apply edits only allowed executed anchor fields."""
import json,sys
from pathlib import Path
from PIL import Image
ROOT=Path(__file__).resolve().parents[1];path=ROOT/'assets/animation/clips.json'
m=json.loads(path.read_text());scales={'devorador':.62,'flagelante':.35,'bruxa':.36,'asmodeia':.42,'duelista':.36}
def bottom(sheet,index):
    im=Image.open(ROOT/'assets/animation'/f'{sheet}.png').getchannel('A')
    box=im.crop((index%6*256+24,index//6*256,index%6*256+232,index//6*256+256)).point(lambda a:255 if a>=64 else 0).getbbox()
    return box[3]-1
results={}
for actor,scale in scales.items():
    d=m[actor]['executed'];h=m['hero']['execute_mourner' if actor in ['bruxa','asmodeia'] else 'execute_devotee']
    measurements=[]
    for i in range(12):
        y=bottom(d['sheet'],d['start']+i);hy=bottom(h['sheet'],h['start']+i)
        delta=(y-250)*scale-(hy-h['anchor'][1])*.44
        measurements.append({'frame':i,'victim_bottom':y,'hero_bottom':hy,'before':round(delta,2)})
    values=[r['before'] for r in measurements]
    new_y=round(250+(min(values)+max(values))/(2*scale)) if max(abs(v) for v in values)>6 else 250
    for r in measurements:r['after']=round(r['before']+(250-new_y)*scale,2)
    results[actor]={'scale':scale,'before_anchor':[128,250],'after_anchor':[128,new_y],'frames':measurements}
    if '--apply' in sys.argv:m[actor]['executed']['anchor']=[128,new_y]
if '--apply' in sys.argv:path.write_text(json.dumps(m,indent=2,ensure_ascii=False)+'\n')
(ROOT/'docs/execucoes-medidas.json').write_text(json.dumps(results,indent=2))
text='# Revisão das execuções\n\nComparação do atlas da vítima com execute_devotee (terrestres) ou execute_mourner (aéreas),12quadros sincronizados. Escalas reais: herói0,44; vítimas conforme Enemy.TYPES. A referência é o ponto inferior visível na faixa centralx24–231, alfa≥64; é uma aproximação dos pés/bainha, não um detector anatômico. Medida em pixels de tela com zoom1 e origens de chão coincidentes. Positivo=abaixo da referência do herói.\n\n'
for actor,r in results.items():
    text+=f"## {actor}\n\nÂncora anterior {r['before_anchor']}; posterior {r['after_anchor']}.\n\n| Quadro | Antes px | Depois px |\n|---|---:|---:|\n"
    for f in r['frames']:text+=f"| {f['frame']} | {f['before']:.2f} | {f['after']:.2f} |\n"
    text+=f"\n[Comparação dos12quadros](imagens/execucao-{actor}.png).\n\n"
text+='Somente âncoras executed foram corrigidas quando a diferença excedia6px; posições, tempos, dano e outros clipes permanecem os da base. O ajuste constante minimiza o pior desvio entre quadros, sem redesenhar as poses.\n\nLimites: um sprite caído não tem a mesma posição anatômica de um sprite em pé. Correntes/armas podem contaminar a leitura por alfa; as folhas precisam de revisão visual. Além disso, a execução de uma criatura aérea pode começar com sua origem até80unidades acima do herói: essa diferença dinâmica não se corrige com uma âncora única. A correção da posição no início da execução depende do Claude e não foi feita aqui. A revisão não comprova fluidez em todas as alturas/zooms.\n'
(ROOT/'docs/execucoes-revisao.md').write_text(text)
print({a:r['after_anchor'] for a,r in results.items()})
