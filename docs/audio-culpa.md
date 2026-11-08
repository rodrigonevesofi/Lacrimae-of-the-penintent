# Áudio das cenas de culpa

Cinco texturas sintetizadas originais, mono22050Hz, PCM16bits. Sem gravações, palavras ou vozes de criança. Os murmúrios usam16fontes harmônicas em registro adulto, ressonâncias de vogal e ruído filtrado; não são uma multidão gravada. Fade de0,4s nas duas pontas dos murmúrios. Corrente com choques sucessivos e estalo final; sino com uma única excitação grave.

| Arquivo | s | Pico dBFS | Início ms | Centroide Hz | 0–200 / 200–1000 / 1–4k / >4k (%) |
|---|---:|---:|---:|---:|---|
| murmurio_01.wav | 3.6 | -1.72 | 14.0 | 455 | 14.5 / 78.8 / 6.7 / 0.0 |
| murmurio_02.wav | 3.8 | -1.72 | 13.9 | 459 | 13.1 / 80.5 / 6.4 / 0.0 |
| murmurio_03.wav | 4.0 | -1.72 | 16.0 | 461 | 12.9 / 80.6 / 6.5 / 0.0 |
| corrente_cede.wav | 2.0 | -1.72 | 0.2 | 468 | 42.8 / 44.2 / 12.8 / 0.3 |
| sino_surdo.wav | 4.0 | -1.72 | 0.2 | 72 | 99.6 / 0.4 / 0.0 / 0.0 |

Medições no PCM exportado: pico inferior a−1dBFS e entrada acima de−60dB relativo ao pico em até50ms. Espectro conferido por FFT com janela Hann e bandas acima; dados completos em culpa-audio-medidas.json. Esses testes não comprovam realismo vocal nem impacto emocional. Falta audição crítica no contexto das cenas, em fones e caixas, pelo autor e pelo responsável pela mixagem. Os sons não foram ligados ao jogo.

Regerar: `python3 tools/make_culpa_audio.py` (numpy). As sementes fixas produzem os mesmos arquivos.
