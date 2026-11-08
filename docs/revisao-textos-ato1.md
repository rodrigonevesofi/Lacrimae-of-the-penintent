# Revisão editorial do Ato I — base v15

Leitura dos textos de `story_text.gd`, `guilt_text.gd`, `narrative.gd`, registros de `exploration.gd`, bestiário de `enemy.gd`, mensagens de `main.gd`/`hud.gd` e legendas sonoras. Comparação com `docs/roteiro-cinco-atos.md`. São propostas para revisão, sem alterações nos scripts. Prioridade alta significa risco de informação incorreta ou de revelação antecipada; média significa clareza ou voz. Não encontrei erro ortográfico grave nos trechos selecionados. Aspas abaixo reproduzem recortes, não necessariamente a página completa.

## 1. A identidade de quem ordenou — alta

Arquivo: `scripts/exploration.gd`, registros `seal` e `decree`. Trechos: “EDRAN DECRETA: NINGUÉM SAIRÁ, NINGUÉM ENTRARÁ.” e “O selo é o de Edran.”

Problema: o objetivo ao fim do Ato I no roteiro é “Descobrir quem ordenou o fechamento”. O registro opcional já responde a essa pergunta. Isso não é necessariamente um erro se o objetivo mudar para compreender a ordem.

Sugestão: escolher explicitamente entre adiar a identificação do selo até o Ato II ou mudar o objetivo para descobrir por que a ordem foi dada e por que o Penitente obedeceu. Preservar sua responsabilidade; Edran não deve absorver toda a culpa.

## 2. Proteção do aquelarre — alta

Arquivo: `scripts/enemy.gd`, `BESTIARY[5]`. Trecho: “elas só caem uma de cada vez.”

Problema: `take_hit` reduz dano conforme o número de irmãs; não impõe uma ordem exclusiva de mortes. A descrição promete outra regra.

Sugestão: “Enquanto uma irmã vive, amortece o golpe que atinge as outras.” A ficha técnica pode explicar a redução separadamente.

## 3. Quem aguarda a ordem — média

Arquivo: `scripts/guilt_text.gd`, `MEMORY_CAPTIONS[2]`. Trecho: “Atrás de você, alguém aguarda uma ordem.”

Problema: pode sugerir que a figura aguarda uma ordem do Penitente. No roteiro I.6, ele olha para uma figura indistinta; a trama estabelece que recebeu uma ordem.

Sugestão: “Atrás de você, uma figura espera.” Mantém a dúvida sem inverter a hierarquia. A ambiguidade atual pode ser intencional; precisa de decisão de roteiro.

## 4. Lado dos portões — média

Arquivo: `scripts/exploration.gd`, `seal`. Trecho: “Os portões estão fechados por fora”.

Problema: sem orientação espacial clara, o jogador pode não entender de que lado estão ele, quem pede entrada e quem prendeu as correntes. Pessoas presas fora e dentro podem coexistir; não há contradição obrigatória.

Sugestão: descrever as correntes visíveis deste pátio e manter consistente o lado mostrado na memória. Não revelar a família de Iria antes do Ato IV.

## 5. Refrão das vozes — média

Arquivos: `scripts/guilt_text.gd`, `scripts/narrative.gd`, `scripts/story_text.gd`. Trecho recorrente: “Abra. Ainda estamos aqui.”

Problema: a repetição funciona como motivo dramático, mas legenda, texto principal e vozes flutuantes podem disputar o mesmo instante.

Sugestão: preservar o primeiro eco e a volta na memória dos portões; revisar duplicações simultâneas. Manter sempre uma equivalência escrita do som, especialmente com pulsos reduzidos.

## 6. Iria repete a conclusão — média

Arquivo: `scripts/story_text.gd`, `iria_pages`. Trecho: “Mas não confunda esse gesto com perdão.”

Problema: forte na primeira resposta à homenagem; repetido em visitas, pode soar como comentário do autor em vez de reação de uma testemunha.

Sugestão: conservar uma ocorrência e, em retornos, usar observações concretas do memorial. Iria continua sem oferecer perdão.

## 7. O nome pertence a quem — média

Arquivo: `scripts/story_text.gd`, página “UM LUGAR PARA O NOME”. Trecho: “O que deixou no memorial já tem um nome.”

Problema: pode parecer que a boneca recebeu um nome, em vez de identificar sua dona.

Sugestão: “No registro, a boneca pertencia a Alba. Leve esse nome à pedra.”

## 8. Referente de procurá-lo — baixa

Arquivo: `scripts/story_text.gd`, resposta com `named`. Trecho: “Não sei se alguém virá procurá-lo.”

Problema: o pronome pode retomar o nome ou a pessoa, causando hesitação. Não é erro de concordância se retoma “nome”.

Sugestão: “Não sei se alguém virá ler esse nome.” Não confirmar o destino de Alba neste diálogo.

## 9. O lugar encontrado — média

Arquivo: `scripts/story_text.gd`, `memorial_text(true)`. Trecho: “O lugar continua vazio. Agora pode ser encontrado.”

Problema: o sujeito oculto pode fazer a frase parecer uma pista de exploração. A imagem já comunica ausência.

Sugestão: depois de “Você grava: Alba” e da boneca entre as velas, encerrar com “O nome agora pode ser lido”, ou simplesmente deixar o gesto terminar em silêncio.

## 10. Dor e recompensa numérica — média

Arquivo: `scripts/exploration.gd`, `pews`. Trecho: “Suas lágrimas caíram sobre a madeira. +120 lágrimas.”

Problema: reúne reação emocional imposta ao personagem e moeda, podendo sugerir recompensa por sofrer. “Ninguém queria ver o altar. Ninguém queria ser visto” também interpreta pelos antigos fiéis.

Sugestão: conservar os bancos voltados à parede e um vestígio físico; exibir a recompensa na interface, separada da prosa, como lágrimas encontradas nas fendas da madeira.

## 11. Relíquia explica sua própria pista — média

Arquivo: `scripts/exploration.gd`, `silence`. Trecho: “Talvez a mesma mão que fechou os portões.”

Problema: o narrador faz a associação pelo jogador antes da revelação do chefe. Pode funcionar como prenúncio, mas reduz a descoberta.

Sugestão: manter o desgaste do terço e uma marca reconhecível na memória. Deixar a conexão ser percebida, sem enunciar a conclusão.

## 12. Corda e aviso — média

Arquivo: `scripts/exploration.gd`, `rope`. Trechos: “A corda está cortada rente à mão de quem puxava” e “Por isso o aviso nunca chegou à cidade.”

Problema: não está claro se a mão ainda está ali. A última frase afirma uma causa histórica que o objeto, sozinho, não prova.

Sugestão: “A corda foi cortada à altura da mão” se não houver mão representada. Substituir a conclusão por um registro concreto de punição de quem tocou o sino. Manter o aviso frustrado como inferência.

## 13. Descrição visual e fala dramática — média

Arquivo: `scripts/guilt_text.gd`, `BOSS_INTRO`/`BOSS_END`. Trechos: “puxa uma corda que já não existe” e “A mão continua o gesto por um instante”.

Problema: descrevem a mesma ação das ilustrações. São úteis como descrição acessível, mas podem competir com a atuação e a fala “Não veio ninguém”.

Sugestão: preservar a descrição em modalidade acessível; na apresentação dramática, permitir pausas e evitar que descrição e fala apareçam como duas conclusões ao mesmo tempo. Não remover legendas de som.

## 14. Memória explica a própria irreversibilidade — média

Arquivo: `scripts/narrative.gd`, montagem da memória. Trecho: “Você apenas assiste. O que foi feito não pode ser desfeito.”

Problema: explicita a interpretação da cena. A primeira parte, porém, ajuda a distinguir lembrança fixa de decisão jogável.

Sugestão: testar um marcador curto “Memória do Penitente”. Preservar a informação de que o jogador não escolheu aquela ação; não fabricar responsabilidade pessoal por uma decisão já escrita.

## 15. A leitura dos três nomes — média

Arquivo: `scripts/story_text.gd`, “OS QUE ESPERARAM”. Trecho: “Você lê os três nomes em voz baixa. Iria espera até o último. Para você, eram linhas numa página.”

Problema: narra a encenação e explica sua interpretação. Somado aos nomes e à conclusão, aumenta a leitura numa cena que poderia respirar.

Sugestão: nomes, pausa da animação e uma resposta curta de Iria. Retirar a conclusão sobre o que eram para ele se a atuação comunicar a mudança. Precisa de teste humano de leitura, não de um tempo presumido.

## 16. Recurso Culpa na execução — média

Arquivo: `scripts/main.gd`, prompt de execução. Trecho: “recupera 8 de vida e 12 de culpa”.

Problema: “recupera culpa” soa como punição embora o valor seja um recurso utilizável. O sistema também usa culpa para a condenação.

Sugestão: “Vida +8 · Culpa +12”, mantendo a nomenclatura mecânica sem inventar outro recurso nesta revisão.

## 17. Capacidade limitada — média

Arquivo: `scripts/hud.gd`. Trecho: “VÍNCULO ROMPIDO · 75%”.

Problema: não esclarece que 75% é capacidade disponível enquanto há fragmento pendente.

Sugestão: “Culpa pendente · capacidade 75%”. Verificar espaço na HUD antes de aplicar.

## Coerência, extensão e limites

A sequência central permanece coerente: Ato I revela o fechamento; II, a criação do ritual; III, o pedido para esquecer; IV, o passado de Iria; V, a natureza da entidade e a decisão. A ordem de Edran é o principal ponto a resolver. Não identifiquei fala ativa que confirme Tomé como identidade do Guardião.

Os textos antigos de `exploration.gd` para boneca/registro/vaso/testemunha são substituídos por `story_pickup_text`; não foram tratados como falas atualmente exibidas. O nome genérico do chefe em `enemy.gd` é sobrescrito por “Guardião dos Sinos” no Ato I; não é prova de aparição antecipada da Mãe das Lágrimas.

A introdução, páginas de Iria e alguns registros concentram ações, interpretação e instrução no mesmo bloco. Recomendo prototipar as reduções acima e medir leitura em 1280×720, sem transformar contagem de caracteres em prova de legibilidade. Esta é revisão de fonte: não comprova ausência de corte em todas as resoluções nem valida impacto dramático.

As legendas “[Sino grave, abafado]”, “[Sino]”, “[Vozes abafadas]” e “[Batida]” são informação funcional. Preservá-las mesmo quando uma versão poética do texto for encurtada. Frases bíblicas e alusões literárias podem permanecer sem capítulo/versículo na tela; referências e distinção entre citação e criação ficam na documentação. “Chorai” é registro intencional, não erro a modernizar automaticamente.
