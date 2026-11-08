# Entregas sobre a base v16

Patch recebido aplicado sobre `d504363` (versão15). A integração do Claude conecta os sons, a arte original de encerramento, sete ajustes editoriais e a opção de reduzir pulsos. Sobre essa base, acrescentei somente arquivos novos. Os12 arquivos protegidos permanecem idênticos ao patch recebido e os192 arquivos de assets preexistentes mantêm seus hashes: [v16-escopo.json](v16-escopo.json).

## Quatro entregas

1. **[Encerramento mais legível](ato1-encerramento-v2.md).** Nova arte `assets/ending/ato1_portoes_v2.png`, opaca1920×1080. Média de brilho passou de3,76 para17,53/255, dentro da faixa14–22; reserva inferior de160px com média2,79. [Prévia Godot1280×720](imagens/v16-encerramento-legenda.png). A original não foi substituída; o Claude conecta a v2 à HUD.
2. **[Auditoria da arte-chave](auditoria-luminancia.md).** 21 imagens: memória, Guardião, encerramentos, dez fundos de sala e abertura. Média, P95 e fração abaixo de12. Os alertas principais são o encerramento v1 e `guardiao_03_imovel.png`. A v2 ainda recebe “Conferir sombras”: atingir a média pedida não elimina a necessidade de inspecionar detalhe local. Nenhuma outra imagem foi alterada.
3. **[Auditoria de volume](auditoria-volume.md).** 38 WAVs, pico, RMS integral e maior RMS em janela móvel de100ms. Propostas adicionais aos ganhos atuais: trilhas−2,22dB; ataque/ação−2,88dB; cena−5,15dB; criaturas−4,05dB. São pontos de partida quantitativos para audição contextual; não foram aplicados e não comprovam equilíbrio perceptivo. Nenhum WAV foi modificado.
4. **[Esboço do Ato II](ato2-esboco.md).** Nove salas principais, duas opcionais, rotas baixa/alta e dois retornos, proposta de ferramenta, criaturas, Madre, limites das revelações e decisões do autor. Duração45–70min é orçamento hipotético, não partida medida. Não há arte, código ou falas novas para o ato. A produção só avança após o autor jogar o Ato I e relatar sua experiência.

## Verificações executadas

Godot Standard4.6.3, Linux; dados das partidas e configurações isolados em `/tmp`.

| Verificação | Resultado |
|---|---|
| Contrato de redução de pulsos | 59 verificações, zero falhas |
| Interface/persistência da opção | 8 verificações, zero falhas |
| Pulsos e equivalências acessíveis | 35 verificações, zero falhas |
| Cenas acessíveis | 22 verificações, zero achados |
| Bestiário | 44 verificações, zero falhas |
| Capítulo | 44 verificações, zero falhas |
| Culpa | 38 verificações, zero falhas |
| Expansão/exploração | 45 verificações, zero falhas |
| Cálculos de brilho | Autoteste: preto, branco, cinza, vermelho e limite estrito12 |
| Cálculos de áudio | Autoteste: níveis conhecidos, estéreo, silêncio, comparação com cálculo direto da janela, PCM8/24 e arquivo curto |
| Encerramento v2 | PNG, opacidade, tamanho, faixa de média e reserva inferior aprovados |
| Editor Godot | Importação concluída com dados temporários, sem erro no log final |
| Prévia visual | Arte inteira e legenda conferidas na captura1280×720 |

São **295 verificações nas oito suítes Godot**. Resultados em [v16-testes.json](v16-testes.json), [v16-reduced-pulses-result.json](v16-reduced-pulses-result.json) e nos JSONs das auditorias. O teste de cenas regrava um documento existente; preservei sua saída como [novo relatório](v16-acessibilidade-cenas-resultado.md) e restaurei o documento da base recebida. A captura usa renderização por software; há aviso de V-Sync indisponível no ambiente virtual.

Reproduzir as auditorias: `python3 tests/luminance_audit.py` e `python3 tests/loudness_audit.py`; cada script aceita `--self-test`. `python3 tests/v16_ending_check.py` verifica a alternativa. Dependências Python: Pillow e numpy. Esses scripts escrevem somente relatórios em `docs/`.

## Limites e integração posterior

Não houve playtest humano, audição crítica no contexto, medição do master com vozes simultâneas, calibração de monitores ou certificação de conforto fotossensível. As médias de brilho são Y′ em RGB codificado, não luminância física ou contraste WCAG. Os níveis de áudio são RMS/pico de amostra, não LUFS nem pico verdadeiro.

A integração recebida está testada; as novas propostas de ganho, a troca para a arte v2 e as decisões do Ato II ficam para a próxima revisão. O pacote `Lacrimae-v16-Entregas-Codex.zip` contém apenas os arquivos novos desta entrega. `Lacrimae-v16-Projeto-Godot.zip` contém a base integrada e os acréscimos; extrair e importar `project.godot` no Godot. O pacote completo ainda mostra a arte v1 na sequência do jogo até o Claude conectar a alternativa.
