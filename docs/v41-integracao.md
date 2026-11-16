# Integração da versão 41

Integração sobre a v40 publicada (`14b2d7b`). Os três pacotes completos foram extraídos e comparados com `v41-somente-o-que-mudou.zip`: os arquivos incrementais coincidem com os completos antes dos ajustes desta integração. [Proveniência e preservação](v41-preservacao.json).

## Trilha do autor

As nove faixas OGG recebidas, geradas pelo autor no Lyria 3.5, passam a tocar em menu, exploração, combate, chefe, história, templo, final, Vale e revelação. Foram mantidas sem nova codificação, idênticas aos hashes de [trilha-v41.json](trilha-v41.json). O jogo dá preferência ao OGG e mantém os WAVs antigos como reserva.

Nave compartilha a faixa do templo; Terraço e Pátio compartilham a exploração. A troca entre contextos que usam o mesmo recurso mantém a reprodução, sem reiniciar. Vale e revelação agora usam as faixas próprias. Nenhum efeito, ambiência, pintura ou atlas anterior foi substituído nesta rodada.

O pacote completo omitia `ost_revelacao.wav`, embora o carregador e o documento descrevam uma reserva em WAV. O arquivo da v40 foi preservado e o verificador dos sons do Argon foi ajustado para conferir sua integridade; o uso do OGG é verificado pela suíte da v41.

## Revelação e suporte a vídeo

**A entrega joga com os closes existentes durante 44 segundos.** Não há clipes finais em `assets/cutscene/`. O arquivo `tests/dados/revelacao_01.ogv` é apenas uma amostra técnica de um segundo, não é instalado no jogo e não contém a animação final dos personagens.

O suporte recebido aceita seis clipes Theora `revelacao_01.ogv` a `revelacao_06.ogv`, com oito segundos cada. Havendo pelo menos um, a cena usa 52 segundos, legendas e os sons do jogo; os trechos sem vídeo mostram o close correspondente. Os clipes são silenciados, e música, corrente, capacete e sino continuam dirigidos pela cena. É possível seguir após três segundos.

[Prompts dos seis clipes](prompts-cutscene-veo-v41.md). [Nomes e destino](../assets/cutscene/LEIA.md). O ZIP `cutscene-quadros-iniciais.zip` citado no prompt também não veio nos pacotes desta rodada. A conversão de futuros MP4 pode ser feita com `python tools/preparar_cutscene.py <pasta>`, com FFmpeg instalado. Esta integração não gerou vídeos novos.

## Ajuste encontrado na revisão

Ao entrar diretamente no Vale antes da primeira montagem da pintura, a consulta de chuva tentava acessar uma sala inexistente no dicionário. `tem_chuva()` agora verifica se a sala está registrada. Um caso de regressão foi acrescentado à suíte da cutscene, e a revisão com renderizador foi repetida sem erro de script.

## Validação

Godot **4.6.3**: **53 suítes aprovadas**, 2861 verificações e recursos, zero falhas. [Relatório por suíte](v41-testes.json).

Inclui trilha (61), cutscene e regressão (34), cenários vivos (149), criaturas e execuções com sangue (69), polimento (56), chefe do Vale (33), história (6), dupla, comandos, salvamento e acessibilidade. Os testes antigos de música foram adaptados ao recurso OGG recebido. Avisos legados de recursos ainda em uso ao encerrar estão identificados no relatório.

Cinco verificadores Python passaram: sons Argon (558), folhas limpas (29), PCM anterior (55 arquivos), memória/fragmento (seis recursos) e trilha OGG (63). O novo `tests/trilha_v41_check.py` usa NumPy e SoundFile/libsndfile para decodificar as nove faixas e conferir 44,1 kHz, estéreo, duração, pico, RMS, hashes e distinção dos arquivos. [Resultados Python](v41-testes-python.json). [Medições independentes dos OGGs](v41-trilha-conferencia.json).

O renderizador Compatibility na Intel Iris Xe produziu oito capturas: dois momentos da cena atual, reprodução da amostra e trechos sem vídeo com os closes de reserva. [Capturas](v41-capturas/). Os salvamentos dos testes foram isolados em APPDATA/LOCALAPPDATA próprios.

## Limites

Não houve escuta humana, avaliação do fraseado na emenda das músicas nem balanceamento da mixagem em uma partida. A fusão aplicada no pacote e as medidas de onda não garantem que a volta musical seja natural ao ouvido. Os seis clipes reais continuam pendentes; a revisão de vídeo usou apenas a amostra técnica.

As limitações de arte da v40 permanecem: algumas pontas de espada/lança cortadas e galerias que ainda não acompanham toda a arquitetura pintada. Esta rodada mantém o combate, as nove criaturas, os controles da dupla e a regra narrativa de entrada de Beatriz no Vale.
