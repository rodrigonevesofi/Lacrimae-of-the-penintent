# Abismo da ponte quebrada

Novo recurso: `assets/abismo_ponte.png`, RGBA270×400. Vista lateral com paredes de pedra irregulares, vigas partidas, profundidade e névoa. Sem chão visível, corpos ou texto. A versão inicial veio com uma travessia intacta e foi corrigida: o centro superior agora permanece aberto. Os cantos superiores têm transparência para encontrar as bordas partidas do piso.

Média Y′ sobre preto: **21,40/255**, dentro da faixa14–22. Y′=0,2126R+0,7152G+0,0722B sobre RGB codificado, multiplicado pelo alfa. Não é luminância física; a transparência altera a média conforme o fundo escolhido. Medidas completas em `v18-arte-medidas.json`.

Posição proposta: canto superior esquerdo em(2000,600), tamanho270×400, junto à linha de piso existente. Não adicionar uma superfície atravessável ao centro. [Prévia1280×720](imagens/v18-abismo.png) usa um nó sobreposto apenas no script de revisão; o retângulo antigo em `world_art.gd` continua na produção até o Claude integrar a troca.

O arquivo nativo foi normalizado tecnicamente para270×400. A arte não cria dano de queda, colisão, física de névoa ou passagem nova. Conferir contato das duas bordas, recorte inferior e modulação da luz na câmera real antes de integrar. A prévia não é uma alteração da fase salva.

A prévia expõe também os triângulos lisos das bordas e o término do fundo antigo abaixo do piso. Eles pertencem à geometria/desenho existente, não ao PNG novo. O integrador precisa retirar ou redesenhar esses remendos e acertar o recorte da câmera; sobrepor a arte sozinha ainda não conclui o acabamento da ponte.
