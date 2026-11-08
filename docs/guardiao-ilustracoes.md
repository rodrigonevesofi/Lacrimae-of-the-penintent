# Guardião dos Sinos — ilustrações

Três PNGs opacos em `assets/boss/`, 1920×1080:

1. `guardiao_01_corda.png`: mão fechada sobre o vazio, corpo fundido ao bronze e contraluz alaranjado.
2. `guardiao_02_gesto.png`: a mesma mão aberta, gesto persistente e poeira de bronze.
3. `guardiao_03_imovel.png`: corpo imóvel em sombra e um ponto de luz.

Não há corda desenhada, rosto legível, criança, texto ou ferimentos explícitos. A identidade do Guardião não é associada a Tomé. A continuidade de armadura, sino e ambiente foi conferida entre os planos.

As gerações nativas de 1672×941 foram padronizadas para 1920×1080 com redimensionamento Lanczos, seguindo a preferência do autor por arquivos no formato pedido. Os originais permanecem em `/workspace/generated_images` no ambiente de criação.

`tools/review_v13_art.gd` mostra cada plano em 1280×720 e sobrepõe a guia dos 160 px inferiores da fonte. Conferidos mão, silhueta e leitura do bronze. O terceiro plano é deliberadamente mais escuro; a leitura em telas de baixo brilho ainda precisa de avaliação humana. Capturas:

- [Corda ausente](imagens/guardiao-1.png)
- [Gesto](imagens/guardiao-2.png)
- [Imóvel](imagens/guardiao-3.png)

Validação técnica em `tests/v13_assets_check.py`: tamanho e opacidade. Não comprova beleza nem impacto dramático. As imagens não foram ligadas à cena do chefe; montagem, legendas e duração ficam com o Claude.
