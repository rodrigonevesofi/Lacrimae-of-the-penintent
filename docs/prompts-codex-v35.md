# Codex — v35: execuções com gore pesado e combate refinado ao máximo

Parta do **zip completo** `Lacrimae-of-the-penintent-v35-completo.zip` (o patch não leva imagens). Rode a suíte inteira no **Godot 4.6.3** antes de publicar. Toda arte é **original**: não copie sprites, poses ou quadros de nenhum jogo existente.

Decisões do autor que valem para tudo: o Penitente atual fica; o rosto dele nunca aparece; Edran e a Inquisidora só no Ato II; nada de crianças como vítimas ou criaturas.

## Regra principal desta rodada
**O autor quer as execuções com muito sangue.** Na versão 33 você escreveu que "o sangue de execução foi reduzido para preservar a leitura do gesto". **Isso foi o contrário do pedido.** Não reduza sangue, partículas, poças ou respingos. A legibilidade vem do tempo (antecipação clara e pausa no golpe mortal), não de menos sangue. Na v35 o Claude já aumentou o gore no código: jato arterial em quatro pulsos, névoa, pedaços de carne, respingos no chão, poça maior, borda da tela manchada de vermelho e inimigo ferido pingando. Os testes `execution_gore_smoke` e `penitence_smoke` cobrem isso; não os enfraqueça.

---

## Parte A — Arte com gore (faça na ordem)

### A1. Refazer as seis execuções com sangue de verdade (prioridade máxima)
Refaça `hero_executa_devorador/flagelante/bruxa/asmodeia/duelista/carregador.png` mantendo o movimento de cada uma, a grade, o registro (pés em 128, 250) e o golpe mortal no quadro 8. Mude o sangue:
- **Quadro 8 (golpe mortal):** jato grande saindo da ferida, ocupando pelo menos um terço da célula; a lâmina atravessando e saindo vermelha.
- **Quadros 9–11:** o sangue continua escorrendo da ferida e **pingando da lâmina**; a armadura e a capa do Penitente **ficam respingadas** até o fim (não some de um quadro para o outro).
- **Do lado da criatura** (quadros 12–23 de cada `*_executado.png`): ferida aberta visível, sangue escorrendo pelo corpo e formando poça embaixo. Onde o movimento pede, **mutilação estilizada** em pixel art: a mandíbula arrancada do Devorador, a asa partida da Asmodeia, o Flagelante estrangulado pelo próprio chicote com o pescoço sangrando. Criaturas, não pessoas comuns; nada de crianças.
- Mesmo vermelho escuro de `efeitos_combate.png` e `impactos.png`, com brilho úmido nos pontos de luz.
Entregue uma folha de contato **antes e depois** de cada uma.

### A2. Atlas de sangue para o cenário
- `assets/efeitos/sangue_chao.png` (1024 × 256, 8 células de 128 × 64, RGBA): manchas de sangue no chão vistas de lado, achatadas, de pequenas a grandes, com escorridos. Serão usadas no lugar das manchas geométricas do código (`_place_splat` em `main.gd`).
- `assets/efeitos/sangue_parede.png` (1024 × 256, 4 células de 256 × 256): respingos verticais em parede, com escorridos para baixo, para golpes perto de paredes.
- `assets/animation/jato_arterial.png` (1536 × 256, 6 quadros de 256): um pulso de sangue saindo de uma ferida, da explosão ao respingo final.
- `assets/animation/pedacos.png` (768 × 256, 6 quadros de 128 × 128 em duas fileiras): pedaços de carne e osso girando no ar.
Ligue cada um no código: `jato_arterial` em `_arterial_spray`, `pedacos` no golpe mortal, `sangue_chao` em `_place_splat` (sorteando a variação), `sangue_parede` quando o alvo estiver a menos de 60 px de uma parede.

### A3. Reações das criaturas ao golpe
Hoje cada criatura tem só **3 quadros de dano**, e isso deixa o combate "duro". Para `devoto`, `flagelante`, `devorador`, `duelista`, `carregador`, `bruxa`, `asmodeia` e `choro`, crie `assets/animation/reacoes_<criatura>.png` (1536 × 1024, 6 × 4): 0–2 golpe leve (cede e volta); 3–6 golpe forte (dobra, a ferida sangra); 7–12 arremessado (sai do chão, gira, cai de costas; 12 deitado); 13–17 atordoado sangrando (a janela da execução); 18–23 empalado pela lança de Beatriz (preso, se debatendo, sangue escorrendo pela haste). Ligue às transições `hurt`, `_launch`, `stagger` e ao empalar de Beatriz.

---

## Parte B — Combate no código (faça na ordem; cada item com teste)

### B1. Tabela de quadros e janelas de cancelamento
Crie `docs/combate-quadros.md` com, para cada ataque dos dois personagens (combo 1/2/3, carregado, descendente, aéreo, contra-ataque): preparação, quadros ativos, recuperação, onde pode cancelar em esquiva, em aparo e no golpe seguinte. Ajuste para que **todo ataque possa ser cancelado em esquiva a partir do quadro ativo**, e o combo encadeie sem perder comando apertado. Teste que meça os tempos.

### B2. Esquiva perfeita
Esquivar nos últimos 0,15 s antes de um golpe acertar: câmera lenta de 0,3 s, rastro da silhueta (use o efeito `silhueta` de `efeitos_golpe.png`), som próprio e uma janela de 0,8 s em que o próximo ataque vale como contra-ataque forte. Teste.

### B3. Cada criatura com pelo menos dois ataques legíveis
Hoje quase todas têm um ataque. Dê a cada criatura comum um segundo ataque com leitura diferente (por exemplo: Devoto, investida curta; Flagelante, chicotada baixa que precisa de salto; Duelista, finta seguida de golpe; Bruxa, lágrimas em leque; Devorador, pisão com onda). Aviso visual antes de cada um: **clarão dourado = pode aparar; clarão vermelho = não pode, esquive**. Teste por criatura que confirme os dois ataques e o aviso correto.

### B4. Malabarismo aéreo
Um inimigo arremessado pelo arremate ou pelo carregado pode ser atingido no ar; o golpe aéreo o mantém suspenso por um instante (no máximo três golpes seguidos). Teste.

### B5. Morte de criatura comum com peso
Ao morrer por golpe normal, criaturas de carne caem com sangue e poça; as de armadura, com faíscas. A última morte de uma arena usa câmera lenta curta. Teste.

Para cada item: o que foi feito, a captura e **o que não foi validado** (ninguém jogou; sensação só uma partida humana confirma).
