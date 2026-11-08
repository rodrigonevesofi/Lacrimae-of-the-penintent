# Mixagem de áudio

## Como o jogo controla o volume
Os níveis de base ficam em `scripts/soundscape.gd`. Para ajustar a mistura depois de ouvir, mude os quatro números de `MIX_TRIM_DB` (em dB, somados ao nível de cada grupo): `tracks` (trilhas), `action` (golpes, saltos, passos, cura), `scene` (altar, sino, respiração, batidas, murmúrios, corrente) e `creature` (sons das criaturas). Todos começam em 0, e um teste confere isso.

## A proposta do Codex e por que não foi aplicada
A [auditoria de volume](auditoria-volume.md) mediu 38 arquivos e propôs deslocamentos: trilhas −2,2 dB, ação −2,9 dB, criaturas −4,1 dB e cena −5,2 dB. São medidas em arquivo, não percepção.

Não apliquei, por duas razões. Primeiro, ninguém ouviu o resultado em jogo, nem eu nem ele, e o próprio documento diz que o RMS por grupo não comprova equilíbrio. Segundo, a proposta deixaria os sons de cena (as batidas, os murmúrios, o sino) cerca de 3 dB mais baixos que as trilhas e 2,3 dB mais baixos que os golpes, o contrário da intenção das cenas: elas abaixam a música justamente para que esses sons apareçam. Se, ao jogar, algo estiver alto demais, comece mexendo em `creature` e `action`.

Para decidir: jogue com fones e anote, na folha do playtest, o que ficou alto ou baixo demais. Eu converto isso em valores.
