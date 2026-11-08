# Sons das criaturas

Nove WAVs sintetizados originais, mono22050Hz/PCM16bits. Sem gravações nem frases inteligíveis; o rugido usa registro grave e o sussurro é ruído filtrado com uma camada adulta grave. Não há fonte de voz infantil. Não estão ligados ao jogo.

Devorador: respiração que passa a rugido rouco e impacto grave. Flagelante: fricção de cordas/estalo e passos pesados. Bruxa: sussurro seco em camadas e três silvos distintos. Asmodeia: aviso ascendente e estilhaços de vidro. Duelista: ressonâncias curtas de madeira, sem cauda metálica. Esses são objetivos de desenho, não realismo comprovado.

| Arquivo | s | Pico dBFS | Início ms | Centroide Hz | Energia<200 /200–1000 /1–4k />4k (%) |
|---|---:|---:|---:|---:|---|
| devorador_rugido.wav | 1.200 | -1.94 | 0.7 | 102 | 90.8 / 8.9 / 0.3 / 0.0 |
| devorador_bote.wav | 0.500 | -1.94 | 0.3 | 72 | 100.0 / 0.0 / 0.0 / 0.0 |
| flagelante_chicote.wav | 0.400 | -1.94 | 0.7 | 952 | 4.2 / 72.1 / 21.3 / 2.4 |
| flagelante_investida.wav | 0.600 | -1.94 | 0.4 | 106 | 98.8 / 0.8 / 0.3 / 0.0 |
| bruxa_sussurro.wav | 1.500 | -1.94 | 0.5 | 1398 | 12.4 / 28.8 / 57.9 / 0.8 |
| bruxa_leque.wav | 0.500 | -1.94 | 0.6 | 1433 | 0.1 / 0.3 / 99.6 / 0.1 |
| asmodeia_aviso.wav | 0.900 | -1.94 | 0.7 | 1625 | 0.0 / 0.1 / 99.8 / 0.0 |
| asmodeia_estilhaco.wav | 0.400 | -1.94 | 0.2 | 3145 | 0.0 / 0.1 / 62.8 / 37.1 |
| duelista_cacete.wav | 0.350 | -1.94 | 0.2 | 191 | 95.0 / 5.0 / 0.0 / 0.0 |

Conferência no PCM exportado: pico inferior a−1dBFS, entrada detectável abaixo de50ms (limiar−60dB relativo ao pico) e distribuição espectral por FFT/Hann. Dados completos em sfx-criaturas-medidas.json. A duração de0,35s é arredondada ao quadro de amostra mais próximo.

Regerar: `python3 tools/make_creature_sfx.py` (numpy); a semente fixa torna a geração reprodutível. Falta audição crítica em fones/caixas, comparação dos níveis com a mixagem e sincronização com os ataques. Medidas não provam que os sons comuniquem bem o perigo, tenham impacto ou sejam acessíveis a todas as pessoas. O Claude integra.
