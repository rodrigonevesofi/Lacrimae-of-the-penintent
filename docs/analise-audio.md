# Análise do áudio do Lacrimae

## Como foi feito e o que não dá para saber
Não ouço áudio. O que fiz foi **medir**: extraí o som da gravação de jogo do autor (10 min 33 s), de oito clipes de Blasphemous e, para eliminar o ganho da gravação de tela, **gravei a mistura digital do próprio jogo** (modo de filmagem da Godot, `tests/record_audio_scenes.gd`) em quatro situações. Medi loudness (LUFS), pico, faixa dinâmica (LRA), equilíbrio de frequências, silêncio, densidade de eventos e a **ocupação espectral** (quanta parte do espectro de 200 Hz a 8 kHz está ativa em cada instante).
Não dá para saber por medição: se a música é boa, se os sons combinam com a imagem, o caráter dos sons, o conforto de ouvir. Isso continua dependendo de ouvidos. Os clipes de Blasphemous vêm de vídeos do YouTube (compressão e normalização, e possivelmente música de terceiros), então comparações absolutas têm folga.

## Uma correção
A gravação de tela do autor media de −28 a −39 LUFS e sugeria um jogo muito baixo. A mistura digital do jogo mede **de −23 a −17 LUFS**, perto dos −13 a −23 dos clipes de Blasphemous. A diferença de cerca de 12 dB vinha do ganho da gravação. O jogo **não** era tão baixo quanto parecia na gravação, mas era de 3 a 5 dB mais baixo que o ideal na exploração.

## Resultados
| Cena | LUFS | Pico dBFS | LRA | Ocupação espectral |
| --- | ---: | ---: | ---: | ---: |
| Nosso, exploração (antes) | −23,3 | −5,5 | 3,2 | 40% |
| Nosso, luta (antes) | −17,0 | **+1,3 (estoura)** | 16,5 | 23% |
| Nosso, cenas do Guardião | −20,7 | −5,9 | 6,2 | 19% |
| Nosso, Memória | −24,0 | −3,9 | 10,2 | 13% |
| Blasphemous, contra-ataques | −17,6 | −0,5 | 3,1 | 88% |
| Blasphemous, combate vs cavaleiro | −18,3 | −1,7 | 2,2 | 67% |
| Blasphemous, plataformas | −21,8 | −2,8 | 4,1 | 62% |
| Blasphemous, chefe | −23,0 | −7,0 | 11,4 | 78% |
| Blasphemous, caixão e corredor | −20,8 | −1,5 | 3,5 | 78% |

O espectrograma ([audio-espectrograma.png](imagens/audio-espectrograma.png)) mostra o mesmo: o nosso som é **uma faixa estreita e contínua de tom, com buracos**, mais barras verticais ocasionais (golpes); o de Blasphemous é **textura em todas as frequências**, com muitos transientes de larguras diferentes.

## O que faltava (e o que já foi feito)
1. **A luta estourava.** Pico de +1,3 dBFS, distorção digital. Não havia nenhum barramento de áudio nem limitador. **Feito:** barramentos Música e Efeitos e limitador no Master (teto de −1 dBFS, com 3 dB de ganho antes). Medido: luta com pico de −0,8 dBFS; exploração de −23,3 para −20,2 LUFS, sem estourar.
2. **Sem espaço.** Nenhum reverb. **Feito:** reverb nos efeitos, com cauda diferente por sala (nave 0,40; cisterna 0,36; Cidade aberta 0,10).
3. **Os sons soavam sempre iguais.** Só 3 sons variavam, só no tom. **Feito:** todos os efeitos, exceto os narrativos (sino, batidas, murmúrios, altar), variam ±6% no tom e ±1,2 dB no volume.
4. **Tudo no centro da tela.** **Feito:** os sons das criaturas e dos projéteis agora são posicionais (à esquerda ou à direita do Penitente, mais fracos longe).
5. **Eventos mudos.** Apenas 8 eventos tocavam som: golpe, swing, passo, esquiva, salto, dano, cura e a morte do Penitente. **Feito:** ganchos ligados a 17 eventos sem som (morte e dor de inimigo, morte e pancada do chefe, aterrissagem, coleta, porta, projétil e seu impacto, espinho, aparo, execução, portão da arena fechando e abrindo, e dois de interface). **Cada gancho fica inerte até existir um arquivo com o nome certo em `assets/audio/`**; assim que o Codex entregar, tocam sem mexer no código.
6. **Mistura fina.** A ocupação espectral de 13% a 40% contra 62% a 88%. **Isto não se resolve com código**: faltam camadas de textura (ambiência por sala, foley, detritos, vento, água, fogo) e sons de cada coisa. Está no prompt do Codex.

## O que ainda falta e depende de arquivos de som
- Ambiência de cada sala (10 faixas em laço).
- Passos por superfície (pedra, madeira, água, osso).
- Variações de golpe (carne, metal), de dor e de morte por tipo de criatura.
- Os 17 sons dos ganchos.
- Música em camadas (que sobem e descem com o combate).

## Depois da entrega de áudio do Codex (v20)
Ligados: os 17 sons de eventos, as 10 ambiências de sala (em laço, com transição de 1,6 s entre salas e abaixando 14 dB durante as cenas), passos por superfície (pedra, madeira, água, osso) e variações de golpe em carne e em metal, de dor, de morte e de swing.

| Cena (mistura digital) | Ocupação espectral | LUFS | Pico |
| --- | ---: | ---: | ---: |
| Exploração | 40,5% → **91,6%** | −23,3 → −19,5 | −5,5 → −4,0 |
| Luta | 23,2% → **90,0%** | −17,0 → −17,4 | +1,3 → −0,8 |
| Cenas do Guardião | 18,9% → 30,9% | −20,7 → −17,6 | −5,9 → −2,8 |

Atenção: a ocupação agora fica **acima** dos clipes de Blasphemous (62% a 88%). Uma ambiência alta demais também enche o espectro e pode encobrir os golpes. O nível das ambiências (−9 dB, ajustável em `MIX_TRIM_DB.ambience`) é um palpite, e só quem ouvir pode confirmar. Nas cenas a ambiência baixa de propósito.
