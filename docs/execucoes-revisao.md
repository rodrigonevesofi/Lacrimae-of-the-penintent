# Revisão das execuções

Comparação do atlas da vítima com execute_devotee (terrestres) ou execute_mourner (aéreas),12quadros sincronizados. Escalas reais: herói0,44; vítimas conforme Enemy.TYPES. A referência é o ponto inferior visível na faixa centralx24–231, alfa≥64; é uma aproximação dos pés/bainha, não um detector anatômico. Medida em pixels de tela com zoom1 e origens de chão coincidentes. Positivo=abaixo da referência do herói.

## devorador

Âncora anterior [128, 250]; posterior [128, 242].

| Quadro | Antes px | Depois px |
|---|---:|---:|
| 0 | 0.18 | 5.14 |
| 1 | -0.26 | 4.70 |
| 2 | -0.26 | 4.70 |
| 3 | 0.18 | 5.14 |
| 4 | 0.80 | 5.76 |
| 5 | 0.18 | 5.14 |
| 6 | -8.68 | -3.72 |
| 7 | -10.36 | -5.40 |
| 8 | -7.88 | -2.92 |
| 9 | -5.58 | -0.62 |
| 10 | -4.34 | 0.62 |
| 11 | -4.78 | 0.18 |

[Comparação dos12quadros](imagens/execucao-devorador.png).

## flagelante

Âncora anterior [128, 250]; posterior [128, 240].

| Quadro | Antes px | Depois px |
|---|---:|---:|
| 0 | -0.79 | 2.71 |
| 1 | -1.23 | 2.27 |
| 2 | -1.23 | 2.27 |
| 3 | -0.79 | 2.71 |
| 4 | -1.14 | 2.36 |
| 5 | -2.19 | 1.31 |
| 6 | -5.25 | -1.75 |
| 7 | -6.04 | -2.54 |
| 8 | -6.04 | -2.54 |
| 9 | -4.55 | -1.05 |
| 10 | -3.85 | -0.35 |
| 11 | -4.29 | -0.79 |

[Comparação dos12quadros](imagens/execucao-flagelante.png).

## bruxa

Âncora anterior [128, 250]; posterior [128, 250].

| Quadro | Antes px | Depois px |
|---|---:|---:|
| 0 | -1.60 | -1.60 |
| 1 | -2.40 | -2.40 |
| 2 | -2.04 | -2.04 |
| 3 | -1.68 | -1.68 |
| 4 | -1.24 | -1.24 |
| 5 | -1.24 | -1.24 |
| 6 | -5.12 | -5.12 |
| 7 | -6.00 | -6.00 |
| 8 | -5.72 | -5.72 |
| 9 | -5.72 | -5.72 |
| 10 | -5.64 | -5.64 |
| 11 | -4.40 | -4.40 |

[Comparação dos12quadros](imagens/execucao-bruxa.png).

## asmodeia

Âncora anterior [128, 250]; posterior [128, 237].

| Quadro | Antes px | Depois px |
|---|---:|---:|
| 0 | -4.24 | 1.22 |
| 1 | -4.68 | 0.78 |
| 2 | -4.68 | 0.78 |
| 3 | -4.68 | 0.78 |
| 4 | -3.82 | 1.64 |
| 5 | -3.82 | 1.64 |
| 6 | -5.06 | 0.40 |
| 7 | -5.94 | -0.48 |
| 8 | -6.38 | -0.92 |
| 9 | -6.80 | -1.34 |
| 10 | -6.36 | -0.90 |
| 11 | -5.90 | -0.44 |

[Comparação dos12quadros](imagens/execucao-asmodeia.png).

## duelista

Âncora anterior [128, 250]; posterior [128, 250].

| Quadro | Antes px | Depois px |
|---|---:|---:|
| 0 | -1.52 | -1.52 |
| 1 | -1.96 | -1.96 |
| 2 | -1.96 | -1.96 |
| 3 | -1.52 | -1.52 |
| 4 | -1.16 | -1.16 |
| 5 | -1.16 | -1.16 |
| 6 | -3.24 | -3.24 |
| 7 | -3.68 | -3.68 |
| 8 | -3.68 | -3.68 |
| 9 | -3.24 | -3.24 |
| 10 | -3.24 | -3.24 |
| 11 | -4.04 | -4.04 |

[Comparação dos12quadros](imagens/execucao-duelista.png).

Somente âncoras executed foram corrigidas quando a diferença excedia6px; posições, tempos, dano e outros clipes permanecem os da base. O ajuste constante minimiza o pior desvio entre quadros, sem redesenhar as poses.

Limites: um sprite caído não tem a mesma posição anatômica de um sprite em pé. Correntes/armas podem contaminar a leitura por alfa; as folhas precisam de revisão visual. Além disso, a execução de uma criatura aérea pode começar com sua origem até80unidades acima do herói: essa diferença dinâmica não se corrige com uma âncora única. A correção da posição no início da execução depende do Claude e não foi feita aqui. A revisão não comprova fluidez em todas as alturas/zooms.
