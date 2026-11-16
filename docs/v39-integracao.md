# Integração da versão 39

As nove fichas receberam aprovação explícita do autor em 15/11/2026. Esta entrega acrescenta as criaturas ao mapa, com arte animada e regras próprias, integra os dois pacotes v39 sobre a v38 publicada e refaz o rosto conforme o documento recebido. A instrução anterior de aguardar aprovação foi satisfeita pela mensagem do autor.

## Criaturas no jogo

| Criatura | Sala e posição inicial | Comportamento e resposta |
| --- | --- | --- |
| O Glutão | Abrigo, x=20190 | Três colheres em leque; palmada próxima aparável; acelera ferido; a tosse abre a recuperação. |
| Disciplinantes | Vale, x=31340/31420/31500; também convocados pelo chefe | O primeiro absorve parte do golpe frontal destinado aos seguintes. O aparo atordoa a formação próxima. |
| O Meio-Enterrado | Cisterna, x=8870 | A cabeça pode ser atingida; emerge com aviso antes do bote e volta à terra na recuperação. |
| As Parcas | Nave, x=23700, altura acessível à espada | Fio marca a posição antes do corte; um golpe interrompe. O corte reduz a vida máxima em 12, até 36; esquivar evita e rezar desfaz. Salva a maldição de cada integrante da dupla. |
| O Sono | Arquivo, x=17030, sobre o bloco em y=550 | Produz aves enquanto dorme; qualquer ferimento o acorda e desfaz os projéteis que criou. |
| A Romaria | Pátio, x=28070 | Cada golpe solta um peregrino, estreita corpo e colisor e reduz a proteção coletiva; avanço com aviso vermelho. |
| O Espantalho do Medo | Terraço, x=25740 | Golpes altos causam dano reduzido; golpes baixos derrubam as pernas de pau, reduzem o colisor e expõem o operador. |
| Os Dois Velhos | Claustro, x=11870 | O dedo fixa o alvo antes da tigela balística; a tigela deixa poça quente por dois segundos. Golpear o lado do apontador interrompe o aviso. |
| A Viúva da Lâmina | Ossuário, x=7520 | Lanterna revela quem está no cone por quatro segundos, aumentando o alcance de alerta das novas criaturas. Pedra bloqueia a visão. Estocada aparável. |

As Parcas, a Romaria e os Dois Velhos são grupos em uma única entidade de combate, com vida compartilhada. Não há seleção individual das três Parcas ou dos dois velhos. As novas criaturas usam o alvo de pé mais próximo da dupla, as colisões e reações físicas existentes, os avisos dourado/vermelho e os sons disponíveis de combate. Nenhuma exige derrotar uma arena para reaparecer após o descanso.

Cada espécie tem duas folhas próprias de 24 quadros: movimento/ataque/recuperação e ferimento/atordoamento/arremesso/morte/reação à execução. São **18 atlas, 432 quadros**. A animação do jogador ao executar essas nove espécies usa os movimentos compartilhados já existentes; a reação da criatura é própria. O sangue, os jatos, as gotas, a câmera lenta e as poças existentes foram mantidos e testados nas nove execuções.

[Contato das criaturas](v39-criaturas-contato.jpg). [Fichas aprovadas](v39-fichas-aprovadas.png). [Capturas em jogo](v39-capturas/).

## Rosto, bichos e cenários

Três closes foram repintados: frente, dois perfis do mesmo homem e revelação das mãos com cabelo e marcas do capacete. Barba escura irregular, cabelo curto empastado e trilhos de sangue seguem o briefing; não foram fornecidas fotos pessoais nesta rodada. O close do elmo-gaiola foi mantido. O rosto continua restrito à cena final em `vale_finale.gd`. [Contato com os quatro closes](v39-closes-contato.jpg).

Corvo pousado, bicada e impulso usam seis quadros novos; os quadros de impulso antecedem o voo. Morcegos e ratos agora usam pinturas em lugar dos polígonos, com os mesmos gatilhos e contadores. As aves do Sono e os projéteis também receberam recortes próprios. Os novos PNGs e três substituições somam **26 arquivos finais**, registrados com dimensões e SHA-256 em [v39-assets.json](v39-assets.json). Ferramenta e prompts completos: [v39-prompts-arte.md](v39-prompts-arte.md).

Os cenários vivos da v39 recebida foram integrados: shader e máscaras sobre as dez pinturas, chuva/trovões no Terraço, bichos reativos, folhas, mariposas e primeiro plano com paralaxe. F6 alterna a pintura viva; P reduz pulsos. Quatro WAVs de chuva e trovão foram recebidos e integrados; os 128 WAVs anteriores estão intactos. [Conferência de preservação](v39-preservacao.json).

## Verificação

Godot **4.6.3**, renderizador Compatibility, Intel Iris Xe. **49 suítes aprovadas, 2629 verificações e recursos, zero falhas**. [Relatório por suíte](v39-testes.json). Inclui cenário vivo (149), criaturas novas (69), arte nova (212), chefe do Vale (33), história (6), dupla, controles, sangue, salvamento e acessibilidade. Os testes de contagem foram atualizados para incluir exatamente os onze novos encontros, mantendo a verificação de não duplicar chefes.

Foram produzidas e inspecionadas **21 capturas dirigidas**: cada criatura parada e preparando seu ataque nas salas, com os dois protagonistas apoiados na física, e três momentos da revelação. Os testes isolam APPDATA/LOCALAPPDATA para não tocar no salvamento do jogador. Alguns testes legados avisam sobre recursos ainda em uso ao encerrar; isso está indicado no relatório. Não houve erro de script ou verificação reprovada nos resultados finais.

## Limites desta entrega

- O item opcional de recortar céu/paisagem/arquitetura em três camadas nas três salas ficou para outra rodada. A paralaxe e os cenários vivos recebidos permanecem; não foi repintada a arquitetura.
- Equilíbrio e sensação do combate com as nove criaturas precisam de uma partida humana. Os testes verificam regras, trajetórias, danos, colisões, persistência e execuções; não dão uma avaliação humana de dificuldade ou fluidez. Não foi medido desempenho de uma partida longa nem feita escuta humana dos áudios.
- Os nove efeitos e duas músicas opcionais do Vale, já pendentes na v38, continuam sem novos arquivos. As criaturas usam os sons de combate disponíveis.
- Esta rodada não altera a regra narrativa recebida do Vale: Beatriz aguarda na beira e entra após a segunda placa; no restante do ato a dupla joga junta. Não incorpora alterações paralelas que ainda estejam sendo feitas no Claude.
