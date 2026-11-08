# Perigos de percurso — atlas v18

`assets/animation/perigos.png`, RGBA1536×1024, grade6×4 de256px. Escala visual de alvenaria gótica; dimensões de colisão precisam ser definidas pelo integrador, nunca inferidas das partículas transparentes.

| Quadros | Conteúdo |
|---|---|
|0|Base de espinhos recolhidos|
|1–5|Cinco estágios de espinhos saindo|
|6|Plataforma de pedra parada|
|7–9|Três variações de tremor|
|10–11|Duas posições de queda/inclinação|
|12–17|Plataforma com correntes em seis posições de balanço|
|18–23|Pilar fraturando, inclinando e desabando|

24 quadros distintos passaram pelo verificador original em fixture isolada. A prévia usa10fps para comparar as poses; não determina os tempos do perigo. Espinhos precisam de aviso antes de causar dano e condição segura entre ciclos. Tremor deve ter alternativa acessível e não substituir o aviso; não alterar colisão sólida a cada irregularidade da arte. Correntes de plataforma móvel não fazem parte automática da superfície pisável. Pilar desabado termina em estado final ou remove o objeto; não reinicia no quadro18 sem uma regra jogável.

Nenhum espinho ou plataforma móvel novo foi criado na fase. Falta testar tempo de reação, quedas possíveis, pontos de retorno, colisão, registro do piso e convivência com inimigos. [Prévia de atlas](imagens/v18-atlas.png). O corpo de uma plataforma se desloca dentro de algumas células: definir âncora por tipo antes de integrar.
