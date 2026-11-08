# Bestiário inspirado em Goya (v12)

Cinco criaturas novas, cada uma com uma regra de combate própria, mais um sistema de encontros em grupo. As referências são as Pinturas Negras e as séries gráficas de Francisco de Goya. Nenhuma imagem dele é copiada: o que se aproveita é a ideia de cada obra.

| Criatura | Obra que inspira | Regra de combate | Como vencer | Onde |
| --- | --- | --- | --- | --- |
| O Devorador | Saturno devorando um filho | Grande e lento. Fica blindado durante a preparação e o bote. O bote agarra, causa 30 de dano, soma culpa e cura 18 de vida dele | Esquivar do bote e golpear na recuperação longa (1,5 s), que abre a execução | Campanário, Nave, Pátio |
| Flagelante | Procissão de disciplinantes | Mantém distância, prepara e investe em linha reta. De perto, usa o chicote | Fazê-lo errar: a investida termina contra parede ou borda e o deixa atordoado | Claustro (2), Abrigo |
| Bruxa do Aquelarre | O Aquelarre | Atira três lágrimas em leque. Três irmãs partilham um voto: cada irmã viva absorve 40% do golpe | Matar uma de cada vez. A morte de uma enfurece as outras por 8 s | Arquivo (3) |
| Asmodeia | Asmodeia | Paira acima e solta três estilhaços que caem a -120, 0 e +120 do alvo, com linhas de aviso | Sair da vertical e atacar quando ela recolhe | Cisterna, Nave, Terraço |
| Duelistas | Duelo a cacetadas | Dois homens lutam entre si e ignoram o jogador distante. Os golpes se ferem, mas nunca se matam (piso de 40% de vida). Quem chega a 340 unidades, ou fere um deles, atrai os dois | Atacar de longe, um de cada vez, ou deixá-los se enfraquecer | Ossuário, Terraço |

Cada criatura mostra uma nota no primeiro encontro. As notas explicam a regra sem dar o plano pronto.

## Estado da arte

Os cinco atlas (criatura e execução) foram pintados pelo Codex a partir do briefing deste documento e estão ligados ao jogo em `clips.json`. Os efeitos de telegrafia (aura, fios do aquelarre, linhas de queda, rastro da investida) continuam desenhados por código. Detalhes de produção e conferência dos atlas: [arte-bestiario.md](arte-bestiario.md). A ancoragem dos pés foi conferida em jogo, ao lado do Penitente. O alinhamento fino das execuções ainda deve ser revisado jogando.

## Como trocar pela arte final

Cada criatura tem uma entrada própria em `assets/animation/clips.json`: `devorador`, `flagelante`, `bruxa`, `asmodeia` e `duelista`. Para refazer um atlas, basta trocar o PNG correspondente em `assets/animation/` ou o campo `"sheet"` dos clipes dessa entrada.

Formato de cada atlas: PNG transparente de 1536 × 1024, grade de 6 colunas × 4 linhas, personagem de perfil virado para a direita.

| Clipe | Quadros | Observação |
| --- | --- | --- |
| idle | 6 | repouso |
| walk | 6 | também usado na investida, acelerado |
| attack | 6 | quadros 0 a 3 são a preparação, 4 e 5 o golpe |
| hurt | 3 | dano |
| death | 3 | queda |
| executed | 12 | usa o atlas de execução (`execute_devotee` para figuras humanas, `execute_mourner` para as aéreas) |

Depois de trocar, rode `python3 tools/check_animation_atlases.py` (verifica quadros vazios e fundo opaco) e `tests/bestiary_smoke.gd`.

## Encontros e geometria

Os grupos são definidos em `scripts/act_one_layout.gd`, na lista `enemies()`: o sexto campo de uma linha é o número do grupo. Bruxas do mesmo grupo formam um aquelarre. Duelistas do mesmo grupo formam um par.

## Validação

`tests/bestiary_smoke.gd` (38 verificações) confere os dados de todas as criaturas e, com física real, o comportamento de cada uma: blindagem do Devorador, cura e janela de execução; investida, golpe curto e queda na borda do Flagelante; escudo e fúria do aquelarre; estilhaços da Asmodeia; duelo, piso de vida e aviso conjunto.

## O que isso não prova

O teste confirma que as regras funcionam, não que o equilíbrio está bom. Dano, vida, velocidade e quantidade de inimigos por sala foram escolhidos com bom senso e ainda não passaram por partidas reais. Ajustes de dificuldade devem vir de quem joga.

## Vida (v12)

Flagelante 70, Duelista 70, Bruxa 45 (ver o escudo do aquelarre), Asmodeia 60 e Devorador 130. Os valores foram aumentados depois que a sonda de equilíbrio mostrou as criaturas leves morrendo em dois golpes, antes de agir; veja [equilibrio.md](equilibrio.md).
