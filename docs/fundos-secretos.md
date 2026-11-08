# Fundos das salas secretas

Três PNGs originais opacos de 2172×724, perspectiva lateral, piso contínuo. Arquivos: `assets/nave_silencio.png`, `assets/terraco_sinos.png`, `assets/patio_portoes.png`.

- Nave: pedra escura, luz fria, coro à esquerda, altar ao fundo e bancos com as costas para o observador, voltados à parede. Sem figuras.
- Terraço: armações, cordas cortadas junto à suspensão, sinos sem badalos, névoa e sino partido atrás do parapeito.
- Pátio: portões triplos largos à esquerda, correntes horizontais, relevos ajoelhados e riscos na parede à direita. Composição distinta de court.png.

## Conferência

`tools/preview_secret_backgrounds.gd` mostra o panorama inteiro numa janela 1280×720, preservando a proporção3:1 com faixas. Sobrepõe a guia a 86% da imagem (y 622,64 na fonte) e um Penitente de 90 px. A guia cruza a faixa contínua de pedra nos três fundos; não há degraus no plano frontal. Elementos de altar, parapeito e coro ficam atrás da faixa. Conferidos tamanho, opacidade e legibilidade por `tests/v12_assets_check.py` e inspeção das capturas:

- [Nave](imagens/fundo-nave_silencio.png)
- [Terraço](imagens/fundo-terraco_sinos.png)
- [Pátio](imagens/fundo-patio_portoes.png)

A conferência não valida colisões ou recorte pela câmera da fase. Os arquivos foram entregues separadamente: `act_one_layout.gd` e `world_art.gd` continuam os do patch v12 e ainda usam os fundos anteriores. O Claude precisa ligar os novos nomes e ajustar a referência de piso para 0,86. Não foi medida percepção com jogadores.


## Integração (v13)

Os três fundos estão ligados às salas em `act_one_layout.gd` (`nave_silencio`, `terraco_sinos`, `patio_portoes`), com a referência de piso em 0,86 e altura de arte de 880 (Nave e Terraço) e 800 (Pátio). Os pisos foram conferidos em jogo, com o Penitente caminhando sobre a faixa de pedra. A arte antiga (`basilica.png`, `city.png`, `court.png`) permanece nos arquivos, usada pelo prólogo, pela memória e pela cidade.
