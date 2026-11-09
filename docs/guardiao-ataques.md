# Novos ataques do Guardião

`assets/animation/guardiao_colosso_ataques.png`: RGBA 2048 × 2048, 4 × 4 células de 512. Mesmos sinos de bronze, punhos maciços e tecido vermelho do atlas anterior; vista para a direita em três quartos. Pivô nominal (256,500). Registro técnico coloca a base visível alpha>40 em y500 nos quadros apoiados; 5 e 6 preservam a elevação do salto. Dados em `v22-exportacao.json`.

| Quadros | Leitura | Proposta de integração |
|---|---|---|
| 0–3 | Braço recua, corpo arma e varre embaixo | 0/1: aviso 200/300 ms; 2: golpe 100 ms; 3: recuperação 250 ms. Parável se o código permitir. |
| 4–7 | Crouch, dois quadros no ar, pancada no chão | 4: 300 ms de aviso; 5/6: subida e descida; 7: impacto. Trajetória e área de dano precisam ser implementadas. |
| 8–11 | Cabeça-sino se ergue, abertura escura se revela, braços se abrem | 8/9: 200/300 ms; 10: emissão proposta; 11: cauda. Onda não está pintada no atlas. |
| 12–15 | Ajoelha, baixa o corpo e começa a recuperar o fôlego | Janela sem ataque; começar com 1,2 s total e medir em luta. |

Distinguir avisos por pose e som: varredura pelo braço recuado, salto pelo agachamento, grito pelo sino voltado para cima. Não usar apenas cor para comunicar perigo. A exaustão deve interromper a pressão para que o jogador reconheça a oportunidade. Não há projeto de nova dificuldade ou duração de chefe aprovado por estes tempos.

Usar quatro colunas, não o leitor de seis sem adaptação. Não ligar automaticamente a janela de dano ao primeiro quadro. As imagens não alteram colisões, trajetória, aparo, onda, câmera ou IA.

Folha `imagens/v22-guardiao_colosso_ataques-contato.png`; `tests/art_v22_check.py`; vídeo isolado `videos/v22-atlas.mp4`. Conferidos dimensões, RGBA, transparência dos cantos, poses na folha e 16 quadros distintos. Não houve validação jogável dos novos ataques, acessibilidade, resposta ao controle ou transições entre atlas.
