# Tarefas para o Codex — partir da v28 (entrega do autor em 16/11)

Use `Lacrimae-of-the-penintent-v28-completo.zip` (ou o patch v28 sobre a sua versão 24). Crie apenas arquivos novos; não edite scripts nem `clips.json`. O rosto do Penitente nunca aparece; Edran e a Inquisidora só no Ato II.

O autor entrega o projeto em **16/11**. Faça **na ordem** e entregue o que estiver pronto; cada item é independente.

## 1 — Execução própria do Penitente para cada criatura, com sangue (prioridade máxima)
Hoje o Penitente tem só duas execuções: `execute_devotee.png` (quadros 0–11, usada por todos os humanoides) e `execute_mourner.png` (Chorão). O jogo já escolhe sozinho `execute_<criatura>` quando a animação existe.
Crie `assets/animation/hero_executa_<criatura>.png` para `devorador`, `flagelante`, `bruxa`, `asmodeia`, `duelista`, `carregador` (1536 × 1024, RGBA, 6 × 4, 256 × 256). Quadros 0–11: o Penitente executando aquela criatura, com um movimento que só faz sentido para ela (arrancar a mandíbula do Devorador; enrolar o chicote do Flagelante no pescoço dele; cravar a espada na Bruxa no ar; partir as asas da Asmodeia; usar o cacete do próprio Duelista; esmagar o Carregador com o caixão partido). Mesmo registro de `execute_devotee.png` (pés em x=128, y=250, mesma escala), 12 quadros a 12 por segundo, **golpe mortal no quadro 8**, sangue escuro pintado a partir do quadro 8. Para o carregador, também `assets/animation/carregador_executado.png` (quadros 12–23, a reação dele). Folha de contato e verificador em `docs/execucoes-proprias.md`.

## 2 — A mão do Penitente segurando a espada
`assets/animation/hero_motion.png`, quadros 0–11 (parado e corrida): a mão da frente está aberta e a espada (`assets/penitent_sword.png`) é colada por cima. Redesenhe em `assets/animation/hero_motion_espada.png` (mesma grade e registro) com a espada desenhada na mão: punho fechado no cabo de couro vermelho, guarda de espinhos dourada logo abaixo, lâmina para a frente e para baixo parado, acompanhando o braço na corrida. `docs/hero-motion-espada.md` com contato antigo e novo.

## 3 — Onda do golpe carregado e do golpe descendente (opcional)
`assets/animation/onda_golpe.png` (1536 × 512, RGBA, 6 × 2, 256 × 256): uma onda de choque de poeira e pedra que se abre no chão (6 quadros) e um anel de impacto vermelho e branco para o golpe carregado (6 quadros).

## Depois da entrega
As fichas do bestiário (prompt v25) ficam para depois de 16/11.
