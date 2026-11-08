# Cenas de culpa (v15)

Seguem as regras do [roteiro dos cinco atos](roteiro-cinco-atos.md): nenhuma cena revela o ritual nem o pedido de esquecimento, nenhuma obriga o jogador a ser autor do fechamento dos portões, memórias duram de 15 a 30 segundos com opção de seguir, e nenhuma dá recompensa nem reduz culpa.

| Cena | Quando | O que acontece |
| --- | --- | --- |
| Eco do fragmento | Nas três primeiras vezes em que o fragmento de culpa é recuperado | O Penitente se ajoelha numa poça de luz; o mundo cai em sombra. Primeiro eco: três batidas ao longe e silêncio. Segundo: uma voz pede que abram. Terceiro: "Ainda estamos aqui." Depois, só uma linha discreta |
| Memorial | Ao deixar a boneca ou gravar o nome | Cena silenciosa de 9 s com um sino; depois o texto escrito, que pode ser relido |
| Memória dos portões | Após o Guardião | 27 s em cinco tempos: vozes, a mão pequena na grade (com o sol bordado se a boneca foi encontrada), uma figura indistinta, a roda girando e três batidas seguidas de corte |
| Três batidas | Ao soltar a corrente alta do Campanário | Três batidas do lado interditado, com intervalo de 0,62 s; terminam antes de qualquer pista de onde vêm |
| Entrada do Guardião | Ao despertar o chefe | Cena curta de 6,5 s: "O Guardião dos Sinos puxa uma corda que já não existe." e a frase "Enquanto tocar, alguém virá abrir." |
| Queda do Guardião | Ao derrotá-lo | Cena de 9 s: "A mão continua o gesto da corda por um instante." e depois "Não veio ninguém.", em silêncio; segue direto para a Memória dos portões. Na segunda metade da luta, três batidas respondem de além dos portões |
| Morte | A cada morte | Uma frase de testemunho abaixo de "A culpa permanece" |

Os textos estão em `scripts/guilt_text.gd`. Os sons são sintetizados: as batidas (`knock.wav`), os murmúrios de vozes abafadas, o sino surdo do memorial e a corrente que cede (ver [audio-culpa.md](audio-culpa.md)). O teste lexical `tests/guilt_text_review.gd` confere que nenhum texto antecipa revelações dos atos seguintes.

## Ilustrações do Guardião

As cenas do Guardião usam as três ilustrações do Codex em `assets/boss/` (`guardiao_01_corda.png`, `guardiao_02_gesto.png`, `guardiao_03_imovel.png`; nomes em `narrative.gd`, constante `BOSS_ART`). Se um arquivo faltar, a cena usa apenas luz de bronze e texto.

## Ilustrações e fragmento

A Memória dos portões usa cinco ilustrações pintadas pelo Codex em `assets/memory/`, na ordem do roteiro: as mãos sobre o mecanismo (abertura), a mão pequena na grade (com o sol bordado se a boneca foi encontrada, sem ele se não), a figura indistinta ao fundo, as mesmas mãos empurrando a roda, com um leve tremor, e o portão fechado com um único ponto de luz, sob as três batidas. As silhuetas desenhadas por código continuam apenas como reserva, se um arquivo faltar.

O fragmento de culpa deixou de ser um desenho improvisado: é um sprite animado (`assets/animation/fragmento_culpa.png`, atlas `fragmento` em `clips.json`) que pulsa onde o Penitente caiu e se dissolve em partículas quando é recuperado.

## Validação

`tests/guilt_smoke.gd` (30 verificações): contagem dos ecos, batidas exatas, impossibilidade de pular os primeiros instantes, retorno de controle, câmera e música, ausência de efeito em vida, culpa e lágrimas, salvamento do contador, o memorial sem recompensa, duração da memória entre 15 e 30 s, memória que avança sozinha e todos os tempos da memória desenhados sem erro de script. As cenas foram renderizadas e revistas quadro a quadro.

## O que isso não prova

Nenhum teste mede se alguém sente culpa. A leitura visual foi feita por captura de tela, não por jogadores. O foco de luz e o ritmo das batidas precisam ser julgados jogando.


## Memorial com a boneca, trilhas e legendas de som (v15)

- O memorial usa o atlas `hero_memorial` (24 quadros): o Penitente ajoelha com a boneca, a deposita, fica com a mão sobre ela e se levanta. Enquanto a cena dura, a boneca do mundo fica oculta e aparece quando ela termina.
- A Nave, o Terraço e o Pátio têm trilha própria (`ost_nave`, `ost_terraco`, `ost_patio`), sintetizadas pelo Codex. Não foram ouvidas em contexto por mim.
- Todo som essencial das cenas tem legenda no canto da tela: `[Sino]`, `[Sino grave, abafado]`, `[Vozes abafadas]` e `[Batida]`.
