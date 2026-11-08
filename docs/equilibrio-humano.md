# Sonda com atraso de reação

Simulação, não substitui jogadores nem comprova equilíbrio.60encontros: cinco cenários pedidos de Layout.enemies() e um controle adicional da Asmodeia para observar estilhaços, dez sementes(1000–1009) cada. IA, posições, grupos, colisões, dano e curas originais.100HP, espada básica, três frascos; sem penitências, execução ou salto duplo. Ataques espaçados aleatoriamente0,50–0,85s; reação programada180–260ms após nova preparação visível, erro Bernoulli10%. Travamento de animação e disponibilidade da esquiva podem atrasar ou impedir o comando; a faixa programada não garante o instante de evasão. Abaixo de40HP recua e tenta curar. Salta por alvos altos e obstáculos; não planeja caminhos. Limite60s.

O par de Flagelantes está nas posições originais do Claustro, separadas1680unidades: encontro sequencial, não dupla simultânea inventada. O Devorador usa sua galeria do Campanário; jogador160unidades à esquerda, dentro da plataforma. Os demais começam260unidades à esquerda do primeiro alvo. Aquelarre e duelistas preservam os grupos da lista. Outros inimigos são removidos para isolar cada encontro; isso difere de uma partida completa.

Dano recebido é cumulativo, incluindo o que foi depois curado. Contagens de acerto observam quedas reais deHP em take_hit: projéteis por gravidade/tipo de dano e corpo a corpo por origem/estado. Acertos bloqueados por invulnerabilidade não contam. Eventos simultâneos podem ter atribuição ambígua; não há alteração do código de combate. Queda fora da sala conta como morte, sem inventar dano.

| Encontro | Semente | Tempo s | Dano | Mortes | Bote | Investida | Estilhaços | Leque | Outros | Curas | Resultado |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---|
| aquelarre | 1000 | 37.60 | 77.0 | 0 | 0 | 0 | 0 | 0 | 11 | 1 | venceu |
| aquelarre | 1001 | 38.33 | 77.0 | 0 | 0 | 0 | 0 | 0 | 11 | 1 | venceu |
| aquelarre | 1002 | 53.70 | 112.0 | 0 | 0 | 0 | 0 | 0 | 16 | 2 | venceu |
| aquelarre | 1003 | 51.95 | 133.0 | 0 | 0 | 0 | 0 | 0 | 19 | 2 | venceu |
| aquelarre | 1004 | 26.78 | 49.0 | 0 | 0 | 0 | 0 | 0 | 7 | 0 | venceu |
| aquelarre | 1005 | 41.03 | 84.0 | 0 | 0 | 0 | 0 | 0 | 12 | 1 | venceu |
| aquelarre | 1006 | 51.18 | 105.0 | 0 | 0 | 0 | 0 | 0 | 15 | 1 | venceu |
| aquelarre | 1007 | 60.00 | 140.0 | 0 | 0 | 0 | 0 | 0 | 20 | 2 | limite |
| aquelarre | 1008 | 53.63 | 133.0 | 0 | 0 | 0 | 0 | 0 | 19 | 2 | venceu |
| aquelarre | 1009 | 60.00 | 105.0 | 0 | 0 | 0 | 0 | 0 | 15 | 1 | limite |
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
| flagelante_solo | 1000 | 1.95 | 0.0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | venceu |
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
| asmodeia_controle | 1000 | 13.78 | 36.0 | 0 | 0 | 0 | 3 | 0 | 0 | 0 | venceu |
| asmodeia_controle | 1001 | 13.80 | 36.0 | 0 | 0 | 0 | 3 | 0 | 0 | 0 | venceu |
| asmodeia_controle | 1002 | 23.77 | 60.0 | 0 | 0 | 0 | 5 | 0 | 0 | 0 | venceu |
| asmodeia_controle | 1003 | 16.70 | 36.0 | 0 | 0 | 0 | 3 | 0 | 0 | 0 | venceu |
| asmodeia_controle | 1004 | 18.00 | 48.0 | 0 | 0 | 0 | 4 | 0 | 0 | 0 | venceu |
| asmodeia_controle | 1005 | 13.78 | 24.0 | 0 | 0 | 0 | 2 | 0 | 0 | 0 | venceu |
| asmodeia_controle | 1006 | 13.82 | 24.0 | 0 | 0 | 0 | 2 | 0 | 0 | 0 | venceu |
| asmodeia_controle | 1007 | 30.97 | 84.0 | 0 | 0 | 0 | 7 | 0 | 0 | 1 | venceu |
| asmodeia_controle | 1008 | 18.78 | 48.0 | 0 | 0 | 0 | 4 | 0 | 0 | 0 | venceu |
| asmodeia_controle | 1009 | 10.95 | 24.0 | 0 | 0 | 0 | 2 | 0 | 0 | 0 | venceu |

## Achados da simulação

- aquelarre: 8vitórias, 0mortes, 2limites; dano médio101.5.
- duelistas: 10vitórias, 0mortes, 0limites; dano médio0.0.
- devorador: 10vitórias, 0mortes, 0limites; dano médio12.0.
- flagelante_solo: 10vitórias, 0mortes, 0limites; dano médio0.0.
- flagelantes_claustro: 0vitórias, 0mortes, 10limites; dano médio0.0.
- asmodeia_controle: 10vitórias, 0mortes, 0limites; dano médio42.0.

Limites: navegação rudimentar pode dominar o resultado; limites de tempo não significam equilíbrio, e zero acertos não prova segurança. Asmodeia/estilhaços foram observados num sexto encontro de controle, isolando a Asmodeia da Nave em sua posição original. Dados e contagens de preparação/erros em equilibrio-humano.json.

Repetir: `XDG_DATA_HOME=/tmp/lacrimae-human-data XDG_CONFIG_HOME=/tmp/lacrimae-human-config XDG_CACHE_HOME=/tmp/lacrimae-human-cache godot --headless --fixed-fps 60 --path . --script res://tests/balance_probe_human.gd`. A sonda exige dados descartáveis e grava o relatório.

## Leitura e ajustes (v13)

- **Aquelarre.** Na primeira rodada, 0 vitórias em 10 e 207 de dano médio. Duas causas: eu havia posto as bruxas a 190 unidades do chão, fora do alcance da espada em pé, e três bruxas atirando um leque de 11 de dano a cada 2,9 s formavam uma verificação de dano contínua. Ajustes: bruxas a 75–90 unidades do chão, leque de 7 de dano a cada 4,2 s, escudo mútuo de 30% por irmã e 40 de vida. Resultado seguinte: 8 vitórias em 10, 0 mortes, 102 de dano médio (com as três curas disponíveis). Um encontro vencível e exigente, para este controlador.
- **Asmodeia.** Pairava a 340 unidades do chão e nenhuma tentativa a derrotou (151 de dano médio). Ajustada a 120 unidades: 10 vitórias em 10 e 42 de dano médio.
- **Devorador.** 10 vitórias, 12 de dano médio. O controlador esquiva o bote com facilidade; é provável que um jogador humano sofra mais.
- **Duelistas e Flagelante solo.** 10 vitórias sem dano. O controlador mata antes de a mecânica acontecer, e a sonda não prova que o Flagelante seja inofensivo.
- **Flagelantes do Claustro.** Os 10 resultados são limites de tempo com 0 dano: falha de navegação do controlador, já declarada acima. Não são dados de equilíbrio.
- Os valores acima são ajustes de projeto feitos contra uma simulação. Não substituem a opinião de quem joga.
