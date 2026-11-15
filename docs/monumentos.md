# Monumentos vivos da v38

Três composições originais, cada uma com duas imagens RGBA de 1024 × 1024, desenhadas na mesma origem para sobreposição. Ficam no fundo, sem colisão; não escondem fisicamente o jogador nem mudam as rotas. O tamanho de apresentação é 620 × 620 unidades. A posição horizontal é 58% da largura da sala, com a base no piso local.

| Sala | Monumento e arquivos | Movimento |
| --- | --- | --- |
| Cisterna dos Nomes (`cistern`) | Santo das Duas Bacias: `assets/vida/santo_base.png` e `santo_movimento.png` | A pedra fica fixa; os dois fios de lágrimas descem em ciclo de 12 unidades, com transparência suave. |
| Ossuário (`ossuary`) | Coluna dos Testemunhos: `assets/vida/ossuario_base.png` e `ossuario_movimento.png` | A base fica fixa; o conjunto das cabeças acompanha a posição horizontal do jogador com inclinação limitada a ±0,08 radiano. É uma aproximação 2D, sem virar uma cabeça tridimensional. |
| Claustro das Cinzas (`cloister`) | Relicário do Voto: `assets/vida/relicario_base.png` e `relicario_movimento.png` | Estrutura e correntes fixas; o recipiente tem balanço lento e mudança de largura que simula rotação ao redor das correntes. Não é uma malha 3D. |

[Contato das peças](v38-capturas/05-vida-contato.png).

Capturas no renderizador do Godot: [Cisterna](v38-capturas/17-monumento-cistern.png), [Ossuário](v38-capturas/17-monumento-ossuary.png), [Claustro](v38-capturas/17-monumento-cloister.png).

`ambient_life.gd` preserva a poeira, a névoa, as gotas e os pêndulos do pacote recebido. Os pendentes pintados substituem as silhuetas; incensários usam a faixa animada de fumaça e altares usam a chama pintada. As lamparinas próximas recebem luz local suave; são removidas ao trocar de sala, sem deixar referências no registro de luzes do jogo.

Dimensões, transparência, importação e enquadramento das três salas foram verificados. Falta ensaio humano de navegação e avaliação de desempenho em outros computadores. As animações são transformações das partes separadas, não séries adicionais de imagens.
