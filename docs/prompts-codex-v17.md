# Tarefas para o Codex — partir da v17

## Preâmbulo (cole antes de qualquer tarefa)

Use o zip `Lacrimae-of-the-penintent-v17-completo.zip` como base (ou aplique `mudancas-v17-sobre-versao-do-codex.patch` com `patch -p1`). Ele já usa a sua ilustração de encerramento v2 e tem uma tabela `MIX_TRIM_DB` para a mixagem; a sua proposta de volume não foi aplicada (veja `docs/mixagem.md`).

Regras: crie apenas arquivos novos. Não edite `enemy.gd`, `narrative.gd`, `soundscape.gd`, `world_art.gd`, `exploration.gd`, `main.gd`, `hud.gd`, `player.gd`, `act_one_layout.gd`, `guilt_text.gd`, `story_text.gd` nem `clips.json`. Ao terminar, descreva em `docs/` o que criou e o que não foi validado.

---

## Tarefa 1 — Versão mais legível de `guardiao_03_imovel.png`

A sua auditoria marcou o bronze imóvel (média 7,1/255; 85,8% dos pixels abaixo de 12). Gere `assets/boss/guardiao_03_imovel_v2.png` (1920 × 1080, opaca) mantendo a composição, o silêncio e a única vela, mas com média entre 12 e 18 e o contorno do bronze, da mão aberta e dos sinos legível; a faixa inferior de 160 px continua a mais escura. Entregue `docs/guardiao-imovel-v2.md` com a medida antes e depois e uma prévia em 1280 × 720.

---

## Tarefa 2 — Robustez do salvamento (somente teste)

O jogo ganhou campos novos ao longo das versões (`echo_count` e outros). Escreva `tests/save_robustness_smoke.gd` que, com dados isolados, grave e carregue: um salvamento completo e válido; um salvamento de versão antiga (sem os campos novos); JSON truncado; JSON com tipos errados (texto onde há número, números absurdos, listas vazias); um arquivo vazio; e um arquivo com campos extras desconhecidos. Para cada caso confirme que o jogo não trava, nem solta erro de script, e que cai em valores seguros. Registre em `docs/robustez-salvamento.md` o que passou e o que falhou; não edite os scripts.

---

## Tarefa 3 — Sonda humana para o Guardião dos Sinos (somente teste)

Estenda a sua sonda com atraso de reação para o chefe (`kind == 2`, arena da Cidade): 10 sementes, controle com reação de 180 a 260 ms e 10% de erro, recuo e cura, três frascos. Registre tempo, dano recebido, mortes, e a quantidade de acertos de cada ataque do chefe e das fases 1 e 2. Grave `tests/balance_probe_boss.gd` e `docs/equilibrio-chefe.md` com a tabela. Declare que o chefe não foi medido antes e que a simulação não substitui jogadores. Não altere nenhum valor.

---

## Tarefa 4 — Guia do autor

Escreva `docs/guia-do-autor.md`, em linguagem simples, para quem não programa: como abrir e jogar o projeto, o que cada pasta contém, o que cada documento de `docs/` é (agrupados por tema: história, arte, áudio, acessibilidade, testes, equilíbrio, entregas), como rodar os testes e ler o resultado, como reportar um problema ao Claude e ao Codex, e o que significa cada tipo de "não validado". Inclua o fluxo de trabalho entre autor, Claude e Codex e a regra de que o Codex só cria arquivos novos enquanto o Claude integra. Não edite nenhum arquivo existente.
