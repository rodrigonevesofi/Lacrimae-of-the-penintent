# Entrega v19

Reconstrução do núcleo do jogo a partir do diagnóstico do autor (o jogo estava vazio) e das referências de Blasphemous. Base: v17 do Claude mais a v18 do Codex.

## Combate
Aparo (tecla L), pausa e efeitos de golpe com peso, resistência a interrupção, vidas novas, arenas trancadas com ondas e mais inimigos nas salas vazias. Detalhes e métricas em [diagnostico-jogabilidade.md](diagnostico-jogabilidade.md) e nos testes `combat_smoke` e `audio_smoke`.

## Chefe
Guardião com o atlas grande, 1.700 de vida (antes 450), três fases e a barra de vida no topo.

## Salvamento
Carregamento à prova de arquivo danificado: os 13 casos do teste do Codex passam (antes falhavam 7).

## Áudio
Barramentos, limitador, reverb por sala, variação, som posicional e ganchos para 17 eventos mudos. [analise-audio.md](analise-audio.md).

## Arte do Codex integrada
Abismo da ponte, efeitos de combate, Guardião grande. Os atlas de perigos, as relíquias e o bronze imóvel v2 estão no projeto mas ainda não ligados.

## Limites
Nada foi jogado por pessoas. As vidas do chefe e do Devorador foram alteradas depois da última medição. As cenas do Guardião ainda não usam o Guardião colossal nem a câmera mais próxima. O abismo só mostra os primeiros 114 px da pintura. Sons e música não foram ouvidos.
