# Guia de apresentação — Lacrimae of the Penitent (Ato I)

Sugestão de roteiro de 8 a 10 minutos para mostrar o jogo. Use o **modo dev (F3)** para pular deslocamentos.

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
