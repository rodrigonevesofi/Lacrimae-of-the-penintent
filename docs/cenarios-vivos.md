# Cenários vivos (v39)

Até a v38, cada sala era **uma pintura parada**, com alguns elementos soltos por cima (pendentes, poeira, névoa, monumentos). Na v39 **a própria pintura se mexe** e a sala reage a quem passa. Nada disso exigiu arte nova: tudo usa as pinturas e as folhas que já estavam no jogo, com as ferramentas do Godot.

## O que se move em cada sala

| Sala | Na pintura | Bichos | Extra |
| --- | --- | --- | --- |
| Cidade da Penitência | estandartes, céu do poente, queda d'água sob a ponte, velas | 4 corvos | |
| Ossuário | velas e lustres (muitas), túnel verde alagado | 7 morcegos, 3 ratos | |
| Cisterna dos Nomes | jorros das fontes, lâmina d'água embaixo, velas, estandartes | 5 morcegos, 2 ratos | |
| Claustro dos Votos | estandartes, cortinas, hera vermelha, céu nos arcos, velas | 3 corvos | folhas secas caindo |
| Campanário | estandartes, céu nas janelas altas, velas | 8 morcegos, 2 corvos | |
| Arquivo das Confissões | luz fria dos janelões | 3 ratos | mariposas nas lamparinas |
| Abrigo das Cinzas | céu vermelho e névoa das ruínas, estandarte, hera | 4 corvos | |
| Nave do Silêncio | vitrais e feixes azuis, tochas, estandartes | 4 morcegos | mariposas nas lamparinas |
| Terraço dos Sinos | céu, estandartes, hera, velas | 5 corvos | **chuva e relâmpagos** do lado de fora |
| Pátio dos Portões Selados | estandartes, hera, céu, lanternas | 4 corvos | folhas secas caindo |

O Vale dos Flagelados não entra aqui: ele já tem cenário próprio, em camadas (`vale_scene.gd`).

## Como funciona, e que ferramenta do Godot faz cada coisa

| O quê | Ferramenta do Godot | Arquivo |
| --- | --- | --- |
| A pintura balança, corre, pisca | **Shader** de `canvas_item` num `Sprite2D` | `shaders/pintura_viva.gdshader`, `scripts/pintura_viva.gd` |
| Relâmpago | **AnimationPlayer**: uma trilha anima o clarão, outra chama o trovão | `scripts/pintura_viva.gd` |
| Corvos | **AnimatedSprite2D** + `SpriteFrames` (arte pintada) e **Tween** para voo e pouso | `scripts/bichos.gd` |
| Folhas secas | **CPUParticles2D** | `scripts/bichos.gd` |
| Primeiro plano em contraluz | **Parallax2D** (35% mais rápido que a câmera) e **Tween** em laço | `scripts/primeiro_plano.gd` |
| Chuva e trovão (som) | `AudioStreamPlayer` com laço | `tools/make_chuva_trovao.py` |

**A pintura viva.** Um script (`tools/gerar_mascaras_vivas.py`) lê cada pintura e marca, por cor e região, o que é **pano, água, céu, chama e vitral**. As marcas ficam em `assets/vivo/` (duas imagens pequenas por sala). O shader usa essas marcas: desloca os panos em ondas, faz riscos descerem pelos jorros, ondula a lâmina d'água, deforma e sombreia as nuvens, faz cada grupo de chamas tremer com o seu halo e faz a luz dos vitrais respirar. Um golpe forte perto de um estandarte pintado sopra o pano.

**Os bichos.** Corvos ficam pousados no chão e nas galerias, bicam o chão de vez em quando, **levantam voo quando o Penitente (ou Beatriz) chega perto** ou quando um golpe forte estala, e voltam a pousar longe depois de uns 15 a 25 segundos. Morcegos pendem sob as galerias e **saem em revoada quando se passa por baixo**. Ratos farejam o chão e **fogem correndo**. Nenhum tem colisão nem causa dano.

**O primeiro plano.** Sinos, gaiolas e ganchos escuros pendem de cima da tela, entre a câmera e a cena, só no terço de cima, e passam mais depressa que a sala. É o que dá a sensação de profundidade.

**O temporal.** No Terraço dos Sinos chove **do lado de fora dos arcos** (a chuva só aparece onde a pintura tem céu), com som de chuva, e relampeja a cada 9 a 19 segundos, com trovão.

## Acessibilidade
Com **reduzir pulsos** (tecla P) ligado: as chamas param de tremer e **não há relâmpago** (só o trovão ao longe). O balanço dos panos, a água e os bichos continuam, porque não piscam.

## Como refazer as máscaras
Se uma pintura de sala mudar:

```
python3 tools/gerar_mascaras_vivas.py            # gera assets/vivo/
python3 tools/gerar_mascaras_vivas.py --revisar  # grava também imagens de conferência
```

Uma sala nova entra em três lugares: `SALAS` no script das máscaras, `SALAS` em `pintura_viva.gd` e `SALAS` em `bichos.gd` e `primeiro_plano.gd`.

## O que foi verificado e o que falta
- `tests/v39_cenario_smoke.gd`: 149 verificações (máscaras, pintura ligada em toda sala no mesmo lugar e tamanho de antes, sopro, relâmpago e reduzir pulsos, fuga de corvos, morcegos e ratos, primeiro plano, Vale de fora).
- `tests/v39_cenario_review.gd` grava quadros de cada sala com o renderizador real; a diferença entre quadros confirma movimento em todas.
- **Não verificado:** como o movimento é percebido por uma pessoa jogando, o desempenho (não foi medido; se pesar em algum computador, **F6** desliga a pintura viva e volta à pintura parada) e se o primeiro plano atrapalha em alguma luta. As máscaras foram geradas por cor: pode haver um detalhe vermelho que balança sem ser pano, ou um pano escuro que ficou parado.
- O que **continua parado**: a arquitetura em si. Para a pintura ter camadas de verdade (céu, fundo distante e construção se movendo em velocidades diferentes, como no Vale), é preciso arte separada por camada; o pedido está em `prompts-codex-v39.md`.
