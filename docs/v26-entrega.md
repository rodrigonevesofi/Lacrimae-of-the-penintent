# Entrega v26 — a espada na mão do Penitente

O autor notou que a espada parecia não estar sendo segurada. Era verdade, por três motivos:

1. **Ponto errado.** Parado, a espada era presa num ponto fixo, (174, 135) do desenho, que fica no **antebraço**, uns 20 px acima do punho. Na corrida, os pontos estavam errados em até 50 px; em dois quadros caíam no ar.
2. **Atrás do corpo.** A espada era desenhada atrás do Penitente; a mão do desenho está aberta, então lia-se uma mão solta ao lado de um cabo.
3. **Atraso de um passo.** A espada era reposicionada antes de a animação trocar de desenho; na corrida, por um instante, ela usava o ponto do quadro anterior (o punho anda até 30 px entre quadros) e saltava para a altura do capacete.

Correções: um ponto de punho medido para cada um dos 12 desenhos (parado e corrida); a espada à frente do corpo, com o cabo sobre os dedos; reposicionamento no instante exato em que o desenho muda; e o balanço artificial removido (a arte já respira).

Testes: `tests/sword_grip_check.py` (cada ponto cai sobre a mão desenhada, não no ar) e `tests/sword_sync_smoke.gd` (erro de 0,00 px entre o cabo e o punho do desenho mostrado, parado e correndo). Antes e depois: [v26-espada-antes-depois.png](imagens/v26-espada-antes-depois.png).

## Limite e correção definitiva
A mão dos desenhos parado e de corrida está **aberta**; o cabo agora a cobre, mas o ideal é a arte com a mão fechada no cabo. Pedido ao Codex.
