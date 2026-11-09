# Carregador de caixão

Carrega a própria sepultura: a Ordem lhe prometeu repouso apenas quando nenhum nome permanecesse por enterrar. As mãos esculpidas na pedra são o sinal visual dessa dívida. O rosto é adulto, coberto por faixas; tecido ocre e pedra cinza distinguem-no dos devotos.

`assets/animation/carregador.png`: RGBA 1536 × 1024; 6 × 4 células de 256. Perfil para a direita, pivô sugerido (128,250).

| Quadros | Leitura |
|---|---|
| 0–5 | Marcha curvada sob o caixão, lenta |
| 6–11 | Traz a pedra à frente e investe; dois quadros de aviso, quatro de avanço |
| 12–14 | Impacto, desequilíbrio e rachaduras |
| 15–17 | Pedra se parte, fragmentos caem e a criatura se ergue |
| 18–23 | Marcha rápida sem caixão, silhueta mais alta e estreita |

## Regra proposta ao integrador

Dois estados persistentes no encontro. Com caixão, deslocamento lento e defesa frontal; o jogador percebe o lado protegido pela pedra. A investida tem aviso e recuperação, permitindo esquiva e ataque pelas costas. Ao quebrar a proteção, tocar 15–17 uma única vez, desativar a defesa e passar a 18–23. O caixão não deve reaparecer no próximo golpe. Guardar a mudança no estado do inimigo; o respawn de altar pode recriar uma criatura intacta conforme a regra geral do jogo.

Os fragmentos estão desenhados na sequência de quebra. Para que permaneçam no chão enquanto ele se afasta, será necessário um objeto de detrito separado; não arrastar os fragmentos com o inimigo. Não foram entregues ataques próprios do estado desprotegido nem execução: não inventar essas transições usando a caminhada como se fossem animações de ataque.

Sugestões para primeira integração: marcha 7 fps; ataque com 180/220 ms de aviso e avanço mais curto; dano 10 fps; quebra 6 fps; marcha exposta 11 fps. São pontos de partida, sem balanceamento confirmado.

Verificador `tests/art_v21_check.py`; folha `imagens/v21-carregador-contato.png`; prévia `videos/v21-atlas.mp4`. Conferidos formato, transparência e 24 quadros distintos. A correspondência das poses foi revisada na folha. Falta validar colisão, deslocamento dos pés, aviso do ataque, transições e comportamento em jogo. Asset ainda não integrado.
