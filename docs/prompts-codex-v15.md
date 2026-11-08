# Tarefas para o Codex — partir da v15

## Preâmbulo (cole antes de qualquer tarefa)

Use o zip `Lacrimae-of-the-penintent-v15-completo.zip` como base (ou aplique `mudancas-v15-sobre-versao-do-codex.patch` com `patch -p1`). Ele já integra as suas ilustrações do Guardião, o atlas do memorial, as trilhas, o roteiro de playtest e a sua verificação de acessibilidade (agora sem pendências, graças a legendas de som).

Regras: crie apenas arquivos novos. Não edite `enemy.gd`, `narrative.gd`, `soundscape.gd`, `world_art.gd`, `exploration.gd`, `main.gd`, `hud.gd`, `player.gd`, `act_one_layout.gd`, `guilt_text.gd` nem `clips.json`. Ao terminar, descreva em `docs/` o que criou e o que não foi validado.

---

## Tarefa 1 — Sons próprios para as cinco criaturas (áudio sintetizado)

Hoje as criaturas novas reaproveitam os sons genéricos. Crie `tools/make_creature_sfx.py` (numpy, como `tools/make_knock.py`) e gere em `assets/audio/`, mono, 22050 Hz, 16 bits, com pico abaixo de −1 dBFS:
- `devorador_rugido.wav` (1,2 s): respiração pesada que vira um rugido grave e rouco; `devorador_bote.wav` (0,5 s): o impacto do bote.
- `flagelante_chicote.wav` (0,4 s): estalo de chicote de cordas; `flagelante_investida.wav` (0,6 s): passos pesados em corrida.
- `bruxa_sussurro.wav` (1,5 s): sussurro seco de vozes velhas, sem palavras reconhecíveis; `bruxa_leque.wav` (0,5 s): três pequenos silvos.
- `asmodeia_aviso.wav` (0,9 s): um som agudo e etéreo que cresce; `asmodeia_estilhaco.wav` (0,4 s): vidro caindo.
- `duelista_cacete.wav` (0,35 s): madeira batendo em madeira.
Sem vozes de criança. Valide: sem clipping, início abaixo de 50 ms, espectro. Entregue `docs/sfx-criaturas.md`. Não ligue ao jogo.

---

## Tarefa 2 — Ilustração de encerramento do Ato I

O capítulo termina diante dos portões. Pinte uma ilustração original, 1920 × 1080, PNG opaco, no estilo de `assets/memory/` e `assets/boss/`, salva como `assets/ending/ato1_portoes.png`: o Penitente visto de costas diante dos Portões Selados do Pátio, quase em silhueta, uma única luz baixa no chão, as correntes dos portões visíveis e uma marca discreta de unhas riscadas na pedra. Sem texto, sem criança, sem rosto. Deixe a faixa inferior de 160 px mais escura para a legenda. Entregue `docs/ato1-encerramento.md`.

---

## Tarefa 3 — Revisão editorial dos textos do Ato I (somente leitura)

Leia todos os textos exibidos ao jogador no Ato I (`scripts/story_text.gd`, `scripts/guilt_text.gd`, `scripts/narrative.gd`, os registros de `scripts/exploration.gd`, as notas de bestiário em `scripts/enemy.gd`, as legendas de som) e escreva `docs/revisao-textos-ato1.md`: repetições de frase, erros de português, trechos longos demais para leitura em tela, inconsistências com `docs/roteiro-cinco-atos.md`, momentos em que o texto explica demais. Para cada achado: arquivo, trecho, problema e sugestão. Não edite nenhum script.

---

## Tarefa 4 — Opção de acessibilidade: reduzir pulsos e tremores (apenas especificação e teste)

Escreva `docs/especificacao-reducao-de-pulsos.md` descrevendo a opção (nome, onde fica, valor padrão, o que muda em cada cena: pulsos de luz, tremor de câmera, batidas) e crie `tests/reduced_pulses_spec.gd` com verificações que o Claude possa usar depois para validar a implementação (por exemplo: com a opção ligada, `narrative.flash` permanece em 0 e `shake_cam` não é chamado nas cenas). Não implemente a opção.
