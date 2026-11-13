# Integração da versão 33

Base: versão 32 publicada. Patch cumulativo v33 integrado, com novas artes autorizadas pelo autor. O Penitente mantém seu estilo, capacete fechado e rosto oculto. Beatriz continua distinta da Inquisidora; Edran e a Inquisidora permanecem no roteiro do Ato II.

## Execuções próprias

Seis atlas RGBA de 1536 × 512, em grade 6 × 2, com 12 quadros e âncora nos pés em (128, 250). A linha de tempo ativa dura um segundo, a 12 quadros por segundo, além da pausa de impacto e da câmera lenta. A primeira emissão de sangue e o golpe mortal das novas sequências ocorrem no quadro 8, contado a partir de zero. O alvo continua sendo desenhado separadamente pelo jogo.

| Criatura | Movimento próprio | Folha de contato |
| --- | --- | --- |
| Devorador | Usa a espada como alavanca e arranca a mandíbula | [12 quadros](contatos-v33/contato-devorador.png) |
| Flagelante | Prende e puxa o chicote do próprio inimigo | [12 quadros](contatos-v33/contato-flagelante.png) |
| Bruxa | Estocada ascendente contra a criatura aérea | [12 quadros](contatos-v33/contato-bruxa.png) |
| Asmodeia | Corta e arranca a membrana da capa que forma a asa | [12 quadros](contatos-v33/contato-asmodeia.png) |
| Duelista | Toma o cacete e aplica o golpe final com ele | [12 quadros](contatos-v33/contato-duelista.png) |
| Carregador | Esmaga com uma lasca do próprio caixão | [12 quadros](contatos-v33/contato-carregador.png) |

O manifesto registra `execute_<criatura>` e os tempos de contato; a seleção existente escolhe o clipe pelo tipo do alvo. O Carregador continua exigindo a quebra prévia da pedra. As sequências anteriores do Devoto, Chorão e de Beatriz conservam seus tempos. O rosário provisório desenhado por código aparece apenas na execução original do Devoto, evitando sobrepor um segundo adereço às novas folhas.

O sangue de execução foi reduzido para preservar a leitura do gesto. As gotas usam um pequeno gradiente arredondado, com gravidade, em vez de quadrados. As poças continuam limitadas e desaparecem gradualmente.

## Peso de Beatriz

`assets/animation/beatriz_peso.png`: 768 × 256, três quadros em grade 3 × 1. No chão e parada, Beatriz usa a pose 0 com peso 0–33, a pose 1 com 34–66 e a pose 2 com 67–100. A mudança é de postura, sem redimensionar o corpo nem alterar a colisão. Ataque, corrida, salto, resgate e rituais mantêm suas próprias animações. A oração zera o peso dos dois personagens.

[Folha de contato das três posturas](contatos-v33/contato-peso.png).

## Impactos por material

A folha `impactos.png` foi preparada a partir da imagem do Argon fornecida pelo autor. Armadura emite [faíscas](contatos-v33/contato-impacto-faiscas.png); carne, [sangue](contatos-v33/contato-impacto-sangue.png); caixão e piso, [pedra](contatos-v33/contato-impacto-pedra.png); o golpe descendente no Ossuário solta [osso](contatos-v33/contato-impacto-osso.png). O material é capturado antes de aplicar o dano: o golpe que quebra o caixão ainda solta pedra, e os seguintes atingem carne. O contato comum com a pedra usa som de impacto duro.

## Comparação com as reações do Argon

As referências `hero_reacoes_argon.jpg` e `hero_carregado_argon.jpg`, fornecidas pelo autor, foram comparadas às animações atuais. Aparo, recuo de aparo, contra-ataque forte, acúmulo e soltura de carga, dano, morte, cura, golpe aéreo e aterrissagem já possuem desenhos no estilo atual. Não foi identificado um estado de reação ausente que exigisse outra folha nesta entrega. O Penitente do Argon não substituiu o atual.

## Verificação e limites

Godot **4.6.3.stable.official.7d41c59c4**, obtido do [arquivo oficial do Godot](https://godotengine.org/download/archive/4.6.3-stable/), com dados temporários de teste isolados dos salvamentos do autor. Foram executadas **38 suítes**, somando 1.398 verificações, casos e recursos conferidos; os testes afetados pelos ajustes finais de arte e sangue foram repetidos. Todas as verificações finais passaram. [Resultados por suíte](v33-testes.json).

`tests/v33_art_smoke.gd` verifica cada criatura antes, durante e depois do quadro 8, o retorno do controle, os limites das três faixas de peso, a restauração no altar, a quebra do caixão por golpe leve e carregado e os materiais do piso. A expectativa antiga do bestiário foi atualizada para exigir a execução própria do Devorador.

Foram renderizadas 11 folhas de contato e 18 capturas em cena, nos quadros 5, 8 e 10 de cada criatura. A limpeza dos fundos e a redução dos efeitos foram conferidas visualmente no renderizador de compatibilidade. O ensaio gráfico terminou sem erros de script. Algumas suítes aceleradas ainda registram recursos de áudio em uso ao encerrar, sem falhas nas verificações.

Não houve partida humana prolongada, avaliação auditiva nova, teste em outros equipamentos ou exportação do executável nesta entrega. A interação visual foi conferida por capturas dirigidas; a avaliação final de sensação, ritmo e equilíbrio depende de jogar. Os 11 WAV da versão 32 foram preservados byte a byte. O patch fornecido não contém o pacote completo de imagens de documentação ou o retrato novo de Beatriz; os recursos novos desta integração são os atlas gerados e as capturas indicadas acima.

As artes usaram a ferramenta integrada de geração de imagens. A preparação posterior apenas exportou as células para a grade e a âncora do jogo, preservando o RGBA. [Prompts e caminhos dos arquivos](v33-prompts-arte.md).
