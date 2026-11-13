# Prompts para o Argon — o que falta (v31)

## Como gerar para entrar no jogo sem retrabalho
- **PNG**, não JPG (o JPG cria halo nas bordas ao remover o fundo).
- Fundo **liso, de uma cor só, sem as linhas da grade** desenhadas.
- Grade 6 × 4, com a personagem de perfil para a direita e **a mesma escala em todos os quadros** (um quadro agachado deve ficar menor que um em pé).
- Para normalizar, use `tools/normalizar_folhas_argon.py` (no projeto), e não o `prepare_sprites_v30.py`: aquele script redimensiona **cada quadro** para a mesma altura, o que deforma a animação.
- Arte original: não copie personagens, poses ou quadros de outros jogos.

## 1 — Beatriz: reações (prioridade)
`beatriz_reacoes` (6 × 4), mesmo estilo e escala de `beatriz_movimento` e `beatriz_combate`:
- 0–5 **aparo**: a haste atravessada à frente, recebendo o golpe; 3 é o instante do choque;
- 6–8 **dano**: o corpo cede para trás;
- 9–14 **caindo e caída**: 14 deitada no chão, de lado, a lança ao lado;
- 15–20 **levantando o parceiro**: ajoelhada, a mão sobre alguém caído à frente, um fio de sangue entre os dois;
- 21–23 **golpe no ar**: estocada para baixo durante o salto.
Prompt: *"2D side-view pixel-art sprite sheet, 6 columns by 4 rows, plain solid dark grey background with no grid lines, an original female executioner with a smooth iron mask without eye holes, dark worn bronze armour, heavy dark cloak, bandaged hands, long spear of beaten iron with relics tied to the shaft, facing right, same scale in every frame. Row 1: parrying with the spear shaft held across the body. Row 2: hit reaction and falling to lie on her side. Row 3: kneeling over a fallen companion, one hand on him, a thread of blood between them. Row 4: downward spear thrust in mid-air."*

## 2 — Penitente no estilo do Argon (só se quiser a dupla coerente)
As folhas que você mandou (`hero_motion_espada`, `hero_golpes`) estão normalizadas e guardadas em `assets/animation/argon/`, **ainda sem uso**, porque cobrem só parte dos movimentos: o Penitente mudaria de estilo no meio da luta. Para trocar o Penitente inteiro, faltam no mesmo estilo:
- `hero_reacoes_argon`: 0–5 aparo, 6–11 recuo depois do aparo, 12–14 dano, 15–20 morte (caído no 20), 21–23 cura (bebendo do frasco);
- `hero_carregado_argon`: 0–3 acúmulo do golpe carregado, 4–5 golpe, 6–11 contra-ataque forte, 12–17 golpe no ar, 18–23 oração ajoelhada;
- execuções: `hero_executa_devoto_argon`, `hero_executa_choro_argon` (12 quadros cada, golpe mortal no quadro 8, sangue a partir do 8).
Regra da história: **o rosto do Penitente nunca aparece**; a máscara de bronze esculpida das suas folhas está dentro dessa regra.
