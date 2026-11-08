# Tarefas para o Codex — partir da v17

Use o zip da v17 (ou o patch da v17) como base. Crie apenas arquivos novos. Não edite `enemy.gd`, `narrative.gd`, `soundscape.gd`, `world_art.gd`, `exploration.gd`, `main.gd`, `hud.gd`, `player.gd`, `act_one_layout.gd`, `guilt_text.gd`, `story_text.gd` nem `clips.json`. Descreva em `docs/` o que criou e o que não foi validado.

## Tarefa 1 — Abismo da ponte quebrada
`assets/abismo_ponte.png`: 270 × 400 px de área útil, PNG com transparência nas bordas superiores, vista lateral, estilo dos cenários atuais. Queda profunda e escura, paredes de pedra irregulares nas duas bordas com a ponte partida, vigas quebradas, névoa subindo, luz fraca e distante ao fundo; sem chão visível, sem corpos, sem texto. A borda superior coincide com a linha do piso. Entregue `docs/abismo-ponte.md` com prévia em 1280 × 720 e luminância média entre 14 e 22 em 255.

## Tarefa 2 — Efeitos de combate (atlas)
`assets/animation/efeitos_combate.png` (1536 × 1024, RGBA, grade 6 × 4, células de 256 × 256, fundo transparente): faíscas de golpe de espada (6 quadros), respingo de sangue escuro (6), clarão de aparo com anel dourado (6), poeira de aterrissagem (6). Sem texto. Valide com `python3 tools/check_animation_atlases.py`.

## Tarefa 3 — Ícones de relíquias
`assets/ui/reliquias.png` (1536 × 1024, RGBA, grade 6 × 4 de 256 × 256 com margem de 24 px): 12 relíquias de penitência diferentes (terço, prego, sino pequeno, sudário, vela, lágrima de cera, cálice, chave enferrujada, medalhão de sol, corda cortada, fragmento de vitral, dente de bronze), as 12 células seguintes com a mesma peça apagada (versão bloqueada). Estilo dos ícones atuais (`assets/reliquary_ui.png`). Entregue `docs/reliquias-icones.md` com os nomes na ordem.

## Tarefa 4 — Perigos de percurso (atlas)
`assets/animation/perigos.png` (1536 × 1024, RGBA, grade 6 × 4): espinhos de ferro (parado 1, saindo 5), plataforma de pedra que cai (parada 1, tremendo 3, caindo 2), plataforma móvel com correntes (6 quadros de balanço), pilar de pedra que desaba (6 quadros). Mesma escala dos cenários atuais. Valide com o verificador de atlas.

## Tarefa 5 — Atlas maior do Guardião dos Sinos
O Guardião em jogo ocupa uma fração pequena da célula. Pinte `assets/animation/guardiao_grande.png` (1536 × 1024, RGBA, grade 6 × 4, 256 × 256): o mesmo personagem das ilustrações de `assets/boss/`, mas com o corpo preenchendo a altura da célula, perfil virado para a direita, pés em y = 250. Quadros: 0–5 repouso, 6–11 caminhada pesada, 12–17 ataque (0–3 preparação, 4–5 golpe), 18–20 dano, 21–23 queda. Entregue `docs/guardiao-grande.md`.
