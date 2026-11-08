# Sonda de equilíbrio

Simulação simples por entradas de controle; não prova equilíbrio com pessoas.

Base sem Enemy.TYPES: medidos somente Devoto e Chorão. Os cinco inimigos do Claude ainda não estão disponíveis; nenhuma conclusão sobre seu equilíbrio.

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

Nesta rodada o controlador venceu antes de iniciar esquivas. Os zeros não demonstram que esquivar seja desnecessário em outros encontros. As sementes não produziram variação observável neste cenário simples.

Para repetir em Linux com salvamento isolado:

```sh
XDG_DATA_HOME=/tmp/lacrimae-balance-data XDG_CONFIG_HOME=/tmp/lacrimae-balance-config XDG_CACHE_HOME=/tmp/lacrimae-balance-cache godot --headless --fixed-fps 60 --path . --script res://tests/balance_probe.gd
```

A sonda grava apenas este relatório e o salvamento descartável do ambiente isolado. Para a v11, rodar novamente e revisar a descoberta de TYPES se a API tiver outro formato. Variação de tempo de reação, alcances, plataformas, grupos de inimigos e leitura humana não foram avaliados.
