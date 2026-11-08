# Arte das novas criaturas

Dez PNGs em `assets/animation/`: `devorador`, `flagelante`, `bruxa`, `asmodeia`, `duelista` e suas versões `_executado`.

Cada atlas tem 1536×1024 pixels RGBA e grade 6×4. Nos principais: repouso0–5, movimento6–11, ataque12–17 (quatro poses de preparação), dano18–20, queda21–23. Nas execuções: vítima12–23; metade superior sem desenho visível. Os arquivos gerados podem conter resíduos de alfa de até2/255 nos espaços vazios, inclusive cantos; não são alfa estritamente zero. A galeria descarta esses resíduos no desenho. A ancoragem e o alinhamento fino com o protagonista ainda precisam de revisão na implementação das criaturas.

A Asmodeia usa máscara clara e manto amplo com forro vermelho; a Bruxa mantém cabelos e xale rasgado. Devorador, Flagelante e Duelista têm anatomias e armas diferentes. As cores seguem os ocres, negros e vermelhos opacos do briefing, com inspiração nas Pinturas Negras sem reproduzir obras.

## Conferência

- `python3 tools/check_animation_atlases.py --bestiary`: inclui os novos arquivos na verificação, sem alterar `clips.json`. Conferidos arquivos, quadros não vazios e distintos, e transparência dos cantos com tolerância do verificador existente.
- Galeria Godot: `godot --path . --script res://tools/preview_bestiary.gd`. Reproduz os seis grupos de poses e salva capturas em `docs/imagens/bestiario-*.png`.
- [Repouso](imagens/bestiario-repouso.png), [ataque](imagens/bestiario-ataque.png), [execução](imagens/bestiario-execucao.png).
- Fundos disponíveis: Claustro (referência usada pelo Arquivo da versão05), exterior da Cidade, Basílica e Ossuário. O Terraço da versão do Claude não está nesta cópia.

## Integração com a versão do Claude

A consulta ao GitHub encontrou somente `main`, commit `9ff0921`, sem `docs/bestiario-goya.md`, `tests/bestiary_smoke.gd` ou as cinco entradas de criaturas em `clips.json`. Portanto esta entrega acrescenta arte e uma galeria de revisão; os encontros da campanha ainda não usam os novos desenhos. Não substitui a implementação do Claude.

Quando essa base estiver disponível, alterar somente `sheet` nas entradas das cinco criaturas: clipes comuns usam o nome da criatura; `executed` usa `<nome>_executado`. Preservar `start`, `count`, `fps` e demais campos existentes. Executar o teste de bestiário daquela versão e conferir alcance, direção, ancoragem e sincronização das execuções em combate. Esses testes integrados ainda não foram executados.
