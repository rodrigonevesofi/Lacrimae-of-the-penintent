# Entrega v40 — união com a versão 39 do Codex e sons do Argon

## 1. União das duas versões 39
O Codex publicou a versão 39 dele (commit `14082a3`) a partir do **primeiro** pacote v39 dos cenários vivos. Ela trouxe as nove criaturas aprovadas, os três closes do rosto com barba e os bichos pintados, mas **não** tinha a rodada de polimento feita em paralelo. A v40 junta as duas:

- **Do Codex, inteiro:** nove criaturas (`criatura_goya.gd`, 18 atlas), closes novos, corvo pousado, morcego e rato pintados, testes e documentos da v39.
- **Do polimento:** chão de colisão no piso pintado, galerias e alvenaria na cor de cada sala, soleiras, sombras de contato, espada atrás da mão, folhas limpas e de cor igualada, teclas de Beatriz para notebook. Detalhes em [v39-polimento.md](v39-polimento.md).
- **Conflitos:** só dois arquivos tinham mudanças dos dois lados no mesmo trecho (`world_art.gd` e o guia de apresentação); ficaram as duas partes. Em `v39_cenario_smoke.gd` valeu o tempo de espera do Codex, necessário para o corvo pintado.

## 2. Sons do Argon
99 arquivos entraram, com o volume igualado ao da mixagem existente; oito músicas ficaram de fora por serem repetidas e sem notas. Tudo em [sons-argon-v40.md](sons-argon-v40.md). O pedido para refazer a música está em [prompts-musica-argon-v40.md](prompts-musica-argon-v40.md).

## 3. Verificação
Suítes novas: `v40_sons_smoke` (91) e `sons_argon_check.py` (558). O conjunto completo foi rodado numa cópia limpa do pacote, em Godot 4.6.3; o resultado está na mensagem de entrega.

## O que não foi verificado
- Escuta dos sons e equilíbrio da mixagem.
- Uma partida humana com as nove criaturas depois do alinhamento do chão.
