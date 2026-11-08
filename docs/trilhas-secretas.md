# Trilhas das salas secretas

Três composições sintetizadas originais, estéreo44100Hz, PCM16bits,16s. Sem vozes gravadas. Nave: órgão e coro harmônico muito suaves; Terraço: vento periódico, sinos distantes e sustentação grave; Pátio: bordões e dissonância contida, sem percussão. Não estão ligadas ao jogo.

Motivo comum usado: F4–A4–F5–D4, observado por picos espectrais na sequência inicial de ost_exploration.wav; transcrição parcial, não identificação integral da melodia. No Pátio aparece uma oitava abaixo. Uma nota a cada4s, com sobreposição; cada sala usa timbres e densidades próprios. Audição crítica pelo autor ainda necessária para confirmar a identidade percebida do motivo.

As frequências são quantizadas em múltiplos de1/16Hz e os envelopes se estendem circularmente pelo loop, inclusive o vento. Não se usa silêncio nas pontas para ocultar a emenda.

| Arquivo | Pico dBFS | Salto na emenda | RMS | Energia<200 /200–1000 /1–4k />4k % |
|---|---:|---:|---:|---|
| ost_nave.wav | -13.98 | 0.006439 | 0.0724 | 83.94 / 15.95 / 0.12 / 0.00 |
| ost_terraco.wav | -7.96 | 0.005341 | 0.1274 | 91.93 / 7.90 / 0.18 / 0.00 |
| ost_patio.wav | -9.90 | 0.003082 | 0.1138 | 97.01 / 2.99 / 0.00 / 0.00 |

Conferência feita no PCM exportado: formatos, duração, pico abaixo de−1dBFS, salto entre último/primeiro quadro abaixo de0,02 nos dois canais e energia por bandas via FFT/Hann. Isso não comprova mixagem adequada, ausência de todo artefato audível ou efeito emocional. Conferir o loop repetido em fones e caixas antes da integração.

Regerar: `python3 tools/make_secret_music.py` (numpy). Dados em trilhas-secretas-medidas.json.
