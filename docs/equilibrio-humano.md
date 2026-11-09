# Sonda com atraso de reação

Simulação, não substitui jogadores nem comprova equilíbrio.60encontros: cinco cenários pedidos de Layout.enemies() e um controle adicional da Asmodeia para observar estilhaços, dez sementes(1000–1009) cada. IA, posições, grupos, colisões, dano e curas originais.100HP, espada básica, três frascos; sem penitências, execução ou salto duplo. Ataques espaçados aleatoriamente0,50–0,85s; reação programada180–260ms após nova preparação visível, erro Bernoulli10%. Travamento de animação e disponibilidade da esquiva podem atrasar ou impedir o comando; a faixa programada não garante o instante de evasão. Abaixo de40HP recua e tenta curar. Salta por alvos altos e obstáculos; não planeja caminhos. Limite60s.

O par de Flagelantes está nas posições originais do Claustro, separadas1680unidades: encontro sequencial, não dupla simultânea inventada. O Devorador usa sua galeria do Campanário; jogador160unidades à esquerda, dentro da plataforma. Os demais começam260unidades à esquerda do primeiro alvo. Aquelarre e duelistas preservam os grupos da lista. Outros inimigos são removidos para isolar cada encontro; isso difere de uma partida completa.

Dano recebido é cumulativo, incluindo o que foi depois curado. Contagens de acerto observam quedas reais deHP em take_hit: projéteis por gravidade/tipo de dano e corpo a corpo por origem/estado. Acertos bloqueados por invulnerabilidade não contam. Eventos simultâneos podem ter atribuição ambígua; não há alteração do código de combate. Queda fora da sala conta como morte, sem inventar dano.

| Encontro | Semente | Tempo s | Dano | Mortes | Bote | Investida | Estilhaços | Leque | Outros | Curas | Resultado |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---|
| aquelarre | 1000 | 60.00 | 119.0 | 0 | 0 | 0 | 0 | 17 | 0 | 2 | limite |
| aquelarre | 1001 | 53.83 | 126.0 | 0 | 0 | 0 | 0 | 18 | 0 | 2 | venceu |
| aquelarre | 1002 | 60.00 | 189.0 | 0 | 0 | 0 | 0 | 27 | 0 | 3 | limite |
| aquelarre | 1003 | 56.12 | 147.0 | 0 | 0 | 0 | 0 | 21 | 0 | 2 | venceu |
| aquelarre | 1004 | 58.48 | 147.0 | 0 | 0 | 0 | 0 | 21 | 0 | 2 | venceu |
| aquelarre | 1005 | 49.92 | 140.0 | 0 | 0 | 0 | 0 | 20 | 0 | 2 | venceu |
| aquelarre | 1006 | 60.00 | 147.0 | 0 | 0 | 0 | 0 | 21 | 0 | 2 | limite |
| aquelarre | 1007 | 59.87 | 147.0 | 0 | 0 | 0 | 0 | 21 | 0 | 2 | venceu |
| aquelarre | 1008 | 60.00 | 154.0 | 0 | 0 | 0 | 0 | 22 | 0 | 2 | limite |
| aquelarre | 1009 | 52.48 | 140.0 | 0 | 0 | 0 | 0 | 20 | 0 | 2 | venceu |
| duelistas | 1000 | 3.25 | 16.0 | 0 | 0 | 0 | 0 | 0 | 1 | 0 | venceu |
| duelistas | 1001 | 3.63 | 16.0 | 0 | 0 | 0 | 0 | 0 | 1 | 0 | venceu |
| duelistas | 1002 | 4.83 | 16.0 | 0 | 0 | 0 | 0 | 0 | 1 | 0 | venceu |
| duelistas | 1003 | 5.15 | 0.0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | venceu |
| duelistas | 1004 | 3.22 | 16.0 | 0 | 0 | 0 | 0 | 0 | 1 | 0 | venceu |
| duelistas | 1005 | 5.10 | 0.0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | venceu |
| duelistas | 1006 | 5.52 | 0.0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | venceu |
| duelistas | 1007 | 6.52 | 16.0 | 0 | 0 | 0 | 0 | 0 | 1 | 0 | venceu |
| duelistas | 1008 | 5.38 | 16.0 | 0 | 0 | 0 | 0 | 0 | 1 | 0 | venceu |
| duelistas | 1009 | 3.67 | 0.0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | venceu |
| devorador | 1000 | 6.17 | 0.0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | venceu |
| devorador | 1001 | 60.00 | 60.0 | 0 | 2 | 0 | 0 | 0 | 0 | 0 | limite |
| devorador | 1002 | 60.00 | 0.0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | limite |
| devorador | 1003 | 60.00 | 60.0 | 0 | 2 | 0 | 0 | 0 | 0 | 0 | limite |
| devorador | 1004 | 8.35 | 60.0 | 0 | 2 | 0 | 0 | 0 | 0 | 0 | venceu |
| devorador | 1005 | 60.00 | 30.0 | 0 | 1 | 0 | 0 | 0 | 0 | 0 | limite |
| devorador | 1006 | 7.18 | 0.0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | venceu |
| devorador | 1007 | 60.00 | 30.0 | 0 | 1 | 0 | 0 | 0 | 0 | 0 | limite |
| devorador | 1008 | 60.00 | 0.0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | limite |
| devorador | 1009 | 60.00 | 30.0 | 0 | 1 | 0 | 0 | 0 | 0 | 0 | limite |
| flagelante_solo | 1000 | 2.78 | 12.0 | 0 | 0 | 0 | 0 | 0 | 1 | 0 | venceu |
| flagelante_solo | 1001 | 3.28 | 0.0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | venceu |
| flagelante_solo | 1002 | 2.98 | 12.0 | 0 | 0 | 0 | 0 | 0 | 1 | 0 | venceu |
| flagelante_solo | 1003 | 3.47 | 0.0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | venceu |
| flagelante_solo | 1004 | 3.27 | 0.0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | venceu |
| flagelante_solo | 1005 | 2.93 | 12.0 | 0 | 0 | 0 | 0 | 0 | 1 | 0 | venceu |
| flagelante_solo | 1006 | 3.43 | 0.0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | venceu |
| flagelante_solo | 1007 | 2.87 | 12.0 | 0 | 0 | 0 | 0 | 0 | 1 | 0 | venceu |
| flagelante_solo | 1008 | 2.92 | 12.0 | 0 | 0 | 0 | 0 | 0 | 1 | 0 | venceu |
| flagelante_solo | 1009 | 3.10 | 12.0 | 0 | 0 | 0 | 0 | 0 | 1 | 0 | venceu |
| flagelantes_claustro | 1000 | 60.00 | 12.0 | 0 | 0 | 0 | 0 | 0 | 1 | 0 | limite |
| flagelantes_claustro | 1001 | 60.00 | 0.0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | limite |
| flagelantes_claustro | 1002 | 60.00 | 12.0 | 0 | 0 | 0 | 0 | 0 | 1 | 0 | limite |
| flagelantes_claustro | 1003 | 60.00 | 0.0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | limite |
| flagelantes_claustro | 1004 | 60.00 | 0.0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | limite |
| flagelantes_claustro | 1005 | 60.00 | 12.0 | 0 | 0 | 0 | 0 | 0 | 1 | 0 | limite |
| flagelantes_claustro | 1006 | 60.00 | 0.0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | limite |
| flagelantes_claustro | 1007 | 60.00 | 12.0 | 0 | 0 | 0 | 0 | 0 | 1 | 0 | limite |
| flagelantes_claustro | 1008 | 60.00 | 12.0 | 0 | 0 | 0 | 0 | 0 | 1 | 0 | limite |
| flagelantes_claustro | 1009 | 60.00 | 12.0 | 0 | 0 | 0 | 0 | 0 | 1 | 0 | limite |
| asmodeia_controle | 1000 | 19.65 | 48.0 | 0 | 0 | 0 | 4 | 0 | 0 | 0 | venceu |
| asmodeia_controle | 1001 | 12.53 | 36.0 | 0 | 0 | 0 | 3 | 0 | 0 | 0 | venceu |
| asmodeia_controle | 1002 | 23.30 | 60.0 | 0 | 0 | 0 | 5 | 0 | 0 | 0 | venceu |
| asmodeia_controle | 1003 | 31.77 | 72.0 | 0 | 0 | 0 | 6 | 0 | 0 | 1 | venceu |
| asmodeia_controle | 1004 | 17.00 | 48.0 | 0 | 0 | 0 | 4 | 0 | 0 | 0 | venceu |
| asmodeia_controle | 1005 | 17.55 | 36.0 | 0 | 0 | 0 | 3 | 0 | 0 | 0 | venceu |
| asmodeia_controle | 1006 | 16.85 | 36.0 | 0 | 0 | 0 | 3 | 0 | 0 | 0 | venceu |
| asmodeia_controle | 1007 | 38.12 | 108.0 | 0 | 0 | 0 | 9 | 0 | 0 | 2 | venceu |
| asmodeia_controle | 1008 | 25.13 | 60.0 | 0 | 0 | 0 | 5 | 0 | 0 | 0 | venceu |
| asmodeia_controle | 1009 | 13.32 | 36.0 | 0 | 0 | 0 | 3 | 0 | 0 | 0 | venceu |

## Achados da simulação

- aquelarre: 6vitórias, 0mortes, 4limites; dano médio145.6.
- duelistas: 10vitórias, 0mortes, 0limites; dano médio9.6.
- devorador: 3vitórias, 0mortes, 7limites; dano médio27.0.
- flagelante_solo: 10vitórias, 0mortes, 0limites; dano médio7.2.
- flagelantes_claustro: 0vitórias, 0mortes, 10limites; dano médio7.2.
- asmodeia_controle: 10vitórias, 0mortes, 0limites; dano médio54.0.

Limites: navegação rudimentar pode dominar o resultado; limites de tempo não significam equilíbrio, e zero acertos não prova segurança. Asmodeia/estilhaços foram observados num sexto encontro de controle, isolando a Asmodeia da Nave em sua posição original. Dados e contagens de preparação/erros em equilibrio-humano.json.

Repetir: `XDG_DATA_HOME=/tmp/lacrimae-human-data XDG_CONFIG_HOME=/tmp/lacrimae-human-config XDG_CACHE_HOME=/tmp/lacrimae-human-cache godot --headless --fixed-fps 60 --path . --script res://tests/balance_probe_human.gd`. A sonda exige dados descartáveis e grava o relatório.
