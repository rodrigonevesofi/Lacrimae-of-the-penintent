# Guia de apresentação — Lacrimae of the Penitent (Ato I)

Sugestão de roteiro de 8 a 10 minutos para mostrar o jogo. Use o **modo dev (F3)** para pular deslocamentos.

Versão atual: **40**, validada no Godot 4.6.3. Se incluir a sequência final abaixo, reserve mais 2 a 3 minutos. [Integração e capturas](v40-integracao.md), [testes](v40-testes.json) e [prompts da arte desta rodada](v39-prompts-arte.md). As nove criaturas aprovadas já têm encontros e animações no mapa. Os nove efeitos do Vale agora tocam e a revelação tem música própria. A luta final mantém a trilha do chefe; as demais músicas anteriores foram preservadas.

1. **Abertura (1 min):** comece um jogo novo; deixe a primeira cena e a Cripta do Despertar falarem. Mostre o HUD: vida, culpa, lágrimas.
2. **Combate (2 min)** — na Cidade, contra os primeiros inimigos:
   - combo de três golpes (**J J J**) e o arremate;
   - **aparo** (**L**) quando aparecer o anel dourado, seguido do contra-ataque forte;
   - cancele um golpe em **K** assim que a lâmina ficar ativa;
   - esquive imediatamente antes do contato: a **esquiva perfeita** deixa um rastro e abre 0,8 s de contra-ataque;
   - espere os **dois padrões** da mesma criatura: dourado permite aparo, vermelho pede esquiva; a chicotada baixa também pode ser saltada;
   - **golpe carregado** (segure **I**);
   - depois do arremate, pule e corte o alvo no ar: há até três suspensões;
   - **golpe descendente** (**S + J** no ar);
   - inimigo aberto → **execução** (**E**), com sangue e câmera lenta.
3. **Exploração (1 min):** mostre um **portão marcado** (arco dourado) e um trancado (vermelho); abra o mapa (**TAB**).
4. **Arena (1 min):** **F3**, vá para a **Cisterna dos Nomes**; entre no trecho com os portões erguidos: eles fecham, vêm as ondas, abrem ao vencer.
5. **Criaturas (1 min):** Nave ou Terraço: o **Carregador de Caixão** (a pedra protege a frente; golpe carregado quebra o caixão).
6. **História (2 min):** a **Memória dos portões** e o **memorial** (a boneca), e o tema de culpa e fé.
7. **Chefe (2 min):** **B** no modo dev (arena do chefe), **G** para não morrer durante a demonstração: o **encontro dentro do jogo** com o Guardião dos Sinos (escala, rosto, lembrança em fogo, grito) e a luta.

Dicas: **P** reduz pulsos e tremores; **M** silencia; **ESC** pausa e mostra os controles.


## Dupla e modo de apresentação

Beatriz começa controlada pela IA. **F4** alterna IA/J2; uma tecla de J2 durante a partida também assume o controle. **←/→** move, **↑/Num8** salta, **↓/Num2** aponta para baixo, **Num1** ataca, **Num3** esquiva, **Num4** apara, **Num5** carrega, **Num6** cura, **Num0** compartilha sangue e **Enter numérico** interage. Segure **H** (Penitente) ou **Num0** (Beatriz) perto do parceiro caído para levantá-lo, gastando vida do doador.

No **F3**, **↑/↓** selecionam a sala e **Enter** transporta; **G** alterna invencibilidade, **N** alterna voo e **B** vai ao chefe. Fechar o voo dentro de alvenaria recupera o último piso seguro. As teclas do painel e do mapa não assumem Beatriz.

## Autoria e ferramentas

Projeto de Rodrigo, desenvolvido no Godot com assistência de Claude e Codex para código, integração, documentação e testes. Há arte produzida com a ferramenta integrada de geração de imagens e referências enviadas pelo autor a partir do Argon; ver `v32-integracao.md`, `v33-integracao.md` e `v36-prompts-arte.md`. Os sons entregues pelo autor foram integrados; os 20 novos WAVs de gore e combate foram enviados em `sons-gore-v32-pacote.zip` e integrados na v36; o gerador de síntese recebido está em `tools/make_sfx_gore_v32.py`. Esta declaração descreve o uso conhecido no projeto; deve acompanhar as regras da disciplina.

As capturas e rotas automatizadas não substituem o ensaio humano com dois jogadores. A v36 executa a lista de arte e combate de `prompts-codex-v35.md`; detalhes, capturas e limites estão em `v36-integracao.md`. A esquiva perfeita e os avisos usam os WAVs enviados no novo pacote, sem escuta humana nesta rodada. Reserve uma partida com dois jogadores para avaliar resposta dos comandos, dificuldade e volume antes da apresentação.

## O final: o Vale dos Flagelados (2 a 3 minutos)
8. **F3**, escolha **VALE DOS FLAGELADOS** e **ENTER**. Mostre o cenário vivo: enforcados e gaiolas balançando, névoa, corvos. Beatriz fica na beira ("Ninguém atravessa a culpa de outro").
9. Ande até o vulto entre as forcas, **o Flagelado**. Ele ergue a cabeça e copia a sua forma: **bata uma vez** para mostrar que o dano volta para você e que cai uma gota de culpa.
10. **Apare** um golpe dele (**L**, no anel dourado) para arrancar a forma verdadeira; ou espere ele recolher as gotas e **rezar**. Com **G** (invencível) ligado, bata até cair a segunda placa: **Beatriz atravessa o vale**.
11. Leve a vida dele ao fim: ele cai de joelhos e vem **a revelação**. Deixe a cena rodar; é o fecho da história.

Explique em uma frase: *o chefe final é a culpa que o protagonista pediu para esquecer; só o vence quem para de fugir do próprio rosto.*

## Cenários vivos (v39)
12. Em qualquer sala, **pare e deixe a tela quieta por alguns segundos**: os estandartes pintados balançam, as velas tremem, a água corre. Na Cisterna, mostre os jorros das fontes; no Claustro, a hera e as folhas caindo.
13. **Ande em direção a um corvo** (Terraço, Pátio, Cidade): ele levanta voo. No Campanário ou no Ossuário, **passe por baixo de uma galeria**: os morcegos saem em revoada.
14. No **Terraço dos Sinos**, espere um relâmpago (a cada 10 a 20 segundos) e mostre a chuva do lado de fora dos arcos.
15. Vale dizer na apresentação: nada disso é vídeo nem imagem trocada; é **shader, AnimationPlayer, AnimatedSprite2D, Tween, Parallax2D e partículas do Godot** sobre as mesmas pinturas.

## Criaturas aprovadas (v39, demonstração opcional de 2 minutos)

16. **F3 → Abrigo**: avance até o Glutão (x=20190). Mostre as colheres e avance na tosse. **F3 → Cisterna**: Meio-Enterrado em x=8870; a terra anuncia o bote.
17. **Nave** (x=23700): deixe o fio das Parcas marcar a posição; esquive ou interrompa. O corte reduz a vida máxima até rezar. **Arquivo** (x=17030): acorde o Sono com um golpe para desfazer as aves.
18. **Terraço** (x=25740): golpe baixo derruba as pernas do Espantalho. **Pátio** (x=28070): golpes dispersam a Romaria. **Claustro** (x=11870): mude de posição depois que o velho apontar.
19. **Ossuário** (x=7520): mostre a lanterna da Viúva e o aparo da estocada. **Vale** (x=31340): apare o primeiro Disciplinante para abrir a formação.

A arquitetura dessas salas conserva a camada de pintura recebida; céu e construção ainda não são camadas independentes. Não apresente os testes como avaliação humana da sensação do combate.

## Atualização da v40

Sem teclado numérico, Beatriz usa (ABNT2) **.** atacar, **,** esquivar, **;** aparar, **Ç** carregar, **~** curar, **´** interagir e **[** doar sangue. F4 alterna IA/jogadora 2. O sangue e as execuções continuam disponíveis.

Na demonstração, mostre o apoio no piso do Claustro e do Campanário, as soleiras das portas altas e o cabo da espada sob a mão. Os efeitos do Vale e a trilha da revelação foram integrados; confira o volume numa partida antes de apresentar. A espada/lança ainda têm alguns quadros com pontas incompletas, conforme [limites da entrega](v40-integracao.md).
