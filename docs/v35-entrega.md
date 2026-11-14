# Entrega v35 — execuções com gore pesado

O autor pediu execuções com bastante sangue. Na versão 33 o sangue tinha sido **reduzido** (jato de tamanho 0,4 com 18 gotas no ferimento e 0,6 com 46 no golpe mortal, durando 1 s). Agora:

- **Ferimento:** jato grande (40 gotas), impacto de sangue pintado, respingos no chão e uma pausa curta.
- **Golpe mortal:** pausa de impacto de 0,16 s, tremor forte, jato de 90 gotas, **jato arterial em quatro pulsos** (o sangue continua saindo depois do golpe), **névoa de sangue**, **pedaços de carne** que giram e caem, impacto pintado, **14 respingos espalhados pelo chão**, poça larga e **borda da tela manchada de vermelho** por 0,5 s (desligada quando "reduzir pulsos" está ativo), câmera lenta de 0,3 s.
- **Golpe comum:** a carne sangra a cada corte, com respingos; ao matar, mais sangue e poça.
- **Inimigo ferido** (abaixo de metade da vida) **pinga sangue** no chão enquanto anda.
- Respingos e poças ficam 40 s no chão (limite de 90 respingos e 14 poças).

Testes: `execution_gore_smoke` (12 verificações, incluindo respingos, jato que continua e mancha na tela) e `penitence_smoke` (agora espera o fim real da execução, com limite de 2 s; o controle volta 35 a 40 quadros depois do golpe mortal). Captura: [v35-execucao-gore.png](imagens/v35-execucao-gore.png).

O sangue ainda é desenhado por código (partículas e manchas). A arte pintada de sangue (manchas, jato, pedaços) e as execuções repintadas com mais sangue estão pedidas em `prompts-codex-v35.md`.
