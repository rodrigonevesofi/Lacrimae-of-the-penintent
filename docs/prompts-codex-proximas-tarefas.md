> Estado: as tarefas 1, 2 e 3 já foram entregues pelo Codex e integradas na v12. Resta a tarefa 4 (fundos próprios das três salas secretas).

# Próximas tarefas para o Codex

Regra de convivência: até o Claude entregar a v11 (fusão da versão 05 + arte do bestiário + cenas de culpa), **não edite** `enemy.gd`, `narrative.gd`, `soundscape.gd`, `world_art.gd`, `exploration.gd`, `main.gd`, `hud.gd`, `act_one_layout.gd` nem `clips.json`. As tarefas abaixo só criam arquivos novos (arte, áudio, testes, documentos).

## 1. Ilustrações-chave da Memória dos portões (prioridade alta)

Crie quatro ilustrações originais, 1920 × 1080, PNG opaco, para a cena "Memórias da culpa · I" do Ato I, no mesmo estilo pintado e sombrio do cenário dos portões (`assets/gates.png`, `assets/court.png`). Salve em `assets/memory/` com estes nomes:

1. `memoria_01_maos_na_roda.png`: plano fechado de duas mãos adultas, sujas de ferrugem, sobre o aro de uma grande roda de bronze de portão. Luz quente baixa vinda do lado oposto, sombra pesada.
2. `memoria_02_mao_pequena.png`: uma mão pequena de criança agarrando uma barra de ferro, em contraluz quente. No pulso, um punho de tecido com um pequeno sol bordado em fio dourado. Sem rosto.
3. `memoria_03_figura_atras.png`: visão de dentro para fora; uma figura encapuzada alta, indistinta, em contraluz pálido, a alguma distância, sem rosto legível.
4. `memoria_04_portao_fechado.png`: a mesma porta monumental dos portões, fechada, quase toda em sombra, com um único ponto de luz. Esta imagem fecha a cena.

Regras: não mostrar rosto de criança nem ferimentos. A criança só aparece pela mão. Nada de texto na imagem. A imagem 2 deve funcionar também sem o sol (haverá uma versão sem o bordado): entregue `memoria_02_mao_pequena_sem_sol.png`.
Valide: abra cada imagem sobre fundo escuro e claro, confira que a mão e a figura têm contraste suficiente quando reduzidas a 1280 × 720.

## 2. Fragmento de culpa animado

Crie `assets/animation/fragmento_culpa.png` (1536 × 1024, RGBA, grade 6 × 4, fundo transparente): 12 quadros de um fragmento luminoso de lágrima azul-pálida que pulsa e solta fios de luz (quadros 0–11, loop), seguido de 6 quadros em que ele se desfaz em partículas (12–17). Sem rosto, sem forma humana. O tamanho do fragmento deve ocupar cerca de metade da célula.

## 3. Sonda de equilíbrio (somente testes)

Crie `tests/balance_probe.gd`, que não altera o jogo. Para cada tipo de inimigo comum (`Enemy.TYPES` das versões que contêm o bestiário), posicione o Penitente com 100 de vida e espada, simule um jogador que ataca e esquiva com regras simples e registre: tempo para derrotar, dano sofrido e quantas esquivas bem-sucedidas. Imprima uma tabela em `docs/equilibrio.md`. Declare no documento que é uma simulação simples, não prova de equilíbrio com pessoas.

## 4. Fundos dedicados das três salas secretas (depois da v11)

Pinturas de cenário originais para Nave do Silêncio, Terraço dos Sinos e Pátio dos Portões Selados, no formato dos fundos atuais (2172 × 724, RGBA ou opaco), com piso contínuo e perspectiva lateral. O Claude integra os arquivos depois.
