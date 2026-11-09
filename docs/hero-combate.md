# Penitente — atlas do novo combate

Novo arquivo `assets/animation/hero_combate.png` (com “e” no final): RGBA1536×1024, grade6×4, células256×256. O original `hero_combat.png` foi preservado. As poses seguem sua armadura, coroa, capa rubra, túnica clara e espada; figura voltada à direita, com pivô nominal(128,250) e escala de integração0,44 igual à atual.

| Quadros | Papel |
|---|---|
|0–5|Postura de aparo: espada cruzada diante do tronco, ombros e joelhos preparados para absorver o contato|
|2|Instante de interceptação, marcado na folha de contato e exibido parado na prévia|
|6–11|Recuo/absorção após sucesso e recuperação da abertura|
|12–14|Preparação do contra-golpe, com rotação de corpo e recuo da lâmina|
|15–17|Corte e acompanhamento do contra-golpe|
|18–21|Acúmulo do golpe carregado|
|22–23|Corte forte e acompanhamento|

A primeira candidata deixava o início do aparo em repouso e confundia corte com estocada. Pedi revisão das poses e remoção do fundo semitransparente que apareceu numa geração. A exportação final tem alfa real,24quadros distintos e não vazios e passou pelo verificador original em fixture isolada. Não foi apenas repetido o mesmo quadro com balanço de corpo.

[Visualizar folha de contato](imagens/v19-hero-contato.png): linha dourada emy250 e eixo central emx128 para conferir o registro. Os limites medidos estão em `v19-assets-result.json`. O pivô é de desenho, não a promessa de que os dois pés se sobreponham ao mesmopixel em toda pose. Conferir contato de pé e ponta da espada antes de integrar, principalmente nas poses baixas.

[Vídeo da prévia](videos/v19-assets.mp4) mostra o quadro2 parado, os quatro grupos em movimento e uma comparação na escala0,44. Tempos demonstrativos: o aparo segura o quadro2 por0,20s; preparação do contra-golpe ocupa os três primeiros quadros; o carregado acumula antes do corte. Esses tempos não definem a janela real de aparo, o dano ou uma vantagem já balanceada. No jogo, a lâmina não pode atravessar o alvo visualmente e só depois aplicar dano.

Verificar: `python3 tools/check_animation_atlases.py` confere o catálogo de produção preservado; `python3 tests/v19_assets_check.py` executa a mesma ferramenta, byte a byte, numa pasta temporária com os quatro novos clipes. Não foi editado `clips.json`. Os resultados não comprovam fluidez equivalente a Blasphemous nem qualidade do combate integrado.

Falta o Claude conectar o atlas aos estados reais, escolher os mínimos/cancelamentos, sincronizar contato e recuperação e decidir como a espada separada atual se comporta. O desenho novo já contém a espada: desenhar a arma separada simultaneamente criaria uma segunda lâmina. Também falta avaliar leitura com jogadores e em diferentes resoluções. A arte mantém a linguagem pintada da referência atual; não anuncia uma conversão completa de estilo.
