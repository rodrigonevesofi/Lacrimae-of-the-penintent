# Lacrimae of the Penitent

Jogo de ação e exploração 2D feito no Godot. A história acompanha o Penitente pelo reino de Vespera, devastado por uma maldição ligada à culpa e à absolvição.

## Como jogar

1. Abra o Godot Standard 4.6.3, usado na validação da versão 33.
2. Importe o arquivo `project.godot`.
3. Aguarde a importação dos arquivos e pressione **F5**.

## Controles

- **A / D:** mover o Penitente
- **Espaço:** pular; **S + Espaço:** descer de uma galeria
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
- **TAB:** abrir o mapa
- **H:** compartilhar sangue; perto do parceiro caído, segurar para levantá-lo
- **F3:** modo de desenvolvimento para visitar salas

Beatriz acompanha o Penitente e luta por conta própria. Para assumir o segundo personagem, use **setas** para mover, **↑** para pular, teclado numérico **1** para atacar, **3** para esquivar, **4** para aparar, **5** para carregar golpe, **6** para curar, **0** para doar sangue e **Enter numérico** para interagir. Também é possível usar um segundo controle.

A [integração da versão 32](docs/v32-integracao.md) inclui os sons enviados pelo autor, a arte adaptada de Beatriz e a correção dos efeitos de duas fileiras.

A [versão 33](docs/v33-integracao.md) acrescenta seis execuções próprias, impactos por material e três posturas de Beatriz conforme o peso da lança, com folhas de contato e testes no Godot 4.6.3.

O primeiro ato tem dez locais interligados: sete no percurso principal e três salas secretas (Nave do Silêncio, Terraço dos Sinos e Pátio dos Portões Selados). Há relevo de alvenaria no chão, galerias elevadas, quinze passagens, quatro atalhos, nove altares, nove descobertas opcionais e um mapa. Inclui penitências equipáveis, fragmentos de culpa e a homenagem no memorial dos portões.

Detalhes da expansão de salas em [docs/expansao-v09.md](docs/expansao-v09.md). O bestiário, com cinco criaturas inspiradas em Goya, está em [docs/bestiario-goya.md](docs/bestiario-goya.md) e as cenas de culpa em [docs/cenas-culpa.md](docs/cenas-culpa.md).

O projeto está em desenvolvimento. A versão atual contém o trecho inicial do primeiro ato.

[Roteiro dos cinco atos](docs/roteiro-cinco-atos.md). Os atos II–V ainda estão no roteiro.

Para jogar o Ato I e relatar o que sentiu, use o [roteiro de playtest](docs/roteiro-de-playtest.md).

Acessibilidade: a tecla **P**, no título e na pausa, reduz pulsos de luz e tremores nas cenas de culpa e do Guardião (veja [docs/acessibilidade-cenas.md](docs/acessibilidade-cenas.md)).

Combate: **J** golpe, **K** esquiva, **L** aparo (aperte quando o golpe chegar; golpes marcados com anel dourado podem ser aparados, os demais só se esquivam), **F** curar, **E** executar um inimigo aberto.
