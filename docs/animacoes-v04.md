# Animações v0.4 — implementação e validação

## Escopo

Refinamento do Ato I. Não implementa o Ato II e não substitui a campanha planejada. Os desenhos são originais, gerados para Lacrimae; não foram extraídos sprites de Blasphemous.

Oito atlas PNG, cada um com 24 células (6 × 4), alimentam 36 clipes definidos em `assets/animation/clips.json`. Algumas células de estudo não são usadas na seleção de estados. Os PNGs foram inspecionados quanto a transparência, presença de conteúdo e quadros distintos. Fundos parcialmente opacos encontrados na primeira geração foram removidos antes da revisão final.

## Sequências configuradas

| Ator | Sequências | Quadros por sequência |
| --- | --- | --- |
| Penitente | Repouso, corrida, esquiva, salto/pouso, dano, morte, choro, ataque A, ataque B, cura, penitência | 6 |
| Devoto | Repouso, caminhada, ataque, dano, morte | 6 / 6 / 6 / 3 / 3 |
| Chorão | Flutuação, deslocamento, conjuração, dano, morte | 6 / 6 / 6 / 3 / 3 |
| Guardião | Repouso, caminhada, pancada, ritual, dano, morte | 2 / 6 / 6 / 6 / 2 / 4 |
| Iria | Repouso, fala, caminhada e oração | 6 |
| Efeitos | Dois arcos de golpe, projétil e impacto | 6 |

O salto seleciona poses de acordo com subida, ápice e queda, e duas poses de pouso por 100 ms. O corpo não é girado para simular uma cambalhota: a esquiva usa desenhos distintos de agachamento, mergulho, giro e recuperação. A caminhada de Iria está disponível no atlas, mas ela permanece no ponto de encontro nesta etapa da narrativa.

## Contato e controle

- Corrida: seis poses a 16 quadros por segundo; a renderização do jogo continua independente da taxa do atlas.
- Espada: seis poses em 0,42 s, alternando dois golpes. Os quadros com índices 2 e 3 são a janela ativa. Os desenhos incluem a arma, com pulso, corpo e lâmina mudando juntos.
- O repouso e a corrida usam uma lâmina em camada separada que acompanha posições de pulso por quadro.
- O próximo golpe e a esquiva podem consumir o comando registrado a partir do último sexto da recuperação.
- Contato bem-sucedido pausa localmente atacante e alvo por 45 ms. Não altera globalmente Engine.time_scale nem a música.
- A pancada do Guardião emite o ataque quando a sequência entra no quadro de contato. O Chorão emite o projétil durante a extensão das mãos.
- Os efeitos e personagens espelham para esquerda/direita sem trocar a colisão física.

## Evidências

- `tests/chapter_smoke.gd`: **39 verificações, zero falhas** na versão final.
- `tests/animation_smoke.gd`: **73 verificações, zero falhas**, incluindo avanço de quadros com entrada real, sincronização da espada, ausência de dano durante preparação e prevenção de acerto duplicado no mesmo alvo.
- `tools/check_animation_atlases.py`: **36 clipes inspecionados**, sem quadros vazios ou animações reduzidas a uma imagem duplicada; transparência dos cantos verificada.
- Revisão visual de uma gravação de **807 quadros**, 13,45 segundos de simulação a 60 Hz. Foram conferidas sequências de corrida, salto, golpes, esquiva, dano, cura, penitência, Devoto, Chorão, Guardião e Iria.
- O ensaio reposiciona personagens e isola ações para inspeção. Não é uma partida completa nem prova de balanceamento.

## Desempenho e limites

A gravação em Movie Maker fixa a simulação; não prova execução a 60 FPS. Em medição separada, sem gravação, com 120 intervalos de renderização a 1280 × 720 no adaptador **llvmpipe (renderização por software)**:

- Antes da redução de repintura e iluminação: aproximadamente **28,95 FPS**, percentil 95 de intervalo **42,24 ms**.
- Depois: aproximadamente **37,59 FPS**, percentil 95 **34,57 ms**.

Essas medições são amostras curtas desta máquina, não resultados do computador do usuário nem garantia de 60 FPS. O cenário decorativo atualiza chamas e poeira a 24 Hz; personagens e câmera continuam sendo atualizados por renderização. Desenhos e fundos já iluminados não recebem passes extras de luz que estouravam as cores. Os recursos dos clipes são compartilhados entre instâncias.

Ainda há espaço para interpolar mais poses, melhorar continuidade de tecido e ampliar reações curtas de alguns inimigos. Não considerar esta versão equivalente ao acabamento final de um jogo comercial apenas por possuir sprite sheets.

## Referências e acesso

O usuário indicou Blasphemous e o trailer https://www.youtube.com/watch?v=T3SxYMu5qGY. As tentativas de abrir YouTube, Steam e Team17 nesta sessão retornaram **403 no proxy de rede**. Não foi possível assistir a esse trailer nem fazer uma comparação quadro a quadro com ele. O vídeo de referência enviado anteriormente havia sido inspecionado na conversa, mas seu arquivo temporário já não estava disponível nesta etapa.

Foram aplicados critérios gerais de jogos de ação 2D: antecipação legível, janela de contato curta, recuperação, poses de peso, reação a dano e comando registrado. Não se atribuem medições de tempo ou análise inédita ao trailer inacessível.
