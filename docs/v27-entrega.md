# Entrega v27 — sangue nas execuções, execução própria de cada criatura, pulo de armadura

## Sangue nas execuções
Antes, o golpe mortal soltava partículas bege (`c69c72`), de poeira: não havia sangue. Agora:
- **primeiro ferimento** (a lâmina entra, 42% da execução): dois jatos de sangue e gotas;
- **golpe mortal** (66%): jato maior em leque, gotas que voam e caem com gravidade, estrela de impacto e uma **poça que fica no chão** (some devagar depois de 25 s; no máximo 14 poças por vez).
Teste: `tests/execution_gore_smoke.gd`. Captura: [v27-execucao-sangue.png](imagens/v27-execucao-sangue.png).

## Execução própria de cada criatura
Todas as criaturas comuns já tinham a **reação** própria (quadros 12–23 das folhas `*_executado`), mas o **Penitente** só tinha dois movimentos: um para humanoides (`execute_devotee`) e o do Chorão (`execute_mourner`). Os quadros 0–11 das outras folhas estão **vazios**. O jogo agora escolhe `execute_<criatura>` automaticamente assim que essa animação existir; até lá, usa o movimento compartilhado. A arte foi pedida ao Codex.

O Guardião não tem execução (como os chefes de Blasphemous); ele tem a cena de queda.

## Pulo
O som antigo era um **tom puro subindo de 194 para 366 Hz** em 0,2 s, o "buíp" de desenho animado. O novo (`tools/make_jump_sfx.py`, três variações) é o impulso do pé na pedra, o atrito, o pano e a capa, placas de armadura e um sopro de esforço, sem tom e sem subida. Teste: `tests/jump_sound_check.py` (reprova o antigo, aprova o novo). Espectrogramas: [v27-pulo-antes-depois.png](imagens/v27-pulo-antes-depois.png). Não foi ouvido por mim.
