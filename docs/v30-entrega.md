# Entrega v30 — os dois penitentes em cena

Pedido do autor: dois personagens jogáveis ao mesmo tempo, sem troca.
- **O Penitente e Beatriz caminham juntos o tempo todo.** Sozinho, o jogo controla Beatriz: ela segue, luta, apara, executa inimigos atordoados e vem levantar o Penitente.
- **Um segundo jogador assume Beatriz** apertando qualquer controle dela (setas + teclado numérico, ou o segundo controle). **F4** devolve Beatriz ao jogo.
- **Sangue compartilhado:** quem cai não morre; fica caído. O outro chega perto e segura **H** (jogador 2: **Num0**) por um segundo para dar 35% da própria vida e levantá-lo. **Só é derrota se os dois caírem.** No altar, os dois voltam.
- Os inimigos atacam o penitente **mais próximo**; uma câmera enquadra os dois; se Beatriz ficar para trás ou em outra sala, ela reaparece ao lado do Penitente; nas cenas ela fica parada.
- O Penitente perdeu as setas (ficou com A/D/W/S/ESPAÇO); as setas passaram para Beatriz.
- Ganchos de som novos para o combate e a dupla (inertes até os arquivos existirem).
- Testes: `tests/duo_coop_smoke.gd` (13). Os testes automáticos antigos rodam com um penitente só.

Prompts: `prompts-combate-arte.md` (arte do combate e de Beatriz, para o Codex ou o Argon) e `prompts-sons.md` (síntese pelo Codex ou geração pelo Gemini/Argon).
