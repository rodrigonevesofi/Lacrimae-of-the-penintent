# Prompt para o Codex — versão 42 (entrega)

Cole o texto abaixo no Codex, anexando os três pacotes `Lacrimae-of-the-penintent-v42-*.zip` (ou `v42-somente-o-que-mudou.zip`).

---

Você está no repositório `rodrigonevesofi/Lacrimae-of-the-penintent`. Hoje é a entrega do projeto. Faça **só** o que está abaixo, nesta ordem, e não altere jogabilidade, arte, sons nem textos.

## Tarefa 1 — Publicar a versão 42 no ramo `main` (obrigatória)

1. Extraia os três pacotes da versão 42 na mesma pasta (ou aplique `v42-somente-o-que-mudou.zip` por cima da versão 41 que está no `main`). A versão 42 **já contém** o ramo `confessionario-ia` fundido e adaptado: não refaça a fusão; em caso de diferença, vale o arquivo do pacote.
2. Confirme que `ia_local.cfg` **não** existe no repositório e que está no `.gitignore`. Se existir qualquer chave de API em algum arquivo, pare e avise.
3. Abra o projeto no Godot 4.6.3, deixe importar e rode: `tests/confessor_smoke.gd`, `tests/gamepad_smoke.gd`, `tests/v41_cutscene_smoke.gd`, `tests/vale_boss_smoke.gd`, `tests/story_decisions_check.gd` e `tests/chapter_smoke.gd`. Todos devem passar.
4. Faça o commit "versão 42: Confessionário com IA, cutscene da revelação, documentação" e publique no `main`. Os arquivos `.ogv` de `assets/cutscene/` somam cerca de 35 MB; nenhum passa de 100 MB.
5. Informe o link do commit e o resultado dos seis testes.

## Tarefa 2 — Executável para Windows (se houver tempo)

Exporte o jogo para Windows (modelo de exportação do Godot 4.6.3, "Windows Desktop", com o `.pck` embutido) e publique como **Release** no GitHub com o nome "Lacrimae of the Penitent — versão 42". Inclua na descrição: para ligar a IA no executável, criar o arquivo `ia.cfg` em `%APPDATA%\Godot\app_userdata\Lacrimae of the Penitent\` com o mesmo formato de `ia_local.cfg.exemplo`. Se a exportação falhar, não insista: relate o erro.

## Tarefa 3 — Pranchas de conceito pintadas (opcional, só depois das outras)

Em `docs/pranchas/` há 24 pranchas montadas com a arte do jogo. Se sobrar tempo, pinte versões novas no mesmo estilo das fichas de `docs/fichas/` (pergaminho envelhecido, título em vermelho-escuro, figura grande, quadro de detalhe, três poses com etiquetas), para: O Penitente (sem mostrar o rosto), Beatriz, Iria, o Guardião dos Sinos, o Flagelado (de elmo) e os onze cenários. Regras: arte original, 1600 × 900, mesmos desenhos dos personagens do jogo, sem texto ilegível, sem crianças, e **o rosto do Penitente não aparece em nenhuma prancha**. Salve em `docs/pranchas/pintadas/` sem apagar as atuais.

## Não faça

- Não reduza o sangue das execuções. Não troque a arte do Penitente. Não mostre o rosto do Penitente fora da cena final. Não chame o chefe final de "Penitente". Não cite os outros atos no README além do gancho que já está lá.
