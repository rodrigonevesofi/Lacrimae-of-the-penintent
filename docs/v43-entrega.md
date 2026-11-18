# v43 — resposta ao retorno do professor

Cada item abaixo responde a um ponto do retorno. No fim estão as medições e o que ainda não foi conferido por uma pessoa.

As fotos das seis execuções, do clarão do golpe, do aviso no altar, das oferendas e de Iria estão em [v43-capturas](v43-capturas/).

## 1. Personagens que se misturavam ao cenário

- Novo shader `shaders/ator_legivel.gdshader`, aplicado a todos os atores por `scripts/actor_animation.gd`. Ele desenha um contorno, uma luz de borda vinda do alto e realça um pouco a cor de quem luta.
  - **Penitente:** contorno e borda quentes.
  - **Beatriz:** contorno e borda frios.
  - **Criaturas:** contorno vermelho-escuro.
  - **O Flagelado:** contorno vermelho.
- O cenário recuou um pouco: `pintura_viva.gdshader` e `world_art.gd` tiram parte da saturação e do brilho do fundo e acrescentam uma névoa leve. Assim a frente se destaca sem pintar nada de novo.
- **Golpe recebido:** a criatura atingida pisca inteira numa cor clara por um instante, como nos vídeos de referência. Antes, o clarão quase não aparecia.
- **Iria** tem uma aura clara, um losango sobre a cabeça e o rótulo "IRIA / a testemunha". Nenhuma criatura tem aura.

## 2. Som

- A trilha estava cerca de 15 LU abaixo dos efeitos. A mixagem foi medida em LUFS (EBU R128) numa luta de teste de 14 segundos no claustro (`tools/medir_mixagem.gd`), separando trilha e efeitos.
- Depois do ajuste, a trilha sobe 9 dB e os golpes descem 10 dB. Os sons mais pesados (respingos, jatos, carne, osso e passos) também têm cortes próprios.

| Medição (luta de teste) | Antes | Depois |
|---|---|---|
| Só trilha | −23,2 LUFS | −18,1 LUFS |
| Só efeitos | −8,4 LUFS | −15,7 LUFS |
| Diferença | efeitos 14,8 LU acima | efeitos 2,4 LU acima |

- **Efeitos novos:** o Flow Music faz música, não efeitos curtos. Os prompts para gerar efeitos no ElevenLabs ou no Argon estão em [prompts-efeitos-sonoros-v43.md](prompts-efeitos-sonoros-v43.md), com o nome de arquivo de cada som. Enquanto um som novo não existir, o jogo toca o mais parecido que já tem (`SUBSTITUTOS` em `soundscape.gd`).

## 3. Combate

| Golpe | Como sai |
|---|---|
| Sequência de quatro | Corte, contracorte, estocada e um descendente que arremata. Cada um tem rastro próprio (`scripts/rastro_golpe.gd`) |
| Corte ascendente | Toque rápido no pesado. Joga a criatura para cima |
| Golpe carregado | Segurar o pesado (como antes) |
| Dois golpes no ar | Ataque, ataque, no ar |
| Investida | Ataque logo no fim da esquiva. Atravessa e fere quem estiver no caminho |
| Lâmina de Sangue | **U** ou R3. Gasta um quarto da culpa e lança uma meia-lua que voa e atravessa (`scripts/lamina_sangue.gd`) |

**Aparo:**
- A janela subiu de 0,22 s para 0,36 s.
- Aparar atrasado não deixa mais o golpe entrar inteiro: **bloqueia** três quartos do dano.
- Apertar o aparo até 0,12 s depois de levar um golpe aparável faz o **aparo tardio**, que devolve a vida e abre o inimigo.
- As preparações de ataque das criaturas correm 1,35 vez mais depressa (cerca de um quarto mais curtas).
- Os golpes aparáveis mostram um **brilho dourado** em estrela antes de sair.

## 4. Execuções e gore

- `scripts/gore.gd` corta o quadro da criatura em pedaços com física, que ficam 30 segundos no chão.
- São **seis estilos**, escolhidos pela família da criatura:

| Estilo | O que acontece |
|---|---|
| Cabeça | Decapitação |
| Vertical | Partir de cima a baixo |
| Cintura | Corte na cintura |
| Erguer | A criatura é erguida na lâmina |
| Coração | O coração é arrancado e bate na mão antes de cair |
| Crânio | Esmagamento do crânio |

- Cada estilo tem o seu próprio instante do golpe mortal (`_assinatura_execucao` em `player.gd`): a forma do corte (horizontal no pescoço, linha de cima a baixo, talho na cintura, lâmina subindo, estocada no peito, golpe de cima com estilhaços de osso) e a direção do sangue mudam. Também mudam os jatos, os respingos na tela, a distância de câmera, a câmera lenta e o som.
- Nenhuma execução envolve crianças.

## 5. Tecla na tela

- Portas, correntes, objetos, altar, Iria e execuções mostram a tecla **acima do objeto**: uma placa com a letra, ou o botão colorido do controle, e o rótulo da ação (`hud.gd`, `_draw_aviso_mundo`).
- No altar aparecem as três ações juntas: [E] Orar · [R] Oferendas · [V] Penitências.

## 6. Crescer na jornada

**Oferendas no altar** (tecla R):

| Oferenda | Efeito | Limite |
|---|---|---|
| Vida | +15 de vida máxima | 5 vezes |
| Força | +10% de dano | 5 vezes |
| Frasco | Mais um frasco de cura | 2 vezes |

O preço sobe a cada compra.

**Relíquias escondidas**, em pedestais fora do caminho principal:
- Três **Cálices de Sangue**, cada um com +12 de vida máxima, na cisterna, no campanário e no terraço.
- Dois **Espinhos da Ira**, cada um com +8% de dano, no claustro e no pátio. (Não confundir com o Espinho da Contrição, que dá o salto duplo.)

Tudo é salvo. Beatriz recebe as mesmas melhorias.

O Confessor (a IA) também foi atualizado: a instrução de sistema conhece os golpes novos, as oferendas e as relíquias, recebe quantos Cálices e Espinhos o jogador já tem, e as respostas prontas (sem internet) explicam como ficar mais forte.

## 7. Beatriz e as lágrimas

- **Beatriz faz o mesmo que o Penitente:**
  - Usa os mesmos golpes, porque ela usa o mesmo código.
  - Tem a Lâmina de Sangue: **7** no teclado numérico ou **=** no notebook.
  - Executa com a tecla de interagir dela.
  - No automático, alterna cortes, corte ascendente, investida e Lâmina.
- **Lágrimas:**
  - Saem do corpo da criatura e voam até quem estiver mais perto, o Penitente ou Beatriz. A bolsa é a mesma.
  - Ao trocar de sala ou morrer, as que ainda voam entram na bolsa na hora.
- **Desenho da lágrima:** trocado por uma gema em gota, cor de granada, com brilho, no mesmo tom do resto da interface (`assets/ui/lagrima_gema.png`, `assets/reliquary_ui.png`).

## Testes

- Novos: `tests/v43_smoke.gd` (35 verificações) e `tests/v43_beatriz_smoke.gd` (12 verificações).
- Atualizados para a v43: os testes que esperavam o combo de três, a mixagem zerada, nove descobertas e as preparações antigas.

## O que não foi conferido por uma pessoa

- **Vídeos de referência:** o trailer de lançamento e o short da execução com martelo foram vistos quadro a quadro pelo navegador. O vídeo dos chefes não foi visto, porque a conexão com o computador caiu antes. O que os dois vídeos mostram:
  - **Cenário:** fundos escuros, de pouco contraste e quase de uma cor só (pedra esverdeada, marrom, névoa cinza).
  - **Personagens:** têm os pontos mais claros e as cores mais saturadas da tela (vermelho, prata, verde).
  - **Golpes:** faíscas curtas, brancas e amarelas, e a criatura atingida pisca inteira numa cor clara.
  - **Tecla:** no short, um "E" pequeno aparece sobre a cabeça da criatura atordoada.

  A v43 segue a mesma ideia: contorno, fundo recuado, criatura que pisca ao ser atingida e tecla no mundo. Se ainda faltar contraste, o próximo passo é escurecer mais o fundo (`recuo` em `pintura_viva.gdshader` e `RECUO` em `world_art.gd`).
- **Ninguém ouviu a mixagem nova em alto-falante:** os números são medições.
- **A sensação do combate não foi testada por uma pessoa:** o aparo, a velocidade das criaturas e a variedade foram testados por script.
- **Os golpes novos não têm quadros desenhados próprios.** Eles reaproveitam quadros existentes, com rastro e efeitos novos por cima. O prompt para o Codex desenhar quadros dedicados está em [prompts-codex-v43.md](prompts-codex-v43.md).
