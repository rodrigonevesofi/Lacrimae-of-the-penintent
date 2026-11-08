# Guardião dos Sinos — primeira sonda com atraso de reação

O chefe não havia sido medido por esta sonda antes desta entrega. A gravação do autor e a estimativa de duração relatada pelo Claude não são uma medição equivalente. Base v17 recebida:450HP, duas fases, arena Cidade x3800–4780. Nenhum valor do jogo foi alterado. Subclasses de teste só observam ataques e dano e chamam os métodos originais.

Dez sementes1700–1709;100HP, espada básica, três frascos, sem penitência/salto duplo/execução. Reação programada180–260ms a novo estado de preparação,10% de erro Bernoulli por oportunidade; não significa10% de dano obrigatório. Animação, recarga e invulnerabilidade podem impedir ou atrasar a esquiva. Ataca a cada0,50–0,85s quando livre e próximo; abaixo de40HP recua e tenta curar. Não prevê trajetórias nem planeja saltos. Limite120s por tentativa; sem renascer na mesma semente.

| Semente | Tempo s | Dano acumulado | Mortes | Curas | HP chefe final | Resultado |
|---|---:|---:|---:|---:|---:|---|
| 1700 | 16.53 | 92.0 | 0 | 1 | -4.0 | venceu |
| 1701 | 15.82 | 76.0 | 0 | 1 | -10.0 | venceu |
| 1702 | 17.58 | 84.0 | 0 | 1 | -10.0 | venceu |
| 1703 | 17.93 | 92.0 | 0 | 1 | -10.0 | venceu |
| 1704 | 18.53 | 88.0 | 0 | 1 | -10.0 | venceu |
| 1705 | 19.77 | 110.0 | 0 | 2 | -10.0 | venceu |
| 1706 | 18.92 | 138.0 | 0 | 2 | -10.0 | venceu |
| 1707 | 15.15 | 102.0 | 0 | 1 | -10.0 | venceu |
| 1708 | 18.47 | 106.0 | 0 | 2 | -16.0 | venceu |
| 1709 | 19.93 | 116.0 | 0 | 2 | -10.0 | venceu |

## Acertos que retiraram HP, por ataque e fase de emissão

| Semente | Fase | Pancada | Onda | Chuva | Espinhos | Não atribuído | Dano | Tempo na fase s |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| 1700 | 1 | 1 | 0 | 0 | 0 | 0 | 26.0 | 7.95 |
| 1700 | 2 | 2 | 0 | 1 | 0 | 0 | 66.0 | 8.58 |
| 1701 | 1 | 1 | 0 | 0 | 1 | 0 | 44.0 | 8.45 |
| 1701 | 2 | 0 | 0 | 1 | 1 | 0 | 32.0 | 7.37 |
| 1702 | 1 | 1 | 0 | 1 | 0 | 0 | 40.0 | 9.32 |
| 1702 | 2 | 1 | 0 | 0 | 1 | 0 | 44.0 | 8.27 |
| 1703 | 1 | 1 | 0 | 0 | 1 | 0 | 44.0 | 8.82 |
| 1703 | 2 | 0 | 1 | 1 | 1 | 0 | 48.0 | 9.12 |
| 1704 | 1 | 0 | 0 | 1 | 1 | 0 | 32.0 | 8.68 |
| 1704 | 2 | 1 | 1 | 1 | 0 | 0 | 56.0 | 9.85 |
| 1705 | 1 | 2 | 0 | 0 | 0 | 0 | 52.0 | 10.53 |
| 1705 | 2 | 1 | 0 | 1 | 1 | 0 | 58.0 | 9.23 |
| 1706 | 1 | 1 | 0 | 2 | 1 | 0 | 72.0 | 9.50 |
| 1706 | 2 | 2 | 0 | 1 | 0 | 0 | 66.0 | 9.42 |
| 1707 | 1 | 1 | 0 | 0 | 1 | 0 | 44.0 | 7.65 |
| 1707 | 2 | 1 | 0 | 1 | 1 | 0 | 58.0 | 7.50 |
| 1708 | 1 | 2 | 0 | 1 | 0 | 0 | 66.0 | 10.08 |
| 1708 | 2 | 1 | 0 | 1 | 0 | 0 | 40.0 | 8.38 |
| 1709 | 1 | 1 | 0 | 0 | 1 | 0 | 44.0 | 9.43 |
| 1709 | 2 | 1 | 0 | 2 | 1 | 0 | 72.0 | 10.50 |

Projéteis e espinhos recebem metadados somente na subclasse observadora, indicando a fase em que foram criados; uma onda antiga não muda de fase só por atingir depois da transição. A pancada direta usa a fase corrente. A contagem registra perda real de HP, incluindo dano depois curado; ataques recusados pela invulnerabilidade não contam. Emissões e oportunidades/erros estão no JSON. Fase não alcançada não significa fase segura.

Esta é simulação de política simples, não um jogador humano. Tempo rápido pode vir de política agressiva; limite pode vir de navegação ruim. Não demonstra diversão, dificuldade ideal, impacto, fluidez nem equivalência a Blasphemous. O Claude deve comparar com a reconstrução futura usando esta mesma base de teste, sem tratar resultados como meta automática de90–120s. É necessário jogar, ouvir e recolher relatos.

Repetir: `XDG_DATA_HOME=/tmp/lacrimae-boss-v17/data XDG_CONFIG_HOME=/tmp/lacrimae-boss-v17/config XDG_CACHE_HOME=/tmp/lacrimae-boss-v17/cache godot --headless --fixed-fps 60 --path . --script res://tests/balance_probe_boss.gd`.

## Resultado observado nesta base

As dez sementes venceram. Tempo entre15.15 e19.93s, média17.86s; dano recebido médio100.4, contando o que foi curado. Isso sustenta a necessidade de revisar o chefe: o resultado rápido não é aprovação de ritmo ou dificuldade. A próxima integração deve repetir a sonda e comparar as fases e os tipos de acerto, além de playtest humano.
