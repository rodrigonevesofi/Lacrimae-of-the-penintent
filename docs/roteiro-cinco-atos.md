# Lacrimae of the Penitent — roteiro dos cinco atos

**Documento de trabalho para revisão narrativa.** A prioridade de produção é refinar o Ato I e fechar o roteiro da campanha. Este texto não solicita implementar os Atos II–V agora. O cânone fornecido pelo autor permanece em [campanha.md](campanha.md); eventos, personagens secundários, habilidades e condições de final acrescentados aqui são propostas de desenvolvimento, não novas decisões atribuídas ao autor.

## 1. Escopo, limites e promessa dramática

**Pergunta da campanha:** o que faz alguém que descobre ter causado um sofrimento que nenhuma punição pode desfazer?

O movimento emocional é: procurar uma sentença → reconhecer o próprio ato → perder a desculpa da ignorância → ouvir quem sofreu sem exigir acolhimento → escolher o que fazer com a vida restante. A vitória não prova merecimento de perdão. A campanha termina com uma ação e suas consequências, não com um julgamento moral do jogador.

### O que existe e o que este roteiro propõe

| Camada | Situação nesta entrega |
| --- | --- |
| Base jogável do Ato I | Sete locais, dois mecanismos de corrente, salto duplo, atalhos, Guardião dos Sinos, memória dos portões e retorno à exploração. A saída encerra a demonstração; não carrega o Ato II. Ver [ato-i-exploracao.md](ato-i-exploracao.md). |
| Investigação de Alba | Refinamento do Ato I em trabalho nesta entrega: boneca com sol bordado, registro, nomes lidos com Iria, memorial que pode receber o nome depois. Os textos têm fonte em `scripts/story_text.gd`. A revisão do roteiro não substitui a validação dessa implementação. |
| Encenação detalhada abaixo | Algumas falas e acontecimentos ampliam a base atual. São direção de roteiro, mesmo quando usam uma sala já existente. Não presumir dublagem, animações ou interações implementadas. |
| Atos II, III, IV e V | Roteiro proposto. Não há campanha jogável desses atos nesta entrega. |
| Reparações posteriores, novas habilidades e finais | Propostas. Condições de final, sinalização e consequências precisam de aprovação editorial e posterior implementação/testes. |

### Verdades que não podem mudar de lugar

1. **Ato I:** o Penitente fechou os portões. Ainda não explicar que criou o ritual ou pediu esquecimento.
2. **Ato II:** participou da criação do Lacrimae Sacramentum. Sua intenção de aliviar sofrimento não o isenta daquilo que fez depois.
3. **Ato III:** escolheu entregar suas memórias; não foi apenas vítima de uma amnésia imposta.
4. **Ato IV:** Iria ficou dentro dos portões e sobreviveu; sua família não. Sua voz reconhecida no Ato I não autoriza antecipar essa relação com a tragédia.
5. **Ato V:** a Mãe das Lágrimas é a entidade formada pelo sofrimento extraído. Não é a Primeira Mártir, uma divindade comprovada nem o chefe do Ato I.

A Ordem extrai **a sensação de culpa**, não apaga acontecimentos, mortos, responsabilidades ou o direito de uma vítima recusar contato. Entregar memórias é uma aplicação excepcional do ritual no arco do Penitente; não presumir que todos os fiéis perdiam suas lembranças. O nome anterior do protagonista continua **a definir pelo autor**. Não inventar um nome em placas, arquivos ou falas.

Alba é uma criança secundária, de oito invernos. Joana, tecelã, e Tomé, sineiro, aparecem no mesmo registro. O documento não fixa parentescos entre os três nem com Iria. Nenhum deles substitui a família de Iria. Não confirmar sobrevivência, morte localizada ou reencontro de Alba sem nova decisão do autor; o que o jogador sabe é que ela esperou nos portões e não voltou para buscar a boneca.

### Gramática das cenas

- A exploração transmite a maioria das informações: direção das fechaduras, instrumentos ainda funcionando, lugares preparados para quem não voltou, registros corrigidos por outra mão.
- Uma conversa entrega uma tensão ou uma ação seguinte. Usar normalmente duas a quatro intervenções, com pausas e reações físicas; não reunir toda a história de um lugar numa fala.
- Memórias obrigatórias: fragmentos de aproximadamente 15–30 segundos, com legenda, opção de avançar e recapitulação acessível. Não usar documentos opcionais para esconder revelações necessárias à compreensão.
- O presente é jogável. As memórias mostram atos já praticados: se houver movimento nelas, deixar claro que não se pode alterar o passado. Nunca obrigar o jogador a apertar um botão para fechar os portões e depois tratá-lo como autor daquela escolha.
- Após cada grande revelação, oferecer espaço sem combate para o jogador andar, parar ou voltar. A emoção não deve ser imediatamente coberta por uma recompensa numérica.
- Lágrimas de sangue pertencem a momentos narrativos específicos. A culpa pode acrescentar sinos e dissonâncias à música, sem mudar a dificuldade nem determinar qual final o jogador merece.

## 2. Arquitetura da campanha e retornos

A campanha tem uma ordem de revelações, mas cada região contém uma rota principal, um desvio de testemunho e um atalho de retorno. As habilidades abrem usos novos em lugares conhecidos. Não trancar a região anterior ao concluir um ato.

| Ato | Percurso proposto | Capacidade e uso | O que permanece ao retornar |
| --- | --- | --- | --- |
| I | Cidade ↔ Ossuário ↔ Cisterna; Claustro ↔ Campanário ↔ Arquivo; desvio ao Abrigo | Salto duplo já presente; alcança o mecanismo alto e passadiços de retorno. | Memorial, nomes, abrigo e Iria; investigação pode continuar após o chefe. |
| II | Basílica: nave pública ↔ confessionários ↔ enfermaria; galeria superior ↔ reservatório | **Passo entre grades**, avanço horizontal curto por vãos marcados, proposto. Não atravessa qualquer parede. | Voltar ao Arquivo abre depósito de plantas; rota curta liga a enfermaria à Cidade. |
| III | Aqueduto ↔ mosteiro exterior ↔ celas de silêncio ↔ torre do Abade | **Gancho da vigília**, ferramenta que se prende a argolas identificáveis, proposta. | Rotas sobre poços e acesso às galerias de manutenção da Cisterna. |
| IV | Vale: pedreira ↔ abrigo vivo ↔ arquivo das sentenças ↔ patíbulo; elevador funerário retorna à Cidade | Uso combinado das capacidades anteriores; conquista principal é abrir uma rota compartilhada. Não adicionar habilidade só para preencher a estrutura. | Sobreviventes e objetos se deslocam de forma visível pela passagem aberta. |
| V | Subsolo da Basílica: galerias de escoamento ↔ reservatórios ↔ câmara da origem ↔ trono | Combina o repertório; apresenta as consequências das rotas reparadas. | Um limiar explícito permite voltar às tarefas pendentes antes da decisão final. |

Os nomes das novas habilidades são rótulos de design, não promessas de nomenclatura final. Não converter a descoberta de uma verdade dolorosa em poder mágico que prova purificação. Ferramentas vêm do espaço explorado; memórias vêm dos confrontos e vestígios.

**Três retornos com finalidade:** o passo permite procurar uma planta no Arquivo; o gancho permite alcançar o escoamento da Cisterna; a passagem do Vale permite levar pessoas vivas a um abrigo seguro. Cada retorno muda uma necessidade concreta do mundo. Evitar buscar três selos idênticos apenas para prolongar a rota.

## 3. Ato I — O Despertar do Condenado

**Tema:** primeiro descobrir quem ficou para trás. **Desejo inicial:** obter uma sentença que explique sua condenação. **Mudança:** reconhecer um ato próprio antes de conhecer sua justificativa.

**Objetivo obrigatório:** atravessar a Cidade, liberar as duas correntes, enfrentar o Guardião e alcançar a lembrança dos portões. **Pergunta em aberto:** por que alguém que ouviu as súplicas decidiu fechar?

### I.1 — O túmulo e o primeiro gesto

**Local:** capela subterrânea, ligada à Cidade. **Forma:** prólogo breve seguido de controle imediato.

Preservar o prólogo canônico de [campanha.md](campanha.md). A espada precisa ser recolhida. A inscrição acusa, mas não explica os fatos. Uma corrente de ar move a chama em direção à saída; um sino responde quando o Penitente se levanta, sem mostrar quem o acionou.

**Fala proposta do Penitente, baixa, ao tocar a inscrição:**

> “Milhares. E nenhum rosto.”

Não narrar sua biografia. O primeiro altar ensina o retorno após a morte com uma ação do jogador. A inscrição do altar pode dizer: “A pedra guarda seu lugar.” Ela não promete perdão.

**Gameplay e emoção:** aprender a mover o corpo antes de poder explicar quem ele é. A primeira travessia leva de um túmulo individual a uma cidade que não consegue sepultar os seus mortos.

### I.2 — A voz que Iria reconhece

**Local:** pátio da Cidade. **Forma:** conversa curta; a primeira frase pode acontecer por proximidade, o restante por interação.

Iria está ocupada separando cera utilizável. Não espera imóvel apenas para entregar a história ao protagonista. Ao ouvi-lo, interrompe o trabalho; volta a ele antes de responder.

> **Iria:** “Condenado... eu reconheceria sua voz.”
>
> **Penitente:** “De onde?”
>
> **Iria:** “Há coisas que ainda não consigo lhe dizer. Nos abrigos, procure o que ficou sem dono.”

A formulação pode ser ajustada à fala já implementada: “Procure primeiro aqueles que você condenou.” O sentido deve ser o mesmo. Iria não é obrigada a explicar sua vida ao jogador e não perde interações futuras se ele partir.

**Objetivo espacial:** o acesso ao sino está preso por duas correntes. A ponte quebrada exige a rota inferior. As duas necessidades são legíveis antes de qualquer tarefa opcional.

**O que ocultar:** nenhuma menção à família de Iria, à criação do ritual ou a um pedido de esquecimento.

### I.3 — O lugar vazio e o nome que falta

**Locais:** Ossuário, Abrigo das Cinzas, Arquivo das Confissões. **Forma:** investigação opcional em qualquer ordem.

1. **Ossuário:** um nicho sem corpo e o pano “voltarei amanhã”. A cidade oferece uma ausência antes de oferecer um objeto de missão.
2. **Abrigo:** boneca de tecido, consertada várias vezes; sol bordado no pulso esquerdo. Cobertores reservam espaço para alguém que não chegou. O frasco adicional tem outra origem e não é pagamento por lembrar uma criança.
3. **Arquivo:** “Alba — oito invernos. Sinal: um sol bordado no pulso.” Joana e Tomé aparecem ao lado, todos marcados “aguardando”. A página seguinte deixa de contar pessoas e passa a pesar lágrimas.
4. **Iria:** pede que os nomes sejam lidos. O jogador ouve os três, com tempo entre eles. Ela não identifica Alba como filha, sobrinha ou membro de sua família.
5. **Memorial:** boneca e nome podem ser depositados em visitas diferentes. Se a boneca veio primeiro, o espaço para o nome continua disponível. Se o registro veio primeiro, a marca bordada confirma a ligação ao encontrar a boneca.

**Falas centrais compatíveis com o refinamento em curso:**

> **Iria, diante do registro:** “Você trouxe nomes, não desculpas. Leia.”
>
> **Penitente:** “Alba. Joana. Tomé.”
>
> **Iria, depois do memorial:** “Não sei se alguém virá procurá-lo. Mas não confunda esse gesto com perdão.”

**Consequência imediata:** o memorial muda; a fala e a memória reconhecem a descoberta. Sem redução de culpa como certificado de bondade, sem objeto de combate concedido por “salvar” uma criança que não foi salva. Para a campanha completa, prever a releitura do registro no diário ou junto ao memorial; essa consulta persistente é uma proposta, não uma função confirmada do protótipo atual.

**Se ignorado:** o ato continua compreensível. A memória mostra uma criança ainda sem nome para o protagonista. A investigação permanece disponível no retorno.

### I.4 — Duas correntes, duas maneiras de ouvir

**Locais:** Cisterna, Claustro e Campanário. **Forma:** exploração, plataforma e combate.

A corrente da Cisterna exige descer sob a cidade. Ao liberá-la, a água descobre a frase “ainda cabem mais dois”. Não explicar quem a escreveu. A outra corrente exige a subida do Campanário e o salto duplo. O atalho superior permite rever o pátio de onde a rota começou.

Na liberação da corrente alta, ouvir três batidas vindas do lado interditado. Elas terminam antes que o jogador possa localizar alguém. Esse padrão retorna na memória; não é sinal de uma criança viva esperando resgate agora.

**Contraste jogável:** descer para ouvir os que ficaram sob a cidade; subir para interromper o instrumento que cobre suas vozes. O sino indica a progressão pela mudança do som, sem depender apenas de texto.

### I.5 — Guardião dos Sinos

**Local:** arena do bronze. **Forma:** chefe em duas partes de encenação, sem exigir alterar agora a quantidade de fases do código.

**Entrada:** o corpo fundido ao sino tenta puxar uma corda que já não existe. Ele mantém o alarme porque parar significaria ter de ouvir a cidade.

> **Guardião:** “Enquanto tocar, alguém virá abrir.”

**Combate proposto:** na primeira parte, os toques marcam ataques amplos; na segunda, os intervalos ficam maiores e revelam o som das batidas no portão. Ataques mantêm sinais visuais equivalentes. Não colocar uma confissão longa no meio de golpes que exigem atenção.

**Derrota:** a mão continua o gesto da corda por um instante. O bronze fica imóvel.

> **Guardião:** “Não veio ninguém.”

Não afirmar que o Guardião é Tomé. A coincidência entre profissão e chefe seria uma nova identidade canônica; permanece vedada até decisão do autor.

### I.6 — A Primeira Lágrima: os portões

**Forma:** memória curta não interativa, seguida de caminhada livre.

Plano fechado das mãos sobre o mecanismo. Vozes pedem passagem. Uma mão pequena segura o ferro; no pulso de tecido, o sol. O Penitente olha para trás, para uma figura que permanece indistinta. Ele gira a roda. Três batidas. Corte antes de qualquer explicação sobre a ordem recebida.

> **Voz do outro lado:** “Abra. Ainda estamos aqui.”
>
> **Memória, sem nome conhecido:** “Suas mãos fecharam os portões.”
>
> **Variação com Alba identificada:** “Alba não estava pedindo absolvição. Suas mãos fecharam os portões.”

**Retorno ao controle:** a espada está baixa. O primeiro passo quebra o silêncio, sem música triunfal. O jogador pode voltar ao memorial ou procurar Iria.

> **Penitente:** “Eu ouvi.”
>
> **Iria:** “Quando encontrar uma porta fechada, lembre-se de ouvir antes de obedecer.”

**Saída do ato, proposta para a campanha:** sob o mecanismo está o selo da Basílica. A galeria de serviço abre o caminho à origem da ordem. Objetivo: “Descobrir quem ordenou o fechamento.” Essa pergunta será aprofundada, não respondida por um vilão que absorve toda a responsabilidade.

**Saída na demonstração atual:** encerrar a vigília é escolha explícita junto aos portões, após poder revisitar as salas. Mostrar “Fim do Ato I disponível nesta versão”; não exibir um dos finais da campanha nem prometer que a porta já leva a uma fase jogável.

## 4. Ato II — A Basílica Profanada

**Tema:** o alívio tornado instituição. **Desejo:** achar o responsável pela ordem. **Mudança:** perceber que sua responsabilidade começou antes dos portões.

**Objetivo:** atravessar a Basílica e alcançar o reservatório da Madre. **Revelação obrigatória:** o Penitente participou da criação do ritual. **Estado emocional final:** a busca por um culpado externo deixa de sustentar sua jornada.

### II.1 — A fila que não termina

**Local:** nave das petições. **Forma:** entrada jogável.

Bancos vazios têm números; figuras transformadas repetem apenas o início de suas confissões. Um atendente morto continua abrindo uma janela para ninguém. Nas paredes, duas camadas de normas: a antiga oferece acolhimento; a mais recente exige comparecimento e comprovação de arrependimento.

**Vestígios curtos, em lugares distintos:**

> “Atendimento aos que não conseguem dormir.”
>
> “Ausência à confissão será registrada como recusa.”

O jogador abre por dentro uma passagem de serviço que liga a enfermaria à Cidade. A Basílica tem saídas para seus funcionários que os fiéis desconheciam: a arquitetura demonstra a desigualdade.

### II.2 — Edran oferece uma explicação

**Local:** pequena enfermaria. **Forma:** encontro obrigatório curto; perguntas extras opcionais.

Edran limpa um leito realmente usado por um sobrevivente. Foi líder da Igreja; não ocultar indefinidamente sua posição só para preparar uma surpresa. Ele reconhece o Penitente e sabe que ele trabalhou no ritual, mas evita nomeá-lo como autor nessa primeira conversa.

> **Edran:** “Eu ouvi confissões aqui quando ainda havia quem voltasse para casa.”
>
> **Penitente:** “De quem foi a ordem dos portões?”
>
> **Edran:** “Da Ordem. Eu a transmiti. Disseram que a cidade inteira morreria se abríssemos.”
>
> **Penitente:** “E vocês souberam se era verdade?”
>
> **Edran:** “Não fomos verificar.”

Essa participação de Edran é **proposta**, explicitamente sujeita à revisão do autor. Serve para dar consequência à sua defesa da instituição. Ele não controla a memória do Penitente nem explica sozinho toda a catástrofe.

**Ação útil:** indica a rota ao reservatório e oferece um cuidado material sem cobrar confissão. A ajuda torna sua contradição concreta: ele pode socorrer alguém e ainda proteger a doutrina que o feriu.

### II.3 — O que os livros deixaram de contar

**Locais:** confessionários, depósito de instrumentos e galeria superior. **Forma:** duas rotas que reencontram o reservatório.

A rota baixa contém uma lista de moradores obrigados a confessar. A alta contém um livro de primeiros atendimentos: “dormiu sem gritar”, “voltou ao trabalho”, “dor permanece”. O ritual produziu alívio real; sua existência não deve depender de todos os fiéis terem sido tolos.

**Documento obrigatório, curto:** as folhas posteriores medem apenas extração. Um gráfico simples ou mudança de cabeçalho transmite a passagem de cuidado a produção. Nenhum texto afirma que os atos cometidos foram apagados.

**Semente opcional para o desmonte:** uma nota de manutenção distingue interromper a entrada de romper o recipiente cheio: “Fechar a admissão antes de soltar o receptáculo. Uma ruptura devolve a carga pela primeira linha aberta.” O jogador ainda não sabe onde todas essas linhas terminam. Essa regra acompanha a proposta de final e deve ser validada com ela.

**Ferramenta proposta:** obter o Passo entre grades numa sala de manutenção, testá-lo no próprio caminho de saída e abrir um atalho. Ele permitirá entrar, em retorno ao Ato I, no depósito de plantas do Arquivo. Esse registro será útil para o desmonte final, sem revelar agora a solução completa.

### II.4 — Madre Dolorosa

**Local:** reservatório do coro, sob a nave. **Forma:** chefe; revelação após a luta.

A Madre está suspensa por correntes sobre o sangue. Ela fazia funcionar os ritos obrigatórios e ainda entende resistência como sofrimento a ser tratado. As correntes têm o mesmo desenho dos mecanismos descobertos pelo jogador, com um estágio de controle a mais.

> **Madre:** “Esta casa aprendeu com suas mãos.”
>
> **Penitente:** “Eu não me lembro desta casa.”
>
> **Madre:** “A casa se lembra.”

**Combate proposto:** interromper correntes que protegem a Madre abre períodos de vulnerabilidade e muda as passagens da arena. O jogador aprende a reconhecer uma rede de condução, sem já aprender que destruí-la de qualquer modo seria seguro. O chefe não obriga ferir penitentes indefesos para progredir.

**Fim:** o reservatório deixa de receber novas lágrimas, mas o volume guardado não desaparece. A Madre vê um frasco vazio e tenta enchê-lo com a própria mão.

> **Madre:** “Se ainda dói, não terminamos.”

### II.5 — A segunda memória: antes do milagre

**Forma:** memória curta.

O protagonista, sem rosto completamente revelado, ajusta um primeiro instrumento. Uma pessoa exausta consegue repousar; ele fica ao lado do leito até a respiração se estabilizar. O corte seguinte mostra instrumentos iguais instalados em fileira. Sua mão assina um desenho técnico; a assinatura não permite ler o nome ainda não definido.

> **Penitente do passado:** “Se pudermos aliviar uma noite, já vale tentar.”
>
> **Voz da Madre, em outro tempo:** “Agora precisamos atender a cidade inteira.”

A montagem encerra numa anotação dele: “A dor retirada permanece no receptáculo.” Ele conhecia a acumulação; o roteiro não afirma que previu o despertar da entidade. A intenção inicial e o risco observável coexistem.

**Presente, conversa de saída com Edran:**

> **Penitente:** “Eu fiz o primeiro.”
>
> **Edran:** “Você tentou ajudar.”
>
> **Penitente:** “Isso explica o começo.”

O Penitente não conclui que bondade inicial absolve o restante. Edran aponta o Mosteiro, onde o ritual era aplicado à memória. Não revela ainda que o Penitente pediu isso.

**Transição:** uma marca de procedimento na coroa corresponde ao selo monástico. Abrir o aqueduto alto inicia a subida. A cidade continua acessível para recuperar nomes e plantas.

## 5. Ato III — O Mosteiro das Lágrimas

**Tema:** sofrimento usado para apagar a pessoa. **Desejo:** encontrar o que lhe foi feito. **Mudança:** reconhecer aquilo que pediu que fizessem.

**Objetivo:** alcançar o Abade Sem Rosto e recuperar o registro de admissão. **Revelação obrigatória:** escolheu esquecer. **Estado final:** o Penitente perde a esperança de que a memória completa o transforme numa vítima inocente.

### III.1 — A subida e o cuidado recusado

**Locais:** aqueduto, rochedos e hospedaria monástica. **Forma:** exploração vertical.

Monges estão presos a instrumentos que impedem repouso. Um sino pequeno chama para refeições que apodrecem sem ser tocadas. Há celas abertas cujos ocupantes não conseguem acreditar que podem sair.

**História secundária proposta — o cuidador da hospedaria:** um sobrevivente sem nome definitivo conserva água, cobertores e uma passagem para pessoas fugidas do Vale. Seu objetivo é mantê-las vivas. Não pede que o Penitente sacrifique vida ou moeda para demonstrar sinceridade.

> **Cuidador:** “Eles aprenderam a pedir licença para ter sede. Deixe a água onde alcancem.”

**Ação:** abrir uma tomada de água e uma porta emperrada; quando o jogador volta, um banco mudou de lugar e alguém bebe. Essa linha terá continuação no Vale. Pode ser feita depois do chefe e recuperada em atos posteriores.

### III.2 — A ferramenta de quem mantinha os caminhos

**Locais:** passarela rompida e oficina exterior. **Forma:** exploração em laço.

O Gancho da vigília permite alcançar argolas de manutenção e retornar pela face externa da torre. A ferramenta possui marcas de reparos comuns, não é uma relíquia concedida por ser digno. Depois de aprendê-la, o jogador enxerga uma argola igual no caminho antigo para a Cisterna.

**Vestígio opcional:** um projeto da Ordem mostra que os receptáculos menores escoavam para um único fundo. É a segunda parte do conhecimento necessário ao futuro desmonte, ainda sem nomear a entidade como santa ou deusa.

**Ligação com Edran:** uma autorização assinada por ele manda continuar um tratamento apesar de perda crescente de memória. Ao ser confrontado em retorno, ele admite a assinatura:

> **Edran:** “Eu chamava a ausência de dor de melhora. Era mais fácil perguntar menos.”

Confrontá-lo acrescenta ao arco, mas não é condição secreta para qualquer final.

### III.3 — As celas sem nomes

**Local:** corredor interno. **Forma:** percurso curto com duas interações opcionais.

Os nomes foram raspados das portas. Dentro, objetos ainda guardam usos pessoais: uma caneca reparada, marcas de altura, uma carta dobrada muitas vezes. Uma instrução manda repetir “não me pertence” até que a lembrança perca o rosto.

O Penitente encontra uma cela com o encaixe de sua coroa. A parede não tem uma explicação; tem riscos das mesmas mãos tentando registrar algo antes de esquecer. Apenas “portões” continua legível.

**Fala:**

> **Penitente:** “Eu tentei guardar uma palavra.”

A presença da palavra impede a leitura simplista de que sua escolha foi fácil ou inteiramente bem-sucedida. Isso não cancela sua decisão de procurar o procedimento.

### III.4 — O Abade Sem Rosto

**Local:** câmara sem espelhos. **Forma:** encontro e chefe.

O Abade sacrificou a própria identidade e tornou essa perda uma receita para os outros. Ele reconhece o procedimento na coroa, não precisa lembrar o rosto do Penitente. As páginas de admissão substituem sua memória.

> **Abade:** “Conheço a marca. O rosto não importa.”
>
> **Penitente:** “Importava a quem o esperava.”

**Combate proposto:** o Abade repete sequências previsíveis, mas apaga temporariamente partes da iluminação do cenário. Plataformas, sinais de ataque e opções de acessibilidade continuam legíveis. Não remover controles, instruções necessárias ou decisões do jogador para simbolizar perda de identidade.

**Derrota:** cai a máscara lisa; sob ela, a encenação evita um rosto-surpresa. O Abade encontra no livro a marca do Penitente.

> **Abade:** “Você não perdeu suas memórias. Você implorou para esquecê-las.”

### III.5 — A terceira memória: o pedido

**Forma:** memória curta, seguida de sala silenciosa.

O Penitente chega ao Mosteiro ainda capaz de dizer o que fez. Mãos afastam dele a espada. Quando oferecem água, ele a empurra; pede o procedimento. Não mostrar Edran coagindo-o por trás nem um feitiço que elimine sua agência.

> **Penitente do passado:** “Quando fecho os olhos, ainda escuto. Tire de mim o caminho de volta.”
>
> **Abade:** “Eles continuarão do outro lado.”
>
> **Penitente do passado:** “Eu sei.”

Uma mão começa a escrever “portões” na parede. Corte para a palavra vista na cela. Uma lágrima de sangue aparece no presente, por um instante.

**Depois:** o corredor de saída não contém combate imediato. Ao retornar à hospedaria, o jogador encontra a água colocada anteriormente ou a tarefa ainda pendente. A mesma ação simples tem outro peso após a revelação.

**Transição:** o registro de remoções leva ao Vale, para onde a Ordem enviava recusantes e testemunhas. Iria deixou, por um mensageiro do abrigo, a indicação de que está seguindo para lá. O jogador vai encontrar pessoas cujos nomes a instituição tentou eliminar. Não dizer ainda o que houve com a família dela.

## 6. Ato IV — O Vale dos Flagelados

**Tema:** ouvir sem negociar perdão. **Desejo:** contar a verdade sobre si. **Mudança:** perceber que a necessidade alheia não se organiza ao redor de sua confissão.

**Objetivo:** libertar a passagem do Vale e obter acesso ao subsolo da Basílica. **Revelação:** Iria sobreviveu aos portões; sua família morreu lá. **Decisão emocional:** continuar a ajudar mesmo que ela recuse perdoá-lo.

### IV.1 — A entrada que só abre por fora

**Locais:** pedreira e abrigo vivo. **Forma:** exploração com objetivo claro.

O Vale reúne condenados por crimes, recusantes do ritual e pessoas punidas por registrar os abusos. Não distinguir quem merece água ou saída pela sentença recebida. O arquivo registra acusações; não é uma fonte infalível sobre culpa real.

O caminho por onde o Penitente entrou pode ser vencido com suas ferramentas; os moradores não conseguem atravessá-lo. A missão do abrigo pede uma rota utilizável por todos, não apenas pelo protagonista.

> **Moradora:** “Você consegue subir. Nós precisamos de uma porta.”

**Gameplay:** localizar o elevador funerário, restaurar sua plataforma e soltar o travamento pelo lado do patíbulo. Reaproveitar capacidades e atalhos; não transformar a tarefa numa coleta arbitrária de materiais.

### IV.2 — Iria escolhe falar

**Local:** abrigo, após a chegada; não condicionar a revelação a entregar presentes. **Forma:** conversa obrigatória curta, seguida de silêncio livre.

Iria veio com uma pequena caravana por um caminho baixo conhecido pelos sobreviventes; não percorreu sozinha as plataformas que o jogo exige do Penitente. Ela está ajudando a organizar a saída. Ele chega com o registro, mas ela o interrompe antes da confissão preparada.

> **Penitente:** “Eu me lembro do ferro. Da ordem. Eu...”
>
> **Iria:** “Eu estava dentro.”
>
> **Penitente:** “Você saiu.”
>
> **Iria:** “A minha família não.”

Pausa. Iria continua o trabalho. Não revelar nessa pausa nomes de familiares ainda não definidos pelo autor.

> **Penitente:** “O que posso fazer?”
>
> **Iria:** “Por eles, não sei. Aqui há gente que precisa sair antes da noite.”

Se o jogador escolhe a pergunta opcional “Você poderá me perdoar?”, a resposta é clara:

> **Iria:** “Não posso lhe dar isso. Você vai abrir a passagem mesmo assim?”

A saída do diálogo não obriga uma resposta heroica. O jogador demonstra a resposta na rota. Nenhuma opção de fala transforma Iria em inimiga ou tranca o final reparador. A cegueira não é prova de santidade nem punição; sua experiência e suas decisões sustentam a cena.

### IV.3 — As pessoas além da sentença

**Locais:** arquivo do Vale, corredor de saída e retorno à Cidade. **Forma:** linha secundária com consequências visíveis.

O abrigo precisa de uma cópia dos nomes para que quem segue adiante possa ser encontrado. Os registros da Cidade e do Vale não coincidem: número de entrada e nome de uso aparecem em folhas diferentes. O jogador pode reunir e devolver as páginas, deixando os moradores conferirem os próprios nomes. Não obrigá-lo a escolher quem tem direito a existir no registro.

**Continuação de Alba:** o sol bordado reaparece num desenho simples do abrigo antigo, sem revelar uma descendência secreta. Se a investigação do Ato I está concluída, o memorial entra na lista de lugares onde procurar desaparecidos. Se está incompleta, o escriba do abrigo indica quais dados faltam: objeto, sinal ou nome. Essa informação permite concluir a linha em retorno, sem guia externo.

> **Escriba:** “Não escreva ‘ninguém voltou’ onde só sabemos que ninguém foi procurar.”

Não converter a incerteza sobre Alba numa promessa de resgate. A consequência é preservar uma procura e impedir que pessoas virem apenas uma contagem.

**Continuação da hospedaria:** abrir a passagem e preparar a água permite que o abrigo do Mosteiro receba moradores do Vale. Algumas pessoas preferem permanecer e recebem mantimentos. Recusar uma mudança não equivale a fracassar numa missão de salvamento.

**Consequência persistente:** o jogador vê o elevador transportando cobertores, ouve conversa na hospedaria e encontra bancos vazios no Vale. Não apenas uma notificação “missão concluída”.

### IV.4 — O Carrasco dos Mil Lamentos

**Local:** patíbulo sobre o mecanismo da passagem. **Forma:** chefe que protege uma função concreta.

O Carrasco continua executando ordens depois de a cadeia de comando ter desaparecido. Não é um simples duplo inocente do protagonista; a comparação nasce de sua justificativa.

> **Carrasco:** “A sentença não era minha.”
>
> **Penitente:** “A mão era.”

**Combate proposto:** o Carrasco usa a corrente do elevador como arma e bloqueia o acesso ao destravamento. O jogador rompe seus pontos de controle sem destruir a plataforma necessária aos moradores. O objetivo final é abrir a passagem; o corpo derrotado não recebe uma celebração de execução.

**Derrota:** o Carrasco procura um selo para saber o que fazer. Não encontra.

> **Carrasco:** “Quem responde agora?”
>
> **Penitente:** “Eu respondo pelo que fiz.”

A fala não significa assumir todos os crimes da Ordem nem falar em nome das vítimas.

### IV.5 — A quarta memória: a palavra inteira

**Forma:** memória curta que completa o contexto dos portões.

Retomar exatamente o gesto visto no Ato I. Antes de girar a roda, o protagonista recebe a ordem: conter a propagação. Ele olha a abertura. Há pessoas ao alcance. Sua hesitação termina numa decisão; não num empurrão de outra pessoa.

> **Penitente do passado, antes da ordem:** “Vou manter a passagem aberta.”
>
> **Voz de comando:** “Se o Pranto passar, você responderá por toda Vespera.”

A memória não confirma que o fechamento salvaria o reino. Mostra a ameaça usada para obter obediência e a promessa que ele quebrou. Não afirmar que ele conhecia pessoalmente toda a família de Iria; a promessa foi feita às pessoas esperando na passagem.

**Nome próprio:** o cânone reserva aqui a recuperação do nome. Até o autor defini-lo, o tratamento de produção deve manter a rubrica **[NOME A DEFINIR PELO AUTOR — NÃO EXIBIR NO JOGO]**. Nenhum diálogo depende de uma palavra inventada. Quando houver definição, alguém o chama na memória e ele a reconhece em silêncio. O nome recuperado não substitui os nomes das vítimas.

**Saída da memória:** o ato seguinte do jogador é operar a passagem no presente. Um som de ferro semelhante ao do Ato I acompanha o movimento inverso: abrir. Não sugerir que abrir agora desfaz o fechamento anterior.

### IV.6 — Edran diante da saída

**Local:** início do elevador, em visita posterior ao chefe. **Forma:** encontro breve com duas respostas possíveis.

Edran seguiu a rota aberta desde a Cidade, levando materiais da enfermaria. Ele vê quem havia sido excluído entrar nela. O Penitente pode mostrar os registros; se não os encontrou, a passagem aberta já fornece evidência suficiente para a conversa.

> **Edran:** “Se o ritual acabar, o que digo a quem entregou a vida a ele?”
>
> **Penitente:** “Que não precisa entregar o resto.”

**Variação proposta:** se confrontado com os registros, Edran aceita copiar os nomes e entregar as chaves do arquivo. Se não foi confrontado, permanece ajudando na água, mas ainda chama os sobreviventes de penitentes; uma pessoa o corrige pelo próprio nome. Ambas as versões preservam a possibilidade de mudança e a responsabilidade pelo passado. Nenhuma oferece reconciliação obrigatória com Iria.

**Transição:** o elevador funerário dá acesso às galerias sob a Basílica. Iria fica com os moradores. Ela não entrega um amuleto de perdão como chave da fase final.

> **Iria, na partida:** “Se voltar, ainda haverá trabalho.”

## 7. Ato V — O Trono do Último Pranto

**Tema:** aliviar a si mesmo, conter o sofrimento ou interromper a máquina. **Desejo:** pôr fim ao ritual. **Conflito:** o sistema oferece ao Penitente exatamente o descanso pelo qual ele já trocou suas memórias.

**Objetivo:** alcançar a origem do reservatório e decidir o destino do Lacrimae Sacramentum. **Revelação:** a Mãe depende do que Vespera deposita nela; não existe uma absolvição divina escondida que anule as responsabilidades.

### V.1 — Tudo o que foi retirado

**Local:** galerias e reservatórios. **Forma:** exploração final que recompõe a arquitetura visitada.

O jogador reconhece tubulações da Cidade, correntes da Basílica e selos do Mosteiro. O subsolo recebe de todos esses lugares. A arte distingue condução ritual e água de consumo: separar seus mecanismos não significa despejar sofrimento num rio ou no abastecimento dos abrigos. Pequenas vozes sobrepostas repetem frases incompletas, não uma exposição explicando a cosmologia.

**Vestígio obrigatório:** instrumento de medição antigo conserva um aviso do próprio projeto: retirar de uma pessoa não faz deixar de existir. Ao lado, uma ordem posterior manda aumentar a capacidade. Esse encontro reúne o que já foi descoberto; não acrescenta uma culpa nova de última hora.

A rota comum permite chegar ao trono. As galerias laterais permitem inspecionar os três pontos de condução relevantes para o desmonte. Cada um corresponde a um lugar e uma ação conhecidos, não a um selo abstrato de virtude.

### V.2 — A última possibilidade de voltar

**Local:** antecâmara do trono. **Forma:** pausa segura com retorno livre.

Marcar o limiar: entrar no confronto não apaga a campanha salva. Antes de confirmar a decisão final, o jogador pode retornar às reparações. Ao concluir um final, uma opção de continuar deve restaurar o estado anterior ao limiar, sem reescrever o epílogo como se nada tivesse acontecido.

**Registro de tarefas proposto, sem pontuação moral:** listar fatos e pendências legíveis: nomes devolvidos; abrigo preparado; passagem aberta; projeto de condução compreendido; escoamento interrompido. Cada pendência aponta uma região descoberta. As condições para o terceiro final não devem ser surpresa revelada depois de horas de irreversibilidade.

**Se houver dúvida sobre a segurança do desmonte:** o mapa mostra condutos ainda ligados às áreas habitadas. O risco se entende pelo espaço e por uma descrição direta. Não ameaçar com uma catástrofe aleatória apenas para justificar um final secreto.

### V.3 — A Mãe das Lágrimas

**Local:** trono dentro do receptáculo original. **Forma:** aparição e combate final.

A entidade tem um rosto que não se estabiliza. Sua voz pode conter cadências de pessoas ouvidas, mas não deve imitar a família morta de Iria para confirmar que suas almas pertencem a ela. A Mãe é feita do sofrimento rejeitado; as vítimas não são automaticamente seus servos nem obstáculos que o jogador precisa matar.

> **Mãe:** “Você voltou cansado.”
>
> **Penitente:** “Vim terminar o que comecei.”
>
> **Mãe:** “Foi isso que me pediu da outra vez.”

Ela pode saber do pedido porque recebeu o sofrimento retirado no procedimento, não por onisciência. Não revelar outras vidas desconhecidas para aumentar artificialmente a escala.

**Combate proposto em três movimentos:**

1. **Acúmulo:** ondas seguem as entradas dos condutos; usar mobilidade para alcançar as margens, reconhecendo o padrão da rede.
2. **Contenção:** o trono fecha passagens e tenta manter o Penitente junto ao centro. Ferramentas abrem janelas de fuga; não retirar comandos como metáfora de rendição.
3. **Silêncio:** derrotada a manifestação que o impede de agir, a Mãe deixa de atacar e oferece descanso. A escolha final acontece fora do combate, com seus efeitos descritos sem urgência artificial.

A derrota de combate rompe a defesa da entidade, não destrói automaticamente a rede. Assim os três finais continuam causalmente possíveis após a mesma luta.

### V.4 — A oferta

> **Mãe:** “Posso tirar os rostos. Posso deixar que durma.”
>
> **Penitente:** “E quem ainda estiver lá em cima?”
>
> **Mãe:** “Terá onde deixar a dor. Como você teve.”

**Alternativas apresentadas por ações concretas:** aceitar o procedimento; ocupar o receptáculo; desmontar a condução preparada. Mostrar uma frase curta de consequência antes de confirmar. Nenhum rótulo “bom”, “ruim” ou “verdadeiro”.

Se as condições do desmonte faltam, o terceiro caminho permanece visível como possibilidade incompleta: “Ainda há condutos ligados aos abrigos” ou a pendência real correspondente. Oferecer “Voltar” antes de confirmar outro caminho. A Mãe não decide se o protagonista merece o terceiro final.

## 8. Desfechos e consequências

Todos os textos e cenas a seguir são propostas de roteiro. Nenhum final está implementado nesta entrega.

### A — A Absolvição

**Ação:** o Penitente aceita entregar novamente as memórias. **Disponibilidade:** sempre, após o confronto.

Ele pousa a espada. A Mãe toca a coroa. Pela última vez, o memorial aparece na lembrança; o nome se desfaz antes da pedra. Não mostrar os mortos agradecendo. O protagonista repousa e a rede permanece operante.

> **Penitente:** “Eu não quero ouvir mais.”
>
> **Mãe:** “Então descanse.”

**Epílogo visual breve, proposto:** a câmera percorre a Cidade; não abrir ações novas que contradigam a decisão encerrada. Um sino volta a soar. No abrigo, alguém repete a pergunta que o protagonista já não ouvirá.

**Variações do mundo:**

- Se o memorial recebeu o nome, Alba continua inscrita: o esquecimento dele não apaga o trabalho material feito.
- Se a passagem foi aberta, moradores continuam usando-a, embora a maldição permaneça. Não desfazer retroativamente toda ajuda para punir a escolha.
- Edran, se entregou as chaves e confrontou os registros, fecha o confessionário de sua enfermaria; se não, prepara uma cadeira diante dele. Em ambos os casos, a rede maior sobrevive.
- Iria não comenta a decisão em nome dos mortos. Vela pelo abrigo, se ele foi preparado, ou pelo lugar onde ainda estão os moradores.

**Última imagem:** o receptáculo recebe uma nova gota. A paz individual não encerrou a condenação de Vespera.

### B — O Sacrifício

**Ação:** o Penitente assume o lugar da entidade, aprisiona o sofrimento e interrompe os rituais. **Disponibilidade:** sempre, após o confronto.

Ele entra no receptáculo em lugar de pedir que o esvaziem. A coroa se prende à estrutura. A Mãe perde a forma enquanto ele passa a suportar o que estava acumulado. As entradas de extração se fecham; não nascem novos ritos autorizados por ele.

> **Mãe:** “Você não caberá em si.”
>
> **Penitente:** “Então feche depois de mim.”

O sacrifício não é prova de superioridade moral, não ressuscita vítimas e não deve sugerir que a única ajuda possível é autodestruição. Ele produz o resultado canônico de conter o sofrimento, ao custo da vida livre do protagonista. O jogo não confirma paz interior.

**Variações do mundo:**

- Abrigo e passagem concluídos dão aos sobreviventes estrutura para enfrentar o fim da instituição. Sem eles, a saída dos antigos dependentes é mais lenta e difícil; mostrar ajuda começando, sem uma contagem punitiva de mortos.
- Nomes preservados acompanham os corpos e desaparecidos; sem registros, moradores ainda procuram como identificá-los.
- Edran pode desmontar o confessionário ou permanecer diante dele sem saber o que dizer. Sua mudança depende de confrontar evidências, não de assistir a um martírio.
- Uma pessoa inicia uma oração ao Penitente. Iria pousa ao lado dela um balde necessário ao abrigo: “Ajude-me a levar.” O gesto desloca a cena para o cuidado; não confirma a criação de outra religião inevitável.

**Última imagem:** dentro da pedra, a mão permanece aberta. Do lado de fora, alguém atravessa uma porta que já não se fecha para exigir confissão.

### C — A Última Lágrima

**Ação:** rejeitar a absolvição, desmontar o ritual e sobreviver com as memórias. **Disponibilidade proposta:** investigação e preparação concretas, recuperáveis antes da decisão final.

Não medir bondade, nível de culpa, quantidade de mortes, dinheiro doado ou disposição de Iria para perdoar. A condição combina **saber como interromper** a rede com **preparar quem será afetado**.

| Preparação proposta | Evidência / ação | Por que importa |
| --- | --- | --- |
| Dar continuidade aos nomes | Concluir boneca + registro + leitura dos nomes + memorial de Alba; devolver ao abrigo a cópia dos desaparecidos. | A linha começa como descoberta individual e termina preservando pessoas identificáveis após a Ordem. É compromisso narrativo, não energia mágica necessária ao mecanismo. |
| Cuidar de quem vive | Preparar água na hospedaria e abrir a passagem coletiva do Vale; conversar com o abrigo após a mudança para verificar chegada e necessidades. | Retirar dependência imediata dos setores da rede que serão desligados. Pessoas podem optar por ficar e receber água por outra rota. |
| Compreender o desmonte | Reunir planta do Arquivo, esquema de derivação do Mosteiro e aviso de carga no subsolo; registrar a sequência de isolamento. | Saber que quebrar o receptáculo cheio apenas redistribuiria o sofrimento. Não bastam golpes mais fortes. |
| Isolar a condução | Abrir o escoamento inerte da Cisterna, fechar a alimentação do reservatório da Basílica e separar o ramo dos abrigos no subsolo, nessa ordem sinalizada. | Criar um caminho de desmonte que não despeje o acúmulo nas pessoas do lado de fora. |

**Decisão editorial a validar:** tornar a linha de Alba obrigatória para esse final reforça a passagem de multidão anônima a nomes, mas pode parecer uma exigência arbitrária sobre uma criança. A proposta inicial mantém essa exigência **visível e recuperável**, sem chamá-la de necessidade física do ritual. Se os testes indicarem sensação de checklist, permitir outra história de nomes com igual profundidade; nunca trocar por uma quantidade genérica de colecionáveis. A escolha final do autor deve anteceder a implementação.

**Lógica sobrenatural proposta, a validar:** a Mãe não pode receber eternamente sofrimento novo se as entradas forem cortadas. Com os condutos isolados, desfazer o receptáculo libera as culpas extraídas de volta à condição humana de lembrar e sentir; não injeta crimes ou memórias de estranhos em inocentes. O que pertence a mortos perde sua prisão, sem cena que certifique um além ou perdão divino. A dor dos vivos não desaparece, e a assistência preparada importa. Esta regra precisa ser semeada pelo esquema de derivação e confirmada no aviso de carga antes da escolha; não pode surgir como milagre conveniente no último minuto.

**Cena final:** o Penitente retira a coroa e a deixa no chão. Opera o mesmo travamento de manutenção usado para isolar os ramos da rede; a alimentação residual cessa e o mecanismo não reinicia. A coroa não funciona como chave secreta ou artefato purificador. A Mãe oferece uma última troca enquanto a estrutura se desfaz.

> **Mãe:** “Vai doer quando você se lembrar.”
>
> **Penitente:** “Eu sei.”

Ele usa a rota construída para sair; não escapa por intervenção divina ou resgate inesperado de Iria. Uma única lágrima de sangue cai antes de ele alcançar o ar. Não lhe atribuir poder purificador.

**Epílogo jogável curto:** sem combate, o jogador leva uma tábua para completar o degrau de um abrigo. O gesto é simples e não recebe medalha. Iria está próxima, ocupada; não espera uma declaração.

> **Penitente:** “Posso ficar?”
>
> **Iria:** “Há trabalho. O lugar para a tábua é ali.”

Não inserir abraço, promessa de perdão ou romance como recompensa. Ela decide a distância que mantém. O protagonista continua vivo com o que sabe, e os moradores conservam o direito de recusá-lo.

**Variações:** nomes recuperados aparecem nos pontos de busca; pessoas ajudadas mantêm conversas próprias; Edran pode aprender a ouvir sem conduzir uma confissão. Mesmo com todas as linhas concluídas, há nomes sem resposta e famílias que não retornam.

**Última imagem:** uma porta aberta; o Penitente permanece para repará-la. O vento move a chama sem apagar o nome de Alba.

## 9. Arcos recorrentes e decisões de encenação

### O Penitente

| Momento | O que acredita | O que faz para mudar |
| --- | --- | --- |
| Início | Uma sentença poderá dizer o que ele é. | Segue uma acusação gravada na pedra. |
| Fim do I | Ele praticou um ato concreto; as vítimas têm rostos. | Pode retornar para dar nome à ausência. |
| Fim do II | A intenção inicial não basta para explicar as consequências. | Procura o próprio registro, mesmo após receber uma desculpa de Edran. |
| Fim do III | Ele participou também do apagamento da verdade. | Retoma uma tarefa de cuidado que não exige ser inocente. |
| Fim do IV | Dizer a verdade não obriga ninguém a acolhê-lo. | Abre uma rota coletiva depois da recusa de Iria. |
| Final | Descanso, contenção e vida com responsabilidade têm custos distintos. | Sua ação encerra o arco; nenhum narrador o declara puro. |

### Iria

Ela tem vida e objetivos fora do protagonista: preservar nomes, organizar abrigo e abrir caminhos para sobreviventes. Reconhecer sua voz no Ato I não significa estar pronta para narrar o trauma. No Ato IV, escolhe o momento de revelar a perda. Não é medidor de culpa, tutorial permanente, prêmio romântico ou porta-voz de todos os mortos. Sua recusa de perdão continua válida em todos os finais.

### Edran

Ajudar pessoas e defender a instituição coexistem desde sua primeira cena. Sua linha progride de “o ritual ajudava” a “eu não quis perguntar pelo custo”. A mudança mais convincente é material: entregar chaves, copiar nomes, desmontar o confessionário. Uma fala correta não resolve sua cumplicidade. Ele pode continuar ambivalente até o fim, sem ser revelado como manipulador que secretamente causou cada ato do protagonista.

### Mãe das Lágrimas

É uma consequência que aprendeu a desejar a própria continuidade. Oferece alívio real e cobra a manutenção da rede; sua proposta repete a tentação original. Não precisa mentir sobre tudo nem ser a fonte de todo mal humano. O culto à Primeira Mártir existe antes; a relação histórica entre Mártir e entidade permanece não definida e não deve ser inventada pela arte ou pelo diálogo.

### Motivos que mudam de sentido

- **Porta:** bloqueio no Ato I; privilégio de serviço no II; cela aberta que ninguém atravessa no III; passagem coletiva no IV; saída ou prisão escolhida no V.
- **Mão:** recolhe a espada; fecha o mecanismo na memória; assina o primeiro projeto; pede que retirem as lembranças; abre uma passagem; escolhe o destino da rede.
- **Nome:** falta na lápide; aparece à margem do peso; é raspado nas celas; volta à voz dos moradores; permanece legível mesmo se o protagonista escolhe esquecer.
- **Sino:** encobre pedidos; organiza a extração; exige penitência; deixa espaço para conversa; seu retorno ou silêncio revela a continuidade do ritual.
- **Água:** nível que bloqueia exploração; recurso administrado pela instituição; cuidado acessível; condição de acolhimento; circulação que precisa ser separada do sistema de extração.

Não usar esses motivos em todas as falas. Reservar a repetição verbal para momentos que mudam seu significado.

## 10. Continuidade, retomadas e critérios de revisão

### Estado narrativo mínimo proposto

Guardar fatos separados, não um único “karma”: boneca encontrada; boneca depositada; registro encontrado; nomes lidos; Alba inscrita; memória dos portões vista; projeto reconhecido; pedido de esquecimento lembrado; testemunho de Iria ouvido; passagem coletiva aberta; abrigo abastecido; registros devolvidos; planos de condução compreendidos; ramos isolados; posição atual de Edran; final confirmado.

A investigação de Alba aceita as ordens boneca→registro e registro→boneca. Depositar antes de conhecer o nome deve abrir uma visita de nomeação posterior. Mudança de ato não cancela uma tarefa. Não exigir refazer a leitura inteira para reconhecer um único fato novo.

### Regras de causalidade para implementação futura

1. Se o protagonista conhece um fato, sua fala não volta a simular ignorância. A recapitulação do diário descreve o que viu, não antecipa o próximo segredo.
2. A família de Iria nunca aparece como explicação escondida do registro de Alba. A arte do memorial também deve evitar essa associação.
3. Os documentos do Ato II podem mostrar mecanismos familiares; não contêm uma frase explícita “você pediu para esquecer”. Essa confirmação é do III.
4. A memória final contextualiza o fechamento; não absolve o Penitente ao declarar que “qualquer pessoa faria o mesmo” ou que o fechamento comprovadamente salvou Vespera.
5. Memórias de sofrimento não restauram vida, moeda ou frascos como prêmio dramático. Recompensas de progressão podem ocorrer separadas, com origem legível.
6. A fuga de moradores precisa usar uma rota que pessoas sem salto duplo possam percorrer. Iria não se teletransporta entre regiões sem justificativa estabelecida.
7. O terceiro final precisa ser compreendido antes de escolhido. O jogador pode interromper a aproximação ao trono para terminar pendências; não há tarefa narrativa essencial perdida para sempre por uma fala.
8. A destruição da rede não torna o protagonista sem culpa, nem exige redistribuir sofrimento a inocentes para funcionar. A regra sobrenatural permanece proposta até aprovação do autor.
9. Não reutilizar a Mãe no Ato I. Não chamar uma luta vencida de absolvição concedida. Não fixar o nome próprio antes de o autor o definir.
10. O fim da demonstração diz exatamente o que termina: o conteúdo jogável disponível, não a história de Vespera.

### Perguntas para sessões de leitura e jogo

Após o I, o jogador consegue dizer o que o protagonista fez, mas ainda pergunta por quê? A boneca produz uma pessoa lembrável, em vez de apenas um ícone no mapa? Após o II, entende que intenção e responsabilidade coexistem? Após o III, a escolha de esquecer é dolorosa sem apagar a possibilidade de agir? No IV, Iria consegue ser compreendida como pessoa que recusa, e não como obstáculo a uma recompensa? Antes do V, o jogador entende os três caminhos e sabe como preparar o desmonte? Os retornos mudam lugares e vidas, além de completar registros?

A duração de cada ato, o tempo das pausas e o número de encontros de combate dependem de testes humanos. Este roteiro não usa o tempo de testes automatizados como previsão de duração ou prova de impacto emocional.

## 11. Notas de referência — fora do jogo

Todos os diálogos propostos acima são originais. As referências abaixo são apoio crítico para o autor, não inscrições com capítulo e versículo nem citações para inserir na interface.

- **Isaías 58:** crítica ao jejum que convive com opressão; cuidado e liberdade como ações materiais. Orienta abrigo, água e passagem coletiva.
- **Ezequiel 18:** responsabilidade pessoal e tensão com a ideia de pecado herdado. Serve para examinar a doutrina de Vespera sem transformar o jogo em exposição teológica.
- **Lucas 19, encontro de Zaqueu:** reparação material como algo distinto de uma declaração de mudança. Não transportar personagens ou falas bíblicas para Vespera.
- **Salmo 51:** reconhecimento de responsabilidade sem tornar uma vítima obrigada a perdoar. Evitar transformar penitência em moeda que compra uma resposta divina.
- **Dante, Inferno, cantos III e V; Purgatório, cantos I–II:** limiares, insistência de vozes e mudança do movimento do corpo entre condenação e possibilidade de caminho. Referências de construção espacial e contraponto, não um mapa para copiar círculos, guardiões ou punições.

Não copiar diálogos de filmes ou jogos. Não transcrever traduções modernas longas. A força dramática pretendida depende dos atos, dos silêncios e das consequências específicas de Vespera.

## Decisões do autor (v23)
- **Quem mandou fechar os portões só é revelado no Ato II.** O Ato I não nomeia Edran em nenhum texto: a inscrição dos Portões Selados e o decreto do Pátio mostram um selo com o nome **raspado**, e a Regra do Confessor fala de "um decreto sem nome". O Ato I termina com a pergunta "Descobrir quem ordenou o fechamento", sem resposta.
- **A Inquisidora serviu a Edran** e aparece no **Ato II**. O close `assets/close/close_06.png` está reservado para ela; o close de Edran (`close_03.png`) também fica para o Ato II.
- **O rosto do Penitente nunca aparece.** `close_01.png` não será usado.
