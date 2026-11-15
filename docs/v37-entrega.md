# Entrega v37 — o Vale dos Flagelados e o chefe final

**Base:** a "versão 36" do Codex (execuções repintadas com mais sangue, manchas de chão e parede, jato arterial, pedaços, oito folhas de reação das criaturas, tabela de quadros do combate). Fundida com o trabalho do Claude sobre a v35. Suíte inteira no Godot 4.6.3: 0 falhas.

Roteiro: [roteiro-vale-dos-flagelados.md](roteiro-vale-dos-flagelados.md).

## O que entrou
- **Vale dos Flagelados** ("onde a culpa permanece"): a décima primeira sala, além dos portões. **Desenhado e animado por código**, sem pintura parada: céu de crepúsculo, sol, nuvens, desfiladeiros em três camadas com paralaxe, névoa, forcas, enforcados e gaiolas que balançam ao vento e **reagem aos golpes**, árvores mortas, corvos e cinzas. O vale **muda com a luta**: a cada placa que o chefe perde, o céu escurece e o vento aumenta. Ambiência própria (`amb_vale.wav`).
- **Chefe final, O Penitente** (`penitent_boss.gd`):
  - **Reflexo:** tem a forma do protagonista; não perde vida; 35% de cada golpe **volta para quem bateu** (nunca mata sozinho) e deixa cair uma **gota de culpa**.
  - **Aparo** no momento certo, ou a **oração dele** depois de recolher três gotas, arrancam a **forma verdadeira** por 30 s: frágil, protegido por até quatro flagelantes de capirote que ele chama.
  - A armadura cai em **quatro partes** (a desculpa, o esquecimento, o castigo e a queda). Na segunda, **Beatriz atravessa o vale**. Na quarta ele cai de joelhos e **não morre**.
  - A culpa pinga sozinha de tempos em tempos: quem nunca bate no reflexo não fica preso.
- **Beatriz fica na beira do vale** no começo ("Ninguém atravessa a culpa de outro") e só entra quando cai a segunda placa.
- **A revelação** (`vale_finale.gd`): cena dentro do mundo, 44 s, pode ser pulada depois de 3 s. Beatriz tira o capacete; o rosto é o do Penitente. É a única vez em que o rosto aparece.
- **Vida do cenário nas outras salas** (`ambient_life.gd`): correntes com sinos e lamparinas, estandartes ao vento, feixes de luz, poeira, cinzas, névoa rasteira, gotas e corvos, com o que está pendurado reagindo a pancadas fortes. É discreto: entre 0,5% e 1% da tela muda a cada instante.
- **Sons de gore do Argon** (20 arquivos) ligados: jato de sangue, carne, osso, respingo no chão, lâmina saindo, corpos caindo, impacto da execução.
- **Modo dev (F3):** escolher o Vale entra pela entrada do jogo, com a luta armada.

## Testes
`vale_boss_smoke` (30 verificações: descida, reflexo, gotas, aparo, oração, placas, Beatriz, queda, revelação, câmera devolvida). Testes ajustados porque o mundo mudou: `ritual_smoke` (dois chefes), `exploration_smoke` (onze lugares), `expansion_smoke` (o Vale é desenhado ao vivo e alcançado só pela descida). `story_decisions_check` passou a permitir o rosto apenas na revelação.

## Limites
- **A arte do chefe é provisória:** a forma verdadeira usa as folhas do Penitente feitas pelo Argon; a armadura caindo é mostrada por cor, placas de código e texto. A arte definitiva está pedida em `prompts-codex-v37.md`.
- **O Vale é silhueta desenhada por código**, um estilo diferente das salas pintadas. As camadas pintadas estão pedidas ao Codex.
- **Ninguém jogou a luta.** Os números (35% de reflexo, 30 s vulnerável, três gotas) são pontos de partida, sem medição com jogador.
- O Codex não produziu a mutilação pedida nas execuções: manteve corpos inteiros com sangue estilizado.
