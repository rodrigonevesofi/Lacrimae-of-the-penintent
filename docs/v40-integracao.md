# Integração da versão 40

Os dois pacotes recebidos foram integrados sobre a versão 39 publicada (`14082a3`), preservando as nove criaturas, seus 18 atlas, os três closes barbados e os bichos pintados. Os 26 PNGs registrados na arte da v39 permanecem idênticos por SHA-256. [Proveniência e preservação](v40-preservacao.json).

## Polimento recebido

- Piso visual ajustado nas nove salas além da Cidade. A física continua em y=600 (Campanário y=1100), e a pintura é posicionada para que o piso desenhado coincida com essa altura.
- Cinco soleiras completam o piso sob portas altas; galerias, mísulas, monumentos e alvenaria recebem a cor da pedra da sala. Rodapé prolonga o piso onde a pintura terminava acima da borda da tela.
- Espada parada e na corrida fica atrás da mão, com empunhadura junto à guarda. Vinte folhas de animação de Penitente/Beatriz chegam limpas e com cor igualada; os deslocamentos de quadros reencaixados são lidos de `clips.json`.
- Primeiro plano ocupa menos espaço no alto da tela. Beatriz aceita teclas fora do numérico, mantendo setas, teclado numérico e segundo controle.

Além do pacote, foi corrigida a herança visual das nove criaturas novas: `criatura_goya.gd` agora chama o desenho comum dos inimigos para receber sombra de contato, vida, aviso de atordoamento e efeito de culpa. O aviso comum dourado/vermelho é reaproveitado, sem dois anéis sobrepostos; fio, área marcada e cone da Viúva continuam próprios.

[Detalhes do polimento recebido](v39-polimento.md). [Pisos das dez salas](v40-capturas/pisos-contato.jpg). [Espada quadro a quadro](v40-capturas/espada-contato.jpg).

## Sons recebidos

São 99 WAVs novos ou substituídos: 76 efeitos, nove efeitos antes ausentes no Vale, onze ambiências, música da revelação e duas variações derivadas. O ajuste de volume e os laços já vêm aplicados no pacote. A integração conferiu os hashes, PCM, picos, volume e seleção pelos eventos do jogo; não sintetizou nem substituiu outros sons.

Os nove eventos do Vale agora têm arquivos: transformação, dano refletido, gota de culpa, coleta da gota, oração, placa, queda de joelhos, retirada do capacete e chegada de Beatriz. A revelação ganhou sua música de 60 segundos em laço. As sete músicas anteriores permanecem, e a luta do Vale continua usando a música do chefe. O `ost_vale.wav` opcional citado no documento recebido não veio em nenhum dos dois ZIPs.

[Registro de cada WAV](sons-argon-v40.json). [Decisões de mixagem recebidas](sons-argon-v40.md). [Prompt para solicitar músicas diferentes ao Argon](prompts-musica-argon-v40.md). Não houve escuta humana nesta integração.

## Verificação desta integração

Godot **4.6.3**: **51 suítes aprovadas**, 2776 verificações e recursos, zero falhas. [Relatório por suíte](v40-testes.json).

Inclui cenário vivo (149), criaturas e suas nove execuções com sangue (69), polimento (56), sons do Vale (91), chefe final (33), história (6), dupla, controles, salvamento e acessibilidade. Alguns testes antigos avisam sobre recursos ainda em uso ao encerrar; o relatório distingue esses avisos de falhas de script.

Quatro verificadores Python também passaram: sons Argon (558), folhas limpas (29), 55 arquivos PCM do verificador anterior e os contratos de seis recursos de memória/fragmento. [Resultados Python](v40-testes-python.json).

Revisão com renderizador Compatibility na Intel Iris Xe: 84 recortes da espada, dez telas e dez recortes dos pés, mais 18 capturas das criaturas e três momentos da revelação. Os dois protagonistas assentaram na física em todas as salas e nos nove encontros capturados. Capturas são dirigidas, não uma avaliação humana de partida longa ou da dificuldade.

## Limites conhecidos

- Dois quadros do primeiro ataque ainda têm lâmina curta ou cortada; pontas da lança de Beatriz também saem de algumas células. O pacote registra que esses casos precisam de retoque de arte.
- As portas ainda são módulos sobre as pinturas e o traçado de algumas galerias não acompanha a arquitetura pintada.
- Não foi feito recorte novo de céu, paisagem e construção, medição de desempenho de partida longa ou escuta da mixagem.
- A regra narrativa do Vale foi mantida: Beatriz aguarda na beira e entra após a segunda placa; nas demais salas a dupla segue jogável junta.
