# Entrega v41 — trilha do Lyria e cutscene da revelação

Feita sobre a versão 40 publicada pelo Codex (commit `14b2d7b`), mantida inteira.

## 1. Trilha nova
As nove músicas geradas pelo autor no Lyria 3.5 (Google Flow Music), com coro, órgão e cordas, substituem as músicas sintetizadas.

| Onde toca | Arquivo | Recebida | Em laço | Volume médio |
| --- | --- | --- | --- | --- |
| Menu | `ost_menu.ogg` | 119 s | 114 s | -23.0 dB |
| Exploração (e Terraço, Pátio) | `ost_exploration.ogg` | 146 s | 141 s | -24.5 dB |
| Combate | `ost_combat.ogg` | 125 s | 118 s | -20.0 dB |
| Chefe | `ost_boss.ogg` | 152 s | 146 s | -19.0 dB |
| História | `ost_story.ogg` | 119 s | 114 s | -23.5 dB |
| Templo e oração (e Nave) | `ost_temple.ogg` | 120 s | 114 s | -24.5 dB |
| Final do ato | `ost_ending.ogg` | 119 s | 112 s | -23.0 dB |
| Luta final no Vale | `ost_vale.ogg` | 181 s | 175 s | -19.0 dB |
| Revelação | `ost_revelacao.ogg` | 90 s | 84 s | -21.5 dB |

O que foi feito em cada faixa (`tools/integrar_trilha.py`):
- convertida de MP3 para OGG Vorbis, 44,1 kHz estéreo;
- silêncio das pontas cortado;
- **laço:** os últimos 3 segundos (a cauda de reverberação) são fundidos sobre os 3 primeiros, para a faixa dar a volta sem buraco nem estalo;
- **volume por contexto:** luta e chefe mais altos, exploração e templo mais baixos, na mesma hierarquia da mixagem anterior. As faixas chegaram todas entre -16 e -20 dB.

No jogo (`scripts/soundscape.gd`): a música de cada contexto é o `.ogg` quando existe; o `.wav` antigo fica como reserva. A Nave do Silêncio passa a usar o canto do templo, e o Terraço e o Pátio a exploração, sem recomeçar a faixa ao trocar de sala. **O Vale e a revelação agora têm música própria.**

## 2. Cutscene em vídeo
A revelação pode ser um filme. Com clipes `revelacao_01.ogv` a `revelacao_06.ogv` em `assets/cutscene/`, a cena passa a durar 52 s: cada clipe ocupa a tela por 8 s, as sete falas viram legendas, e continuam tocando a música da revelação, a corrente, o capacete e o sino. Um trecho sem clipe mostra o close parado. **Sem nenhum clipe, a cena é a de antes (44 s), e é assim que esta versão sai: os clipes ainda não foram gerados.**

- Prompts e quadros iniciais: [prompts-cutscene-veo-v41.md](prompts-cutscene-veo-v41.md).
- Conversão dos MP4: `tools/preparar_cutscene.py` (o Godot só toca Ogg Theora).

## 3. Verificação
- `tests/v41_trilha_smoke.gd`: 61 verificações (nove faixas em OGG, em laço, diferentes entre si, na duração registrada; hierarquia de volume; contextos que compartilham faixa; Vale e revelação com música).
- `tests/v41_cutscene_smoke.gd`: 33 verificações, com um clipe de teste (modo filme liga, tempos dos seis trechos, falas dentro do trecho certo, som do jogo, término; sem clipes nada muda).
- O conjunto completo foi rodado numa cópia limpa do pacote; o resultado está na mensagem de entrega.

## O que não foi verificado
- **Escuta.** A emenda do laço é uma fusão de 3 s; ela evita estalo e silêncio, mas não garante que a frase musical continue de forma natural na volta. Só ouvindo.
- O equilíbrio entre a trilha nova e os efeitos numa partida.
- A cutscene com clipes reais: foi testada só com um clipe de teste de 1 segundo.
