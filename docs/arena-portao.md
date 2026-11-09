# Portões de arena

Dois arquivos novos com a mesma tela RGBA96×540:

- `assets/arena_portao.png`: grade fechada, com ferro gasto, correntes, suportes de pedra e brasão apagado; ocupa a altura até a linha do piso.
- `assets/arena_portao_aberto.png`: estado recolhido no teto; somente a base inferior da grade fica visível no topo da imagem. A região de passagem abaixo é transparente. “Base” aqui é a travessa inferior do portão levantado, não um bloco que permanece atravessando o piso.

Origem proposta: canto superior central(48,0); piso emy540. Usar o mesmo ponto do mundo nos dois estados. A arte é vista de lado como obstáculo vertical de jogo2D; não é uma porta dupla abrindo para o fundo do cenário. Os arquivos foram normalizados tecnicamente para96×540 a partir das gerações originais preservadas na sessão.

## Brilho e transparência

A faixa pedida40–90/255 é aplicada ao **material visível**, com média ponderada pelo alfa: soma(Y′×alfa)/soma(alfa). Y′=0,2126R+0,7152G+0,0722B em RGB codificado. O relatório também conserva a média da tela inteira sobre preto, para não esconder a diferença de critério.

Medir o retângulo inteiro do aberto seria inadequado: quase tudo é transparente. Com uma base de16px numa tela de540px, mesmo uma faixa branca totalmente preenchida daria média global inferior a8/255. Isso não significa que o metal esteja preto. Valores finais em [v19-assets-result.json](v19-assets-result.json), ambos dentro de40–90 para o material visível.

`tests/v19_assets_check.py` confere formato, dimensões, alfa, brilho do material, alcance vertical do fechado e área vazia abaixo do topo no aberto. A prévia troca estados no mesmo ponto, sem colisão. [Vídeo](videos/v19-assets.mp4).

## Integração ainda necessária

O Claude deve definir a altura de encaixe na arquitetura, direção e tempo de descida, aviso de fechamento e coincidência entre grade visível e colisão. Não prender, esmagar ou empurrar o jogador sem uma regra explícita e um teste de segurança; não permitir cruzar a grade fechada ou manter uma parede invisível após abrir. Trocar instantaneamente os dois PNGs na prévia não implementa essa lógica nem uma animação de descida. Para descida contínua, deslocar/recortar o mesmo desenho fechado no motor, preservando as travessas.

O estado aberto é uma interpretação visual do portão recolhido e compartilha material/ponto de origem; os dois desenhos não são uma translação pixel a pixel. Confirmar o encaixe das travessas e suportes na integração antes de usar a transição como finalizada. Não foram alteradas salas, colisões, encontros ou salvamentos.
