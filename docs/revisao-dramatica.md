# Revisão dramática e verificação narrativa

Revisão independente em 7 de novembro de 2026. Escopo: `campanha.md`, `historia.md`, `roteiro-cinco-atos.md`, `fontes-literarias.md`, `scripts/story_text.gd`, os trechos narrativos e de salvamento de `main.gd`, a memória em `narrative.gd` e seus pontos de integração em `exploration.gd` e `world_art.gd`.

## Conclusão e fronteira da entrega

O arco de Alba agora liga uma pista física a uma pessoa identificável, permite agir no memorial e devolve uma reação de Iria e uma variação da lembrança. A ação não concede cura, dinheiro ou redução de culpa. A ordem das descobertas pode variar sem impedir a conclusão. O roteiro dos cinco atos desenvolve a responsabilidade do Penitente por revelações sucessivas e mantém a recusa de perdão de Iria.

Isso descreve duas entregas distintas: refinamento jogável do Ato I e roteiro proposto da campanha. Os Atos II–V, seus chefes encenados, ferramentas, reparações, epílogos e condições de final não foram implementados por este trabalho. Mesmo no Ato I, falas do Penitente e do Guardião, batidas sonoras precisas e encenações descritas no roteiro são direção proposta quando não constam do código. Não apresentar leitura do roteiro ou teste automatizado como partida completa da campanha.

## Achados concretos e correções acordadas

| Achado | Efeito sobre a experiência | Encaminhamento e estado |
| --- | --- | --- |
| Depois de ler os nomes, com memorial pendente, Iria voltava à saudação inicial. | O diálogo parecia esquecer a descoberta e retirava a indicação de ação seguinte. | Corrigido pelo responsável pela narrativa em `Story.iria_pages`: ramo `has_register and names_read` mantém Alba, abrigo e memorial; oferece outra página quando a memória já ocorreu. Revisado no código. |
| I.3 do roteiro afirmava que o registro continuava consultável. No protótipo, recolher remove a interação e não existe diário de releitura. | Uma capacidade planejada parecia já disponível. | Corrigido pelo responsável pelo roteiro: releitura agora é proposta da campanha completa, não funcionalidade confirmada do protótipo. |
| No terceiro final, encaixar a coroa no regulador resolvia o mecanismo sem preparação suficiente. | Um objeto simbólico virava solução física conveniente no último instante. | Corrigido pelo responsável pelo roteiro: a coroa fica no chão; o Penitente usa o travamento de manutenção já empregado no isolamento dos ramos. |
| Iria prioriza nomes ainda não lidos mesmo depois da memória dos portões. | Uma única conversa não apresenta imediatamente todas as reações possíveis. | Decisão intencional confirmada pelo responsável pela narrativa: leitura primeiro, reação à memória em conversa posterior. Flags permanecem separadas. Não interpretar essa prioridade como perda de progresso. |

## Pista, ação e reação no Ato I

| Pista | Ação possível | Reação confirmada | Limite |
| --- | --- | --- | --- |
| Sol bordado na boneca; sinal correspondente no registro de Alba. | Encontrar os objetos em qualquer ordem. | `knows_alba()` exige ambos; a memória passa a mencionar Alba. | O teste não julga se a marca é legível na imagem em movimento. |
| Registro com Alba, Joana e Tomé; indicação de procurar Iria. | Ler nomes em uma conversa com páginas próprias. | `names_read` é salvo ao terminar a sequência. Reabrir o jogo durante a conversa permite retomá-la do começo. | Não há recapitulação persistente do registro disponível para livre consulta. |
| Memorial e lugar vazio. | Deixar a boneca antes de conhecer Alba ou já com o registro encontrado. | O primeiro caso preserva uma interação posterior de nomeação; o segundo registra `memorial_named` no primeiro depósito. | O desenho atual muda a aparência do memorial conforme a homenagem; a inscrição “Alba” é confirmada pelo texto. Não foi verificada uma inscrição legível no cenário. |
| Nomes conhecidos e memorial concluído. | Voltar a Iria. | Ela reconhece Alba e distingue homenagem de perdão. | Sua família não é identificada como a família de Alba. |
| Duas correntes liberadas. | Abrir caminho ao Guardião. | Textos breves antecipam o espaço e as vozes dos portões sem bloquear o controle. | Três batidas precisas e fases dramatizadas do chefe são propostas de encenação. |
| Memória dos portões. | Reconhecer o ato passado; voltar às salas ou encerrar a demonstração explicitamente. | O jogador conserva a agência no presente; a memória não exige que escolha fechar os portões. | A encenação visual não foi avaliada por sessão humana nesta revisão. |

## Continuidade e revelações

- Ato I: fechamento dos portões. Ato II: participação na criação do ritual. Ato III: pedido de esquecimento. Ato IV: testemunho de Iria e contexto completo da ordem. Ato V: decisão sobre a entidade e a rede. A leitura não encontrou inversão dessas revelações no roteiro revisto.
- O registro não fixa parentesco entre Alba, Joana, Tomé e Iria. Tomé ser sineiro não identifica o Guardião como Tomé. A dúvida sobre Alba não se transforma numa promessa de resgate.
- `historia.md` conserva perguntas do material inicial; sua indicação de precedência de `campanha.md` deve ser respeitada. Essas perguntas históricas não anulam os personagens e finais já definidos em `campanha.md`.
- O nome anterior do protagonista permanece decisão do autor. A rubrica do Ato IV é instrução de produção e não pode chegar à interface.
- Bíblia e Dante aparecem no produto como frases breves dentro das vozes e inscrições. Atribuições ficam em `fontes-literarias.md` e nas notas do roteiro. Referências de jogos não autorizam copiar personagens, diálogos ou recursos visuais.

## Agência, dramaticidade e pontos a resolver antes da campanha completa

O eixo mais sustentado do roteiro é a inversão do gesto dos portões: fechar no passado, abrir uma passagem coletiva no presente. O Vale dá uma necessidade concreta aos moradores, inclusive aos que não querem mudar de abrigo. Iria tem trabalho e deslocamento próprios; a conversa não converte a recusa em bloqueio de missão. Edran ajuda materialmente enquanto continua defendendo a instituição, preservando uma contradição dramática que pode ser encenada.

Três decisões permanecem propostas editoriais, explicitamente marcadas no roteiro: Edran ter transmitido a ordem dos portões; a regra sobrenatural para desarmar o receptáculo; exigir a história específica de Alba para A Última Lágrima. Não há aprovação implícita dessas novas regras nesta revisão.

A exigência de Alba é a ligação causal mais fraca entre história secundária e final. Plantas, isolamento e abrigo explicam como desmontar a rede; uma homenagem específica não explica fisicamente por que o desmonte funciona. O roteiro reconhece a diferença e mantém a tarefa visível e recuperável. Ainda é preciso decidir se será condição obrigatória ou variação de consequência. A transparência evita surpresa, mas sozinha não elimina a impressão de lista de tarefas morais.

A regra de devolver a capacidade de sentir sem transferir crimes de terceiros precisa ser compreendida antes da escolha final. Há sementes no aviso de manutenção do II e nos esquemas posteriores, mas sua clareza só poderá ser julgada na encenação. O terceiro final não deve depender de o leitor aceitar uma regra que o jogador nunca pôde observar.

### Frases que merecem teste de leitura

| Trecho | Risco específico | Direção de revisão futura |
| --- | --- | --- |
| “O peso de cada lágrima.”, durante a memória | Resume o tema sem acrescentar informação situada. | Comparar a versão atual com silêncio ou a primeira súplica dos portões. Não substituir o prólogo canônico sem decisão editorial. |
| “Não peça a uma lembrança que o liberte. Escute o que ela ainda lhe exige.”, Iria após nomes e memória | Duas formulações abstratas consecutivas podem fazer Iria soar como narradora da tese. | Testar uma reação menor e mais concreta, ligada ao lugar ainda vazio. A fala anterior já fornece abrigo e memorial. |
| “Para alguém, ainda são uma porta aberta.”, leitura dos nomes | A metáfora pode encobrir o sentido prático de manter uma procura. | Na leitura encenada, dar tempo aos três nomes antes dessa conclusão; considerar retirar a conclusão se o silêncio cumprir a função. |
| “Eu respondo pelo que fiz.”, derrota do Carrasco, roteiro IV | Declara a mudança antes de o jogador executar o gesto que a comprova. | Preservar a abertura da passagem como conclusão da cena; comparar uma versão com menos fala. |

Esses pontos não bloqueiam o Ato I. São hipóteses de ritmo e voz para leitura em voz alta e jogo observado, não defeitos demonstrados por um teste de flags.

## Verificação realizada e limites

Foi criado e executado `tests/story_review_smoke.gd`: **13 verificações, zero falhas, código de saída 0**, na execução final com Godot 4.6.3. O teste usa interação em posições controladas; cobre registro antes da boneca, interrupção da leitura, reinício por Continue, retorno à conversa, nomeação no primeiro depósito, persistência, ausência de depósito duplicado e resposta de Iria sem perdão automático. Também percorre as combinações dos cinco parâmetros de diálogo para procurar três revelações textuais proibidas; esse último teste lexical complementa a leitura humana, não prova sozinho ausência de spoilers.

Comando utilizado, com diretórios de dados e cache próprios para não escrever no salvamento normal:

```sh
env XDG_DATA_HOME=/tmp/lacrimae-story-review-data XDG_CACHE_HOME=/tmp/lacrimae-story-review-cache godot --headless --path /workspace/Lacrimae-of-the-penintent --script res://tests/story_review_smoke.gd
```

A primeira versão do teste acionava a entrada no contexto de quadro inadequado; isso foi corrigido no teste antes do resultado final. Uma execução intermediária também mostrou erro de compilador de shader durante alterações gráficas paralelas e avisos de encerramento de áudio. A execução final acima terminou sem esses avisos, após as atualizações compartilhadas e encerramento explícito das vozes no teste.

O teste complementar do responsável pela narrativa, `tests/story_smoke.gd`, cobre a ordem boneca antes do registro e a compatibilidade de saves sem flags novas; seu resultado não foi contado nas 13 verificações desta revisão. Não foram medidos nesta revisão duração de campanha, dificuldade, navegação sem teleporte, leitura visual de todas as falas, acessibilidade audiovisual ou efeito emocional em jogadores. Também não houve execução dos Atos II–V, que permanecem roteiro. Nenhum commit foi criado pelo revisor.
