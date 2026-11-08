# Expansão de exploração do Ato I (v09)

## O que mudou

**Arte própria em cada sala.** O Arquivo e o Abrigo deixaram de repetir a arte do Claustro e do Ossuário. O Arquivo usa a galeria de vitrais com confessionários e o Abrigo usa o terraço dos portões, com sacos, barris e cestos. Nenhuma sala do Ato I compartilha o mesmo cenário.

**Três salas secretas novas**, todas com cenário original do projeto que antes não era usado:

| Local | Como chegar | O que tem |
| --- | --- | --- |
| Nave do Silêncio | Porta na prateleira alta do Arquivo; a saída leva à prateleira do Abrigo (novo circuito) | Altar, coro elevado, galeria sobre o altar-mor, 2 descobertas, 4 inimigos |
| Terraço dos Sinos | Porta na galeria mais alta do Campanário | Altar, escada até uma passarela alta, atalho de volta ao Claustro (abre por dentro), 1 descoberta, 3 inimigos |
| Pátio dos Portões Selados | Final do Terraço | Altar, os portões gravados com os relevos dos penitentes, balaustrada, 2 descobertas, 2 inimigos |

**Relevo no chão.** Catorze blocos de alvenaria (montes e degraus) quebram o piso reto das salas. Nenhum passa de um salto, e os inimigos nunca patrulham contra eles.

**Galerias e plataformas redesenhadas.** As lajes com espetos viraram galerias de pedra com mísulas, sombra e borda gasta.

**Mapa e contadores.** O mapa mostra dez lugares. O contador de vestígios passou a ser dinâmico (nove).

**Narrativa.** Cinco novos registros: bancos virados para a parede, terço de contas apagadas, corda do sino cortada, os portões selados (decreto de Edran e a frase riscada por unhas) e o decreto em cera. Cada um dá lágrimas uma única vez, exceto os portões, que apenas anunciam o Ato II.

## Números

Dez locais, quinze passagens (quatro atalhos com tranca), nove altares, nove descobertas, catorze blocos de alvenaria.

## Validação

Todos os testes `tests/*_smoke.gd` passam, incluindo o novo `tests/expansion_smoke.gd`. Ele confere a geometria (salas sem sobreposição, passagens e itens apoiados em pedra, blocos dentro do alcance do salto, nenhum inimigo dentro de alvenaria, mapa conexo) e percorre fisicamente os três ambientes novos, com salto, descida, portas, descobertas, atalho de mão dupla, salvamento e carregamento. O teste de exploração anterior foi atualizado e agora também atravessa os blocos.

## O que isso não prova

Os testes confirmam que os caminhos funcionam. Eles não provam duração, dificuldade nem que a qualidade é equivalente à de Blasphemous. Isso depende de partidas jogadas por pessoas. As salas novas reutilizam cenários já existentes no projeto; arte inédita para elas (novos fundos, inimigos temáticos) é a próxima frente.

## Capturas

`docs/imagens/expansao-*.png` mostram as salas na versão atual.
