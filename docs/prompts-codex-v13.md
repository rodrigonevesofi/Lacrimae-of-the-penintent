# Tarefas para o Codex — partir da v13

## Preâmbulo (cole antes de qualquer tarefa)

Use o zip `Lacrimae-of-the-penintent-v13-completo.zip` como base (ou aplique `mudancas-v13-sobre-versao-do-codex.patch` com `patch -p1`). Ele já contém os seus fundos, áudio, âncoras e testes, integrados.

Regras: crie apenas arquivos novos (arte, áudio, testes, documentos). Não edite `enemy.gd`, `narrative.gd`, `soundscape.gd`, `world_art.gd`, `exploration.gd`, `main.gd`, `hud.gd`, `player.gd`, `act_one_layout.gd`, `guilt_text.gd` nem `clips.json`. Ao terminar, descreva em `docs/` o que foi criado, como validar e o que não foi validado. Não declare equilíbrio, beleza ou impacto emocional comprovados por teste automatizado.

---

## Tarefa 1 — Três ilustrações do Guardião dos Sinos (cena de impacto)

O roteiro (`docs/roteiro-cinco-atos.md`, I.5) pede: o Guardião entra puxando uma corda que já não existe; ao cair, a mão continua o gesto da corda por um instante; o bronze fica imóvel. Pinte três ilustrações originais, 1920 × 1080, PNG opaco, no estilo das ilustrações de `assets/memory/`. Salve em `assets/boss/`:

1. `guardiao_01_corda.png`: o corpo fundido a um sino de bronze, a mão fechada sobre o vazio onde deveria haver uma corda, contraluz alaranjado, sombra pesada. Sem rosto legível.
2. `guardiao_02_gesto.png`: a mesma mão aberta no ar, um instante depois do golpe final, poeira de bronze, a corda ausente.
3. `guardiao_03_imovel.png`: o bronze imóvel, quase todo em sombra, com um único ponto de luz.

Regras: sem texto, sem criança, sem ferimentos explícitos. Não afirme que o Guardião é Tomé. Valide: 1280 × 720 com contraste legível; deixe a faixa inferior de 160 px mais escura, onde ficam as legendas. Entregue `docs/guardiao-ilustracoes.md`.

---

## Tarefa 2 — Duas cenas do Penitente com a boneca (animação)

O memorial hoje usa os quadros de choro do herói, sem a boneca nas mãos. Crie `assets/animation/hero_memorial.png` (1536 × 1024, RGBA, grade 6 × 4, fundo transparente, 256 × 256 por célula, personagem de perfil virado para a direita, pés em x = 128, y = 250, mesma escala de `hero_grief.png`):
- quadros 0–5: o Penitente ajoelha com a boneca de pano nas duas mãos;
- quadros 6–11: ele a deposita no chão e mantém a mão sobre ela;
- quadros 12–17: cabeça baixa, imóvel, respirando (ciclo);
- quadros 18–23: ele se levanta deixando a boneca.
A boneca tem um pequeno sol bordado no pulso esquerdo (`assets/cloth_doll.png` é a referência). Valide com `python3 tools/check_animation_atlases.py` e uma folha de contato. O Claude integra no `clips.json`.

---

## Tarefa 3 — Três trilhas sintetizadas para as salas secretas

Crie `tools/make_secret_music.py` (numpy) e gere em `assets/audio/`, estéreo, 44100 Hz, 16 bits, loop contínuo sem estalo de emenda, 16 s cada, com o motivo melódico comum das trilhas atuais (`assets/audio/ost_exploration.wav` é a referência):
- `ost_nave.wav`: coro vazio e órgão muito suave, quase silêncio, notas longas;
- `ost_terraco.wav`: vento, sinos distantes e uma corda grave sustentada;
- `ost_patio.wav`: bordões graves, tensão contida, sem percussão.
Valide: pico abaixo de −1 dBFS, a emenda do loop sem descontinuidade (diferença entre o último e o primeiro quadro abaixo de 0,02 de amplitude), espectro conferido. Entregue `docs/trilhas-secretas.md`. Não ligue ao jogo.

---

## Tarefa 4 — Roteiro de playtest para o autor (documento)

Escreva `docs/roteiro-de-playtest.md`: um roteiro de 30 a 40 minutos para o autor jogar o Ato I e relatar o que sentiu, já que nenhum teste automático mede isso. Estruture por etapas: túmulo e espada; Cidade e Iria; Ossuário (duelistas e relevo); Cisterna (Asmodeia); Claustro (flagelantes); Campanário (Devorador e a corrente alta com as três batidas); Arquivo (aquelarre); salas secretas (Nave, Terraço, Pátio); o Guardião; a Memória dos portões. Para cada etapa: o que fazer, o que observar (leitura dos ataques, justiça do dano, ritmo, clareza do mapa, som) e 3 perguntas curtas com respostas de 1 a 5, mais uma linha livre. Inclua também uma tabela para registrar mortes por local e o tempo total. Termine com uma folha-resumo de uma página para o autor colar aqui na conversa. Declare que o objetivo é coletar a percepção do autor e que o documento não mede nada por si só.

---

## Tarefa 5 — Verificação de acessibilidade das cenas (testes e documento)

Crie `tests/accessibility_scenes_check.gd` que, para cada cena de culpa (eco, memorial, memória), confirma: toda informação sonora essencial (batidas, vozes, sino) tem equivalente visual ou legenda; a cena pode ser pulada depois do tempo mínimo; nenhuma cena tem mais de 3 flashes por segundo (a luz branca de cada batida conta como um flash). Registre o resultado em `docs/acessibilidade-cenas.md`. Se houver falha, descreva-a e não edite os scripts do jogo.
