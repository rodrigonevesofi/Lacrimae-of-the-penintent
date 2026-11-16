# Lacrimae of the Penitent

Jogo de ação e exploração 2D feito no Godot. A história acompanha o Penitente pelo reino de Vespera, devastado por uma maldição ligada à culpa e à absolvição.

## Como jogar

1. Abra o Godot Standard 4.6.3, usado na validação da versão 41.
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
- **TAB:** abrir o mapa
- **H:** compartilhar sangue; perto do parceiro caído, segurar para levantá-lo
- **P:** reduzir pulsos e tremores (no título ou na pausa)
- **F3:** modo dev; ↑/↓ selecionam sala, Enter transporta, G alterna invencibilidade, N alterna voo e B vai ao chefe
- **F4:** alternar Beatriz entre IA e jogadora 2
- **F6:** liga ou desliga a pintura viva dos cenários (use se o jogo ficar lento)
- **Enter:** iniciar; **C:** continuar salvamento no título

Beatriz acompanha o Penitente e luta por conta própria. Para assumir o segundo personagem, use **setas** para mover, **↑ / Num8** para pular, **↓ / Num2** para baixo, teclado numérico **1** para atacar, **3** para esquivar, **4** para aparar, **5** para carregar golpe, **6** para curar, **0** para doar sangue e **Enter numérico** para interagir. Também é possível usar um segundo controle. **Em notebook sem teclado numérico** (teclado ABNT2): **.** atacar, **,** esquivar, **;** aparar, **Ç** golpe carregado, **~** curar, **´** interagir e **[** doar sangue. O primeiro comando de Beatriz tira o controle do jogo e o passa para a segunda pessoa; **F4** devolve.

A [integração da versão 32](docs/v32-integracao.md) inclui os sons enviados pelo autor, a arte adaptada de Beatriz e a correção dos efeitos de duas fileiras.

A [versão 33](docs/v33-integracao.md) acrescenta seis execuções próprias, impactos por material e três posturas de Beatriz conforme o peso da lança, com folhas de contato e testes no Godot 4.6.3.

O primeiro ato tem onze locais: sete no percurso principal, três salas secretas (Nave do Silêncio, Terraço dos Sinos e Pátio dos Portões Selados) e o Vale dos Flagelados, alcançado após o Guardião e a memória dos portões. Há relevo de alvenaria no chão, galerias elevadas, atalhos, altares, descobertas opcionais e um mapa. Inclui penitências equipáveis, fragmentos de culpa e a homenagem no memorial dos portões.

Detalhes da expansão de salas em [docs/expansao-v09.md](docs/expansao-v09.md). O bestiário, com cinco criaturas inspiradas em Goya, está em [docs/bestiario-goya.md](docs/bestiario-goya.md) e as cenas de culpa em [docs/cenas-culpa.md](docs/cenas-culpa.md).

O projeto está em desenvolvimento. A versão atual contém o trecho inicial do primeiro ato.

[Roteiro dos cinco atos](docs/roteiro-cinco-atos.md). Os atos II–V ainda estão no roteiro.

Para jogar o Ato I e relatar o que sentiu, use o [roteiro de playtest](docs/roteiro-de-playtest.md).

Acessibilidade: a tecla **P**, no título e na pausa, reduz pulsos de luz e tremores nas cenas de culpa e do Guardião (veja [docs/acessibilidade-cenas.md](docs/acessibilidade-cenas.md)).

Combate: **J** golpe, **K** esquiva, **L** aparo (aperte quando o golpe chegar; golpes marcados com anel dourado podem ser aparados, os demais só se esquivam), **F** curar, **E** executar um inimigo aberto.


A [integração da versão 35](docs/v35-integracao.md) inclui o código de sangue das execuções, correções do modo dev e dos controles da dupla, a nova pausa e os pontos de integração dos sons de gore. Os sons existentes foram preservados. A lista adicional foi executada na [versão 36](docs/v36-integracao.md): 24 atlas novos ou repintados, cancelamento em esquiva no primeiro quadro ativo, comandos de combo preservados, esquiva perfeita com contra-ataque, dois padrões por criatura, suspensão aérea limitada e mortes com queda física. As execuções usam sangue estilizado e manchas persistentes. Os 20 WAVs de gore e combate enviados pelo autor também foram integrados, incluindo os avisos e a esquiva perfeita. [Validação dos sons](docs/v36-audio.json).

Na [versão 38](docs/v38-integracao.md), o Vale recebe camadas pintadas com paralaxe, forcas e gaiolas em pêndulos; O Flagelado tem elmo-gaiola e quatro etapas de armadura. Três monumentos animados dão vida às salas. Dissolução em cinzas, rastros de espada e lança, luz de aparo e respiração das criaturas foram integrados. As [nove fichas novas](docs/fichas/fichas-goya.md) foram aprovadas e integradas na versão 39, com animação e combate próprios. A documentação da integração contém detalhes do final da história.

Para o professor: [guia de apresentação](docs/guia-de-apresentacao.md), [defeitos corrigidos](docs/v34-defeitos.md), [resultados dos testes da v41](docs/v41-testes.json) e [tabela de quadros](docs/combate-quadros.md). O guia registra o uso de Claude, Codex, geração de imagens e referências do Argon. As verificações automatizadas não substituem uma partida humana para avaliar a sensação do combate.

Na [versão 39](docs/v39-integracao.md), nove criaturas aprovadas entram no mapa com regras próprias, cenários vivos, bichos pintados e rosto barbado na revelação. [Contato das criaturas](docs/v39-criaturas-contato.jpg).

Na [versão 40](docs/v40-integracao.md), o polimento do Claude (personagens no piso pintado, pedra da cor de cada sala, espada na mão, folhas limpas) foi unido à versão 39 do Codex, e entraram 99 sons do Argon: os nove efeitos do Vale, as ambiências e a música da revelação. [Relatório dos sons](docs/sons-argon-v40.md).

Na [versão 41](docs/v41-integracao.md), a trilha passa a ser a gerada pelo autor no Lyria 3.5 (nove faixas com coro, em OGG), e a revelação do Vale aceita uma cutscene em vídeo: [prompts e quadros iniciais](docs/prompts-cutscene-veo-v41.md).

Os clipes finais ainda não estão incluídos: a revelação usa os closes atuais até receber os vídeos. [Validação e limites da v41](docs/v41-integracao.md).
