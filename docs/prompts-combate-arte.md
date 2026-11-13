# Prompts de arte para refinar o combate — Codex ou Argon

Todos os pedidos são de arte **original** (não copie personagens, poses ou quadros de outros jogos). Formato comum para tudo, para entrar no jogo sem mudar código:
- PNG RGBA, fundo transparente, grade de células de **256 × 256**;
- personagem de perfil virado para a **direita**, **pés em x=128, y=250**, mesma escala do Penitente (`assets/animation/hero_motion.png`);
- luz vinda da esquerda e de cima, mesma paleta da arte atual (bronze, vermelho-sangue, pedra);
- entregar também uma folha de contato com o número de cada quadro.

O jogo já usa: combo de 3 golpes (o 3º é um arremate), golpe carregado, golpe descendente, aparo com contra-ataque, execução com sangue e câmera lenta nos golpes fortes. O que falta é **arte de qualidade nesses momentos**: antecipação, impacto, recuperação, e a reação de quem apanha.

## 1 — Penitente: golpes com antecipação e rastro (prioridade)
`assets/animation/hero_golpes.png`, 1536 × 1024 (6 × 4):
- 0–5 golpe A: 0–1 antecipação (corpo recua, espada atrás), 2 impacto com **rastro em meia-lua desenhado no próprio quadro**, 3–5 recuperação;
- 6–11 golpe B: mesma estrutura, de baixo para cima;
- 12–17 arremate: avanço com o peso do corpo, estocada que atravessa; 14 é o impacto;
- 18–23 golpe descendente: 18–19 no ar com a espada para baixo, 20 impacto no chão com poeira, 21–23 levantando.
Prompt de imagem (para o Argon), um por quadro-chave: *"2D side-view game sprite, a penitent knight in dark bronze plate armour with a tall metal capirote helmet and a crown of thorns, red tattered cape, holding a long sword with a red leather grip and a golden thorned guard, mid-swing with a crescent motion smear of red and white, dynamic pose, painterly pixel-art style, transparent background, facing right, no face visible."*

## 2 — Reações das criaturas: leve, forte e arremesso
Para cada criatura (`devoto`, `flagelante`, `devorador`, `duelista`, `carregador`, `bruxa`, `asmodeia`, `choro`), `assets/animation/reacoes_<criatura>.png`, 1536 × 1024:
- 0–2 golpe leve (o corpo cede para trás e volta);
- 3–6 golpe forte (dobra, solta a arma por um instante);
- 7–12 arremessado (sai do chão, gira, cai de costas, 12 deitado);
- 13–17 atordoado (cambaleia; é a janela da execução);
- 18–23 empalado pela lança de Beatriz (preso no lugar, se debate).

## 3 — Beatriz e a Lança de Vladimir
Ver `docs/personagem-beatriz.md`. Máscara de ferro lisa e **sem aberturas para os olhos**, armadura escura de carrasca, mãos enfaixadas, lança de ferro batido com relíquias amarradas e sangue coagulado, ponta cinzenta.
- `assets/animation/beatriz_movimento.png`: 0–5 parada, 6–11 corrida, 12–17 salto, 18–23 esquiva.
- `assets/animation/beatriz_combate.png`: 0–5 estocada (impacto no 2, a ponta à frente), 6–11 varredura baixa, 12–17 empalar (a lança atravessa), 18–23 golpe carregado (0–3 a haste pesando, 4–5 estocada longa).
- `assets/animation/beatriz_reacoes.png`: 0–5 aparo, 6–8 dano, 9–14 caindo (fica caída no 14), 15–20 levantando o parceiro (ajoelhada, a mão sobre ele), 21–23 golpe no ar.
- `assets/animation/beatriz_peso.png` (768 × 256, 3 quadros): a mesma pose parada com a lança cada vez mais pesada (a haste curva os ombros).
Prompt de imagem: *"2D side-view game sprite of an original female executioner of an old inquisition, smooth iron mask with no eye holes, dark worn armour, long heavy cloak, bandaged hands, carrying a long spear of beaten iron with relics tied to the shaft and dried blood, grey spear tip, somber painterly pixel-art style, transparent background, facing right."*

## 4 — Execuções próprias de cada criatura (pendente)
`assets/animation/hero_executa_<criatura>.png`: 12 quadros a 12 fps, golpe mortal no quadro 8, sangue escuro a partir do 8, mesmo registro de `execute_devotee.png`.

## 5 — Efeitos de impacto por material
`assets/animation/impactos.png`, 1536 × 1024: 0–5 faíscas em metal (laranja), 6–11 sangue em carne (vermelho escuro), 12–17 lascas de pedra (cinza), 18–23 estilhaços de osso (marfim). Cada um em 6 quadros, com o mais forte no 1.
