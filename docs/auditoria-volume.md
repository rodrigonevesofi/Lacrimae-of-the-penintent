# Auditoria de volume dos WAVs

Níveis dos arquivos PCM, sem alterar WAVs ou volumes do jogo. Pico é máximo absoluto das amostras de todos os canais. RMS é a raiz da média dos quadrados, com canais ponderados igualmente e todo o silêncio incluído. A janela mais alta considera todas as posições possíveis de100ms, em passos de uma amostra; arquivo menor usaria sua duração total. 0dBFS corresponde à amplitude digital1. Não é LUFS, pico verdadeiro entre amostras nem medição de pressão sonora. −∞ indica silêncio.

| Arquivo | Grupo | Pico dBFS | RMS dBFS | RMS máximo100ms dBFS | Início janela s |
|---|---|---:|---:|---:|---:|
| `altar.wav` | sons de cena | -5.52 | -22.37 | -13.66 | 0.008 |
| `asmodeia_aviso.wav` | sons de criatura | -1.94 | -11.69 | -7.24 | 0.762 |
| `asmodeia_estilhaco.wav` | sons de criatura | -1.94 | -19.73 | -14.96 | 0.001 |
| `bell.wav` | sons de cena | -5.03 | -20.42 | -12.13 | 0.008 |
| `breath.wav` | sons de cena | -12.47 | -27.86 | -22.90 | 1.328 |
| `bruxa_leque.wav` | sons de criatura | -1.94 | -10.73 | -10.06 | 0.276 |
| `bruxa_sussurro.wav` | sons de criatura | -1.94 | -14.99 | -14.03 | 1.287 |
| `corrente_cede.wav` | sons de cena | -1.72 | -20.73 | -15.85 | 1.779 |
| `death.wav` | efeitos de ataque/ação | -5.24 | -18.41 | -10.04 | 0.001 |
| `devorador_bote.wav` | sons de criatura | -1.94 | -16.92 | -10.60 | 0.001 |
| `devorador_rugido.wav` | sons de criatura | -1.94 | -8.87 | -6.17 | 0.658 |
| `duelista_cacete.wav` | sons de criatura | -1.94 | -17.50 | -12.29 | 0.000 |
| `flagelante_chicote.wav` | sons de criatura | -1.94 | -17.16 | -12.33 | 0.194 |
| `flagelante_investida.wav` | sons de criatura | -1.94 | -15.29 | -11.95 | 0.180 |
| `guilt.wav` | sons de cena | -13.57 | -25.27 | -19.16 | 12.123 |
| `heal.wav` | efeitos de ataque/ação | -5.52 | -18.42 | -13.66 | 0.008 |
| `hit.wav` | efeitos de ataque/ação | -0.45 | -15.61 | -12.28 | 0.000 |
| `hurt.wav` | efeitos de ataque/ação | -0.45 | -15.64 | -10.48 | 0.001 |
| `jump.wav` | efeitos de ataque/ação | -8.20 | -20.43 | -17.09 | 0.000 |
| `knock.wav` | sons de cena | -1.94 | -19.18 | -10.71 | 0.000 |
| `murmurio_01.wav` | sons de cena | -1.72 | -15.44 | -13.38 | 0.990 |
| `murmurio_02.wav` | sons de cena | -1.72 | -15.86 | -13.59 | 2.827 |
| `murmurio_03.wav` | sons de cena | -1.72 | -17.69 | -14.82 | 1.314 |
| `ost_boss.wav` | trilhas | -5.97 | -19.60 | -17.59 | 5.487 |
| `ost_combat.wav` | trilhas | -8.41 | -20.11 | -18.37 | 4.921 |
| `ost_ending.wav` | trilhas | -15.02 | -27.57 | -23.14 | 2.010 |
| `ost_exploration.wav` | trilhas | -7.47 | -25.62 | -16.83 | 12.016 |
| `ost_menu.wav` | trilhas | -12.51 | -25.21 | -20.33 | 2.012 |
| `ost_nave.wav` | trilhas | -13.98 | -22.81 | -21.16 | 3.378 |
| `ost_patio.wav` | trilhas | -9.90 | -18.88 | -15.76 | 3.152 |
| `ost_story.wav` | trilhas | -11.08 | -23.20 | -19.19 | 6.015 |
| `ost_temple.wav` | trilhas | -14.35 | -27.19 | -23.62 | 2.015 |
| `ost_terraco.wav` | trilhas | -7.96 | -17.89 | -16.07 | 2.796 |
| `roll.wav` | efeitos de ataque/ação | -2.75 | -16.32 | -13.10 | 0.070 |
| `sino_surdo.wav` | sons de cena | -1.72 | -15.46 | -8.04 | 0.009 |
| `step.wav` | efeitos de ataque/ação | -2.20 | -18.76 | -17.62 | 0.000 |
| `swing.wav` | efeitos de ataque/ação | -2.34 | -16.37 | -13.14 | 0.069 |
| `vespera_lament.wav` | trilhas | -8.45 | -20.30 | -17.09 | 2.065 |

## Proposta de deslocamento por grupo

Ponto de partida para audição, relativo aos ganhos atuais de `soundscape.gd`: trilha−3dB, ação−2dB (passo−7), criatura−4dB, cena−2dB (murmúrios−8). São valores de referência: oração, memória e crossfades reduzem a trilha; a camada `guilt.wav` varia de−42 a−5dB e requer ajuste separado. `vespera_lament.wav` é legado não carregado pelo controlador atual; aparece na tabela, mas não influencia a proposta de trilhas.

Ajuste sugerido = alvo menos a mediana do RMS máximo100ms já com ganho de referência. Limita-se qualquer aumento para que nenhum pico individual projetado passe de−3dBFS. Os alvos abaixo são escolhas de mixagem para separar música, cenas e ataques, não normas de acessibilidade. Um único ganho de grupo não elimina diferenças dentro dele.

| Grupo | Mediana atual100ms | Alvo inicial | Acrescentar ao ganho atual | Maior pico individual previsto |
|---|---:|---:|---:|---:|
| trilhas | -21.78dBFS | -24.00dBFS | -2.22dB | -11.19dBFS |
| efeitos de ataque/ação | -15.12dBFS | -18.00dBFS | -2.88dB | -5.32dBFS |
| sons de cena | -17.85dBFS | -23.00dBFS | -5.15dB | -8.87dBFS |
| sons de criatura | -15.95dBFS | -20.00dBFS | -4.05dB | -9.99dBFS |

## Aplicação posterior e limites

O Claude aplica os deslocamentos depois de audição contextual. Manter sinal de perigo audível sem cobrir a música e o ambiente; comparar as três batidas, murmúrios, confirmação do altar e ataques em fones, caixas e celular. Sons curtos têm RMS integral baixo por desenho: não normalizar todo arquivo à mesma média. Separar ajustes de passos, respiração e culpa contínua se um ganho comum produzir resultados incoerentes.

RMS por grupo não comprova equilíbrio perceptivo: frequências, densidade, intenção narrativa e sobreposição importam. O pico do master pode exceder0dBFS com vozes simultâneas mesmo quando cada uma respeita−3dBFS. Medir o master em combate com trilha, camada de culpa e múltiplas criaturas, e revisar headroom/limitação no mixer antes de aprovar. Não foi feita audição crítica nem captura do master nesta tarefa.

Reproduzir: `python3 tests/loudness_audit.py`; validar cálculos: `--self-test`. Inventário, hashes, formatos, tempos de janela e valores sem arredondamento estão em `auditoria-volume.json`.
