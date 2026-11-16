# Versão 42 — entrega

Base: versão 41 (trilha do Lyria e suporte à cutscene), mais o ramo `confessionario-ia` do repositório.

## O que entrou

- **Confessionário com IA** (ramo `confessionario-ia`), fundido sobre a versão 41: painel, Confessor (Gemini com modo sem rede), telemetria local, suporte a controle, tela cheia (F11) e prévia no editor. Documentação em [confessionario.md](confessionario.md).
- **O Confessor conhece o jogo atual:** o Vale dos Flagelados, o Flagelado, as nove criaturas de Goya e as teclas novas. Ganhou a regra de nunca dizer quem é o Flagelado, um assunto "vale" no modo sem rede e a pergunta pronta "O que me espera no Vale?".
- **No Vale o Confessor se cala:** o Confessionário não abre durante a última luta nem durante a revelação.
- **Cutscene da revelação com os seis clipes** enviados pelo autor (`assets/cutscene/revelacao_01.ogv` a `06`). Os clipes vieram com 10 s; `tools/preparar_cutscene.py` agora acelera até 1,3x para caberem nos 8 s de cada trecho.
- **Encerramento depois do Vale:** quatro linhas novas e "— FIM —" no lugar de "fim do capítulo jogável". A última linha é o gancho: "Agora você sabe de quem eram as mãos. Falta saber de quem era a ordem."
- **README** reescrito: só o jogo, com a continuação como gancho.
- **Documentos:** [documentacao/](documentacao/) traz a documentação do jogo e o roteiro completo, em Word e PDF.
- **Pranchas de conceito:** [pranchas/](pranchas/) traz 24 pranchas (11 cenários, 5 personagens, 8 criaturas) montadas por `tools/gerar_pranchas.py` com a arte usada no jogo e telas reais.

## Clipes escolhidos

Vieram duas versões dos clipes 5 e 6. Entraram o **5 original** (continua o plano do rosto: a mão baixa e ele olha para quem joga) e o **6 v2** (a lança e os pilares ao fundo). Para trocar, renomeie o outro arquivo e rode `python3 tools/preparar_cutscene.py <pasta>`.

## Não verificado

- **A resposta real do Gemini.** Não havia chave aqui: só o modo sem rede e o formato da requisição foram testados. O nome do modelo em `ia_local.cfg.exemplo` precisa ser conferido com `Testar-IA-Windows.cmd`; se o modelo não existir, o painel mostra "modelo não encontrado" e responde com as falas prontas.
- **Som.** Ninguém ouviu a cutscene com a música da revelação por cima.
- **Controle.** O suporte a controle foi testado por simulação de entradas, não com um controle físico.
- As pranchas são **montagens** da arte do jogo, não pinturas novas.
