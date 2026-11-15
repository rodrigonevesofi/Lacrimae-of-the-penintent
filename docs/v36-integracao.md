# Integração da versão 36

Base: versão 35, commit `9ec932b69e1299bf715ddfb789ff8eff2773e464`. Esta rodada executa a lista adicional de arte e combate de `prompts-codex-v35.md`, autorizada pelo autor. Os patches e documentos recebidos anteriormente permanecem como registros históricos.

## A1 — Seis execuções e seis reações à execução

Foram repintados os seis atlas `hero_executa_<criatura>.png` e os seis `<criatura>_executado.png`. O Penitente mantém a identidade, o elmo fechado e os gestos existentes. O contato principal fica no quadro local 8 de 12; manchas e gotas continuam nos quadros 9–11. O Carregador recebeu um atlas próprio, separado da versão exposta em combate.

As execuções usam sangue estilizado e corpos inteiros. A mutilação e a anatomia explícita descritas no documento não foram produzidas. Foram mantidos no código os 40 pingos do primeiro ferimento, 90 do golpe mortal, quatro pulsos, névoa, pausa e poça; os testes anteriores de execução não foram reduzidos.

| Criatura | Penitente antes/depois | Criatura antes/depois |
| --- | --- | --- |
| Devorador | [Contato](contatos-v36/comparacao-heroi-devorador.png) | [Contato](contatos-v36/comparacao-criatura-devorador.png) |
| Flagelante | [Contato](contatos-v36/comparacao-heroi-flagelante.png) | [Contato](contatos-v36/comparacao-criatura-flagelante.png) |
| Bruxa | [Contato](contatos-v36/comparacao-heroi-bruxa.png) | [Contato](contatos-v36/comparacao-criatura-bruxa.png) |
| Asmodeia | [Contato](contatos-v36/comparacao-heroi-asmodeia.png) | [Contato](contatos-v36/comparacao-criatura-asmodeia.png) |
| Duelista | [Contato](contatos-v36/comparacao-heroi-duelista.png) | [Contato](contatos-v36/comparacao-criatura-duelista.png) |
| Carregador | [Contato](contatos-v36/comparacao-heroi-carregador.png) | [Contato](contatos-v36/comparacao-criatura-carregador.png) |

[Contato no jogo](contatos-v36/a1-execucao.png). Não validado: percepção do impacto e alinhamento em todas as situações durante uma partida humana; a inspeção foi feita por contatos e cenas dirigidas no renderizador do Godot.

## A2 — Quatro atlas de efeitos ligados ao cenário

| Arquivo | Layout final e uso |
| --- | --- |
| `assets/efeitos/sangue_chao.png` | 1024×256 RGBA; oito células 128×64 na primeira fileira. As três fileiras restantes ficam transparentes. `_place_splat` sorteia as oito variações e apoia a mancha no piso; as poças grandes usam as quatro últimas. |
| `assets/efeitos/sangue_parede.png` | 1024×256; quatro células 256×256. Um raio de até 60 px encontra uma parede vertical próxima do alvo; sem parede não cria decalque. Limite de 45 manchas, 40 s antes de desaparecer em 5 s. |
| `assets/animation/jato_arterial.png` | 1536×256; seis quadros 256×256, 24 fps. Cada pulso de `_arterial_spray` instancia a animação pintada além das gotas existentes. |
| `assets/animation/pedacos.png` | 768×256; seis células 128×128 em duas fileiras e três colunas à esquerda, com a metade direita transparente. O material de partículas lê apenas a região 384×256, com rotação e gravidade. São fragmentos estilizados, sem anatomia identificável. |

As dimensões solicitadas para chão e fragmentos excedem a área das células descritas. Foi preservado o tamanho externo e deixada transparente a área não utilizada, sem esticar os quadros. [Atlas renderizados](contatos-v36/a2-atlas.png). Os limites antigos de 90 respingos e 14 poças continuam ativos. Não validado: desempenho no limite de partículas em outras GPUs, e todas as geometrias possíveis de parede numa partida completa.

## A3 — Oito folhas de reações

`reacoes_<criatura>.png`, 1536×1024, grade 6×4: dano leve 0–2, forte 3–6, arremesso 7–12, atordoamento 13–17 e reação à lança 18–23. Os estados `hurt`, `hurt_heavy`, `launched`, `stagger` e `impaled` foram ligados no manifesto e nas transições. Em Devorador, Duelista, Carregador e Asmodeia, o arremesso mantém o desenho 11 na última amostra: o desenho 12 gerado começava a levantar e causava um salto visual antes da queda física.

Contatos: [Devoto](contatos-v36/reacoes-devoto.png), [Flagelante](contatos-v36/reacoes-flagelante.png), [Devorador](contatos-v36/reacoes-devorador.png), [Duelista](contatos-v36/reacoes-duelista.png), [Carregador](contatos-v36/reacoes-carregador.png), [Bruxa](contatos-v36/reacoes-bruxa.png), [Asmodeia](contatos-v36/reacoes-asmodeia.png), [Chorão](contatos-v36/reacoes-choro.png).

Não validado: leitura dessas reações em combate com muitos inimigos e dois jogadores humanos. Os fundos transparentes, dimensões, seleção dos estados e contagem dos quadros foram conferidos automaticamente e no renderizador.

## B1 — Cancelamentos e comandos

Todo golpe pode sair em esquiva desde seu primeiro contato ativo, se a esquiva estiver disponível. O descendente permite interromper a própria descida. A reserva de comando do combo sobrevive até a próxima janela, mesmo com Beatriz no peso máximo, e é consumida uma única vez. O aparo mantém sua janela mais tardia; não virou cancelamento livre durante a preparação.

[Tabela completa dos dois personagens](combate-quadros.md), [primeiro quadro ativo](contatos-v36/b1-contato.png) e [esquiva após cancelar](contatos-v36/b1-cancelamento.png). Testes medem os limiares de tempo e o comando reservado. Não validado: latência de controle físico, estabilidade de FPS e sensação humana da resposta.

## B2 — Esquiva perfeita

Janela de 0,15 s junto ao contato; o código considera ataques corporais, Guardião, espinhos e trajetórias de projéteis. Uma recompensa por esquiva: 0,3 s reais de câmera lenta a 35%, silhueta translúcida atrás do personagem, som próprio e 0,8 s para começar um contra-ataque forte. Em reduzir pulsos, conserva a recompensa sem câmera lenta.

[Captura](contatos-v36/b2-esquiva-perfeita.png). O som `esquiva_perfeita.wav` veio em `sons-gore-v32-pacote.zip`: PCM16 mono 44,1 kHz, 0,5 s, pico −2,1 dBFS. [Proveniência](v36-som-esquiva.json). Ele substitui a montagem provisória feita antes do recebimento do pacote, que não foi publicada. Testados os limites 0,149/0,151 s, recompensa única, consumo do contra-ataque e fim da câmera lenta. Começar a carga dentro da janela reserva o bônus até a liberação, mesmo após completar os 0,9 s, sem transferi-lo para outro golpe. Não validado: audição humana, todas as velocidades relativas e a adequação da janela para diferentes jogadores.

## B3 — Dois padrões por criatura comum

Os padrões alternam por criatura. O aviso aparece antes do golpe: anel dourado para aparo, vermelho com marca adicional para esquiva. O segundo padrão fixa o alvo na preparação e deixa 0,75 s de recuperação; sua preparação varia de 0,60 a 0,85 s. Os dois avisos usam agora os WAVs `aviso_aparavel` e `aviso_perigo` enviados no pacote, carregados pelos eventos existentes.

| Criatura | Padrão principal | Segundo padrão | Capturas dos avisos |
| --- | --- | --- | --- |
| Devoto | Corte dourado | Investida curta vermelha | [1](contatos-v36/b3-aviso-0-0.png), [2](contatos-v36/b3-aviso-0-1.png) |
| Chorão | Projétil vermelho | Três lágrimas direcionadas douradas | [1](contatos-v36/b3-aviso-1-0.png), [2](contatos-v36/b3-aviso-1-1.png) |
| Devorador | Bote vermelho | Pisão vermelho com duas ondas pelo chão | [1](contatos-v36/b3-aviso-3-0.png), [2](contatos-v36/b3-aviso-3-1.png) |
| Flagelante | Corte próximo dourado ou investida distante vermelha, fixado no aviso | Chicote baixo vermelho, evitável com salto | [1](contatos-v36/b3-aviso-4-0.png), [2](contatos-v36/b3-aviso-4-1.png) |
| Bruxa | Leque vermelho | Lágrima rápida direcionada dourada | [1](contatos-v36/b3-aviso-5-0.png), [2](contatos-v36/b3-aviso-5-1.png) |
| Asmodeia | Chuva vermelha | Mergulho direcionado dourado | [1](contatos-v36/b3-aviso-6-0.png), [2](contatos-v36/b3-aviso-6-1.png) |
| Duelista | Corte dourado | Arremate tardio vermelho | [1](contatos-v36/b3-aviso-7-0.png), [2](contatos-v36/b3-aviso-7-1.png) |
| Carregador | Investida com caixão vermelha; exposto, golpe dourado | Pisão vermelho com ondas | [1](contatos-v36/b3-aviso-8-0.png), [2](contatos-v36/b3-aviso-8-1.png) |

Cada criatura é testada iniciando os dois padrões pela própria IA, verificando aviso e saída da preparação. Testes adicionais cobrem salto sobre chicote e aparo de projéteis. Beatriz sob IA reage aos avisos próximos. Não validado: equilíbrio das combinações de inimigos, dificuldade com dois jogadores ou percepção e mixagem dos avisos sonoros.

## B4 — Suspensão aérea limitada

Arremate e carregado podem lançar o alvo; ele cai com gravidade, toca o piso e se recupera. O corte aéreo suspende a queda por 0,10 s até três vezes por arremesso. Não há suspensão infinita; o alvo continua recebendo dano depois do limite. Beatriz pode abrir a reação à lança sem substituir a janela de execução já existente.

[Captura](contatos-v36/b4-suspensao.png). Testados três acertos, ausência da quarta suspensão e queda física. Não validado: facilidade de realizar a sequência com entrada humana, equilíbrio e todas as alturas de plataforma.

## B5 — Mortes e final de arena

A morte normal espera a queda do corpo antes de começar a dissolver. Carne produz sangue e poça ao tocar o chão, Duelista de armadura produz faíscas, caixão intacto produz pedra. O material de morte do Devorador foi corrigido para carne; a tabela histórica de impactos durante golpes foi preservada. A última morte da última onda de uma arena aciona câmera lenta curta, respeitando reduzir pulsos.

[Captura](contatos-v36/b5-queda.png). Testadas queda, poça, distinção carne/armadura e última morte da arena. Não validado: percepção humana do peso e todas as mortes simultâneas possíveis em cooperativo.

## Verificação, arquivos e limites gerais

Godot 4.6.3: **43 suítes aprovadas, 1.885 verificações/casos/recursos**. Inclui 115 verificações novas de arte, 94 de combate e 70 de carregamento e reprodução de áudio. [Resultado por suíte](v36-testes.json). Os testes anteriores `execution_gore_smoke` e `penitence_smoke` continuam aprovados. Algumas suítes aceleradas emitem avisos de recursos ainda em uso ao encerrar; não foram encontrados erros de script nem verificações reprovadas. Os testes usam salvamentos isolados dos dados do jogador.

São **24 atlas** novos ou repintados e **43 imagens de evidência**: 12 comparações, oito contatos de reações, um contato de efeitos e 22 capturas dirigidas. [Prompts completos e caminhos finais](v36-prompts-arte.md), produzidos com geração de imagens integrada. Edran e a Inquisidora permanecem fora deste ato; o rosto do Penitente não foi revelado.

Os 11 WAVs de `sons-v32-sem-zumbido.zip` foram comparados e permanecem idênticos byte a byte. Os 20 WAVs pedidos no documento de sons foram recebidos em `sons-gore-v32-pacote.zip` durante esta rodada e integrados sem regeneração, normalização ou mudança nos bytes dos arquivos. O gerador Python e seu relatório foram incluídos como fornecidos. As importações usam PCM sem compressão. [Medidas e SHA256](v36-audio.json), [relatório recebido](sons-gore-v32.md). Formato PCM16 mono 44,1 kHz, picos de −2,2 a −1,8 dBFS, início em até 3,946 ms e durações dentro de 15 ms da especificação. As quatro famílias têm variações distintas; os sete eventos individuais também foram carregados e reproduzidos em teste. O teste de ausência de WAVs foi isolado para continuar verificando o fallback com o pacote instalado. Não houve escuta humana; as medidas espectrais são indicadores e não comprovam realismo nem ausência perceptiva de zumbido. O ZIP completo v35 não foi fornecido; esta versão parte das imagens e do código já publicados no repositório, com as substituições documentadas aqui.

Não houve partida humana completa, teste de controles físicos, ensaio em outra máquina ou exportação do jogo. As capturas demonstram os estados dirigidos e os testes verificam comportamento; a qualidade subjetiva do combate ainda precisa ser confirmada numa partida humana.
