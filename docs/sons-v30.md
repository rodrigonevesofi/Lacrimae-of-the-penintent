# Relatório técnico de síntese e validação — Sons v30

Registro histórico do autor. Os arquivos atuais vieram do pacote `sons-v32-sem-zumbido.zip`; as medidas vigentes estão em [sons-v32-integracao.md](sons-v32-integracao.md). Este gerador antigo não reproduz o pacote v32.

Todos os arquivos foram gerados proceduralmente em Python (`tools/make_sfx_v30.py`) com `numpy`, seguindo o padrão de `tools/make_jump_sfx.py`: WAV PCM 16 bits, 44,1 kHz, mono, pico abaixo de −1 dBFS, início imediato (< 50 ms), camadas de ruído filtrado, transientes curtos e impactos inarmônicos sem subida tonal.

## Medidas validadas

| Arquivo (`assets/audio/`) | Duração (s) | Pico (dBFS) | Início (ms) | Planura espectral | Subida tonal? | Status |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: |
| `lanca_estocada_01.wav` | 0.30 | -2.00 | 1.0 | 0.64 | Não | PASS |
| `lanca_estocada_02.wav` | 0.30 | -2.00 | 1.2 | 0.64 | Não | PASS |
| `lanca_estocada_03.wav` | 0.30 | -2.00 | 1.4 | 0.65 | Não | PASS |
| `empalar.wav` | 0.50 | -1.80 | 0.6 | 0.64 | Não | PASS |
| `golpe_carregado_carga.wav` | 0.90 | -2.20 | 1.8 | 0.71 | Não | PASS |
| `golpe_carregado_solta.wav` | 0.40 | -1.90 | 0.5 | 0.71 | Não | PASS |
| `arremate.wav` | 0.45 | -1.80 | 0.5 | 0.69 | Não | PASS |
| `mergulho_impacto.wav` | 0.70 | -1.80 | 0.8 | 0.67 | Não | PASS |
| `sangue_compartilhado.wav` | 1.00 | -2.20 | 3.3 | 0.72 | Não | PASS |
| `caido.wav` | 0.80 | -2.00 | 4.2 | 0.74 | Não | PASS |
| `levanta.wav` | 0.80 | -2.10 | 3.8 | 0.72 | Não | PASS |

## Descrição das camadas acústicas

- **`lanca_estocada_01.wav`**: Ar cortado por haste longa e pesada + rangido de ferro e couro (var. 1).
- **`lanca_estocada_02.wav`**: Ar cortado por haste longa e pesada + rangido de ferro e couro (var. 2).
- **`lanca_estocada_03.wav`**: Ar cortado por haste longa e pesada + rangido de ferro e couro (var. 3).
- **`empalar.wav`**: Ponta entrando em carne seguida de baque surdo.
- **`golpe_carregado_carga.wav`**: Tensão crescendo, metal sob esforço e zumbido grave que engrossa.
- **`golpe_carregado_solta.wav`**: Soltura violenta e ar deslocado.
- **`arremate.wav`**: Golpe pesado com cauda de eco de pedra.
- **`mergulho_impacto.wav`**: Armadura caindo do alto no chão de pedra e cascalho espalhando.
- **`sangue_compartilhado.wav`**: Batida de coração grave e sopro solene sem melodia.
- **`caido.wav`**: Corpo de armadura indo ao chão e gemido abafado sem palavras.
- **`levanta.wav`**: Fôlego retomado e armadura rangendo.
