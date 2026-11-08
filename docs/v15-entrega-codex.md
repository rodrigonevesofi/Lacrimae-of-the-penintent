# Entregas sobre a base v15

Apliquei o patch v15 recebido sobre `5e82da3` e acrescentei somente arquivos novos. Os onze arquivos protegidos pelo pedido estão idênticos à base resultante do patch; hashes em [v15-escopo.json](v15-escopo.json). As alterações nos arquivos existentes pertencem ao patch recebido.

- [Nove sons das criaturas](sfx-criaturas.md), com gerador reproduzível e medidas espectrais. PCM mono 22050 Hz/16 bits, pico abaixo de −1 dBFS, início abaixo de 50 ms. Uma verificação independente identificou deslocamento nas pontas após a remoção da média; apliquei uma rampa final antes de regenerar e aprovar os arquivos.
- [Ilustração de encerramento](ato1-encerramento.md), opaca, 1920×1080, personagem de costas, correntes e uma luz baixa. [Prévia com legenda no Godot](imagens/v15-encerramento-legenda.png). A frase é apenas teste de composição.
- [Revisão editorial](revisao-textos-ato1.md): 17 propostas com trechos, problemas e sugestões; sem modificar falas.
- [Especificação de redução de pulsos e tremores](especificacao-reducao-de-pulsos.md), fixture de observação e teste de contrato. A opção não foi implementada.

## Verificações executadas

Godot Standard 4.6.3, Linux, dados de teste isolados em `/tmp`:

| Verificação | Resultado |
|---|---|
| `accessibility_pulses_check.gd` | 35 verificações, zero falhas |
| `accessibility_scenes_check.gd` | 22 verificações, zero achados |
| `guilt_smoke.gd` | Passou |
| `bestiary_smoke.gd` | Passou |
| `chapter_smoke.gd` | Passou |
| `expansion_smoke.gd` | Passou |
| `v15_assets_check.py` | 9 WAVs e PNG aprovados nos critérios técnicos |
| `reduced_pulses_spec.gd` | Controle normal aprovado; código 2 / NOT_IMPLEMENTED, esperado sem a API |
| Prévia visual Godot | Captura 1280×720 inspecionada, arte inteira e legenda visíveis |

Resultados: [testes](v15-testes.json), [arquivos](v15-assets-result.json), [contrato futuro](reduced-pulses-spec-result.json). A captura usa renderização por software; o aviso de V-Sync indisponível nesse ambiente não impediu sua geração.

## Para integrar

Os nove sons e a ilustração ainda não estão ligados à execução do jogo, conforme solicitado. O Claude pode conectar os sons aos sinais de cada ataque, ajustar volumes e conectar a arte ao encerramento. As sugestões editoriais precisam de decisão de roteiro, principalmente sobre quando identificar Edran. A API proposta para a opção é detalhada na especificação e deverá ser implementada antes de o teste poder aprová-la.

Não houve audição crítica dos sons em contexto, playtest humano, validação de impacto emocional nem certificação de conforto fotossensível. Testes de roteiro e fonte não demonstram qualidade equivalente a Blasphemous. Esta entrega atende às quatro tarefas v15, sem alterar combate ou extensão do Ato I.

O pacote `Lacrimae-v15-Entregas-Codex.zip` contém apenas os novos recursos e documentos desta entrega. Para abrir o projeto completo no Godot, use o repositório atualizado ou `Lacrimae-v15-Projeto-Godot.zip`, extraia e importe `project.godot`; a primeira importação cria os dados locais do editor.
