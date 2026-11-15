# Quadros e janelas do combate — versão 36

As tabelas descrevem o tempo lógico de `player.gd`, sem pausa de impacto nem câmera lenta. F é o primeiro passo de física a 60 Hz em que o limiar pode ser atingido, numerado a partir de 1. A discretização, o instante do comando e o contato físico podem acrescentar um passo. Índices dos desenhos começam em zero e são diferentes de F.

O Penitente usa escala 1. Beatriz usa `1,15 × (1 + peso × 0,004)`: escala 1,15 com peso 0 e 1,61 com peso 100. Os valores intermediários seguem a mesma fórmula. Aéreo e descendente não usam essa escala.

Nos combos, os desenhos ativos são 2 e 3 de seis: intervalo [1/3, 2/3) da duração. O aparo abre em 60%, ainda durante a cauda ativa; a esquiva abre em 1/3 e o golpe seguinte em 76%. Há um acerto por alvo a cada golpe. O carregado aplica um único pulso em 30% da sua duração; o restante é recuperação. Todas as esquivas dependem do término da recarga de esquiva, e todos os aparos exigem chão, arma e recarga disponível.

## Penitente

| Ataque | Preparação | Ativo | Recuperação | Esquiva desde | Aparo desde | Próximo golpe desde |
| --- | --- | --- | --- | --- | --- | --- |
| Combo 1 | 0–0.107 s (F7) | 0.107 s (F7) até antes de 0.213 s (F13) | 0.213 s (F13)–0.320 s (F20) | 0.107 s (F7) | 0.192 s (F12) | 0.243 s (F15) |
| Combo 2 | 0–0.120 s (F8) | 0.120 s (F8) até antes de 0.240 s (F15) | 0.240 s (F15)–0.360 s (F22) | 0.120 s (F8) | 0.216 s (F13) | 0.274 s (F17) |
| Combo 3 | 0–0.153 s (F10) | 0.153 s (F10) até antes de 0.307 s (F19) | 0.307 s (F19)–0.460 s (F28) | 0.153 s (F10) | 0.276 s (F17) | 0.350 s (F21) |
| Carregado, após soltar I/Num5 | 0–0.096 s (F6) | Pulso em 0.096 s (F6) | Após o pulso até 0.320 s (F20) | 0.096 s (F6) | 0.218 s (F14) | Ao terminar 0.320 s (F20); comando ainda no buffer |
| Aéreo | 0–0,200 s (F12) | 0,200–antes de 0,320 s (F20); desenhos 5–7/12 | 0,320–0,480 s (F29) | 0,200 s (F12) | Ao pousar, na recuperação | Ao terminar, se ainda permitido no ar; no chão após metade da recuperação |
| Descendente | Descida variável a 950 px/s | Um impacto ao tocar o chão | 0,160 s após o pouso | Imediatamente durante a descida; no chão durante a recuperação | Ao pousar | 0,080 s depois do pouso (F5 da recuperação) |
| Contra-ataque | Herda o ataque escolhido | Herda combo, aéreo, carregado ou descendente | Herda o ataque escolhido | Herda o ataque escolhido | Herda o ataque escolhido | Herda o ataque escolhido |

## Beatriz — peso 0

| Ataque | Preparação | Ativo | Recuperação | Esquiva desde | Aparo desde | Próximo golpe desde |
| --- | --- | --- | --- | --- | --- | --- |
| Combo 1 | 0–0.123 s (F8) | 0.123 s (F8) até antes de 0.245 s (F15) | 0.245 s (F15)–0.368 s (F23) | 0.123 s (F8) | 0.221 s (F14) | 0.280 s (F17) |
| Combo 2 | 0–0.138 s (F9) | 0.138 s (F9) até antes de 0.276 s (F17) | 0.276 s (F17)–0.414 s (F25) | 0.138 s (F9) | 0.248 s (F15) | 0.315 s (F19) |
| Combo 3 | 0–0.176 s (F11) | 0.176 s (F11) até antes de 0.353 s (F22) | 0.353 s (F22)–0.529 s (F32) | 0.176 s (F11) | 0.317 s (F20) | 0.402 s (F25) |
| Carregado, após soltar I/Num5 | 0–0.110 s (F7) | Pulso em 0.110 s (F7) | Após o pulso até 0.368 s (F23) | 0.110 s (F7) | 0.250 s (F16) | Ao terminar 0.368 s (F23); comando ainda no buffer |
| Aéreo | 0–0,200 s (F12) | 0,200–antes de 0,320 s (F20); desenhos 5–7/12 | 0,320–0,480 s (F29) | 0,200 s (F12) | Ao pousar, na recuperação | Ao terminar, se ainda permitido no ar; no chão após metade da recuperação |
| Descendente | Descida variável a 950 px/s | Um impacto ao tocar o chão | 0,160 s após o pouso | Imediatamente durante a descida; no chão durante a recuperação | Ao pousar | 0,080 s depois do pouso (F5 da recuperação) |
| Contra-ataque | Herda o ataque escolhido | Herda combo, aéreo, carregado ou descendente | Herda o ataque escolhido | Herda o ataque escolhido | Herda o ataque escolhido | Herda o ataque escolhido |

## Beatriz — peso 100

| Ataque | Preparação | Ativo | Recuperação | Esquiva desde | Aparo desde | Próximo golpe desde |
| --- | --- | --- | --- | --- | --- | --- |
| Combo 1 | 0–0.172 s (F11) | 0.172 s (F11) até antes de 0.343 s (F21) | 0.343 s (F21)–0.515 s (F31) | 0.172 s (F11) | 0.309 s (F19) | 0.392 s (F24) |
| Combo 2 | 0–0.193 s (F12) | 0.193 s (F12) até antes de 0.386 s (F24) | 0.386 s (F24)–0.580 s (F35) | 0.193 s (F12) | 0.348 s (F21) | 0.440 s (F27) |
| Combo 3 | 0–0.247 s (F15) | 0.247 s (F15) até antes de 0.494 s (F30) | 0.494 s (F30)–0.741 s (F45) | 0.247 s (F15) | 0.444 s (F27) | 0.563 s (F34) |
| Carregado, após soltar I/Num5 | 0–0.155 s (F10) | Pulso em 0.155 s (F10) | Após o pulso até 0.515 s (F31) | 0.155 s (F10) | 0.350 s (F22) | Ao terminar 0.515 s (F31); comando ainda no buffer |
| Aéreo | 0–0,200 s (F12) | 0,200–antes de 0,320 s (F20); desenhos 5–7/12 | 0,320–0,480 s (F29) | 0,200 s (F12) | Ao pousar, na recuperação | Ao terminar, se ainda permitido no ar; no chão após metade da recuperação |
| Descendente | Descida variável a 950 px/s | Um impacto ao tocar o chão | 0,160 s após o pouso | Imediatamente durante a descida; no chão durante a recuperação | Ao pousar | 0,080 s depois do pouso (F5 da recuperação) |
| Contra-ataque | Herda o ataque escolhido | Herda combo, aéreo, carregado ou descendente | Herda o ataque escolhido | Herda o ataque escolhido | Herda o ataque escolhido | Herda o ataque escolhido |

## Carga, comandos e contra-ataque

A preparação do carregado inclui o tempo segurando I/Num5, anterior à tabela: carga completa em 0,900 s, liberação automática acima de 2,500 s. Durante a carga, esquiva, aparo no chão e salto podem cancelar. A liberação tem dano gradual de 28 a 62,4, antes dos multiplicadores do personagem e penitências.

O comando de combo apertado durante um golpe fica reservado até a janela de 76%, inclusive com a lança no peso máximo; é consumido uma vez. A pausa de impacto preserva o comando. Esquiva tem prioridade sobre aparo, salto e encadeamento. A reserva de ataque fora do combo dura no máximo 0,360 s; não é uma fila ilimitada de golpes.

A esquiva perfeita reconhece um contato iminente até 0,150 s após o início da esquiva, ou um ataque detectado nos últimos 0,150 s de preparação. Há uma recompensa por esquiva: 0,300 s reais de câmera lenta a 35% e 0,800 s de janela para iniciar um contra-ataque. Em reduzir pulsos, a recompensa permanece e a câmera lenta fica desativada. O aparo mantém sua janela de contra-ataque existente.

O próximo ataque consome essa janela ao começar. No carregado, o início da carga reserva o bônus até soltar, mesmo que a carga dure mais que a janela: dano-base 38 no combo (normalmente 20/26/34), 38 no aéreo (normalmente 22), multiplicador 1,5 no carregado ou base 45 no descendente (normalmente 30). Os multiplicadores próprios de Beatriz continuam valendo. Os quadros e cancelamentos são os do ataque escolhido, inclusive o estágio atual do combo; não há duração oculta de um ataque adicional.

O corte aéreo dura 0,480 s. Ao acertar uma criatura arremessada, pode suspender a queda por 0,100 s e permitir outro corte, com limite de três suspensões por arremesso. A aterrissagem reinicia a cadeia. Acertos adicionais ainda podem causar dano, mas não renovam a suspensão.

## Evidência e limites

`v36_combat_smoke.gd` mede os limiares de esquiva com passos lógicos de 1 ms para Penitente e Beatriz nos pesos 0/100; verifica a reserva real de comando, o fim da câmera lenta em tempo real, os três acertos de suspensão e a queda física. [Contato](contatos-v36/b1-contato.png), [cancelamento](contatos-v36/b1-cancelamento.png), [esquiva perfeita](contatos-v36/b2-esquiva-perfeita.png).

Esses valores não são uma medição de latência de monitor, controle físico ou desempenho gráfico. Não houve partida humana para confirmar conforto, dificuldade ou equilíbrio.
