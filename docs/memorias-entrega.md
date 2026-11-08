# Memórias dos portões — arquivos para integração

Criados sem alterar os arquivos reservados ao Claude. Os fundos das três salas secretas ficam para depois da v11.

## Ilustrações

Em `assets/memory/`, cinco PNGs opacos de1920×1080:

- `memoria_01_maos_na_roda.png`
- `memoria_02_mao_pequena.png`
- `memoria_02_mao_pequena_sem_sol.png`
- `memoria_03_figura_atras.png`
- `memoria_04_portao_fechado.png`

As gerações nativas de1672×941 foram padronizadas com Lanczos para1920×1080, conforme a escolha do autor. Os originais da geração permanecem em `/workspace/generated_images` no ambiente de criação. As duas variantes da mão foram geradas com a mesma referência, mas não são uma troca de pixels exclusivamente no bordado; existem pequenas diferenças de desenho. A criança aparece somente pela mão, sem rosto nem ferimentos. A figura encapuzada mantém o rosto ilegível.

[Prévia conjunta](imagens/memorias-previa.png).

Revisão: `godot --path . --script res://tools/review_memory_assets.gd`. O script apresenta cada imagem inteira em1280×720 sobre molduras claras e escuras; salva dez capturas locais em `artifacts/memory/` e uma prévia conjunta. Conferidos mão, sol, silhueta distante e ponto de luz. O portão final permanece deliberadamente escuro. A revisão não comprova o impacto emocional da cena nem substitui sua montagem na campanha.

## Fragmento de culpa

`assets/animation/fragmento_culpa.png`:1536×1024 RGBA, grade6×4 de256×256. Centro de referência128,128 por célula. Quadros0–11: pulsação em ciclo. Quadros12–17: dissolução em partículas. Quadros18–23: sem desenho visível (resíduo máximo de alfa1/255). Cantos do PNG com alfa0. O núcleo ocupa aproximadamente metade da célula; fios de luz têm maior alcance durante o pulso. Há margens entre todos os desenhos.

Não foram adicionadas entradas a `clips.json`. Na integração, usar quadros0–11 em ciclo e12–17 sem ciclo, com o tempo escolhido pelo responsável pela cena. O script de revisão reproduz os18quadros em sequência apenas para inspeção, sem estabelecer o tempo da mecânica final.

## Validação e equilíbrio

- `python3 tests/memory_assets_check.py`: dimensões, opacidade,18quadros distintos, margens, cantos e área vazia conferidos.
- Revisão Godot4.6.3 com GL Compatibility: imagens e fragmento exibidos; aviso de V-Sync da tela virtual, sem erro de script.
- [Sonda e resultados](equilibrio.md): seis encontros simulados, somente Devoto e Chorão da base disponível. A base consultada não contém `Enemy.TYPES` nem os cinco novos comportamentos; esses resultados não avaliam o bestiário do Claude.
- `tests/balance_probe.gd` descobre `Enemy.TYPES` quando disponível, ou declara a cobertura legada. Recusa executar sem `XDG_DATA_HOME` para exigir diretório descartável. A API de TYPES ainda precisa ser conferida na v11; formatos não reconhecidos abortam sem inventar tipos.

Integração das memórias e do fragmento na campanha, medição dos cinco novos inimigos e os fundos de Nave do Silêncio, Terraço dos Sinos e Pátio dos Portões Selados continuam pendentes da v11.
