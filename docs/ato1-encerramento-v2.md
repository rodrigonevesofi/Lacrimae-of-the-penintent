# Encerramento do Ato I — alternativa mais legível

Novo arquivo: `assets/ending/ato1_portoes_v2.png`, PNG RGB opaco, 1920×1080. A ilustração original `ato1_portoes.png` foi preservada byte a byte. A HUD recebida ainda usa a original: a troca para v2 fica para o Claude, conforme a regra de não editar scripts nesta entrega.

## Antes e depois

Mesma fórmula da auditoria: Y′ =0,2126R +0,7152G +0,0722B, em valores RGB codificados de0 a255, sem linearização. Medidas do PNG final, não da miniatura mostrada no chat.

| Critério | Original | V2 |
|---|---:|---:|
| Média da imagem /255 | 3,76 | 17,53 |
| Percentil95 /255 | 11,93 | 48,01 |
| Média dos160px inferiores /255 | 0,57 | 2,79 |
| Dimensão | 1920×1080 | 1920×1080 |
| Opacidade | Total | Total |

A v2 está dentro do intervalo solicitado de14 a22. O aumento de brilho atinge a arquitetura central e os elos das correntes, mantendo céu/bordas escuros, a lanterna como única fonte pontual e o Penitente de costas como foco humano. As marcas laterais permanecem discretas, mas se distinguem da pedra. A faixa inferior continua escura para legenda; a leitura da composição não depende de aumentar o brilho global do monitor.

A arte foi revisada com o gerador de imagem usando a versão anterior como referência. A candidata inicial ficou acima do intervalo e recebeu nova revisão. O resultado nativo de1672×941 foi padronizado por redimensionamento Lanczos, autorizado anteriormente, sem alterar a composição. A resolução de saída não significa detalhe nativo de1920×1080. Os arquivos gerados originais permanecem em `/workspace/generated_images` durante esta sessão.

## Prévia e verificação

[Prévia Godot em1280×720, com legenda de teste](imagens/v16-encerramento-legenda.png). A frase serve somente para conferir a reserva inferior; não cria texto narrativo novo nem substitui as quatro frases da HUD.

`tools/review_v16_ending.gd` carrega somente a arte alternativa, desenha a legenda e captura a composição inteira. `tests/v16_ending_check.py` verifica formato, tamanho, alfa, média14–22 e reserva inferior abaixo de12. Valores completos em [v16-encerramento-medidas.json](v16-encerramento-medidas.json); a auditoria geral inclui as duas versões.

A inspeção visual é de arquivo e captura local. Ainda falta conferir a arte na sequência real de encerramento, no brilho de uso de monitores/celulares e com jogadores. Média de brilho não certifica contraste local ou legibilidade de qualquer legenda. Esta revisão não aprova automaticamente os outros arquivos escuros apontados na auditoria.
