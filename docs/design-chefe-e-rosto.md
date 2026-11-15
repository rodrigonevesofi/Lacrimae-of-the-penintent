# Design — o chefe final e o rosto do Penitente

Arte **original**. As referências são de clima e tema (a procissão e as Pinturas Negras de Goya, a Semana Santa), não para copiar composição, personagem ou sprite de nenhum jogo ou obra.

## 1. O nome
**O FLAGELADO.** Combina com o vale e não entrega o final. "O Penitente" só aparece como nome dele **depois** da revelação. Alternativas, se o autor preferir: O Sem-Rosto, O Carcereiro do Vale, Aquele que Espera.

## 2. A regra do design: esconder no começo, entregar aos poucos
O jogador não pode reconhecer o protagonista no chefe ao vê-lo pela primeira vez. Por isso a armadura **cobre tudo e tem outra silhueta**. Cada parte que cai deixa aparecer uma peça **igual à do protagonista**. Quem presta atenção desconfia antes do fim; a certeza só vem com o capacete.

| Estado | O que cai | O que aparece por baixo (a pista) |
| --- | --- | --- |
| 0 — inteiro | nada | um estranho de ferro, maior que o Penitente |
| 1 — "a desculpa" | ombreiras e o manto de pergaminhos | **a capa vermelha rasgada**, a mesma do Penitente |
| 2 — "o esquecimento" | peitoral e correntes | **a couraça de bronze** do Penitente. Beatriz chega |
| 3 — "o castigo" | braçais e grevas | **as manoplas e as botas** dele; o corpo magro, cheio de marcas de açoite |
| 4 — a queda | tudo, menos o elmo | o corpo do Penitente em trapos, de joelhos. Só o elmo o separa do protagonista |

## 3. O Flagelado — aparência
- **Porte:** cerca de 1,25 vez a altura do Penitente, curvado, largo por causa das camadas de ferro. Anda devagar, como quem carrega peso.
- **Elmo (o que mais importa):** **sem capirote.** Um **elmo-gaiola**: ferro escuro em forma de sino fechado, com uma **grade de confessionário** no lugar da viseira e um **cadeado no queixo** (o cadeado dos portões). Pelas frestas da grade **escorre sangue**: ele chora por dentro. Nenhum traço do rosto aparece.
- **Armadura:** placas desencontradas de ferro negro e bronze manchado, amarradas com **cordas de penitência**. Pregadas nas placas, **tiras de pergaminho** com os pecados que ele ouviu e carregou pelos outros; elas se soltam e voam quando ele apanha. **Cera de vela derretida** nos ombros, selos de lacre, ex-votos. **Correntes** cruzadas no peito com chaves que ele não alcança.
- **Arma:** **a tranca dos portões**, a trave de ferro com que as portas foram fechadas, usada com as duas mãos como um malho. O instrumento do pecado dele é a arma dele. (Quando copia o jogador, usa a espada do jogador.)
- **Cores:** ferro frio e preto, osso sujo dos pergaminhos, amarelo de cera. **Um único vermelho**, escondido: a capa por baixo, que só aparece quando a primeira parte cai.
- **Como reflexo:** a aparência exata do protagonista, mas **dessaturada e escura, com os contornos escorrendo** como cera, e duas brasas vermelhas onde seriam os olhos da fenda.
- **A troca de forma:** a figura **derrete em cera e sangue** e se recompõe.

### Prompt de imagem (inglês, para gerador de imagem)
*"Original 2D side-view pixel-art boss for a dark gothic action game: a tall hunched armoured figure, about 1.25 times the height of a knight, wearing a closed iron helmet shaped like a hanging bell-cage with a confessional grille instead of a visor and a padlock at the chin, blood seeping through the grille. Mismatched black iron and tarnished bronze plates tied with penitential ropes, strips of parchment nailed to the armour and fluttering, melted candle wax on the shoulders, chains across the chest with keys. He wields a heavy iron gate-bar with both hands. Cold iron greys, dirty bone parchment, wax yellow; no visible face, no pointed hood. Sombre painterly pixel art, transparent background, facing right."*

## 4. O rosto do Penitente
**Ideia central: um homem comum.** Não um santo, não um herói, não um monstro. O horror do final é que quem fechou os portões tem um rosto em que ninguém repararia (a banalidade de quem "só obedecia"). Evitar a figura de Cristo: **nada de cabelo longo, barba cheia e coroa de espinhos na cabeça**. A coroa de espinhos fica **no capacete**, que é tirado.

- **Idade e traços:** uns 45 anos. Magro, olheiras fundas, maçãs do rosto marcadas. Cabelo **raspado**, crescendo irregular, grisalho nas têmporas. Barba de poucos dias, falhada.
- **As marcas do capacete:** um **sulco vermelho na testa e nas têmporas**, onde o ferro apertou por anos; a pele mais pálida do que o resto, porque nunca viu sol.
- **O sangue:** **dois trilhos secos e escuros** descendo dos olhos até o queixo, com uma lágrima fresca por cima. O branco dos olhos avermelhado.
- **Os olhos:** castanhos, cansados. **Fechados** quando o capacete sai; ele os abre no último quadro e **olha direto para quem joga**.
- **Um detalhe que conta a história:** na palma da mão direita, erguida perto do rosto, **a marca em queimadura do ferro da tranca**.
- **Expressão:** nem dor nem raiva. **Alívio e vergonha** ao mesmo tempo, de quem finalmente foi visto.
- **O rosto do chefe é o mesmo**, traço por traço. A única diferença: no chefe os olhos já estão abertos e as lágrimas de sangue são frescas.

### Os três closes da revelação (512 × 512, no estilo pontilhado dos closes atuais)
1. `close_flagelado_elmo.png`: o elmo-gaiola de perto, a grade, o cadeado, o sangue escorrendo.
2. `close_revelacao_maos.png`: as mãos enfaixadas de Beatriz **erguendo o capirote** do Penitente; por baixo começa a aparecer a testa com o sulco vermelho.
3. `close_dois_rostos.png`: **os dois de perfil, frente a frente**, o chefe sem elmo e o Penitente sem capacete. **O mesmo rosto**, um de olhos abertos, o outro abrindo os olhos. É a imagem que faz o jogador entender sem precisar de texto.

### Prompt de imagem (inglês)
*"Original close-up portrait, dark gothic stippled pixel-art style: an ordinary gaunt man in his mid-forties, shaved head with uneven grey stubble, a few days of patchy beard, deep-set tired brown eyes, a red groove pressed into his forehead and temples from years under an iron helmet, pale skin, two dark dried tracks of blood running from his eyes to his chin with one fresh tear of blood. Expression of relief and shame. Not a saint, not a hero, no long hair, no crown of thorns. Dark background, warm candle light from one side."*
