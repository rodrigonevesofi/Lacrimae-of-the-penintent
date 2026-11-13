# Prompts de som — Codex (síntese) ou Gemini/Argon (geração)

**Formato obrigatório para entrar no jogo sem mudar código:** WAV PCM 16 bits, 44,1 kHz; efeitos em mono, ambiências e músicas em estéreo; pico abaixo de −1 dBFS; sem silêncio no começo (o som começa em menos de 50 ms); laços (ambiência e música) com emenda sem clique. Salve em `assets/audio/` com **exatamente** estes nomes. Peça sempre sons originais: nada de imitar uma música ou trilha existente.

## Parte A — Para o Codex (síntese com numpy)
Use o padrão de `tools/make_jump_sfx.py` (camadas de ruído filtrado, transientes curtos, tons inarmônicos, nenhum tom que suba como em desenho animado). Entregue o script, os WAV e `docs/sons-v30.md` com medidas.
1. `lanca_estocada_01.wav` a `_03.wav` (0,3 s): ar cortado por uma haste longa e pesada, um rangido curto de ferro e couro.
2. `empalar.wav` (0,5 s): ponta entrando em carne, um baque surdo.
3. `golpe_carregado_carga.wav` (0,9 s): tensão crescendo, metal sob esforço, um zumbido grave que engrossa.
4. `golpe_carregado_solta.wav` (0,4 s): soltura violenta, ar deslocado.
5. `arremate.wav` (0,45 s): golpe pesado com cauda de eco de pedra.
6. `mergulho_impacto.wav` (0,7 s): armadura caindo do alto no chão de pedra, cascalho.
7. `sangue_compartilhado.wav` (1,0 s): uma batida de coração grave e um sopro, sem melodia.
8. `caido.wav` (0,8 s): corpo de armadura indo ao chão, um gemido abafado sem palavras.
9. `levanta.wav` (0,8 s): fôlego retomado, armadura rangendo.

## Parte B — Para o Gemini ou o Argon (geração por descrição)
Cole um pedido por vez. Depois converta para WAV no formato acima e corte o silêncio do início.

**Efeitos (mesmos nomes da Parte A):**
- `lanca_estocada_01`: *"Short sound effect, 0.3 seconds: a heavy iron spear thrust cutting the air, with a brief creak of leather and iron. Dry, close, no music, no voice."*
- `empalar`: *"Short sound effect, 0.5 seconds: a spear point piercing flesh, followed by a dull thud. Dark, visceral, no music."*
- `golpe_carregado_carga`: *"Sound effect, 0.9 seconds: tension building as a warrior charges a heavy blow — straining metal, a low hum growing thicker. No melody."*
- `arremate`: *"Short sound effect, 0.45 seconds: a heavy sword finisher striking an armoured body, with a short stone-hall echo."*
- `mergulho_impacto`: *"Sound effect, 0.7 seconds: an armoured knight landing hard from a height onto a stone floor, scattering gravel."*
- `sangue_compartilhado`: *"Sound effect, 1 second: one deep, slow heartbeat and a soft exhale, solemn, no melody."*

**Ambiências (laços de 30 s, estéreo, `amb_<sala>.wav`, substituem as atuais):**
- `amb_city`: *"30-second seamless loop: wind over a ruined gothic city at dusk, distant bells, dust, crows far away. No music."*
- `amb_cistern`: *"30-second seamless loop: an underground cistern, running water, slow drips, deep echo. No music."*
- `amb_belfry`: *"30-second seamless loop: a bell tower, wind through wooden beams, hanging bells softly brushing each other. No music."*

**Música (laços de 60–90 s, estéreo, `ost_<contexto>.wav`):**
- `ost_exploration`: *"Original 75-second seamless loop for a dark 2D action game about guilt and faith: slow Andalusian Holy Week procession feeling, muffled brass and snare marching far away, a low cathedral organ drone, a wordless mournful female voice in the distance. Sparse, melancholic, never loud."*
- `ost_combat`: *"Original 60-second seamless loop for combat in a dark religious setting: heavy war drums, low brass stabs, tense strings, a solemn male choir humming without words. Driving but not heroic."*
- `ost_boss`: *"Original 90-second seamless loop for a boss fight against a giant bell-ringer fused with his bell: huge tolling bells as percussion, organ, choir without words, rising dread."*
