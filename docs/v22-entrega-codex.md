# Entrega v22

Base `df3dacc` com o patch v21 recebido. As alterações nos scripts do jogo e no manifesto são exclusivamente do patch. A produção nova acrescenta os três assets solicitados, documentos, verificador e prévia; não integra os novos ataques.

- [Carregador exposto](carregador-exposto.md): 24 quadros, ataque, recuo e execução.
- [Guardião](guardiao-ataques.md): 16 quadros, varredura, salto, grito e exaustão.
- [Detritos](detritos-caixao.md): quatro fragmentos principais num PNG transparente.

`python3 tests/art_v22_check.py` confere os arquivos exportados e gera folhas de contato e `v22-arte-medidas.json`. `tests/art_v22_resources.gd` confere a importação dos três PNGs. [Prévia animada](videos/v22-atlas.mp4): montagem de atlas, não gameplay.

Base recebida: áudio 18, combate 37, capítulo 44 e animações 329 asserções sem falhas. O teste de áudio emitiu erro de 10 recursos ainda em uso no encerramento; mantido em `v22-base-testes.json`. Isso impede afirmar uma execução inteiramente sem diagnósticos. Não foi corrigido nesta tarefa de arte.

Originais preservados em `/workspace/generated_images`. Exportação técnica redimensionou os resultados para as dimensões pedidas e registrou o Guardião apoiado na mesma base; os quadros no ar mantêm sua elevação. Ampliar a imagem não cria detalhe nativo. Nenhum teste técnico comprova fluidez, dificuldade, acessibilidade ou impacto emocional. As novas ações precisam de integração e playtest antes de serem apresentadas como combate concluído.
