# Combate refinado sobre a v29

Esta versão usa o patch cumulativo v29 recebido do autor como base. Os novos controles e as duas personagens foram mantidos. O refino modifica código e integra uma folha de impacto; não é apenas um pacote de arte.

## O que mudou ao jogar

- **Combo com ritmo próprio:** golpes com duração de 0,32 s, 0,36 s e 0,46 s para o Penitente. Beatriz conserva seu multiplicador de duração e o peso da lança. A janela do combo acompanha a duração real, inclusive com peso máximo.
- **Comandos antecipados:** ataque, carregado, aparo, esquiva e salto podem ser capturados durante a pausa de impacto. Um toque guarda no máximo uma intenção de cada ação; não inicia uma sequência automática infinita. A direção da esquiva e do aparo também é preservada.
- **Recuperação com opções:** após 60% do golpe, a recuperação pode dar lugar a esquiva ou aparo; após 70%, a salto; após 76%, ao próximo ataque ou carregamento. A preparação e o contato continuam tendo compromisso. A prioridade é defesa, salto e depois ofensiva.
- **Aparo com resposta:** um aparo bem-sucedido permite partir para o contra-ataque assim que termina a pausa de impacto. O contra-ataque tem dano base 38, antes dos modificadores.
- **Golpe pesado utilizável:** um toque curto em I produz um golpe parcial. Segurar aumenta o dano de 28 até 62,4, sem modificadores, ao completar 0,9 s. A carga aceita movimento lento e pode ser abandonada com esquiva, aparo ou salto. Uma barra e um som confirmam a carga completa.
- **Impacto sem congelamento excessivo:** golpe leve pausa 45 ms; arremate/contra-ataque 65 ms; morte e pesado 85 ms. O pesado usa câmera lenta mais breve e moderada. Pulsos reduzidos desativam a câmera lenta e o tremor do combate.
- **Alcance mais consistente:** a lança conserva seu alcance no ar e nos dois sentidos. Golpes leves, pesados e descendentes não atravessam obstáculos sólidos. Um ataque causa dano uma vez por alvo.
- **Inimigos em grupo:** Devotos e Duelistas próximos, do mesmo lado do jogador, alternam a preparação em vez de atacar exatamente sobrepostos. Inimigos do lado oposto ainda podem flanquear. O equilíbrio se recupera gradualmente após 1,4 s sem acertos, preservando a importância de manter pressão.
- **Efeitos mais claros:** um arco por golpe, inclusive quando erra; uma nova onda de pedra/poeira no descendente e anel vermelho no carregado completo. Poeira duplicada foi removida. O indicador de carga não reutiliza o sinal dourado de aparo.
- **Estado limpo:** reviver limpa combo, recargas e comandos antigos. Fechar diálogos não dispara o ataque usado para fechar a mensagem. Sangue compartilhado preserva pelo menos 1 ponto de vida do parceiro.

## Controles

J/X: ataque, repetido para combo. I: golpe pesado, segurando para carregar. L: aparo. K/Shift: esquiva. Espaço: salto. Baixo + J no ar: descendente. E: interação/execução quando o inimigo está aberto. T: troca de personagem no chão. H: sangue compartilhado nas condições da v29. F3: modo de apresentação. P no título/pausa: pulsos reduzidos.

## Testes e evidências

Godot 4.7.2 Standard para Windows, renderizador de compatibilidade, Intel Iris Xe. Verificações feitas com dados descartáveis em APPDATA separado; o salvamento pessoal não foi usado.

| Suíte | Verificações aprovadas |
|---|---:|
| Entradas reais e transições de combate | 23 |
| Regras de combate | 44 |
| Combo, pesado e descendente | 10 |
| Dupla de personagens | 13 |
| Execução e sangue | 9 |
| Bestiário | 44 |
| Pulsos reduzidos: comportamento | 59 |
| Pulsos reduzidos: interface | 8 |
| Áudio | 18 |
| Quadros e sincronização de animação | 339 |
| Sincronização da espada | 3 |
| Modo de apresentação | 5 |
| **Total funcional** | **575** |

Os testes antigos que exigiam uma pausa leve de pelo menos 80–85 ms foram atualizados para exigir uma pausa curta, conforme o novo ritmo. As verificações de contato, preparação sem dano e dano único por alvo foram mantidas. As três variações de pulo ausentes no ZIP de patch foram geradas pelo sintetizador já fornecido na v29; o teste espectral passou nas quatro amostras.

Capturas reais de golpe leve, carga completa, golpe pesado e descendente ficam no pacote de evidências. São uma revisão renderizada dirigida, não uma partida humana nem uma medição de desempenho. A qualidade subjetiva de ritmo e dificuldade ainda se beneficia da sua partida com teclado e som.

Algumas execuções aceleradas e sem janela imprimem avisos de recursos de áudio ainda em uso ao encerrar o motor. Os relatórios preservam esses avisos. Não ocorreram erros de script durante as verificações aprovadas, nem erros na execução gráfica de revisão. Não se afirma ausência absoluta de vazamentos do motor.

## Escopo da arte

Foi integrada `onda_golpe.png`, com suporte a grade 6 × 2 no carregador. As demais folhas continuam com grade padrão 6 × 4. Não foram ligadas automaticamente as execuções experimentais do pacote de arte anterior nem foi criada uma nova Beatriz neste refino. A aparência provisória de Beatriz da v29 permanece; os ajustes de mecânica valem para ela.

O projeto completo pode ser aberto pelo `project.godot` ou pelos lançadores Windows existentes. A atualização menor destina-se **somente à v29 fornecida**: extraia sobre uma cópia dela. Se houver alterações posteriores, revise o patch em vez de sobrescrever seus arquivos.
