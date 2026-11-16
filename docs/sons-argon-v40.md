# Sons do Argon na v40

O pacote `sons-lacrimae-argon-completo.zip` trouxe 105 arquivos: 85 efeitos, 11 ambiências e 9 músicas. O segundo pacote (`sons-vale-dos-flagelados.zip`) tem 12 arquivos **idênticos** aos do primeiro. Tudo foi medido antes de entrar; **ninguém ouviu** estes sons neste processo, então o que segue vem de medidas de onda, não de escuta.

## O que entrou (99 arquivos)

| Grupo | Quantos | Observação |
| --- | --- | --- |
| Efeitos que substituem os anteriores | 76 | passos, golpes, dor, mortes, criaturas, portas, sinos, menu |
| Efeitos novos do Vale | 9 | transformação, reflexo, gota de culpa (cai e recolhe), oração, placa caindo, chefe ajoelha, capacete saindo, chegada de Beatriz. **Estes pontos estavam mudos até a v39.** |
| Ambiências | 11 | as dez salas e o Vale |
| Música da revelação | 1 | `ost_revelacao`, toca só na cena final |
| Variações derivadas | 2 | `swing` e `dor` (ver abaixo) |

## O que foi ajustado nos arquivos
- **Volume.** O pacote veio com **todos os arquivos no mesmo pico (−1,2 dB)**. Isso desfaz a mixagem: as ambiências ficariam de 2 a 10 dB mais altas que antes e os sons de menu de 10 a 13 dB. Cada som foi levado ao volume médio do arquivo que substitui (diferença máxima de 0,8 dB). Os nove do Vale ficaram em −19 dB, o volume típico dos efeitos de cena.
- **21 sons com estalos mais altos que os antigos** (chicote, leque da bruxa, rugido, rolamento e outros) ficariam mais baixos; receberam um limitador suave só nas pontas dos estalos.
- **Ambiências sem emenda.** Chegaram com um corte de 1 a 3 milissegundos em cada ponta, que estalaria a cada 30 segundos. Foram refeitas em laço contínuo, com a mesma duração.
- **`swing.wav` e `dor.wav`** são sorteados junto com as variações `_01` a `_03`, mas não vieram no pacote. Para o golpe não alternar entre o som novo e o antigo, foram derivados de `swing_02` e `dor_02`, um pouco mais grave e mais agudo.
- **`ost_revelacao`:** 92% da energia estava abaixo de 200 Hz. Cortei 8 dB abaixo de 120 Hz e igualei a parte audível à da música de história.

## O que ficou de fora: oito músicas
`ost_menu`, `ost_exploration`, `ost_story`, `ost_temple`, `ost_ending`, `ost_boss`, `ost_combat` e `ost_vale` **não substituíram** as músicas do jogo. Motivos, todos medidos:

1. **Cinco são o mesmo arquivo com nomes diferentes.** `ost_menu`, `ost_exploration`, `ost_story`, `ost_temple` e `ost_revelacao` têm a onda idêntica (semelhança 1,000). `ost_ending` é 97% igual a elas, e `ost_boss` é 89% igual a `ost_combat`. Na prática vieram **três peças**, não nove.
2. **Não há notas.** Entre 92% e 98% da energia está abaixo de 200 Hz: é um ronco grave que pulsa, com estalidos finos a cada poucos segundos. O espectrograma não mostra melodia nem acordes. As músicas atuais do jogo têm notas e harmonia visíveis.
3. **Em alto-falante de notebook quase não se ouve.** Essa faixa de frequência é a que esses alto-falantes não reproduzem.

Consequência: **menu, exploração, combate, chefe, história, templo e final continuam com as músicas de antes.** A luta no Vale continua com a música do chefe. A revelação ganhou `ost_revelacao`, porque um fundo grave e quase vazio serve a uma cena de silêncio, e porque assim ela é a única a usar essa peça.

Para experimentar uma música própria do Vale, coloque um `ost_vale.wav` em `assets/audio/`; o jogo passa a usá-lo na luta final. **Os dois pacotes v40 recebidos não incluem esse WAV nem o diretório opcional citado originalmente.** Nesta entrega, a luta mantém a música do chefe.

## Verificação
- `tools/integrar_sons_argon.py` faz a conferência e o ajuste; `docs/sons-argon-v40.json` registra cada arquivo (duração, volume recebido e final, regra aplicada, SHA-256).
- `tests/sons_argon_check.py`: 558 verificações (arquivo registrado, formato, pico, volume, músicas antigas mantidas, nenhuma música duplicada).
- `tests/v40_sons_smoke.gd`: 91 verificações (os nove sons do Vale carregam e tocam pelo evento, a revelação tem música em laço, a luta usa a do chefe).
- `tests/audio_assets_check.py` (o teste anterior do projeto) continua passando com os 55 arquivos que ele cobre.

## O que não foi verificado
- **Como os sons soam.** Vários efeitos novos são mais graves e mais tonais que os anteriores (golpe de espada, dor, porta, morte do chefe). Pelas medidas, são versões mais escuras do mesmo tipo de som, não bipes; só a escuta confirma.
- O equilíbrio entre música, ambiência e efeitos numa partida.
