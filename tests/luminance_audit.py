"""Read-only RGB brightness audit. Run from any directory; no image is modified."""
from pathlib import Path
import argparse
import hashlib
import json
import re
import numpy as np
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
COEFFICIENTS = np.array([0.2126, 0.7152, 0.0722])

def metrics(rgb):
    y = np.asarray(rgb, dtype=np.float64) @ COEFFICIENTS
    return {'mean': float(y.mean()), 'p95': float(np.percentile(y, 95)),
            'below_12_percent': float(np.mean(y < 12) * 100)}

def risk(m):
    if m['mean'] < 12:
        return 'REVER: média <12'
    if m['below_12_percent'] >= 75:
        return 'REVER: ≥75% abaixo de12'
    if m['mean'] < 22 or m['below_12_percent'] >= 50:
        return 'Conferir sombras'
    return 'Sem alerta pelo critério'

def inventory():
    # Read actual room declarations, rather than guessing from every root PNG.
    layout = (ROOT/'scripts/act_one_layout.gd').read_text()
    room_art = sorted(set(re.findall(r'"art"\s*:\s*"([^"]+)"', layout)))
    if not room_art:
        raise ValueError('No room backgrounds discovered; check the layout parser')
    paths = {p: 'cena / '+folder for folder in ['memory', 'boss', 'ending']
             for p in sorted((ROOT/'assets'/folder).rglob('*.png'))}
    for name in room_art:
        paths[ROOT/'assets'/f'{name}.png'] = 'fundo de sala'
    # Opening is another full-screen key illustration, outside the requested directories.
    if (ROOT/'assets/opening.png').exists():
        paths[ROOT/'assets/opening.png'] = 'abertura (adicional)'
    return paths

def audit():
    rows = []
    for path, group in sorted(inventory().items()):
        before = hashlib.sha256(path.read_bytes()).hexdigest()
        with Image.open(path) as im:
            rgba = im.convert('RGBA')
            opaque = rgba.getchannel('A').getextrema() == (255, 255)
            # Explicit backdrop for any future alpha-bearing illustration.
            rgb = Image.alpha_composite(Image.new('RGBA', im.size, (0,0,0,255)), rgba).convert('RGB')
            result = metrics(rgb)
            size = list(im.size)
        assert hashlib.sha256(path.read_bytes()).hexdigest() == before, path
        rows.append({'file': path.relative_to(ROOT).as_posix(), 'group': group,
                     'size': size, 'opaque': opaque, 'sha256': before, **result,
                     'review': risk(result)})
    report = {'method': 'Yprime=0.2126R+0.7152G+0.0722B on encoded RGB8, no linearisation; alpha over black',
              'read_only': True, 'illustrations': rows}
    (ROOT/'docs/auditoria-luminancia.json').write_text(json.dumps(report, ensure_ascii=False, indent=2)+'\n')
    lines = ['# Auditoria de luminância da arte-chave', '',
             'Medição do arquivo, antes de modulação, vinheta, zoom ou iluminação do Godot. '
             'Usa Y′ = 0,2126R + 0,7152G + 0,0722B em RGB codificado de 0 a255; '
             'é um indicador de brilho, não luminância física nem luminância relativa WCAG. '
             'Sem conversão linear ou simulação de monitor. Alfa, se houver, é composto sobre preto.', '',
             'Inventário: todos os PNGs de memory/boss/ending, os fundos declarados em '
             '`act_one_layout.gd` e a abertura adicional. Sprites, atlas e objetos transparentes '
             'não são fundos de sala. O script não modifica imagens; confere seus hashes.', '',
             '**Triagem:** rever média <12 ou ≥75% de pixels abaixo de12; conferir sombras '
             'se média <22 ou ≥50% abaixo de12. São limiares editoriais conservadores, não '
             'prova de perda num monitor específico. P95 alto pode vir de uma única lanterna '
             'e não garante correntes, personagens ou caminhos legíveis.', '',
             '| Arquivo | Uso | Média /255 | P95 /255 | Pixels <12 | Triagem |',
             '|---|---|---:|---:|---:|---|']
    for row in rows:
        lines.append(f"| `{row['file']}` | {row['group']} | {row['mean']:.2f} | {row['p95']:.2f} | {row['below_12_percent']:.1f}% | {row['review']} |")
    lines += ['', '## Como usar', '',
              'Priorizar os itens marcados REVER: conferir em brilho comum, tela de celular e '
              'capturas reais do jogo, sem alterar o brilho global para compensar uma única cena. '
              'Comparar correntes, rostos/gestos, bordas de plataformas e saídas, além da média. '
              'O encerramento v1 permanece como referência; v2 é uma alternativa, ainda sem '
              'substituição automática na HUD. Fundos grandes são recortados pela câmera: a '
              'média do panorama inteiro pode esconder um trecho problemático.', '',
              'Reproduzir: `python3 tests/luminance_audit.py`. Resultados completos e hashes em '
              '`auditoria-luminancia.json`. Não houve teste humano nem calibração de monitores.']
    (ROOT/'docs/auditoria-luminancia.md').write_text('\n'.join(lines)+'\n')
    print(f'LUMINANCE_AUDIT: {len(rows)} images, read-only; '+str(sum(r['review'].startswith('REVER') for r in rows))+' flagged')

def self_test():
    black = metrics(np.zeros((2,2,3))); white = metrics(np.full((2,2,3),255))
    assert black == {'mean':0.0, 'p95':0.0, 'below_12_percent':100.0}
    assert abs(white['mean']-255) < 1e-10 and white['below_12_percent']==0
    assert abs(metrics(np.full((3,4,3),18))['mean']-18) < 1e-10
    assert abs(metrics(np.array([[[255,0,0]]]))['mean']-54.213)<1e-10
    boundary=metrics(np.array([[[11,11,11],[12,12,12]]]))
    assert boundary['below_12_percent']==50
    print('PASS brightness: black/white/grey/red/strict threshold')

if __name__ == '__main__':
    parser=argparse.ArgumentParser();parser.add_argument('--self-test',action='store_true');args=parser.parse_args()
    if args.self_test:self_test()
    else:audit()
