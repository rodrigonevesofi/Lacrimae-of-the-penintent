# Áudio v20

55 WAVs originais sintetizados com numpy: 17 eventos, 10 ambiências e 28 variações. PCM16, 44.100 Hz; efeitos mono e ambiências estéreo. Semente fixa; nenhuma gravação de voz ou amostra de terceiros. A dor usa harmônicos graves e ruído; as vozes distantes do claustro são ruído filtrado, sem palavras ou voz infantil.

## Base e integração

Aplicado o patch `mudancas-v19-sobre-versao-do-codex.patch` sobre `de07246`. As alterações de scripts são exclusivamente desse patch. A produção v20 acrescenta arquivos novos.

Os 17 nomes exatos são encontrados automaticamente por `HOOK_NAMES` em `soundscape.gd` após a importação. As dez ambiências e as 28 variações ainda precisam ser ligadas pelo integrador: a base não carrega esses nomes. Não substituí a OST nem os sons antigos. Para o laço estéreo PCM16: `loop_begin=0`, `loop_end=1323000`, `loop_mode=LOOP_FORWARD`; a unidade é quadro estéreo, não byte. Fazer transição entre salas, sem reiniciar a textura a cada passo.

## Desenho das camadas

Cidade: vento filtrado com pulsos de poeira/pedra. Ossuário: ar seco e estalos. Cisterna: ruído de água e salpicos. Claustro: murmúrio difuso sem fala. Campanário: ressonâncias metálicas espaçadas. Arquivo: fricção e batidas de madeira. Refúgio: estalos curtos de brasas. Nave: ar grave lentamente modulado com respiração de pedra. Terraço: vento mais aberto e tilintar. Pátio: fricção metálica e correntes. São objetivos de síntese; a identificação perceptiva desses materiais não foi comprovada por escuta.

Efeitos combinam ruído, transientes, ressonâncias inarmônicas e envelopes. Morte do chefe acrescenta um sino de altura descendente; portões encadeiam fricção, correntes e impacto; aparo enfatiza clangor agudo. As variações mudam ruído e ressonância, preservando duração e família.

## Medições nos arquivos exportados

`python3 tools/make_audio_v20.py` gera os WAVs. `python3 tests/audio_assets_check.py` verifica os 55 arquivos e grava `audio-v20-medidas.json`. Pico medido por amostra, não true peak interamostra. Início detectado acima de 1% do pico (−40 dB relativo). Nos laços, salto entre última/primeira amostra e mudança de inclinação ficam abaixo do percentil 99,9 das diferenças internas, por canal. Também verifica DC, canais estéreo distintos e energia em pelo menos três bandas largas. Esses critérios detectam descontinuidades numéricas; não certificam ausência perceptiva de clique, repetição ou transição audível entre salas.

| Arquivo | Duração s | Pico dBFS | RMS dBFS | Início ms |
|---|---:|---:|---:|---:|
| morte.wav | 0.60 | -2.00 | -19.63 | 0.23 |
| morte_grande.wav | 1.10 | -2.00 | -19.23 | 0.32 |
| chefe_morte.wav | 3.00 | -2.00 | -20.55 | 0.18 |
| chefe_pancada.wav | 0.90 | -2.00 | -19.31 | 0.23 |
| dor.wav | 0.30 | -2.00 | -17.19 | 0.20 |
| aterrissagem.wav | 0.25 | -2.00 | -18.30 | 0.34 |
| coleta.wav | 0.50 | -8.00 | -21.70 | 0.34 |
| porta.wav | 0.80 | -2.00 | -17.23 | 0.54 |
| projetil.wav | 0.50 | -2.00 | -15.74 | 0.29 |
| projetil_impacto.wav | 0.30 | -2.00 | -14.28 | 0.18 |
| espinho.wav | 0.35 | -2.00 | -16.08 | 0.16 |
| aparo.wav | 0.45 | -2.00 | -15.85 | 0.16 |
| execucao.wav | 0.70 | -2.00 | -18.17 | 0.29 |
| portao_fecha.wav | 1.20 | -2.00 | -17.26 | 0.27 |
| portao_abre.wav | 1.40 | -2.00 | -18.13 | 0.50 |
| ui_mover.wav | 0.08 | -14.00 | -27.23 | 0.14 |
| ui_confirmar.wav | 0.25 | -12.00 | -24.59 | 0.16 |
| step_pedra_01.wav | 0.15 | -4.00 | -19.64 | 0.32 |
| step_pedra_02.wav | 0.15 | -4.00 | -18.81 | 0.34 |
| step_pedra_03.wav | 0.15 | -4.00 | -18.21 | 0.29 |
| step_pedra_04.wav | 0.15 | -4.00 | -19.69 | 0.36 |
| step_madeira_01.wav | 0.15 | -4.00 | -18.21 | 0.23 |
| step_madeira_02.wav | 0.15 | -4.00 | -18.21 | 0.18 |
| step_madeira_03.wav | 0.15 | -4.00 | -18.92 | 0.18 |
| step_agua_01.wav | 0.15 | -4.00 | -21.18 | 0.27 |
| step_agua_02.wav | 0.15 | -4.00 | -19.94 | 0.18 |
| step_agua_03.wav | 0.15 | -4.00 | -20.68 | 0.25 |
| step_osso_01.wav | 0.15 | -4.00 | -22.37 | 0.25 |
| step_osso_02.wav | 0.15 | -4.00 | -20.90 | 0.18 |
| step_osso_03.wav | 0.15 | -4.00 | -20.84 | 0.29 |
| swing_01.wav | 0.25 | -2.00 | -17.87 | 0.57 |
| swing_02.wav | 0.25 | -2.00 | -16.76 | 0.34 |
| swing_03.wav | 0.25 | -2.00 | -16.17 | 0.43 |
| hit_carne_01.wav | 0.20 | -2.00 | -18.98 | 0.29 |
| hit_carne_02.wav | 0.20 | -2.00 | -18.73 | 0.27 |
| hit_carne_03.wav | 0.20 | -2.00 | -17.66 | 0.25 |
| hit_metal_01.wav | 0.20 | -2.00 | -14.46 | 0.16 |
| hit_metal_02.wav | 0.20 | -2.00 | -13.95 | 0.20 |
| hit_metal_03.wav | 0.20 | -2.00 | -13.70 | 0.18 |
| dor_01.wav | 0.30 | -2.00 | -16.63 | 0.18 |
| dor_02.wav | 0.30 | -2.00 | -16.94 | 0.23 |
| dor_03.wav | 0.30 | -2.00 | -19.54 | 0.18 |
| morte_01.wav | 0.60 | -2.00 | -19.31 | 0.36 |
| morte_02.wav | 0.60 | -2.00 | -19.12 | 0.29 |
| morte_03.wav | 0.60 | -2.00 | -19.62 | 0.34 |
| amb_city.wav | 30.00 | -11.19 | -28.00 | 0.00 |
| amb_ossuary.wav | 30.00 | -12.18 | -28.00 | 0.00 |
| amb_cistern.wav | 30.00 | -12.58 | -28.00 | 0.00 |
| amb_cloister.wav | 30.00 | -11.06 | -28.00 | 0.00 |
| amb_belfry.wav | 30.00 | -10.88 | -28.00 | 0.00 |
| amb_archive.wav | 30.00 | -11.88 | -28.00 | 0.00 |
| amb_refuge.wav | 30.00 | -11.78 | -28.00 | 0.00 |
| amb_nave.wav | 30.00 | -12.40 | -28.00 | 0.00 |
| amb_terrace.wav | 30.00 | -11.91 | -28.00 | 0.00 |
| amb_court.wav | 30.00 | -11.96 | -28.00 | 0.00 |

## Limites e pendências

Não houve audição crítica nem avaliação com fones/caixas. Os testes não demonstram realismo, impacto emocional, equilíbrio da mixagem ou conforto auditivo. Ganhos e reverb do jogo alteram o resultado; pico seguro de um arquivo isolado não garante segurança da soma. A análise de áudio recebida do Claude foi usada como contexto, sem tratar suas medidas como medições repetidas nesta entrega.

O verificador original de atlas encontra `efeitos/idle: repeated single image`: o patch declara um estado estático com `count=1`. A v20 não altera esse manifesto nem suprime o diagnóstico. A suíte Godot está registrada em `audio-v20-regressao.json`; avisos de encerramento devem ser distinguidos das asserções aprovadas.

A prévia `audio-v20-previa.mp3` reúne aparo, golpe, porta, chefe e três segundos de cada ambiência, com pausas entre segmentos; não é uma mixagem em jogo. A compressão MP3 da prévia não deve ser usada para avaliar as emendas dos WAVs.

O teste novo `tests/audio_v20_smoke.gd` confirma os 17 recursos ligados ao barramento SFX, com zero falhas nas asserções. O encerramento acusa instâncias/2 recursos ainda em uso; isso não foi corrigido nesta entrega de assets. O teste antigo `chapter_smoke.gd:58` exige exatamente 26 efeitos, mas a base com os novos ganchos carrega 43; falha por expectativa desatualizada. Não foi alterado para esconder o resultado.

Resultados do patch: áudio 12 verificações, combate 29, animações 309, bestiário 44, exploração 52, expansão 45 e penitências 56, todos sem falhas. Capítulo: 44 verificações, uma falha na contagem antiga de efeitos. O teste de salvamento exige um prefixo próprio para isolamento; a primeira tentativa foi bloqueada antes de executar casos e foi repetida com o diretório exigido.

Salvamento: 13 casos aprovados, incluindo JSON truncado, tipos inválidos e valores extremos. Os relatórios antigos recebidos foram preservados; a execução desta entrega está em `audio-v20-regressao.json`.
