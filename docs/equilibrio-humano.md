# Sonda com atraso de reação

Simulação, não substitui jogadores nem comprova equilíbrio.60encontros: cinco cenários pedidos de Layout.enemies() e um controle adicional da Asmodeia para observar estilhaços, dez sementes(1000–1009) cada. IA, posições, grupos, colisões, dano e curas originais.100HP, espada básica, três frascos; sem penitências, execução ou salto duplo. Ataques espaçados aleatoriamente0,50–0,85s; reação programada180–260ms após nova preparação visível, erro Bernoulli10%. Travamento de animação e disponibilidade da esquiva podem atrasar ou impedir o comando; a faixa programada não garante o instante de evasão. Abaixo de40HP recua e tenta curar. Salta por alvos altos e obstáculos; não planeja caminhos. Limite60s.

O par de Flagelantes está nas posições originais do Claustro, separadas1680unidades: encontro sequencial, não dupla simultânea inventada. O Devorador usa sua galeria do Campanário; jogador160unidades à esquerda, dentro da plataforma. Os demais começam260unidades à esquerda do primeiro alvo. Aquelarre e duelistas preservam os grupos da lista. Outros inimigos são removidos para isolar cada encontro; isso difere de uma partida completa.

Dano recebido é cumulativo, incluindo o que foi depois curado. Contagens de acerto observam quedas reais deHP em take_hit: projéteis por gravidade/tipo de dano e corpo a corpo por origem/estado. Acertos bloqueados por invulnerabilidade não contam. Eventos simultâneos podem ter atribuição ambígua; não há alteração do código de combate. Queda fora da sala conta como morte, sem inventar dano.

| Encontro | Semente | Tempo s | Dano | Mortes | Bote | Investida | Estilhaços | Leque | Outros | Curas | Resultado |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---|
| aquelarre | 1000 | 60.00 | 220.0 | 0 | 0 | 0 | 0 | 20 | 0 | 3 | limite |
| aquelarre | 1001 | 60.00 | 198.0 | 0 | 0 | 0 | 0 | 18 | 0 | 3 | limite |
| aquelarre | 1002 | 60.00 | 209.0 | 0 | 0 | 0 | 0 | 19 | 0 | 3 | limite |
| aquelarre | 1003 | 60.00 | 209.0 | 0 | 0 | 0 | 0 | 19 | 0 | 3 | limite |
| aquelarre | 1004 | 60.00 | 198.0 | 0 | 0 | 0 | 0 | 18 | 0 | 3 | limite |
| aquelarre | 1005 | 60.00 | 198.0 | 0 | 0 | 0 | 0 | 18 | 0 | 3 | limite |
| aquelarre | 1006 | 54.68 | 235.0 | 1 | 0 | 0 | 0 | 22 | 0 | 3 | morte |
| aquelarre | 1007 | 60.00 | 231.0 | 0 | 0 | 0 | 0 | 21 | 0 | 3 | limite |
| aquelarre | 1008 | 60.00 | 176.0 | 0 | 0 | 0 | 0 | 16 | 0 | 3 | limite |
| aquelarre | 1009 | 60.00 | 198.0 | 0 | 0 | 0 | 0 | 18 | 0 | 3 | limite |
| duelistas | 1000 | 2.27 | 0.0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | venceu |
| duelistas | 1001 | 3.58 | 0.0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | venceu |
| duelistas | 1002 | 3.52 | 0.0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | venceu |
| duelistas | 1003 | 3.20 | 0.0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | venceu |
| duelistas | 1004 | 3.42 | 0.0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | venceu |
| duelistas | 1005 | 2.82 | 0.0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | venceu |
| duelistas | 1006 | 3.38 | 0.0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | venceu |
| duelistas | 1007 | 3.47 | 0.0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | venceu |
| duelistas | 1008 | 2.50 | 0.0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | venceu |
| duelistas | 1009 | 3.02 | 0.0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | venceu |
| flagelante_solo | 1000 | 2.57 | 0.0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | venceu |
| flagelante_solo | 1001 | 3.35 | 0.0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | venceu |
| flagelante_solo | 1002 | 3.45 | 0.0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | venceu |
| flagelante_solo | 1003 | 3.53 | 0.0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | venceu |
| flagelante_solo | 1004 | 3.33 | 0.0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | venceu |
| flagelante_solo | 1005 | 2.90 | 0.0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | venceu |
| flagelante_solo | 1006 | 3.50 | 0.0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | venceu |
| flagelante_solo | 1007 | 2.77 | 0.0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | venceu |
| flagelante_solo | 1008 | 4.90 | 0.0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | venceu |
| flagelante_solo | 1009 | 2.43 | 0.0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | venceu |
| flagelantes_claustro | 1000 | 60.00 | 0.0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | limite |
| flagelantes_claustro | 1001 | 60.00 | 0.0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | limite |
| flagelantes_claustro | 1002 | 60.00 | 0.0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | limite |
| flagelantes_claustro | 1003 | 60.00 | 0.0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | limite |
| flagelantes_claustro | 1004 | 60.00 | 0.0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | limite |
| flagelantes_claustro | 1005 | 60.00 | 0.0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | limite |
| flagelantes_claustro | 1006 | 60.00 | 0.0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | limite |
| flagelantes_claustro | 1007 | 60.00 | 0.0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | limite |
| flagelantes_claustro | 1008 | 60.00 | 0.0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | limite |
| flagelantes_claustro | 1009 | 60.00 | 0.0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | limite |
| asmodeia_controle | 1000 | 60.00 | 84.0 | 0 | 0 | 0 | 7 | 0 | 0 | 1 | limite |
| asmodeia_controle | 1001 | 60.00 | 144.0 | 0 | 0 | 0 | 12 | 0 | 0 | 2 | limite |
| asmodeia_controle | 1002 | 60.00 | 156.0 | 0 | 0 | 0 | 13 | 0 | 0 | 3 | limite |
| asmodeia_controle | 1003 | 60.00 | 156.0 | 0 | 0 | 0 | 13 | 0 | 0 | 3 | limite |
| asmodeia_controle | 1004 | 60.00 | 156.0 | 0 | 0 | 0 | 13 | 0 | 0 | 3 | limite |
| asmodeia_controle | 1005 | 60.00 | 156.0 | 0 | 0 | 0 | 13 | 0 | 0 | 3 | limite |
| asmodeia_controle | 1006 | 60.00 | 156.0 | 0 | 0 | 0 | 13 | 0 | 0 | 3 | limite |
| asmodeia_controle | 1007 | 60.00 | 120.0 | 0 | 0 | 0 | 10 | 0 | 0 | 2 | limite |
| asmodeia_controle | 1008 | 60.00 | 156.0 | 0 | 0 | 0 | 13 | 0 | 0 | 3 | limite |
| asmodeia_controle | 1009 | 60.00 | 156.0 | 0 | 0 | 0 | 13 | 0 | 0 | 3 | limite |
| devorador | 1000 | 4.70 | 0.0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | venceu |
| devorador | 1001 | 5.27 | 30.0 | 0 | 1 | 0 | 0 | 0 | 0 | 0 | venceu |
| devorador | 1002 | 4.60 | 0.0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | venceu |
| devorador | 1003 | 4.85 | 30.0 | 0 | 1 | 0 | 0 | 0 | 0 | 0 | venceu |
| devorador | 1004 | 4.33 | 0.0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | venceu |
| devorador | 1005 | 5.20 | 0.0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | venceu |
| devorador | 1006 | 5.00 | 30.0 | 0 | 1 | 0 | 0 | 0 | 0 | 0 | venceu |
| devorador | 1007 | 4.97 | 0.0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | venceu |
| devorador | 1008 | 4.60 | 30.0 | 0 | 1 | 0 | 0 | 0 | 0 | 0 | venceu |
| devorador | 1009 | 4.73 | 0.0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | venceu |

## Achados da simulação

- aquelarre: 0vitórias, 1mortes, 9limites; dano médio207.2.
- duelistas: 10vitórias, 0mortes, 0limites; dano médio0.0.
- devorador: 10vitórias, 0mortes, 0limites; dano médio12.0.
- flagelante_solo: 10vitórias, 0mortes, 0limites; dano médio0.0.
- flagelantes_claustro: 0vitórias, 0mortes, 10limites; dano médio0.0.
- asmodeia_controle: 0vitórias, 0mortes, 10limites; dano médio144.0.

Limites: navegação rudimentar pode dominar o resultado; limites de tempo não significam equilíbrio, e zero acertos não prova segurança. Asmodeia/estilhaços foram observados num sexto encontro de controle, isolando a Asmodeia da Nave em sua posição original. Dados e contagens de preparação/erros em equilibrio-humano.json.

Repetir: `XDG_DATA_HOME=/tmp/lacrimae-human-data XDG_CONFIG_HOME=/tmp/lacrimae-human-config XDG_CACHE_HOME=/tmp/lacrimae-human-cache godot --headless --fixed-fps 60 --path . --script res://tests/balance_probe_human.gd`. A sonda exige dados descartáveis e grava o relatório.
