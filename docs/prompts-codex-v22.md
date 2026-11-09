# Tarefas para o Codex — partir da v21

Use o zip `Lacrimae-of-the-penintent-v21-completo.zip` (ou o patch v21). Crie apenas arquivos novos; não edite scripts do jogo nem `clips.json`. As suas entregas v21 estão ligadas: Guardião colossal, efeitos de golpe e carregador.

## 1 — Ataque do carregador exposto e sua execução
Hoje, sem o caixão, ele não tem ataque próprio e só fere ao alcançar o Penitente. Pinte `assets/animation/carregador_exposto.png` (1536 × 1024, RGBA, 6 × 4, 256 × 256, mesmo registro e escala de `carregador.png`): 0-5 golpe com as mãos amarradas (0-2 preparação legível, 3-5 golpe), 6-11 recuo, 12-23 execução em 12 quadros (o Penitente não aparece; só a reação da criatura). Entregue `docs/carregador-exposto.md`.

## 2 — Guardião colossal: mais ataques legíveis
`assets/animation/guardiao_colosso_ataques.png` (2048 × 2048, 4 × 4, 512 × 512, mesmo registro): 0-3 varredura baixa com o braço (aparável: preparação clara com o braço recuado), 4-7 salto e queda (2 quadros no ar), 8-11 grito com o sino aberto (preparação de uma onda), 12-15 de joelhos, exausto (janela para golpear). Entregue `docs/guardiao-ataques.md` com a leitura de cada ataque.

## 3 — Fragmentos de pedra no chão
`assets/detritos_caixao.png` (256 × 128, RGBA): três ou quatro pedaços do caixão do carregador, deitados no chão, mesma luz e escala.

Para cada item: folha de contato, verificador e o que não foi validado.
