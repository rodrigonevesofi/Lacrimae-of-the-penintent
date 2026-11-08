# Tarefas para o Codex — partir da v12

## Preâmbulo (cole antes de qualquer tarefa)

Antes de começar, atualize a base: use o zip `Lacrimae-of-the-penintent-v12-completo.zip` como ponto de partida (ou aplique `mudancas-v12-sobre-versao-do-codex.patch` com `patch -p1`). Ele já contém as salas secretas, o bestiário com a sua arte, as cenas de culpa, as suas ilustrações da Memória dos portões e o fragmento animado.

Regras de convivência: crie apenas arquivos novos (arte, áudio, testes, documentos). Não edite `enemy.gd`, `narrative.gd`, `soundscape.gd`, `world_art.gd`, `exploration.gd`, `main.gd`, `hud.gd`, `act_one_layout.gd` nem `guilt_text.gd`. A única edição permitida em arquivo existente está dita na tarefa 3. Ao terminar, descreva em um documento em `docs/` o que foi criado, como validar e o que não foi validado. Não declare equilíbrio, beleza ou impacto emocional comprovados por teste automatizado.

---

## Tarefa 1 — Fundos próprios das três salas secretas

Pinte três cenários originais, 2172 × 724, PNG opaco, perspectiva lateral, no mesmo estilo dos fundos atuais (`assets/cistern.png`, `assets/cloister.png`). O piso onde os pés pisam fica a 86% da altura da imagem, contínuo de ponta a ponta, sem degraus pintados que pareçam caminháveis. Salve em `assets/`:

1. `nave_silencio.png`: nave de basílica de pedra escura; bancos virados para a parede nua (nenhum aponta para o altar), um coro elevado à esquerda, um altar-mor ao fundo com velas, luz fria dos vitrais. Atmosfera de silêncio imposto, sem figuras humanas.
2. `terraco_sinos.png`: terraço ao ar livre sobre a cidade em ruínas, armações de sinos com cordas cortadas rente, parapeito, névoa azulada, um sino partido no chão. Sem badalos.
3. `patio_portoes.png`: pátio de pedra diante de portões monumentais selados com correntes, relevos de figuras ajoelhadas nas folhas, marcas de unhas riscadas na parede ao lado. Luz laranja de poente baixa.

Regras: sem texto, sem criança, sem corpos. Os portões do Pátio não podem ser os mesmos desenhos de `assets/court.png`: mude composição e proporção.

Valide: sobreponha uma linha a 86% e confira que o piso coincide; reduza a 1280 × 720 e confira legibilidade com o Penitente de ~90 px de altura sobre o piso. Entregue `docs/fundos-secretos.md`.

---

## Tarefa 2 — Sonda de equilíbrio com reflexos humanos (somente testes)

Crie `tests/balance_probe_human.gd`, sem alterar nenhum valor do jogo. O robô atual ataca sem parar e mata as criaturas antes de elas agirem; não mede perigo. Faça um controlador com:
- latência de reação aleatória entre 180 e 260 ms antes de esquivar uma preparação de ataque, e 10% de erros;
- recuo quando a vida cai abaixo de 40 e uso da cura;
- encontros reais de `Layout.enemies()` (o aquelarre de três bruxas, o par de duelistas, o Devorador isolado, o Flagelante sozinho e em dupla).

Para cada encontro, 10 sementes: tempo, dano recebido, mortes do Penitente, quantas vezes cada mecânica acertou (bote, investida, estilhaços, leque de lágrimas). Grave `docs/equilibrio-humano.md` com a tabela, o método e uma lista curta de achados. Declare que é simulação e que não substitui jogadores.

---

## Tarefa 3 — Revisão visual das execuções (arte e âncoras)

Para cada uma das cinco criaturas novas, gere uma folha com os 12 quadros da execução (Penitente e vítima) lado a lado com o clipe `execute_devotee` ou `execute_mourner` do herói, usando `tools/preview_bestiary.gd` como base. Meça o deslocamento em pixels entre os pés da vítima e o chão do herói em cada quadro. Só você pode editar, e apenas o campo `"anchor"` das entradas `executed` das cinco criaturas em `assets/animation/clips.json` (`devorador`, `flagelante`, `bruxa`, `asmodeia`, `duelista`), para corrigir deslocamentos maiores que 6 px. Documente cada alteração em `docs/execucoes-revisao.md` com antes e depois.

---

## Tarefa 4 — Murmúrios e sons para as cenas de culpa (áudio sintetizado)

Crie `tools/make_culpa_audio.py` (numpy, como `tools/make_knock.py`) e gere em `assets/audio/`, mono 22050 Hz, 16 bits:
- `murmurio_01.wav`, `murmurio_02.wav`, `murmurio_03.wav`: 3 a 4 s cada, uma multidão de vozes adultas abafadas, ouvidas através de pedra, sem palavras reconhecíveis e sem voz de criança; fade de entrada e saída de 0,4 s.
- `corrente_cede.wav`: 2 s, elos de ferro pesados cedendo, com um estalo final.
- `sino_surdo.wav`: 4 s, um sino grave abafado, uma única badalada.

Valide: sem clipping (pico abaixo de −1 dBFS), sem silêncio inicial maior que 50 ms, espectro conferido. Entregue `docs/audio-culpa.md`. Não ligue os sons ao jogo; o Claude integra.

---

## Tarefa 5 — Teste lexical dos textos de culpa

Crie `tests/guilt_text_review.gd`, no estilo de `tests/story_review_smoke.gd`. Ele lê `scripts/guilt_text.gd` e `scripts/narrative.gd` e falha se algum texto exibido ao jogador no Ato I mencionar: o ritual (Lacrimae Sacramentum), o pedido de esquecimento, o nome do protagonista, parentesco entre Alba e Iria, ou confirmar a sobrevivência de Alba. Inclua também a verificação de que nenhuma cena de culpa promete perdão, cura ou recompensa. Liste no resultado cada frase examinada.
