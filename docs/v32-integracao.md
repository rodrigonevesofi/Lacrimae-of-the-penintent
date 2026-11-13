# Integração da versão 32

Integra o patch cumulativo v32 à versão 30 publicada, preservando o refinamento do combate: comandos armazenados durante a pausa de impacto, cancelamentos na recuperação, aparo com contra-ataque imediato, três ritmos de combo, carga variável, alcance simétrico e bloqueio por paredes e plataformas.

- Quatro folhas próprias de Beatriz, adaptadas das referências do Argon ao estilo do Penitente atual: movimento, combate, reações e rituais. A máscara é fechada, sem aberturas para os olhos. A lança desenhada substitui o recurso provisório feito por código. Os rituais também mantêm a aparência de Beatriz.
- A queda permanece na pose deitada; doar sangue durante o resgate usa o gesto próprio. A história, o peso da lança e o sangue compartilhado continuam integrados à dupla.
- Onze WAV do pacote `sons-v32-sem-zumbido.zip`, sem ressíntese. Três variações de estocada, empalar, carga, soltura, arremate, impacto descendente, doação de sangue, queda e resgate. [Medidas dos arquivos](sons-v32-integracao.md).
- Recortes de duas fileiras em `onda_golpe` e `onda_grito`, com suporte preservado à propriedade `grid`. O golpe descendente emite uma onda de poeira; a carga completa emite um anel vermelho, sem duplicar os efeitos.
- Comentários novos dos scripts em português e controles atualizados no README.

## Verificação

Godot 4.7.2: 17 suítes, 780 verificações/casos aprovados. Inclui cooperação (18), recursos v32 (61), fluxo de comandos (23), regras de combate (44), combate enriquecido (10), modo de desenvolvimento (5), dupla e peso (13), sangue nas execuções (9), apresentação do herói (31), salvamento corrompido/legado (13 casos), animação (339), áudio (18), pulsos reduzidos (59 + 8), encontros (16), entradas (81) e recortes de efeitos (32).

A sonda de alcance aéreo à esquerda foi posicionada abaixo de uma plataforma que antes interceptava a trajetória. Ela agora confirma explicitamente que o alvo está em espaço livre antes de conferir o dano; a colisão do jogo foi preservada.

Sete capturas renderizadas conferem golpe leve, carga, soltura, onda descendente, estocada de Beatriz, queda e doação de sangue. O ensaio gráfico terminou sem erros. Algumas suítes aceleradas ainda informam recursos de áudio em uso ao encerrar; não houve erros de script ou falhas nas verificações finais.

A validação de áudio foi numérica e de integração de eventos; o timbre e o eventual zumbido precisam de escuta humana. As verificações não substituem uma partida para avaliar sensação e equilíbrio.

[Arte, arquivos e prompts utilizados](arte-beatriz-v32.md).
