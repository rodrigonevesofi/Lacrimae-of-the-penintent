# Tarefas para o Codex — áudio (partir da v19)

Crie apenas arquivos novos, sintetizados (numpy, como `tools/make_creature_sfx.py`). Não edite scripts do jogo. Leia `docs/analise-audio.md`. WAV PCM 16 bits, 44,1 kHz; pico abaixo de −1 dBFS; início abaixo de 50 ms nos efeitos curtos; sem clipping; sem vozes de criança. Entregue `tools/make_audio_v20.py`, `tests/audio_assets_check.py` (verifica formato, pico, duração, início e, nos laços, que a emenda não faz clique) e `docs/audio-v20.md` com medidas e o que não foi validado.

## Tarefa 1 — Sons dos 17 eventos mudos (nomes exatos, em assets/audio/)
`morte.wav` (0,6 s, inimigo comum cai: golpe seco, sopro e queda de armadura), `morte_grande.wav` (1,1 s, elite), `chefe_morte.wav` (3 s, bronze rachando e um sino que afunda), `chefe_pancada.wav` (0,9 s, impacto pesado de bronze no chão com cauda), `dor.wav` (0,3 s, grunhido curto e abafado), `aterrissagem.wav` (0,25 s), `coleta.wav` (0,5 s, tilintar de lágrimas de vidro), `porta.wav` (0,8 s, pedra raspando), `projetil.wav` (0,5 s, um assobio cristalino), `projetil_impacto.wav` (0,3 s), `espinho.wav` (0,35 s, ferro afiado), `aparo.wav` (0,45 s, clangor metálico com anel agudo), `execucao.wav` (0,7 s, lâmina e carne), `portao_fecha.wav` (1,2 s, grade de ferro e correntes), `portao_abre.wav` (1,4 s), `ui_mover.wav` (0,08 s), `ui_confirmar.wav` (0,25 s).

## Tarefa 2 — Ambiência de cada sala (laços de 30 s, estéreo, `amb_<sala>.wav`)
Salas: `city`, `ossuary`, `cistern`, `cloister`, `belfry`, `archive`, `refuge`, `nave`, `terrace`, `court`. Cada uma é uma **textura larga em frequência** (não um tom): vento e poeira (cidade), goteiras e ossos que estalam (ossuário), água corrente e eco (cisterna), vozes distantes e velas (claustro), sinos pendurados que roçam (campanário), papel e madeira (arquivo), brasas (refúgio), silêncio com respiração de pedra (nave), vento alto e sinos (terraço), correntes e metal (pátio). RMS de −30 a −26 dBFS, emenda sem clique.

## Tarefa 3 — Passos e golpes com variação
`step_pedra_01` a `_04`, `step_madeira_01` a `_03`, `step_agua_01` a `_03`, `step_osso_01` a `_03` (0,15 s cada); `swing_01` a `_03` (0,25 s); `hit_carne_01` a `_03` e `hit_metal_01` a `_03` (0,2 s); `dor_01` a `_03` e `morte_01` a `_03`, variações dos sons da tarefa 1.
