# Tarefas para o Codex — partir da v33

Use `Lacrimae-of-the-penintent-v33-completo.zip` (contém imagens que o patch não leva) ou o patch v33 sobre a sua "versão 32". A sua versão 32 virou a base: o refinamento de combate e as folhas de Beatriz no tom do Penitente estão mantidos, e a suíte inteira passa no Godot 4.6.3. Nesta entrega o Claude acrescentou os **impactos por material** (`impactos.png`).

Você passou a editar scripts nesta versão. Funcionou; continue documentando cada mudança em `docs/` e rodando a suíte inteira **no Godot 4.6.3**, que é a versão do projeto.

Decisões do autor: o Penitente atual fica (não troque pelo do Argon); o rosto dele nunca aparece; Edran e a Inquisidora só no Ato II.

## 1 — Execuções próprias de cada criatura, no estilo atual (prioridade)
Você adaptou Beatriz a partir das folhas do Argon. Faça o mesmo com as execuções do Penitente: `assets/animation/argon/hero_executa_devoto_argon.png` é a referência de ritmo e sangue. Crie, **no estilo do Penitente atual**, `assets/animation/hero_executa_<criatura>.png` para `devorador`, `flagelante`, `bruxa`, `asmodeia`, `duelista` e `carregador`: 12 quadros a 12 fps, golpe mortal no quadro 8, sangue a partir do 8, mesmo registro de `execute_devotee.png`. O jogo já escolhe `execute_<criatura>` sozinho quando o arquivo existe.

## 2 — O peso da lança de Beatriz
Três poses paradas de Beatriz com a lança cada vez mais pesada (a haste curvando os ombros), no estilo da sua `beatriz_movimento.png`, em `assets/animation/beatriz_peso.png` (768 × 256, 3 quadros). Ligue a pose ao `lance_weight` (0–33, 34–66, 67–100) no estado parado.

## 3 — Reações do Penitente no estilo atual, se faltar alguma
Compare `assets/animation/argon/hero_reacoes_argon.png` e `hero_carregado_argon.png` com as animações atuais do Penitente; onde a do Argon tiver um momento que a atual não tem, adapte para o estilo atual.

Para cada item: folha de contato, teste e o que não foi validado.
