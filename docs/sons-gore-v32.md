# Relatório técnico de síntese e validação — Sons de Gore e Combate (v32)

Relatório recebido no pacote do autor. Os WAVs foram integrados na versão 36; a verificação independente e seus limites estão em [v36-audio.json](v36-audio.json). A descrição das camadas abaixo é a do gerador fornecido, sem avaliação auditiva humana nesta integração.

Todos os 20 arquivos especificados em `prompts-sons-gore-argon.md` foram sintetizados em `tools/make_sfx_gore_v32.py` usando modelagem física/orgânica (micro-impulsos líquidos, rasgo fibroso granular, fratura óssea seca, ressonância modal metálica sem oscilador contínuo e reverberação fria de catedral).

## Medidas validadas

| Arquivo (`assets/audio/`) | Duração (s) | Pico (dBFS) | Início (ms) | Planura espectral | Subida tonal? | Status |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: |
| `sangue_jato_01.wav` | 0.40 | -2.00 | 3.0 | 0.28 | Não | PASS |
| `sangue_jato_02.wav` | 0.40 | -2.00 | 2.9 | 0.26 | Não | PASS |
| `sangue_jato_03.wav` | 0.40 | -2.00 | 2.6 | 0.30 | Não | PASS |
| `carne_rasga_01.wav` | 0.35 | -1.90 | 3.9 | 0.25 | Não | PASS |
| `carne_rasga_02.wav` | 0.35 | -1.90 | 3.5 | 0.22 | Não | PASS |
| `carne_rasga_03.wav` | 0.35 | -1.90 | 3.3 | 0.22 | Não | PASS |
| `osso_quebra_01.wav` | 0.30 | -1.80 | 2.0 | 0.24 | Não | PASS |
| `osso_quebra_02.wav` | 0.30 | -1.80 | 2.0 | 0.25 | Não | PASS |
| `osso_quebra_03.wav` | 0.30 | -1.80 | 2.0 | 0.22 | Não | PASS |
| `respingo_chao_01.wav` | 0.20 | -2.20 | 2.0 | 0.21 | Não | PASS |
| `respingo_chao_02.wav` | 0.20 | -2.20 | 2.0 | 0.21 | Não | PASS |
| `respingo_chao_03.wav` | 0.20 | -2.20 | 2.0 | 0.21 | Não | PASS |
| `respingo_chao_04.wav` | 0.20 | -2.20 | 2.0 | 0.20 | Não | PASS |
| `lamina_sai.wav` | 0.40 | -2.00 | 2.9 | 0.26 | Não | PASS |
| `corpo_cai_carne.wav` | 0.70 | -1.80 | 3.0 | 0.15 | Não | PASS |
| `corpo_cai_armadura.wav` | 0.90 | -1.80 | 3.0 | 0.18 | Não | PASS |
| `esquiva_perfeita.wav` | 0.50 | -2.10 | 3.0 | 0.10 | Não | PASS |
| `aviso_aparavel.wav` | 0.25 | -2.00 | 2.0 | 0.50 | Não | PASS |
| `aviso_perigo.wav` | 0.35 | -2.00 | 2.7 | 0.19 | Não | PASS |
| `execucao_impacto.wav` | 0.90 | -1.80 | 2.0 | 0.14 | Não | PASS |

## Camadas acústicas

- **`sangue_jato_01.wav`**: Jorro pressurizado de sangue de ferida profunda pulsando (var. 1).
- **`sangue_jato_02.wav`**: Jorro pressurizado de sangue de ferida profunda pulsando (var. 2).
- **`sangue_jato_03.wav`**: Jorro pressurizado de sangue de ferida profunda pulsando (var. 3).
- **`carne_rasga_01.wav`**: Lâmina rasgando carne e pano grosso, pesado e úmido (var. 1).
- **`carne_rasga_02.wav`**: Lâmina rasgando carne e pano grosso, pesado e úmido (var. 2).
- **`carne_rasga_03.wav`**: Lâmina rasgando carne e pano grosso, pesado e úmido (var. 3).
- **`osso_quebra_01.wav`**: Osso partindo sob golpe pesado, estalo seco com cauda úmida (var. 1).
- **`osso_quebra_02.wav`**: Osso partindo sob golpe pesado, estalo seco com cauda úmida (var. 2).
- **`osso_quebra_03.wav`**: Osso partindo sob golpe pesado, estalo seco com cauda úmida (var. 3).
- **`respingo_chao_01.wav`**: Gotas espessas de sangue batendo na laje de pedra (var. 1).
- **`respingo_chao_02.wav`**: Gotas espessas de sangue batendo na laje de pedra (var. 2).
- **`respingo_chao_03.wav`**: Gotas espessas de sangue batendo na laje de pedra (var. 3).
- **`respingo_chao_04.wav`**: Gotas espessas de sangue batendo na laje de pedra (var. 4).
- **`lamina_sai.wav`**: Espada arrancada do corpo em deslize úmido de aço.
- **`corpo_cai_carne.wav`**: Corpo caindo morto na pedra sobre poça de sangue.
- **`corpo_cai_armadura.wav`**: Criatura de armadura desabando morta na pedra.
- **`esquiva_perfeita.wav`**: Tempo desacelerando: sopro abafado grave e batimento cardíaco.
- **`aviso_aparavel.wav`**: Centelha metálica curta de luz batendo na lâmina (aviso de aparo).
- **`aviso_perigo.wav`**: Sibilo seco de fôlego e couro rangendo (ataque indefensável).
- **`execucao_impacto.wav`**: Golpe mortal da execução: lâmina cravada, osso partindo, sangue e eco na pedra.
