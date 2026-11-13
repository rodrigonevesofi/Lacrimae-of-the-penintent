# Tarefas para o Codex — partir da v29 (entrega do autor em 16/11)

Use `Lacrimae-of-the-penintent-v29-completo.zip` (ou o patch v29 sobre a sua versão 24). Crie apenas arquivos novos; não edite scripts nem `clips.json`. Leia `docs/personagem-beatriz.md`.

## 1 — Beatriz, a segunda personagem jogável (prioridade máxima)
Personagem **original** (não copie nenhuma personagem de outro jogo): ex-executora da Inquisição, amnésica, que se recusou a ver os rostos de quem matou. Proposta visual: armadura escura de carrasca, longa capa de tecido grosso, **uma máscara de ferro lisa e sem aberturas para os olhos** (ela não vê os rostos), mãos enfaixadas, e a **Lança de Vladimir**: haste de ferro batido com relíquias amarradas e sangue coagulado, ponta cinzenta. Diferente do Penitente (capirote) e da Inquisidora (`close_06`, máscara rendada).

Três folhas, mesmo registro do Penitente (`hero_motion.png`): 1536 × 1024, RGBA, grade 6 × 4, 256 × 256, perfil virado para a direita, **pés em x=128, y=250**, mesma escala, lança desenhada na mão:
- `assets/animation/beatriz_movimento.png`: 0–5 parada, 6–11 corrida, 12–17 salto (subida 0–2, queda 3–5), 18–23 esquiva (rolamento).
- `assets/animation/beatriz_combate.png`: 0–5 estocada A, 6–11 varredura B, 12–17 arremate (empalar: a lança atravessa à frente), 18–23 golpe carregado (0–3 acúmulo com a haste pesando, 4–5 estocada longa).
- `assets/animation/beatriz_reacoes.png`: 0–5 aparo (a haste atravessada), 6–8 dano, 9–14 morte, 15–20 oração ajoelhada com a lança deitada, 21–23 golpe no ar.
Mais `assets/close/close_beatriz.png` (512 × 512, mesmo estilo dos closes): a máscara de ferro em close, sangue seco nas frestas.

Entregue `docs/beatriz-arte.md` com folhas de contato e um verificador (grade, registro dos pés, transparência).

## 2 — Execuções próprias de cada criatura, com sangue
Igual ao item 1 do prompt v28 (ainda pendente): `hero_executa_<criatura>.png` para devorador, flagelante, bruxa, asmodeia, duelista e carregador; 12 quadros a 12 fps, golpe mortal no quadro 8, sangue a partir do quadro 8, mesmo registro de `execute_devotee.png`.

## 3 — A mão do Penitente fechada na espada
Igual ao item 2 do prompt v28 (pendente): `hero_motion_espada.png`.

Entregue na ordem; cada item é independente.
