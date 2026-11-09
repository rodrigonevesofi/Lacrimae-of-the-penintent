# Guardião dos Sinos — primeira sonda com atraso de reação

O chefe não havia sido medido por esta sonda antes desta entrega. A gravação do autor e a estimativa de duração relatada pelo Claude não são uma medição equivalente. Base v17 recebida:450HP, duas fases, arena Cidade x3800–4780. Nenhum valor do jogo foi alterado. Subclasses de teste só observam ataques e dano e chamam os métodos originais.

Dez sementes1700–1709;100HP, espada básica, três frascos, sem penitência/salto duplo/execução. Reação programada180–260ms a novo estado de preparação,10% de erro Bernoulli por oportunidade; não significa10% de dano obrigatório. Animação, recarga e invulnerabilidade podem impedir ou atrasar a esquiva. Ataca a cada0,50–0,85s quando livre e próximo; abaixo de40HP recua e tenta curar. Não prevê trajetórias nem planeja saltos. Limite120s por tentativa; sem renascer na mesma semente.

| Semente | Tempo s | Dano acumulado | Mortes | Curas | HP chefe final | Resultado |
|---|---:|---:|---:|---:|---:|---|
| 1700 | 42.07 | 174.0 | 0 | 3 | -24.0 | venceu |
| 1701 | 41.20 | 206.0 | 0 | 3 | -24.0 | venceu |
| 1702 | 42.60 | 210.0 | 0 | 3 | -24.0 | venceu |
| 1703 | 41.15 | 212.0 | 0 | 3 | -24.0 | venceu |
| 1704 | 44.22 | 218.0 | 0 | 3 | -10.0 | venceu |
| 1705 | 40.50 | 184.0 | 0 | 3 | -4.0 | venceu |
| 1706 | 40.03 | 186.0 | 0 | 3 | -10.0 | venceu |
| 1707 | 40.52 | 226.0 | 0 | 3 | -4.0 | venceu |
| 1708 | 39.12 | 235.0 | 1 | 3 | 134.0 | morte |
| 1709 | 43.63 | 220.0 | 0 | 3 | -16.0 | venceu |

## Acertos que retiraram HP, por ataque e fase de emissão

| Semente | Fase | Pancada | Onda | Chuva | Espinhos | Não atribuído | Dano | Tempo na fase s |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| 1700 | 1 | 2 | 1 | 2 | 0 | 0 | 96.0 | 21.92 |
| 1700 | 2 | 0 | 0 | 0 | 2 | 0 | 36.0 | 9.62 |
| 1700 | 3 | 1 | 1 | 0 | 0 | 0 | 42.0 | 10.53 |
| 1701 | 1 | 2 | 1 | 0 | 1 | 0 | 86.0 | 21.05 |
| 1701 | 2 | 0 | 1 | 1 | 1 | 0 | 48.0 | 10.22 |
| 1701 | 3 | 1 | 0 | 2 | 1 | 0 | 72.0 | 9.93 |
| 1702 | 1 | 2 | 0 | 0 | 2 | 0 | 88.0 | 20.78 |
| 1702 | 2 | 0 | 0 | 3 | 1 | 0 | 60.0 | 10.50 |
| 1702 | 3 | 1 | 0 | 0 | 2 | 0 | 62.0 | 11.32 |
| 1703 | 1 | 1 | 1 | 1 | 2 | 0 | 92.0 | 19.92 |
| 1703 | 2 | 0 | 0 | 0 | 2 | 0 | 36.0 | 10.37 |
| 1703 | 3 | 2 | 0 | 1 | 1 | 0 | 84.0 | 10.87 |
| 1704 | 1 | 1 | 0 | 4 | 3 | 0 | 136.0 | 23.88 |
| 1704 | 2 | 0 | 1 | 0 | 1 | 0 | 34.0 | 10.63 |
| 1704 | 3 | 0 | 1 | 1 | 1 | 0 | 48.0 | 9.70 |
| 1705 | 1 | 1 | 1 | 1 | 2 | 0 | 92.0 | 21.03 |
| 1705 | 2 | 0 | 0 | 0 | 2 | 0 | 36.0 | 9.62 |
| 1705 | 3 | 1 | 1 | 1 | 0 | 0 | 56.0 | 9.85 |
| 1706 | 1 | 2 | 0 | 0 | 2 | 0 | 88.0 | 20.70 |
| 1706 | 2 | 2 | 0 | 2 | 0 | 0 | 80.0 | 11.77 |
| 1706 | 3 | 0 | 0 | 0 | 1 | 0 | 18.0 | 7.57 |
| 1707 | 1 | 1 | 1 | 1 | 2 | 0 | 92.0 | 20.87 |
| 1707 | 2 | 1 | 0 | 0 | 2 | 0 | 62.0 | 10.58 |
| 1707 | 3 | 1 | 0 | 2 | 1 | 0 | 72.0 | 9.07 |
| 1708 | 1 | 2 | 1 | 1 | 1 | 0 | 100.0 | 20.95 |
| 1708 | 2 | 0 | 2 | 4 | 0 | 0 | 88.0 | 13.02 |
| 1708 | 3 | 0 | 1 | 1 | 1 | 0 | 47.0 | 5.15 |
| 1709 | 1 | 2 | 0 | 0 | 2 | 0 | 88.0 | 21.60 |
| 1709 | 2 | 1 | 1 | 1 | 1 | 0 | 74.0 | 11.70 |
| 1709 | 3 | 1 | 0 | 1 | 1 | 0 | 58.0 | 10.33 |

Projéteis e espinhos recebem metadados somente na subclasse observadora, indicando a fase em que foram criados; uma onda antiga não muda de fase só por atingir depois da transição. A pancada direta usa a fase corrente. A contagem registra perda real de HP, incluindo dano depois curado; ataques recusados pela invulnerabilidade não contam. Emissões e oportunidades/erros estão no JSON. Fase não alcançada não significa fase segura.

Esta é simulação de política simples, não um jogador humano. Tempo rápido pode vir de política agressiva; limite pode vir de navegação ruim. Não demonstra diversão, dificuldade ideal, impacto, fluidez nem equivalência a Blasphemous. O Claude deve comparar com a reconstrução futura usando esta mesma base de teste, sem tratar resultados como meta automática de90–120s. É necessário jogar, ouvir e recolher relatos.

Repetir: `XDG_DATA_HOME=/tmp/lacrimae-boss-v17/data XDG_CONFIG_HOME=/tmp/lacrimae-boss-v17/config XDG_CACHE_HOME=/tmp/lacrimae-boss-v17/cache godot --headless --fixed-fps 60 --path . --script res://tests/balance_probe_boss.gd`.
