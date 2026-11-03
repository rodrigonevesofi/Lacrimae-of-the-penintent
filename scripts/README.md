> Notas do protótipo de origem. Para o fluxo e o estado atuais, consulte [README do projeto](../README.md). A nova partida agora começa desarmada e exige recolher a espada com E.

# Lacrimae of the Penitent — Protótipo (Godot 4.2+)

Protótipo jogável do escopo: **Metroidvania / Soulslike 2D, dark fantasy gótica**.
Todos os visuais são *placeholders* desenhados por código (nenhum arquivo de arte),
para que a equipe possa trocar por sprites e áudio reais depois.

## Como abrir
1. Instale o **Godot 4.2 ou superior** (versão "Standard", não precisa do .NET).
2. Abra o Godot → **Importar** → selecione `project.godot` desta pasta.
3. Pressione **F5** para jogar.

## Controles
| Ação | Teclas |
|---|---|
| Mover | A / D ou ← → |
| Pular (2x após a Relíquia) | ESPAÇO / W / ↑ |
| Atacar (combo de 2 golpes) | J ou X |
| Rolar (invulnerável) | K ou SHIFT |
| Lágrima Curativa (3 por descanso) | F |
| Penitência (gasta Culpa ≥ 50%) | Q |
| Interagir / orar / continuar texto | E |
| Oferecer lágrimas no altar (+15 de vida máxima) | R |

## O que o protótipo demonstra
- **Conceitos do jogo**: culpa, pecado, penitência e perdão viram mecânica.
  - *Culpa* sobe ao sofrer dano, ao ferir inimigos e ao morrer.
  - *Penitência* (Q) converte a culpa acumulada em uma explosão de fogo sagrado.
  - Ao morrer, as **lágrimas** (moeda) ficam numa **mancha de culpa**; recupere-a ou perca tudo.
  - *Altares* salvam o jogo, curam, reiniciam os inimigos e permitem ofertar lágrimas.
- **Metroidvania**: o abismo no meio da fase só é atravessado após pegar a
  **Relíquia: Espinho da Contrição** (salto duplo), escondida em plataformas altas.
- **Combate soulslike**: ataques com telegrafia, rolamento com invulnerabilidade,
  cura limitada (3 lágrimas curativas por descanso), checkpoints.
- **Inimigos**: Devoto Corrompido (corpo a corpo), Chorão (voador, atira lágrimas).
- **Chefe**: *A Mãe das Lágrimas* — 3 ataques (pancada com onda de choque, chuva de
  lágrimas, espinhos) e fase 2 ao chegar a 50% da vida.
- **Narrativa**: lápides e gravuras revelam aos poucos que o Penitente
  **não é só vítima, mas um dos responsáveis** pela tragédia (final após o chefe).

## Mapa do código → frentes da equipe
| Frente | Onde mexer |
|---|---|
| 01 Direção, Game Design e Narrativa | `main.gd`: array `lore` (textos), `show_message` (intro), `HUD._draw_ending` (final); constantes de dano/vida em `player.gd` e `enemy.gd` |
| 02 Programação — Jogador e Combate | `player.gd`, `enemy.gd`, `tear.gd`, `spike.gd` |
| 03 Programação — Sistemas e Integração | `hud.gd`, save/load em `main.gd` (`_save`, `_load`), mapa de teclas em `main.gd` (`_setup_input`) |
| 04 Character Design e Animação | `_draw()` de `player.gd` e `enemy.gd` — substituir por `AnimatedSprite2D` |
| 05 Cenários, Level Design e Áudio | `main.gd`: `platforms`, `enemy_defs`, `candle_xs`, `_draw()` (cenário), luzes (`_build_lights`); **áudio ainda não existe** (adicionar `AudioStreamPlayer`) |

## Dicas para evoluir
- Trocar o cenário por `TileMap` e a arte por sprites mantendo as mesmas colisões.
- O save fica em `user://lacrimae_save.json` (ENTER = novo jogo apaga; C = continua).
- Se algo não rodar, abra o painel **Saída/Depurador** do Godot e envie a mensagem de erro.
