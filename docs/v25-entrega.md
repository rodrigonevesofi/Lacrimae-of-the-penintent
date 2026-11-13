# Entrega v25 — o primeiro encontro de história dentro do jogo

A chegada do Guardião dos Sinos deixou de ser uma tela preta com uma pintura e passou a acontecer no mundo, como o encontro com o gigante em Blasphemous (ver [referencia-blasphemous.md](referencia-blasphemous.md)). Onze segundos, que podem ser pulados depois de dois:

1. **Plano geral (0–2,6 s):** o mundo continua à vista; faixas de cinema; a câmera recua e enquadra o Penitente e o Guardião; o HUD some; a primeira frase em letra gótica (UnifrakturMaguntia, licença SIL OFL) na moldura de lore.
2. **Close (2,6–5,2 s):** o rosto sob o sino, com a segunda frase.
3. **Lembrança em fogo (5,2–8,6 s):** as três imagens do Codex — o homem na corda, a corda cortada, o bronze derramado sobre ele — com o sino abafado, legendado.
4. **Grito (8,6–9,5 s):** o rosto gritando; os anéis do grito saem do sino no mundo; legenda "[Grito de bronze]".
5. **Retorno (até 11 s):** a câmera volta, o HUD volta e a luta começa no mesmo lugar, sem corte.

Teste: `tests/encounter_smoke.gd` (16 verificações). Captura: [v25-encontro-guardiao.png](imagens/v25-encontro-guardiao.png).

## Limites
O ritmo foi visto em quadros parados, não em movimento; o tempo de cada parte é um ponto de partida. As lembranças não têm texto: as imagens contam. O sistema serve para outros encontros, mas só o do Guardião existe por ora.
