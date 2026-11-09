# Entrega v21

Base `7570cd0` com o patch v20 recebido. Nenhuma alteração adicional em scripts de produção ou `clips.json`; as tarefas desta entrega acrescentam assets, documentação, verificadores e ferramentas de prévia.

## Arquivos entregues

1. Guardião colossal: atlas RGBA 2048 × 2048 com 16 quadros, close 1920 × 1080 e [instruções](guardiao-colosso.md).
2. Efeitos: 24 quadros RGBA 1536 × 1024, [instruções](efeitos-golpe.md).
3. Carregador: 24 quadros RGBA 1536 × 1024 com proteção quebrável e [regra visual](carregador.md).
4. Seis retratos 512 × 512, moldura 1280 × 160, fonte gótica original com OFL e [guia](fonte-gotica.md).

As artes novas ainda não estão ligadas ao jogo. O patch recebido integra as entregas anteriores, incluindo ambiências, variações de sons, aparo e portões. O atlas colossal precisa de leitura em quatro colunas; o sistema existente usa seis. Não trocar apenas o nome do arquivo e presumir que funcionará.

## Validação

`python3 tests/art_v21_check.py`: tamanhos, alpha, quadros distintos, registro vertical do Guardião, área livre da moldura e glifos portugueses. Resultado em `v21-arte-medidas.json`. Folhas de contato em `docs/imagens/v21-*-contato.png`. Fonte, retratos e close também conferidos visualmente nas amostras de composição.

`tests/art_v21_resources.gd`: carga dos 12 recursos no Godot após importação. Não testa um encontro jogável.

Testes da base recebida: áudio 18, combate 30, capítulo 44, animações 313 verificações, todos sem falhas. Relatório `v21-base-testes.json`. O verificador Python antigo de atlas continua rejeitando o estado estático `efeitos/idle` de um quadro, declarado pelo patch anterior. Este diagnóstico é preservado em `v21-escopo.json`; não foi removido nem confundido com falha dos novos atlas.

## Prévia

[Vídeo dos atlas](videos/v21-atlas.mp4), 10 segundos, MP4 H.264 1280 × 720. É uma montagem isolada com tempos propostos e herói como referência de escala, sem lógica de combate. [Close e lore](imagens/v21-rosto-lore.png), [retratos](imagens/v21-close-contato.png).

Exportação técnica: os tamanhos nativos do gerador variaram; foram redimensionados para as dimensões pedidas, retratos separados da grade e Guardião registrado por célula na base y500. `v21-exportacao.json` conserva fontes e deslocamentos. `tools/prepare_art_v21.py` requer os originais em `/workspace/generated_images`, preservados neste ambiente; o pacote entrega os PNGs prontos, não depende desse diretório para abrir no Godot. O redimensionamento amplia pixels existentes; não equivale a detalhe desenhado nativamente em 2048.

Não foram validados fluidez por jogadores, sincronização de hitboxes/áudio, acessibilidade dos flashes, ritmo de cena ou impacto emocional. As quatro poses de caminhada do Guardião e os dois quadros de queda são a contagem solicitada; não são prova de animação no nível de uma produção comercial. As regras novas do carregador são propostas para implementação pelo integrador.
