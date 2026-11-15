# Integração da versão 35

Registro histórico. A lista adicional de arte e combate abaixo foi executada depois, na [versão 36](v36-integracao.md).

Base: `261ccf7e15495c3df53598736baa1f72b62206a8` (versão 33). Foram integrados os documentos da v34 e o patch cumulativo da v35 fornecido pelo autor, preservando os atlas e sons já publicados.

## Código entregue e correções

O patch acrescenta sangue nas execuções: 40 gotas no ferimento, 90 no golpe mortal, quatro pulsos subsequentes, névoa, fragmentos, manchas no chão e uma poça maior. O golpe mortal tem pausa de impacto de 0,16 s e câmera lenta. Inimigos feridos pingam enquanto se movem; cortes comuns também produzem sangue. Mantidos os limites de 90 respingos e 14 poças, que começam a desaparecer após 40 s. A borda vermelha fica desativada em reduzir pulsos.

Na integração foram corrigidos o tempo real da borda, seu acionamento para Beatriz e o apoio dos respingos no piso. Também foram corrigidos os conflitos de controles do F3/mapa e a saída do voo dentro de alvenaria; a pausa foi reorganizada em duas colunas. [Defeitos e evidências](v34-defeitos.md).

## Sons do Argon

[Documento recebido](prompts-sons-gore-argon.md). **O arquivo é uma lista de pedidos, não um pacote de áudio. Nenhum WAV novo de gore foi recebido nesta rodada.**

O carregador reconhece três variações de `sangue_jato`, `carne_rasga` e `osso_quebra`, quatro de `respingo_chao`, além de `lamina_sai`, `corpo_cai_carne`, `corpo_cai_armadura`, `esquiva_perfeita`, `aviso_aparavel`, `aviso_perigo` e `execucao_impacto`. São 20 nomes de WAV. Arquivos opcionais ausentes não causam erro nem substituem os sons atuais.

Pontos já ligados: jatos e pulsos → `sangue_jato`; cortes/ferimento → `carne_rasga`; golpe mortal → `osso_quebra` e `execucao_impacto`; fim da execução → `lamina_sai`; manchas → `respingo_chao`, com limite temporal do áudio localizado; morte → queda de carne ou armadura. A esquiva perfeita e os novos avisos são apenas nomes preparados para mecânicas futuras. Copiar os WAVs para `assets/audio/`, importar no Godot e reiniciar a cena habilita o carregamento. Formato e durações: documento do Argon.

Os 11 WAV da v32 foram preservados byte a byte. Não houve audição dos sons novos, pois os arquivos não existem nesta entrega.

## Validação

Godot 4.6.3.stable.official.7d41c59c4: **40 suítes, 1.426 verificações/casos/recursos aprovados**, incluindo 12 de execução com sangue, 7 dos conflitos de controles e 18 da integração nova. [Resultados por suíte](v35-testes.json). As rotas físicas adicionais passaram em IA e J2 em espera (52 verificações cada, separadas dessa contagem). Salvamentos temporários de testes ficaram isolados dos dados do jogador.

[Pausa](contatos-v35/pausa-controles.png), [golpe mortal](contatos-v35/execucao-golpe.png), [manchas após o golpe](contatos-v35/execucao-respingos.png) e [reduzir pulsos](contatos-v35/execucao-reduzir-pulsos.png) foram renderizados e conferidos. Algumas suítes aceleradas ainda emitem avisos de recursos de áudio em uso ao encerrar, sem falhas de script ou verificações.

Não houve partida humana completa, avaliação auditiva nova, teste de controles físicos, ensaio em outra máquina ou exportação nesta integração. A fluidez subjetiva e o equilíbrio precisam de uma partida humana.

## Pendências explícitas

- O ZIP completo da v34/v35 não foi fornecido; os pacotes pequenos e patches não contêm o retrato e as capturas adicionais mencionados na entrega do autor.
- A nova lista de `prompts-codex-v35.md` está registrada como trabalho adicional: repintura das seis execuções e criaturas, quatro atlas de sangue, oito folhas de reações, nova tabela/janelas de ataques, esquiva perfeita, segundos ataques/avisos, malabarismo aéreo e mortes/última morte de arena. **Esses itens não são apresentados como implementados nesta integração.** As artes publicadas na v33 continuam em uso.
- Os 20 WAVs novos aguardam produção e entrega pelo Argon.

Os documentos `v34-entrega.md` e `v35-entrega.md` preservam a descrição recebida do autor. Este registro descreve o que foi efetivamente integrado, testado e o que falta.
