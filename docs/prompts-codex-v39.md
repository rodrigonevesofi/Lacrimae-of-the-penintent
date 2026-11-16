# Prompts para o Codex — v39

Envie ao Codex os dois pacotes da v39 (`...-v39-jogo.zip` e `...-v39-documentacao-midia.zip`, extraídos na mesma pasta) e cole o texto abaixo. Se quiser que o rosto lembre o seu, **anexe também duas ou três fotos suas** (frente, três quartos e perfil).

A ordem é a de prioridade. **O item 1 é o único indispensável para a entrega de 16/11.**

---

Trabalhe sobre o projeto dos dois pacotes v39 anexados, em **Godot 4.6.3**. Regras que valem para tudo:

- Entregue o **projeto completo** publicado no repositório, não só um patch. Não apague imagens existentes.
- **Não reduza o sangue** nem os efeitos de execução.
- Comentários, funções e variáveis novas em **português**.
- Antes de publicar, rode todas as suítes de `tests/`. `v39_cenario_smoke` (149 verificações), `vale_boss_smoke` e `story_decisions_check` precisam continuar passando. Diga o que foi verificado e o que não foi.
- O rosto do Penitente só pode aparecer em `scripts/vale_finale.gd`.

## 1. Refazer o rosto do Penitente (com barba)

O rosto atual (`assets/close/close_01.png` e `close_dois_rostos.png`) ficou limpo demais: cabeça raspada, barba rala. Refaça seguindo a **seção 4 de `docs/design-chefe-e-rosto.md`** (segunda versão). Resumo:

- Homem comum de 35 a 45 anos, magro, olheiras fundas, que **passou anos dentro de um capacete de ferro e se abandonou**.
- **Barba cheia, escura e malcuidada**, de vários meses: irregular, rala nas bochechas, densa no queixo e no bigode, alguns fios grisalhos, com **sangue seco e cera endurecida** nos fios, amassada para um lado pelo capacete.
- **Cabelo curto a médio, escuro, empastado de suor**, achatado, mechas coladas na testa.
- **Sulco vermelho e fundo** na testa e nas têmporas; **fila de pequenas cicatrizes** na testa (espinhos do capacete); pele pálida e encardida; lábios rachados.
- **Dois trilhos secos de sangue** descendo dos olhos e sumindo na barba, uma lágrima fresca por cima; olhos castanhos, cansados, branco avermelhado.
- Expressão de **alívio e vergonha**.
- **Proibido:** cabelo longo até os ombros, barba longa e bem desenhada, coroa de espinhos na cabeça, auréola, expressão serena. Não pode parecer imagem de Cristo.

**Se houver fotos anexadas:** use-as como referência para o formato do rosto, as sobrancelhas, o nariz e o desenho da barba. O resultado é o homem das fotos **envelhecido, emagrecido e gasto**, com todas as marcas acima, no estilo pontilhado dos closes atuais. Não faça um retrato fiel e limpo.

Arquivos (mesmo estilo, tamanho e enquadramento dos atuais, para não mexer no código):

1. `assets/close/close_01.png` — o rosto de frente, olhos se abrindo, a mão direita erguida com a queimadura da tranca na palma.
2. `assets/close/close_dois_rostos.png` — o chefe sem elmo e o Penitente sem capacete, de perfil, frente a frente. **O mesmo rosto barbado nos dois**; um de olhos abertos, o outro abrindo.
3. `assets/close/close_revelacao_maos.png` — só se necessário: sob o capirote que Beatriz ergue devem aparecer **mechas coladas na testa e o sulco**, em vez de testa raspada.

`close_flagelado_elmo.png` não muda. Confira que os três closes mostram **a mesma pessoa** (mesma barba, mesmo cabelo, mesmas marcas). Entregue uma folha de contato com os quatro closes.

## 2. Bichos pintados (hoje parte deles é desenhada por código)

`scripts/bichos.gd` já faz corvos, morcegos e ratos reagirem ao Penitente. Falta arte:

1. `assets/animation/corvo_pousado.png` — faixa de 6 quadros de 128 × 128, corvo **pousado**, virado para a direita, pés na base da célula: 0–1 parado (pisca, vira a cabeça), 2–3 bicando o chão, 4–5 abrindo as asas para levantar voo. Mesmo traço de `corvo.png`. Em `bichos.gd`, use esses quadros na animação `pousado` e toque 4–5 antes do voo.
2. `assets/animation/morcego.png` — 6 quadros de 64 × 64: 0 pendurado de cabeça para baixo, 1–5 batendo asas. Substitua o desenho por código em `_draw`.
3. `assets/animation/rato.png` — 6 quadros de 64 × 32, virado para a direita: 0–1 farejando, 2–5 correndo. Substitua o desenho por código.

Todos escuros, quase em silhueta, para lerem contra as pinturas. Mantenha as posições, os gatilhos e os contadores (`voos`, `revoadas`) que o teste usa.

## 3. Profundidade de verdade em três salas (só se sobrar tempo)

Hoje a pintura de cada sala é uma camada só, animada por shader (`docs/cenarios-vivos.md`). Para o céu e o fundo distante se moverem em velocidade diferente da construção, como no Vale, é preciso separar a arte. Faça em **três salas com céu aberto**: Terraço dos Sinos (`terraco_sinos`), Claustro dos Votos (`cloister`) e Cidade (`vespera_panorama`).

Para cada uma:

- `assets/camadas/<arte>_ceu.png` — só o céu, opaco, 25% mais largo que a pintura, sem construção.
- `assets/camadas/<arte>_longe.png` — a paisagem distante (ruínas, montanhas), com transparência.
- `assets/camadas/<arte>_frente.png` — a pintura atual com **o céu recortado para transparente** (mesmo tamanho e mesma posição de cada pedra; a arquitetura não pode mudar, porque casa com as colisões).

Em `scripts/pintura_viva.gd`: quando os três arquivos existirem, desenhe céu (paralaxe 0,15) e longe (0,35) atrás e use `_frente` no lugar da pintura inteira; sem eles, tudo continua como está. Rode `python3 tools/gerar_mascaras_vivas.py` de novo se a pintura mudar. A chuva do Terraço hoje cai onde a máscara marca céu: passe-a para a camada de céu.

Entregue capturas das três salas com a câmera em dois pontos diferentes, mostrando o deslocamento entre as camadas.

## 4. Criaturas novas

**Não anime ainda.** As nove fichas de `docs/fichas/` aguardam a aprovação do autor.
