# Sonda de equilíbrio

Simulação simples por entradas de controle; não prova equilíbrio com pessoas.

Tipos comuns descobertos em Enemy.TYPES; chefe de id2 e entradas marcadas boss/is_boss excluídos.

100 de vida, espada básica, sem cura, penitência, execução ou salto duplo. Três sementes por tipo; limite40s por encontro. Separação inicial280unidades; a contagem começa após a aparição visual, com ambos imóveis durante essa aparição. Persegue até55unidades, ataca abaixo de90 e esquiva ao detectar preparação próxima. Salta para alvos altos. IA, colisões e dano são os do jogo; o controlador é simplificado.

Esquiva bem-sucedida aqui é uma aproximação: início da esquiva durante uma ameaça a menos de160unidades, seguido de0,6s sem perder vida. Não comprova que um golpe teria acertado sem a esquiva. A coluna tempo só é tempo para derrotar quando o resultado diz derrotado; nos demais casos é duração observada.

| Inimigo | Tipo | Semente | Tempo(s) | Dano recebido | Esquivas sem dano | Esquivas iniciadas | Resultado |
|---|---:|---:|---:|---:|---:|---:|---|
| Devoto Corrompido | 0 | 11 | 1.10 | 0.0 | 0 | 0 | derrotado |
| Devoto Corrompido | 0 | 23 | 1.10 | 0.0 | 0 | 0 | derrotado |
| Devoto Corrompido | 0 | 37 | 1.10 | 0.0 | 0 | 0 | derrotado |
| Chorão | 1 | 11 | 1.40 | 0.0 | 0 | 0 | derrotado |
| Chorão | 1 | 23 | 1.40 | 0.0 | 0 | 0 | derrotado |
| Chorão | 1 | 37 | 1.40 | 0.0 | 0 | 0 | derrotado |
| O Devorador | 3 | 11 | 5.22 | 30.0 | 1 | 2 | derrotado |
| O Devorador | 3 | 23 | 5.22 | 30.0 | 1 | 2 | derrotado |
| O Devorador | 3 | 37 | 5.22 | 30.0 | 1 | 2 | derrotado |
| Flagelante | 4 | 11 | 1.68 | 0.0 | 0 | 0 | derrotado |
| Flagelante | 4 | 23 | 2.10 | 0.0 | 0 | 0 | derrotado |
| Flagelante | 4 | 37 | 2.10 | 0.0 | 0 | 0 | derrotado |
| Bruxa do Aquelarre | 5 | 11 | 1.40 | 0.0 | 0 | 0 | derrotado |
| Bruxa do Aquelarre | 5 | 23 | 1.40 | 0.0 | 0 | 0 | derrotado |
| Bruxa do Aquelarre | 5 | 37 | 1.40 | 0.0 | 0 | 0 | derrotado |
| Asmodeia | 6 | 11 | 1.78 | 0.0 | 0 | 0 | derrotado |
| Asmodeia | 6 | 23 | 1.78 | 0.0 | 0 | 0 | derrotado |
| Asmodeia | 6 | 37 | 1.78 | 0.0 | 0 | 0 | derrotado |
| Duelista | 7 | 11 | 1.53 | 0.0 | 0 | 0 | derrotado |
| Duelista | 7 | 23 | 1.95 | 0.0 | 0 | 0 | derrotado |
| Duelista | 7 | 37 | 1.95 | 0.0 | 0 | 0 | derrotado |

Nesta rodada o controlador venceu antes de iniciar esquivas. Os zeros não demonstram que esquivar seja desnecessário em outros encontros. As sementes não produziram variação observável neste cenário simples.

Para repetir em Linux com salvamento isolado:

```sh
XDG_DATA_HOME=/tmp/lacrimae-balance-data XDG_CONFIG_HOME=/tmp/lacrimae-balance-config XDG_CACHE_HOME=/tmp/lacrimae-balance-cache godot --headless --fixed-fps 60 --path . --script res://tests/balance_probe.gd
```

A sonda grava apenas este relatório e o salvamento descartável do ambiente isolado. Para a v11, rodar novamente e revisar a descoberta de TYPES se a API tiver outro formato. Variação de tempo de reação, alcances, plataformas, grupos de inimigos e leitura humana não foram avaliados.

## Leitura da rodada com o bestiário completo (v12)

- A espada causa 20 ou 26 por golpe. Quem tem 46 de vida ou menos morre em dois golpes. Isso valia para o Devoto (45) e o Chorão (30) originais, e valia também para as criaturas novas, que morriam em cerca de 1,3 s, antes de preparar qualquer ataque.
- Por isso a vida das quatro criaturas leves foi aumentada: Flagelante 38 → 70, Duelista 42 → 70, Bruxa 28 → 45 (depois 40 na v13) e Asmodeia 34 → 60. O Devorador (130) já exigia seis golpes e foi o único a acertar o Penitente na primeira rodada (30 de dano, uma esquiva sem dano de duas tentativas).
- **Esta sonda não valida os mecanismos novos.** O controlador ataca sem parar e as criaturas só começam a agir depois de cerca de um segundo de espera; mesmo com a vida maior, as quatro morrem em 1,5 a 1,8 s, sem causar dano. Ela mede a tenacidade, não o perigo. Para julgar a investida do Flagelante, o escudo do aquelarre, os estilhaços da Asmodeia e o duelo, é preciso jogar.
- O aumento de vida é uma decisão de projeto baseada nesta evidência, não um valor calibrado com jogadores. Se as salas ficarem demoradas ou duras, ajuste o campo `hp` de `Enemy.TYPES` em `scripts/enemy.gd`.
