# Codex — v38: o chefe final, o Vale dos Flagelados, criaturas à Goya e cenários vivos

Parta dos **dois pacotes da v38, extraídos na mesma pasta**: `Lacrimae-of-the-penintent-v38-jogo.zip` (o jogo inteiro e a documentação em texto) e `Lacrimae-of-the-penintent-v38-documentacao-midia.zip` (imagens e vídeos da documentação). O patch sozinho não leva imagens nem sons. Rode a suíte inteira no **Godot 4.6.3**. Leia antes `docs/roteiro-vale-dos-flagelados.md` e `docs/v38-entrega.md` e, principalmente, **`docs/design-chefe-e-rosto.md`**. Toda arte é **original**: as pinturas de Goya são referência de clima e tema (domínio público), não para copiar a composição; não copie sprites, cenários ou personagens de nenhum jogo.

O autor entrega o projeto **amanhã (16/11)**. Faça **na ordem** e publique o que estiver pronto; cada item é independente. Não reduza sangue, partículas nem animações de cenário que já existem.

## O que mudou no roteiro (decisão do autor)
O Guardião dos Sinos deixou de ser o fim. Depois dele, os portões descem ao **Vale dos Flagelados**, onde espera o chefe final. **O nome dele no jogo é O FLAGELADO**: "O Penitente" entregaria o final. Ele é o reflexo do protagonista, mas o jogador só pode ter certeza disso na revelação. Beatriz só entra na luta quando cai a segunda placa da armadura, e no fim é ela quem tira o capacete: o rosto é o do próprio Penitente. **O rosto do Penitente agora aparece uma única vez, nessa cena.** Fora dela, continua oculto. Edran e a Inquisidora continuam no Ato II.

O Claude já implementou a luta, o vale desenhado e animado por código, a revelação e uma camada de vida em todas as salas (`penitent_boss.gd`, `vale_scene.gd`, `vale_finale.gd`, `ambient_life.gd`, teste `vale_boss_smoke.gd`). **Falta arte.**

---

## 1 — O chefe final: O Flagelado (prioridade máxima)
Siga **`docs/design-chefe-e-rosto.md`** à risca. Resumo do que não pode falhar:
- **Outra silhueta, sem capirote.** Elmo-gaiola em forma de sino fechado, com grade de confessionário e cadeado no queixo, sangue escorrendo pela grade. Cerca de 1,25 vez a altura do Penitente, curvado. Placas de ferro negro e bronze manchado amarradas com cordas, tiras de pergaminho pregadas, cera derretida, correntes com chaves. A arma é **a tranca dos portões**, usada com as duas mãos.
- **Hoje a forma verdadeira usa folhas provisórias com capirote (`assets/animation/argon/`), o que entrega o final.** Substitua.
- **A armadura cai em quatro estados e cada queda mostra uma peça igual à do protagonista:** a capa vermelha; a couraça de bronze; manoplas e botas; por fim só o elmo, com o corpo do Penitente em trapos.

Folhas, 1536 × 1024, grade 6 × 4, células de 256, pés em (128, 250), perfil para a direita. Como ele é maior, use a célula inteira e avise a escala em `docs/`:
- `assets/animation/flagelado_movimento.png`: 0–5 parado (respirando pesado), 6–11 andando, 12–17 ajoelhando para rezar (17 de joelhos, as mãos sobre a tranca), 18–23 rezando (laço).
- `assets/animation/flagelado_combate.png`: 0–5 golpe lateral com a tranca, 6–11 golpe de cima para baixo, 12–17 estocada longa com a ponta da tranca, 18–23 pancada no chão com as duas mãos.
- `assets/animation/flagelado_reacoes.png`: 0–2 dano (pergaminhos voam), 3–8 **uma parte da armadura se solta e cai**, 9–14 caindo de joelhos, 15–17 de joelhos, cabeça baixa (laço), 18–23 golpe carregado.
- `assets/animation/flagelado_estados.png`: o parado (6 quadros) repetido nos **quatro estados da armadura**, uma fileira por estado, para o jogo trocar conforme a vida. Se der tempo, faça também andando e golpeando nos quatro estados (`flagelado_estado1.png` a `flagelado_estado4.png`, mesma grade das três folhas acima resumida em 24 quadros).
- `assets/animation/flagelado_transformacao.png` (1536 × 256, 6 quadros): a figura **derretendo em cera e sangue** e se recompondo (serve nos dois sentidos).
- `assets/animation/gota_culpa.png` (768 × 128, 6 quadros de 128): gota de sangue escuro que cai, pulsa no chão e é recolhida.
- `assets/efeitos/placas_flagelado.png` (512 × 128, 4 peças de 128): ombreira com pergaminhos, peitoral com correntes, braçal, greva, caídos no chão.

### O rosto do Penitente e os closes da revelação
**Um homem comum de uns 45 anos**, magro, cabelo raspado e grisalho, barba falhada de poucos dias, sulco vermelho do capacete na testa e nas têmporas, dois trilhos secos de sangue descendo dos olhos. **Sem cabelo longo, sem barba cheia, sem coroa de espinhos na cabeça** (a coroa fica no capacete). O `close_01.png` atual não segue isso: substitua.
Três closes, 512 × 512, no estilo pontilhado dos closes atuais:
- `assets/close/close_flagelado_elmo.png`: o elmo-gaiola de perto.
- `assets/close/close_revelacao_maos.png`: as mãos enfaixadas de Beatriz erguendo o capirote do Penitente; aparece a testa com o sulco.
- `assets/close/close_dois_rostos.png`: os dois de perfil, frente a frente, sem elmo e sem capacete: **o mesmo rosto**, um de olhos abertos, o outro abrindo os olhos.

### Ligar no código
- `penitent_boss.gd`: `_wear` (forma verdadeira com as folhas novas e o estado da armadura), `_break_armor` e `_shed_plates` (as peças pintadas), `_drop_guilt` (a gota), a transformação nos dois sentidos. O nome exibido vem de `NOME` (**não troque por nada que contenha "Penitente"**; o teste `vale_boss_smoke` confere).
- `vale_finale.gd`: a revelação passa a ter **três tempos**: o elmo do Flagelado; as mãos de Beatriz no capirote do Penitente; os dois rostos. Ajuste `LINES` e os pesos de cada close. O teste `story_decisions_check` só permite o rosto nesse script.
- Os testes `vale_boss_smoke` (33 verificações) e `story_decisions_check` têm de continuar passando.

## 2 — O Vale dos Flagelados pintado, sem perder a animação
O vale hoje é desenhado por código em silhueta. Pinte as **camadas separadas**, com transparência, para o código continuar movendo cada uma (paralaxe, vento, balanço):
- `assets/vale/ceu.png` (2048 × 720, opaco): crepúsculo vermelho, sol pálido baixo, nuvens rasgadas.
- `assets/vale/desfiladeiro_longe.png`, `desfiladeiro_meio.png`, `desfiladeiro_perto.png` (4096 × 720, RGBA, repetíveis na horizontal): paredões de pedra em três distâncias.
- `assets/vale/forcas.png` (1536 × 512, 6 peças de 256 × 512): postes e traves de forca **sem os corpos**.
- `assets/vale/enforcados.png` (1024 × 256, 8 peças de 128 × 256): corpos pendurados de capirote e túnica, e **gaiolas de ferro** com alguém encolhido. Peças soltas, com o ponto de suspensão no topo ao centro, para o código balançar.
- `assets/vale/arvores_mortas.png` (1024 × 512, 4 peças), `assets/vale/chao.png` (1024 × 128, repetível): terra pisada, ossos, cordas cortadas.
- `assets/animation/corvo.png` (768 × 128, 6 quadros): voo em silhueta.
Ligue em `vale_scene.gd` mantendo `set_mood` (o céu escurece a cada placa) e `impulse` (o que está pendurado balança com os golpes).

## 3 — Cenários vivos nas outras salas (peças animadas)
`ambient_life.gd` já desenha por código correntes, estandartes, feixes de luz, poeira, névoa e gotas. Pinte as peças para substituir os desenhos de código (mesma lógica de peças soltas com ponto de suspensão):
- `assets/vida/pendentes.png` (1024 × 512, 8 peças de 128 × 512): corrente com sino, corrente com lamparina, incensário, gaiola, estandarte rasgado, rosário gigante, corda com ex-votos, gancho.
- `assets/animation/chama_vela.png` (768 × 128, 6 quadros) e `assets/animation/fumaca_incenso.png` (768 × 256, 6 quadros).
- **Três monumentos originais**, cada um em duas partes (base fixa + parte que se move), 1024 × 1024: (a) um santo colossal de pedra cujas **lágrimas escorrem** para a Cisterna; (b) no Ossuário, uma coluna de crânios cujas cabeças **se viram** para o Penitente; (c) no Claustro, um relicário suspenso por correntes que **gira devagar**. Entregue `docs/monumentos.md` dizendo onde cada um fica.

## 4 — Criaturas novas, bizarras, à maneira das Pinturas Negras (fichas primeiro)
Entregue **fichas** (1600 × 900, criatura em perfil + detalhe + três quadros-chave: aviso, ataque, vulnerável) em `docs/fichas/` e o texto em `docs/fichas/fichas-goya.md` (nome, sala, regra visual, como se lê o aviso, como se vence, qual obra inspirou). O autor aprova antes de animar. **Nada de crianças, nem como vítimas.** Ideias de partida:
1. **O Glutão** (*Saturno*): um gigante magro, de olhos arregalados, que **devora a si mesmo** (o próprio braço) e cospe os ossos no Penitente. Quanto mais ferido, mais come e mais rápido fica.
2. **Disciplinantes** (*Procissão de disciplinantes*): fila de flagelantes de capirote branco e costas em carne viva. Fracos sozinhos; em fila, o da frente protege os de trás. São os que o chefe final convoca.
3. **O Meio-Enterrado** (*Cão semi-afundado*): só uma cabeça para fora do chão; quando o Penitente passa, o resto do corpo sai da terra.
4. **As Parcas** (*Átropos*): três velhas flutuando com um fio e uma tesoura; se cortam o fio, a vida máxima diminui até a próxima oração.
5. **O Sono** (*O sono da razão*): um escriba adormecido sobre a mesa; enquanto dorme, saem dele corujas e morcegos. Acordá-lo com um golpe acaba com o enxame.
6. **A Romaria** (*A romaria de Santo Isidro*): uma massa de rostos e bocas abertas que se arrasta como uma criatura só; cada golpe solta um peregrino.
7. **O Espantalho do Medo** (*Disparate do medo*): um vulto enorme de mortalha; por baixo é um homem pequeno em pernas de pau. Golpear as pernas derruba.
8. **Os Dois Velhos** (*Dois velhos comendo sopa*): um come, o outro aponta; o que aponta marca o Penitente e o outro arremessa a tigela fervendo.
9. **A Viúva da Lâmina** (*Judite e Holofernes*): uma mulher de luto com uma espada curta e uma lanterna feita de cabeça; a luz da lanterna revela onde o Penitente está escondido.

## 5 — Efeitos do Godot em oponentes e armas (código)
- **Shader de dissolução** no chefe ao trocar de forma (use `sombra_transformacao` como máscara) e nas criaturas ao morrer (cinza que se desfaz de baixo para cima).
- **Rastro da lâmina** com `Line2D` (largura que afina, vermelho para os golpes fortes, dourado no contra-ataque) na espada e na lança.
- **Luz**: `PointLight2D` suave nas velas, lamparinas e no clarão do aparo, com `CanvasModulate` escurecendo um pouco as salas (confira que o texto e o HUD continuam legíveis; respeite "reduzir pulsos").
- **Respiração e peso**: `Tween` de escala nas criaturas paradas; tremor de câmera direcional no golpe.
Cada um com um teste e uma captura.

Para cada item: o que foi feito, a folha de contato e **o que não foi validado**.
