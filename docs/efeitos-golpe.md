# Efeitos de golpe

`assets/animation/efeitos_golpe.png`: RGBA 1536 × 1024, 6 × 4 células de 256.

- 0–5: arco vermelho e branco, cresce e se dispersa; sugestão 20 fps.
- 6–11: estrela de impacto branca e ciano; sugestão 24 fps.
- 12–17: clarão de uma silhueta humana genérica, seguido de dissipação; sugestão 18 fps.
- 18–23: gotas formando uma poça que se espalha e escurece; sugestão 12 fps, manter o último quadro e remover depois.

Pivô central (128,128) nos três primeiros; poça com origem de chão (128,250). Não colocar uma poça completa em cada acerto: reservar para mortes/finalizações e limitar quantidade/duração. O clarão genérico **não coincide com todos os inimigos**: para branquear a silhueta exata de cada criatura, o integrador deve usar o próprio sprite/modulação ou shader; este atlas serve como efeito separado, não como máscara universal.

Verificador: `tests/art_v21_check.py`; folha `imagens/v21-efeitos_golpe-contato.png`; prévia `videos/v21-atlas.mp4`. Os 24 quadros são distintos, com alpha e cantos transparentes. Não houve teste de sobreposição em combate, redução de flashes, acessibilidade, mistura de cores no cenário ou desempenho com muitos efeitos. Os tempos são propostas, não uma validação de segurança luminosa. Nenhuma alteração no jogo ou em clips.json nesta tarefa.
