# Detritos do caixão

`assets/detritos_caixao.png`: PNG RGBA 256 × 128. Quatro fragmentos principais de pedra com metal e partes da mão votiva, mais pequenas lascas. Luz quente superior esquerda, coerente com o caixão. A área superior é transparente: posicionar pela base visível, não pelo centro do retângulo. Medidas em `v22-arte-medidas.json`.

Criar um objeto independente na posição da quebra, atrás dos atores e acima do piso. Não anexar ao nó que caminha. Não conceder colisão bloqueante sem teste: fragmentos decorativos não devem impedir o percurso. Remover no descarregamento da sala ou conforme regra de persistência do integrador. O arquivo contém o grupo inteiro, não quatro sprites separados.

Folha ampliada `imagens/v22-detritos-contato.png`; verificador `tests/art_v22_check.py`. Conferidos tamanho, RGBA, conteúdo e cantos transparentes. A escala e composição foram vistas na prévia isolada; falta ajustar ao piso e à câmera de cada sala. Asset ainda não integrado.
