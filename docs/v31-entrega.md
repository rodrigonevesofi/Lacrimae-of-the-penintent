# Entrega v31 — registro do pacote do autor

Registro histórico recebido com o patch cumulativo. A integração efetivamente publicada, os arquivos usados e a validação atual estão em [v32-integracao.md](v32-integracao.md). A arte entregue separadamente foi adaptada; o retrato e o arquivo de comparação citados abaixo não fazem parte desta integração.

- **Beatriz** agora é desenhada com a arte do Argon (`beatriz_movimento`, `beatriz_combate`): parada, corrida, salto, esquiva, estocada, varredura, empalar, golpe carregado, execução e queda. Normalizadas por `tools/normalizar_folhas_argon.py` (escala única por folha, fundo removido a partir da borda, pés em 128, 250). Close: `assets/close/close_beatriz.png`.
- Ainda sem arte própria (usam quadros aproximados dela): aparo, dano, golpe no ar, levantar o parceiro. Pedido em `prompts-argon-v31.md`.
- **Sons:** os 11 do pacote v30 integrados (estocada da lança ×3, empalar, carga e soltura do golpe carregado, arremate, golpe descendente, sangue compartilhado, cair, levantar). Formato conferido: 44,1 kHz, mono, pico entre −1,8 e −2,2 dBFS. Não foram ouvidos por mim.
- **Penitente do Argon:** normalizado e guardado em `assets/animation/argon/`, sem uso; trocar só com o conjunto completo, para ele não mudar de estilo no meio da luta. Comparação: [v31-estilos-comparados.png](imagens/v31-estilos-comparados.png).
- Corrigido: a checagem de "Beatriz tem arte própria" olhava a lista errada e sempre dizia que não.
