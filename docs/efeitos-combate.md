# Efeitos de combate — atlas v18

`assets/animation/efeitos_combate.png`: RGBA1536×1024, seis colunas e quatro linhas de256px, leitura da esquerda para a direita.

| Quadros | Efeito | Sugestão inicial |
|---|---|---|
|0–5|Faíscas de espada, ignição/expansão/dispersão|12fps, uma passagem|
|6–11|Respingo de sangue escuro, expansão e queda|12fps, uma passagem|
|12–17|Aparo: clarão e anel dourado abrindo e apagando|12fps, uma passagem|
|18–23|Poeira de aterrissagem, expansão e dissipação|12fps, uma passagem|

24 imagens distintas e não vazias, com canal alfa real. Não foi ligado ao combate nem foi criado aparo no jogador. O último quadro retém partículas: na integração, retirar o nó após a animação. Não repetir automaticamente faísca, sangue ou aparo em loop durante uma ação. Verificar origem de contato, direção, escala, sobreposição e modo de redução de pulsos antes de liberar.

O verificador original é executado em fixture temporária por `python3 tests/v18_art_check.py`, sem alterar `clips.json`. Ele aprova conteúdo não vazio, diferença entre quadros e transparência do canto; não prova ausência de cintilação, bom timing ou impacto. A prévia animada usa12fps; comparar com os instantes reais de colisão ainda é tarefa de integração. [Prévia](imagens/v18-atlas.png).
