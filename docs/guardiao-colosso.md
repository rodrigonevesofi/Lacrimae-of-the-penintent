# Guardião colossal

`assets/animation/guardiao_colosso.png`: RGBA, 2048 × 2048, 4 × 4 células de 512. Corpo voltado à direita em três quartos, com sino no torso, elmo e ombreiras de bronze, tecidos vermelhos. Mantém a iconografia de `assets/boss/`.

| Quadros | Ação | Sugestão inicial |
|---|---|---|
| 0–3 | Repouso | 4 fps, laço |
| 4–7 | Passos pesados | 6 fps, laço |
| 8–11 | Preparação e pancada | 8–9: 200/300 ms; 10–11: 90/210 ms |
| 12–13 | Dano | 100/160 ms |
| 14–15 | Queda | 200/500 ms; manter 15 |

Pivô proposto (256,500). A exportação registra verticalmente cada célula: o último pixel de silhueta com alpha > 40 fica em y=500. Os deslocamentos técnicos estão em `v21-exportacao.json`. Isso alinha a base visível, mas não substitui uma análise de apoio de cada pé. A marcha tem quatro poses: alongar sua duração indefinidamente evidenciará os saltos entre poses.

O close `assets/boss/guardiao_rosto.png` tem 1920 × 1080, rosto sob o sino, bronze rachado e uma lágrima de metal. Não contém texto. Use como plano breve do mesmo personagem, com transição para sua posição no mundo; não é uma animação facial.

## Integração

Não ligado a `clips.json`. O leitor de atlas atual e seu verificador assumem seis colunas: **não usar essa indexação para esta folha de quatro colunas**. Criar SpriteFrames com regiões 512 × 512 ou ampliar o leitor pelo integrador. A escala próxima de 0,9 produz aproximadamente 430 px de altura em repouso; comparar com o herói e com a área útil da arena antes de fixar. A prévia usa 480 px de célula e herói a 112 px apenas para estudo de proporção. A colisão não deve crescer automaticamente com a textura: separar corpo, alcance das mãos e ataque de chão. Preparação precisa permanecer visível antes da janela de dano.

## Conferência

`python3 tests/art_v21_check.py`: dimensões, RGBA, transparência dos cantos, 16 quadros distintos, base registrada e fonte. Folha: `imagens/v21-guardiao_colosso-contato.png`. Prévia: `videos/v21-atlas.mp4`. O close aparece em `imagens/v21-rosto-lore.png`.

Não validados: luta com o novo corpo, hitboxes, câmera, leitura em telas pequenas, transições de animação em motor, duração/diversão do chefe. A prévia isolada não comprova fluidez equivalente a Blasphemous.
