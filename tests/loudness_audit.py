"""PCM level audit, not LUFS: no WAV or runtime mixer settings are changed."""
from pathlib import Path
import argparse
import hashlib
import json
import math
import wave
import numpy as np

ROOT=Path(__file__).resolve().parents[1]
CREATURES={'devorador_rugido','devorador_bote','flagelante_chicote','flagelante_investida',
           'bruxa_sussurro','bruxa_leque','asmodeia_aviso','asmodeia_estilhaco','duelista_cacete'}
SCENE={'altar','bell','breath','knock','corrente_cede','sino_surdo','guilt'}
# Starting points for later listening, not loudness standards or automatic normalization.
TARGETS={'trilhas':-24.0,'efeitos de ataque/ação':-18.0,'sons de cena':-23.0,'sons de criatura':-20.0}

def db(amplitude):
    return 20*math.log10(amplitude) if amplitude>0 else None

def pcm_decode(raw,width,channels):
    if width==1:
        data=(np.frombuffer(raw,dtype=np.uint8).astype(np.float64)-128)/128
    elif width in (2,4):
        data=np.frombuffer(raw,dtype='<i2' if width==2 else '<i4').astype(np.float64)/(2**(width*8-1))
    elif width==3:
        b=np.frombuffer(raw,dtype=np.uint8).reshape(-1,3).astype(np.int32)
        value=b[:,0]|(b[:,1]<<8)|(b[:,2]<<16)
        data=((value ^ 0x800000)-0x800000).astype(np.float64)/8388608
    else:
        raise ValueError(f'Unsupported PCM width: {width}')
    return data.reshape(-1,channels)

def levels(samples,sr):
    if not len(samples):raise ValueError('Empty WAV')
    energy=np.mean(samples*samples,axis=1)  # average channels; do not count stereo twice
    n=min(len(energy),max(1,round(sr*.100)))
    cumulative=np.concatenate(([0.0],np.cumsum(energy,dtype=np.float64)))
    windows=(cumulative[n:]-cumulative[:-n])/n
    start=int(np.argmax(windows))
    return {'peak_dbfs':db(float(np.max(np.abs(samples)))),
            'rms_dbfs':db(float(np.sqrt(energy.mean()))),
            'max_100ms_rms_dbfs':db(float(np.sqrt(max(0.0,windows[start])))),
            'window_ms':n/sr*1000,'loudest_window_start_s':start/sr,
            'clipped_samples':int(np.count_nonzero(np.abs(samples)>=1))}

def group_for(name):
    if name.startswith('ost_') or name=='vespera_lament':return 'trilhas'
    if name in CREATURES:return 'sons de criatura'
    if name in SCENE or name.startswith('murmurio_'):return 'sons de cena'
    return 'efeitos de ataque/ação'

def current_gain(name,group):
    if name=='guilt':return None # variable -42..-5, muted in title/quiet memory
    if group=='trilhas':return -3.0 # normal context; scenes duck this further
    if name=='step':return -7.0
    if name.startswith('murmurio'):return -8.0
    if name in CREATURES:return -4.0
    return -2.0

def fmt(value):return '−∞' if value is None else f'{value:.2f}'

def audit():
    rows=[]
    source=(ROOT/'scripts/soundscape.gd').read_text()
    expected=['ambience.volume_db = -3','-7 if name == "step"','-8 if name.begins_with("murmurio")','-4 if CREATURE_SFX.has(name)','else -2']
    if not all(token in source for token in expected):
        raise ValueError('Runtime gain assumptions changed; revise current_gain before proposing shifts')
    for path in sorted((ROOT/'assets/audio').rglob('*.wav')):
        digest=hashlib.sha256(path.read_bytes()).hexdigest()
        with wave.open(str(path)) as wav:
            if wav.getcomptype()!='NONE':raise ValueError(f'Not PCM: {path}')
            sr=wav.getframerate();channels=wav.getnchannels();bits=wav.getsampwidth()*8
            samples=pcm_decode(wav.readframes(wav.getnframes()),wav.getsampwidth(),channels)
        group=group_for(path.stem)
        rows.append({'file':path.relative_to(ROOT).as_posix(),'group':group,'seconds':len(samples)/sr,
                     'sample_rate':sr,'channels':channels,'bits':bits,'sha256':digest,
                     'reference_runtime_gain_db':current_gain(path.stem,group),**levels(samples,sr)})
        assert hashlib.sha256(path.read_bytes()).hexdigest()==digest,path
    proposals=[]
    for group,target in TARGETS.items():
        members=[r for r in rows if r['group']==group and r['reference_runtime_gain_db'] is not None and r['max_100ms_rms_dbfs'] is not None]
        # Exclude legacy unused track from runtime proposal, but keep it in the exhaustive table.
        members=[r for r in members if not r['file'].endswith('/vespera_lament.wav')]
        values=[r['max_100ms_rms_dbfs']+r['reference_runtime_gain_db'] for r in members]
        median=float(np.median(values))
        desired=target-median
        # Reserve -3dBFS per voice. This does not protect the summed master bus.
        peak=max(r['peak_dbfs']+r['reference_runtime_gain_db'] for r in members)
        delta=min(desired,-3-peak)
        proposals.append({'group':group,'files_in_proposal':len(members),'reference_100ms_median_dbfs':median,
                          'target_100ms_median_dbfs':target,'suggested_additional_gain_db':delta,
                          'desired_gain_before_peak_cap_db':desired,'projected_max_voice_peak_dbfs':peak+delta})
    report={'method':'sample peak; RMS across channels; sliding 100ms window at every frame; not LUFS/true peak',
            'read_only':True,'audio':rows,'proposals':proposals}
    (ROOT/'docs/auditoria-volume.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n')
    lines=['# Auditoria de volume dos WAVs','',
           'Níveis dos arquivos PCM, sem alterar WAVs ou volumes do jogo. Pico é máximo absoluto '
           'das amostras de todos os canais. RMS é a raiz da média dos quadrados, com canais '
           'ponderados igualmente e todo o silêncio incluído. A janela mais alta considera todas '
           'as posições possíveis de100ms, em passos de uma amostra; arquivo menor usaria sua '
           'duração total. 0dBFS corresponde à amplitude digital1. Não é LUFS, pico verdadeiro '
           'entre amostras nem medição de pressão sonora. −∞ indica silêncio.', '',
           '| Arquivo | Grupo | Pico dBFS | RMS dBFS | RMS máximo100ms dBFS | Início janela s |',
           '|---|---|---:|---:|---:|---:|']
    for r in rows:
        lines.append(f"| `{Path(r['file']).name}` | {r['group']} | {fmt(r['peak_dbfs'])} | {fmt(r['rms_dbfs'])} | {fmt(r['max_100ms_rms_dbfs'])} | {r['loudest_window_start_s']:.3f} |")
    lines+=['','## Proposta de deslocamento por grupo','',
            'Ponto de partida para audição, relativo aos ganhos atuais de `soundscape.gd`: trilha−3dB, '
            'ação−2dB (passo−7), criatura−4dB, cena−2dB (murmúrios−8). São valores de referência: '
            'oração, memória e crossfades reduzem a trilha; a camada `guilt.wav` varia de−42 a−5dB '
            'e requer ajuste separado. `vespera_lament.wav` é legado não carregado pelo controlador '
            'atual; aparece na tabela, mas não influencia a proposta de trilhas.', '',
            'Ajuste sugerido = alvo menos a mediana do RMS máximo100ms já com ganho de referência. '
            'Limita-se qualquer aumento para que nenhum pico individual projetado passe de−3dBFS. '
            'Os alvos abaixo são escolhas de mixagem para separar música, cenas e ataques, não '
            'normas de acessibilidade. Um único ganho de grupo não elimina diferenças dentro dele.', '',
            '| Grupo | Mediana atual100ms | Alvo inicial | Acrescentar ao ganho atual | Maior pico individual previsto |',
            '|---|---:|---:|---:|---:|']
    for r in proposals:
        lines.append(f"| {r['group']} | {r['reference_100ms_median_dbfs']:.2f}dBFS | {r['target_100ms_median_dbfs']:.2f}dBFS | {r['suggested_additional_gain_db']:+.2f}dB | {r['projected_max_voice_peak_dbfs']:.2f}dBFS |")
    lines+=['','## Aplicação posterior e limites','',
            'O Claude aplica os deslocamentos depois de audição contextual. Manter sinal de perigo '
            'audível sem cobrir a música e o ambiente; comparar as três batidas, murmúrios, '
            'confirmação do altar e ataques em fones, caixas e celular. Sons curtos têm RMS integral '
            'baixo por desenho: não normalizar todo arquivo à mesma média. Separar ajustes de '
            'passos, respiração e culpa contínua se um ganho comum produzir resultados incoerentes.', '',
            'RMS por grupo não comprova equilíbrio perceptivo: frequências, densidade, intenção '
            'narrativa e sobreposição importam. O pico do master pode exceder0dBFS com vozes '
            'simultâneas mesmo quando cada uma respeita−3dBFS. Medir o master em combate com '
            'trilha, camada de culpa e múltiplas criaturas, e revisar headroom/limitação no mixer '
            'antes de aprovar. Não foi feita audição crítica nem captura do master nesta tarefa.', '',
            'Reproduzir: `python3 tests/loudness_audit.py`; validar cálculos: `--self-test`. '
            'Inventário, hashes, formatos, tempos de janela e valores sem arredondamento estão '
            'em `auditoria-volume.json`.']
    (ROOT/'docs/auditoria-volume.md').write_text('\n'.join(lines)+'\n')
    print(f'LOUDNESS_AUDIT: {len(rows)} WAVs, no files modified')
    for r in proposals:print(r['group'],f"{r['suggested_additional_gain_db']:+.2f} dB additional")

def self_test():
    x=np.ones((1000,2))*.5;r=levels(x,1000)
    assert abs(r['peak_dbfs']+6.020599913)<1e-8
    assert abs(r['rms_dbfs']-r['peak_dbfs'])<1e-8
    assert abs(r['max_100ms_rms_dbfs']-r['peak_dbfs'])<1e-8
    stereo=np.column_stack((np.ones(1000)*.5,np.zeros(1000)))
    assert abs(levels(stereo,1000)['rms_dbfs']+9.03089987)<1e-7
    assert levels(np.zeros((100,1)),1000)['rms_dbfs'] is None
    rng=np.random.default_rng(16);a=rng.normal(0,.1,(137,2));r=levels(a,1000)
    brute=max(float(np.mean(a[i:i+100]**2)) for i in range(38))
    assert abs(r['max_100ms_rms_dbfs']-10*np.log10(brute))<1e-10
    assert levels(np.ones((25,1))*.25,1000)['window_ms']==25
    assert np.allclose(pcm_decode(bytes([0,0,128,255,255,127,0,0,0]),3,1).ravel(),[-1,1-1/8388608,0])
    assert np.allclose(pcm_decode(bytes([0,128,255]),1,1).ravel(),[-1,0,127/128])
    print('PASS audio: reference levels, stereo average, silence, sliding-window oracle, short clip, PCM8/24')

if __name__=='__main__':
    parser=argparse.ArgumentParser();parser.add_argument('--self-test',action='store_true');args=parser.parse_args()
    if args.self_test:self_test()
    else:audit()
