# Lacrimae of the Penitent

Jogo de ação e exploração 2D feito no Godot. A história acompanha o Penitente pelo reino de Vespera, devastado por uma maldição ligada à culpa e à absolvição.

## Como jogar

1. Abra o Godot Standard 4.6.3, usado na validação da versão 35.
2. Importe o arquivo `project.godot`.
3. Aguarde a importação dos arquivos e pressione **F5**.

## Controles

- **A / D:** mover o Penitente
- **Espaço / W:** pular; **S + Espaço:** descer de uma galeria
- **J / X:** atacar; no ar, corte aéreo
- **I (segurar):** carregar golpe pesado; **S + J no ar:** golpe descendente
- **L:** aparar
- **K / Shift:** esquivar
- **E:** interagir ou executar inimigo atordoado
- **F:** curar
- **Q:** penitência
- **R:** oferecer lágrimas no altar
- **V:** trocar penitências no altar; **1 / 2 / 3:** escolher
- **Esc:** pausar
- **M:** ativar ou silenciar o som
- **F11:** alternar tela cheia (a escolha fica salva). Em telas menores que 1280×720 em janela (ex.: notebook 1366×768), o jogo abre em tela cheia na primeira vez
- **TAB:** abrir o mapa
- **H:** compartilhar sangue; perto do parceiro caído, segurar para levantá-lo
- **P:** reduzir pulsos e tremores (no título ou na pausa)
- **C:** abrir o Confessionário em qualquer lugar, fora de combate: um chat com IA (Gemini) que tira dúvidas e dá pistas; veja [docs/confessionario.md](docs/confessionario.md)
- **F3:** modo dev; ↑/↓ selecionam sala, Enter transporta, G alterna invencibilidade, N alterna voo e B vai ao chefe
- **F4:** alternar Beatriz entre IA e jogadora 2
- **Enter:** iniciar; **C:** continuar salvamento no título

### Controle (Xbox, PlayStation ou genérico)

O **1º controle** conectado é o Penitente; o **2º controle** é Beatriz (mesmos botões, sem menus). No controle de PlayStation, A=✕, B=○, X=□, Y=△. Ao usar o controle, as dicas na tela passam a mostrar os botões.

| Ação | Botão | Ação | Botão |
|---|---|---|---|
| Mover | analógico esquerdo ou direcional | Baixo / descer galeria | ↓ (↓ + A desce) |
| Pular | A | Atacar | X |
| Esquivar | B | Interagir, orar, executar | Y |
| Aparar | RB | Golpe carregado (segurar) | RT |
| Curar | LB | Penitência | LT |
| Doar sangue / levantar parceiro | ↑ | Mapa | Back / View |
| Pausa | Start / Menu | Penitências no altar | L3 (escolher com X / Y / B) |
| Oferecer lágrimas no altar | R3 | Título: iniciar / continuar | A / Y |
| Confessionário | segurar Y (ou Start, depois Y) | Perguntas prontas | ↑ / ↓ escolhe, A pergunta, B fecha |

No controle, o Confessionário oferece perguntas prontas que mudam conforme a jornada; digitar perguntas livres continua no teclado (C). F3, F4, F11, M e P também ficam no teclado.

Beatriz acompanha o Penitente e luta por conta própria. Para assumir o segundo personagem, use **setas** para mover, **↑ / Num8** para pular, **↓ / Num2** para baixo, teclado numérico **1** para atacar, **3** para esquivar, **4** para aparar, **5** para carregar golpe, **6** para curar, **0** para doar sangue e **Enter numérico** para interagir. Também é possível usar um segundo controle.

A [integração da versão 32](docs/v32-integracao.md) inclui os sons enviados pelo autor, a arte adaptada de Beatriz e a correção dos efeitos de duas fileiras.

A [versão 33](docs/v33-integracao.md) acrescenta seis execuções próprias, impactos por material e três posturas de Beatriz conforme o peso da lança, com folhas de contato e testes no Godot 4.6.3.

O primeiro ato tem dez locais interligados: sete no percurso principal e três salas secretas (Nave do Silêncio, Terraço dos Sinos e Pátio dos Portões Selados). Há relevo de alvenaria no chão, galerias elevadas, quinze passagens, quatro atalhos, nove altares, nove descobertas opcionais e um mapa. Inclui penitências equipáveis, fragmentos de culpa e a homenagem no memorial dos portões.

Detalhes da expansão de salas em [docs/expansao-v09.md](docs/expansao-v09.md). O bestiário, com cinco criaturas inspiradas em Goya, está em [docs/bestiario-goya.md](docs/bestiario-goya.md) e as cenas de culpa em [docs/cenas-culpa.md](docs/cenas-culpa.md).

O projeto está em desenvolvimento. A versão atual contém o trecho inicial do primeiro ato.

[Roteiro dos cinco atos](docs/roteiro-cinco-atos.md). Os atos II–V ainda estão no roteiro.

Para jogar o Ato I e relatar o que sentiu, use o [roteiro de playtest](docs/roteiro-de-playtest.md).

Acessibilidade: a tecla **P**, no título e na pausa, reduz pulsos de luz e tremores nas cenas de culpa e do Guardião (veja [docs/acessibilidade-cenas.md](docs/acessibilidade-cenas.md)).

Combate: **J** golpe, **K** esquiva, **L** aparo (aperte quando o golpe chegar; golpes marcados com anel dourado podem ser aparados, os demais só se esquivam), **F** curar, **E** executar um inimigo aberto.


A [integração da versão 35](docs/v35-integracao.md) inclui o código de sangue das execuções, correções do modo dev e dos controles da dupla, a nova pausa e os pontos de integração dos sons de gore. Os WAVs novos ainda não foram entregues; os sons existentes foram preservados. A lista adicional de arte e mecânicas está registrada como pendente, sem ser apresentada como pronta.

Para o professor: [guia de apresentação](docs/guia-de-apresentacao.md), [defeitos corrigidos](docs/v34-defeitos.md) e [resultados dos testes](docs/v35-testes.json). O guia registra o uso de Claude, Codex, geração de imagens e referências do Argon. As verificações automatizadas não substituem uma partida humana para avaliar a sensação do combate.
