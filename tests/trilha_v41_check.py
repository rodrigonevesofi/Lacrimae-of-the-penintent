from pathlib import Path
import json,hashlib,sys
import numpy as np
import soundfile as sf
base=Path(__file__).resolve().parents[1]
registro=json.loads((base/'docs/trilha-v41.json').read_text(encoding='utf-8'))
resultados=[];falhas=[];hashes=set()
for nome,dados in registro['faixas'].items():
 p=base/'assets/audio'/(nome+'.ogg')
 sha=hashlib.sha256(p.read_bytes()).hexdigest()
 onda,taxa=sf.read(p,dtype='float32',always_2d=True)
 duracao=len(onda)/taxa
 pico=float(20*np.log10(max(float(np.abs(onda).max()),1e-12)))
 volume=float(20*np.log10(max(float(np.sqrt(np.mean(onda.astype(np.float64)**2))),1e-12)))
 verificacoes={'sha256':sha==dados['sha256'],'bytes':p.stat().st_size==dados['bytes'],'formato':taxa==44100 and onda.shape[1]==2,'duracao':abs(duracao-dados['segundos_em_laco'])<0.2,'pico_sem_ceifamento':pico<0 and pico<=dados['pico_final_db']+1.5,'volume':abs(volume-dados['volume_final_db'])<0.5,'distinta':sha not in hashes}
 hashes.add(sha)
 resultados.append({'arquivo':p.relative_to(base).as_posix(),'sha256':sha,'segundos':round(duracao,3),'hz':taxa,'canais':onda.shape[1],'pico_dbfs':round(pico,3),'rms_dbfs':round(volume,3),'emenda_amplitude_max':round(float(np.abs(onda[0]-onda[-1]).max()),6),'verificacoes':verificacoes})
 falhas += [nome+': '+rotulo for rotulo,ok in verificacoes.items() if not ok]
saida={'metodo':'Decodificação independente com libsndfile; duração, PCM estéreo, hash, pico e RMS do OGG recebido. Não certifica fraseado musical, emenda perceptiva, true peak nem mixagem em partida.','faixas':len(resultados),'verificacoes':sum(len(r['verificacoes']) for r in resultados),'falhas':falhas,'resultados':resultados}
(base/'docs/v41-trilha-conferencia.json').write_text(json.dumps(saida,ensure_ascii=False,indent=2),encoding='utf-8')
print(json.dumps({k:v for k,v in saida.items() if k not in ['metodo','resultados']},ensure_ascii=False))
sys.exit(1 if falhas else 0)
