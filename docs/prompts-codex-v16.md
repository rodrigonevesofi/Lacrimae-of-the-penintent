# Tarefas para o Codex — partir da v16

## Preâmbulo (cole antes de qualquer tarefa)

Use o zip `Lacrimae-of-the-penintent-v16-completo.zip` como base (ou aplique `mudancas-v16-sobre-versao-do-codex.patch` com `patch -p1`). Ele integra os seus sons das criaturas, a ilustração de encerramento e a opção de reduzir pulsos (o seu teste de contrato passa, com 59 verificações). Também aplica sete das suas propostas editoriais; as respostas estão em `docs/revisao-textos-respostas.md`.

Regras: crie apenas arquivos novos. Não edite `enemy.gd`, `narrative.gd`, `soundscape.gd`, `world_art.gd`, `exploration.gd`, `main.gd`, `hud.gd`, `player.gd`, `act_one_layout.gd`, `guilt_text.gd`, `story_text.gd` nem `clips.json`. Ao terminar, descreva em `docs/` o que criou e o que não foi validado.

---

## Tarefa 1 — Versão mais legível da ilustração de encerramento

`assets/ending/ato1_portoes.png` tem luminância média de cerca de 4 em 255 no arquivo, e as correntes e os portões mal aparecem em monitores comuns (a sua prévia parecia mais clara que o arquivo). Gere `assets/ending/ato1_portoes_v2.png` (1920 × 1080, opaca) mantendo a composição, o clima sombrio e a faixa inferior escura de 160 px, mas com as correntes, os portões e as marcas de unhas legíveis: luminância média entre 14 e 22, o Penitente e a lanterna como foco, o céu e as bordas ainda escuros. Entregue `docs/ato1-encerramento-v2.md` com a medida antes e depois e uma prévia em 1280 × 720.

---

## Tarefa 2 — Auditoria de luminância de toda a arte-chave

Escreva `tests/luminance_audit.py` (Pillow, numpy) que meça, para cada ilustração de `assets/memory/`, `assets/boss/`, `assets/ending/` e para os fundos de `assets/*.png` usados nas salas, a luminância média, o percentil 95 e a fração de pixels abaixo de 12 em 255. Grave `docs/auditoria-luminancia.md` com a tabela e marque o que estiver tão escuro que possa se perder em monitores comuns. Não altere nenhuma imagem.

---

## Tarefa 3 — Auditoria de volume de todo o áudio

Escreva `tests/loudness_audit.py` (numpy) que meça, para cada WAV de `assets/audio/` (trilhas, efeitos, sons das criaturas e das cenas), o pico em dBFS, o RMS em dBFS e o RMS dos 100 ms mais altos. Grave `docs/auditoria-volume.md` com a tabela e proponha, para cada grupo (trilhas, efeitos de ataque, sons de cena, sons de criatura), um deslocamento em dB que deixaria o conjunto equilibrado. O Claude aplica depois. Não altere nenhum WAV.

---

## Tarefa 4 — Esboço do Ato II (somente documento)

Com base em `docs/roteiro-cinco-atos.md`, escreva `docs/ato2-esboco.md`: proposta de estrutura jogável do Ato II (salas, passagens, atalhos, criaturas novas e quais reaproveitar, chefe, cenas de culpa e o que cada uma revela e não revela, objetivo, duração estimada de uma partida e riscos de roteiro). Não crie arte, código nem texto de jogo. Marque claramente o que depende de decisão do autor. O Ato II só começa depois que o autor jogar o Ato I e relatar o que sentiu.
