# Acessibilidade das cenas de culpa

Medido por `tests/accessibility_scenes_check.gd` (35 verificações, 0 falhas). Dados brutos em [acessibilidade-cenas-medidas.txt](acessibilidade-cenas-medidas.txt).

## O que foi medido
- **Pulsos de luz.** No máximo 2 por segundo em qualquer cena; as únicas cenas com pulsos são o primeiro eco e a Memória dos portões (um por batida, três no total). A intensidade máxima é 0,14, que se traduz em cerca de 5% a 8% de branco sobre uma tela escura. Nunca há tela branca cheia.
- **Pular.** Toda cena pode ser pulada depois de 2 a 3 segundos (a memória, depois do choro, aos 6,9 s de 27 s) e nunca em seus primeiros 0,5 s. A cena de abertura do Guardião pode ser pulada aos 2,1 s; a do encerramento, aos 3,1 s.
- **Som com equivalente visual.** As batidas do primeiro eco e as vozes do segundo e do terceiro estão escritas na tela; as vozes da memória aparecem como texto; cada batida da memória também pulsa a tela; as batidas após a corrente alta são anunciadas no aviso; o sino do memorial tem título na tela; as cenas do Guardião têm legendas.

## O que isto não mede
Não mede o conforto real de quem tem fotossensibilidade, surdez ou dislexia, nem testou outros tamanhos de tela ou contraste do texto sobre as ilustrações. Os pulsos são contados por evento, não por luminância medida na imagem final. Falta uma opção no jogo para reduzir ou desligar os pulsos e as batidas de câmera, e ela seria uma melhoria sensata.
