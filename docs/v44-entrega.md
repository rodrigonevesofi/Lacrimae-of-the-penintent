# v44 — separação por salas, espada, passos e combate

## Separação por fase (pedido do professor)

A branch `migracao-cena-jogador`, da Bárbara, já fazia a separação. Ela foi validada e juntada ao `main` atual, que inclui os sons finais da v43.

**O que a separação faz:**
- **Salas:** cada sala do Ato I é uma cena própria em `scenes/salas/<sala>.tscn` (Cidade, Ossuário, Cisterna, Claustro, Campanário, Arquivo, Refúgio, Nave, Terraço, Pátio e Vale).
- **Conteúdo de cada sala:** altares, vestígios, inscrições, velas, luzes, portas, abismos, pontos especiais, arenas e o som de cada sala viram nós da própria cena. Ficam visíveis e editáveis no editor do Godot.
- **Jogador e interface:** o jogador está em `scenes/player.tscn` e a interface em `scenes/interface.tscn`.
- **Inimigos, projéteis e efeitos:** os inimigos têm uma cena por família, e os projéteis e os efeitos de sangue e gore também viraram cenas.
- **Animações:** as dos personagens viraram SpriteFrames (`.tres`).
- **Cena principal:** `scenes/main.tscn` monta as salas, o jogador e a interface.

**Validação:**
- **Junção:** a branch juntou com o `main` sem conflito.
- **Testes:** dos 60 grupos de testes, só 1 falhou: o das decisões da história procurava o texto do selo raspado em `exploration.gd`, e agora ele mora em `scenes/salas/court.tscn`. O teste foi corrigido para ler a cena da sala.
- **Visual:** cada sala foi fotografada no mesmo ponto antes e depois da separação, para comparar.

## Espada do Penitente

- **No chão, antes de pegar:** antes era desenhada com quatro linhas. Agora usa a mesma arte da espada na mão, cravada no chão e um pouco inclinada. Tem um monte de terra rachada na base, uma luz que desce sobre ela e um brilho que corre pela lâmina (`_desenhar_espada_fincada` em `world_art.gd`).
- **Na mão:**
  - O ponto do cabo que fica no punho passou da metade da empunhadura para logo atrás da guarda, então a guarda encosta no punho e a espada não parece mais solta.
  - A espada ficou 20% maior.
  - Na corrida, a lâmina muda de ângulo com o braço: punho alto aponta a ponta para a frente, punho baixo aponta para baixo.
  - A textura passou a ter mipmaps, então a lâmina fina não serrilha mais.
- **Limite:** os quadros parado e correndo do Penitente foram desenhados sem espada. A espada continua sendo uma peça separada que segue o punho. Beatriz parece melhor porque a lança já está desenhada nos quadros dela. A solução definitiva são quadros com a espada desenhada junto (prompt do Codex).

## Passos e pulo

- **Pulo:** feito com a Kenney (CC0): passo de impulso grave, tecido da capa e um leve tilintar de armadura, sem o tom que sobe como em desenho animado.
- **Passos:** os de madeira e de osso também vieram da Kenney. Os de água continuam os anteriores.
- **Ritmo:** correndo, o passo agora toca no quadro em que o pé encosta no chão (quadros 1 e 4 da corrida), e não mais num relógio de 0,28 s que não batia com os pés.

## Combate

- **Ritmo das criaturas de corpo a corpo:** a cada dois ataques, o golpe é duplo (um segundo corte curto, também aparável e com o mesmo brilho). A cada três, a preparação é segurada por mais tempo, para enganar quem aperta o aparo no automático.
- **Sangue na tela:** os círculos lisos com reflexo pareciam balões. Agora são respingos de contorno recortado, com gotas soltas e um filete que escorre.

## Ainda não feito

- **Quadros com a espada desenhada junto:** para parado, correndo e os golpes novos (prompt do Codex).
- **Zoom de combate:** aproximar a câmera quando há criaturas perto. Ficou de fora porque mexe com vários testes de câmera e não daria para validar a tempo.
