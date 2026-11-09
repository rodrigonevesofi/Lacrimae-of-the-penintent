# Guardião dos Sinos — primeira sonda com atraso de reação

O chefe não havia sido medido por esta sonda antes desta entrega. A gravação do autor e a estimativa de duração relatada pelo Claude não são uma medição equivalente. Base v17 recebida:450HP, duas fases, arena Cidade x3800–4780. Nenhum valor do jogo foi alterado. Subclasses de teste só observam ataques e dano e chamam os métodos originais.

Dez sementes1700–1709;100HP, espada básica, três frascos, sem penitência/salto duplo/execução. Reação programada180–260ms a novo estado de preparação,10% de erro Bernoulli por oportunidade; não significa10% de dano obrigatório. Animação, recarga e invulnerabilidade podem impedir ou atrasar a esquiva. Ataca a cada0,50–0,85s quando livre e próximo; abaixo de40HP recua e tenta curar. Não prevê trajetórias nem planeja saltos. Limite120s por tentativa; sem renascer na mesma semente.

| Semente | Tempo s | Dano acumulado | Mortes | Curas | HP chefe final | Resultado |
|---|---:|---:|---:|---:|---:|---|
| 1700 | 50.30 | 222.0 | 0 | 3 | 0.0 | venceu |
| 1701 | 50.78 | 234.0 | 0 | 3 | 0.0 | venceu |
| 1702 | 51.67 | 232.0 | 0 | 3 | -6.0 | venceu |
| 1703 | 47.23 | 235.0 | 1 | 3 | 66.0 | morte |
| 1704 | 50.75 | 217.0 | 0 | 3 | 0.0 | venceu |
| 1705 | 49.45 | 235.0 | 1 | 3 | 78.0 | morte |
| 1706 | 44.00 | 235.0 | 1 | 3 | 204.0 | morte |
| 1707 | 48.30 | 212.0 | 0 | 3 | 0.0 | venceu |
| 1708 | 41.98 | 235.0 | 1 | 3 | 276.0 | morte |
| 1709 | 52.03 | 218.0 | 0 | 3 | 0.0 | venceu |

## Acertos que retiraram HP, por ataque e fase de emissão

| Semente | Fase | Pancada | Onda | Chuva | Espinhos | Não atribuído | Dano | Tempo na fase s |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| 1700 | 1 | 0 | 0 | 2 | 2 | 2 | 91.0 | 25.13 |
| 1700 | 2 | 1 | 2 | 1 | 0 | 1 | 90.0 | 15.23 |
| 1700 | 3 | 0 | 0 | 1 | 1 | 1 | 41.0 | 9.93 |
| 1701 | 1 | 1 | 2 | 0 | 0 | 7 | 148.0 | 27.45 |
| 1701 | 2 | 0 | 1 | 0 | 2 | 0 | 52.0 | 11.83 |
| 1701 | 3 | 0 | 1 | 0 | 0 | 1 | 34.0 | 11.50 |
| 1702 | 1 | 2 | 0 | 0 | 3 | 4 | 151.0 | 29.67 |
| 1702 | 2 | 0 | 0 | 0 | 0 | 3 | 36.0 | 11.33 |
| 1702 | 3 | 0 | 0 | 0 | 0 | 3 | 45.0 | 10.67 |
| 1703 | 1 | 2 | 0 | 1 | 2 | 5 | 174.0 | 27.48 |
| 1703 | 2 | 0 | 0 | 1 | 0 | 2 | 41.0 | 11.20 |
| 1703 | 3 | 0 | 0 | 1 | 0 | 1 | 20.0 | 8.55 |
| 1704 | 1 | 1 | 0 | 2 | 1 | 3 | 117.0 | 26.78 |
| 1704 | 2 | 0 | 0 | 2 | 1 | 0 | 46.0 | 12.62 |
| 1704 | 3 | 0 | 0 | 0 | 1 | 3 | 54.0 | 11.35 |
| 1705 | 1 | 2 | 0 | 1 | 2 | 3 | 147.0 | 27.47 |
| 1705 | 2 | 1 | 0 | 0 | 1 | 1 | 53.0 | 13.70 |
| 1705 | 3 | 0 | 0 | 1 | 0 | 2 | 35.0 | 8.28 |
| 1706 | 1 | 3 | 0 | 0 | 1 | 5 | 159.0 | 27.78 |
| 1706 | 2 | 1 | 0 | 1 | 1 | 1 | 67.0 | 11.58 |
| 1706 | 3 | 0 | 1 | 0 | 0 | 0 | 9.0 | 4.63 |
| 1707 | 1 | 0 | 0 | 1 | 3 | 2 | 95.0 | 23.07 |
| 1707 | 2 | 0 | 0 | 0 | 0 | 2 | 27.0 | 12.72 |
| 1707 | 3 | 1 | 0 | 2 | 2 | 0 | 90.0 | 12.52 |
| 1708 | 1 | 1 | 1 | 1 | 1 | 5 | 137.0 | 26.85 |
| 1708 | 2 | 0 | 1 | 3 | 1 | 0 | 76.0 | 12.73 |
| 1708 | 3 | 0 | 0 | 1 | 0 | 1 | 22.0 | 2.40 |
| 1709 | 1 | 1 | 0 | 1 | 3 | 0 | 94.0 | 26.35 |
| 1709 | 2 | 0 | 0 | 0 | 1 | 2 | 36.0 | 13.18 |
| 1709 | 3 | 2 | 0 | 0 | 0 | 3 | 88.0 | 12.50 |

Projéteis e espinhos recebem metadados somente na subclasse observadora, indicando a fase em que foram criados; uma onda antiga não muda de fase só por atingir depois da transição. A pancada direta usa a fase corrente. A contagem registra perda real de HP, incluindo dano depois curado; ataques recusados pela invulnerabilidade não contam. Emissões e oportunidades/erros estão no JSON. Fase não alcançada não significa fase segura.

Esta é simulação de política simples, não um jogador humano. Tempo rápido pode vir de política agressiva; limite pode vir de navegação ruim. Não demonstra diversão, dificuldade ideal, impacto, fluidez nem equivalência a Blasphemous. O Claude deve comparar com a reconstrução futura usando esta mesma base de teste, sem tratar resultados como meta automática de90–120s. É necessário jogar, ouvir e recolher relatos.

Repetir: `XDG_DATA_HOME=/tmp/lacrimae-boss-v17/data XDG_CONFIG_HOME=/tmp/lacrimae-boss-v17/config XDG_CACHE_HOME=/tmp/lacrimae-boss-v17/cache godot --headless --fixed-fps 60 --path . --script res://tests/balance_probe_boss.gd`.
