# Sons do Lacrimae — prompts para o Argon

## Estilo (cole no início de cada pedido)
*"Original sound design for a dark gothic 2D action game about guilt, penance and a decayed Catholic city. Organic and physical, never electronic or synthetic: iron, leather, bone, stone, wax, blood, bronze bells. Recorded in a vast stone cathedral, with a natural cold reverberation. Heavy, sombre and solemn. Spanish Holy Week processions as the cultural world: muffled drums, brass, chains, a wordless lament. No modern instruments, no synthesizer tones, no melody unless asked, no voices with words."*

## Formato obrigatório (para entrar no jogo sem mudar código)
- **WAV PCM 16 bits, 44,1 kHz.** Efeitos em **mono**; ambiências e músicas em **estéreo**.
- **Pico abaixo de −1 dBFS.** O som começa em **menos de 50 ms** (corte o silêncio do início). Sem clique no fim.
- Ambiências e músicas em **laço perfeito** (o fim emenda no começo sem clique).
- **Nomes exatos** abaixo, em `assets/audio/`. Cada nome substitui o arquivo atual.
- Evite um **tom contínuo** por baixo do som (um "zumbido" fixo): é o que faz um efeito soar sintético.

## Prioridade 1 — o combate, que se ouve o tempo todo
| Arquivo | Duração | Pedido |
| --- | --- | --- |
| `swing_01` a `swing_03` | 0,25 s | A long sword cutting the air hard, a dark whoosh with weight; three variations. |
| `hit_carne_01` a `_03` | 0,2 s | A sword biting into flesh and cloth, wet and blunt; three variations. |
| `hit_metal_01` a `_03` | 0,2 s | A sword striking old bronze armour, a dull heavy clang with a short ring. |
| `aparo` | 0,45 s | Two blades meeting in a parry: a sharp metallic clang with a bright ring that fades into the stone hall. |
| `execucao` | 0,7 s | An execution: a blade driven deep into a body, a crunch of bone, a wet release. Visceral, not comic. |
| `morte` | 0,6 s | A body in rags falling to stone, a last breath. |
| `morte_grande` | 1,1 s | A large armoured creature collapsing, metal and weight hitting the floor. |
| `dor_01` a `_03` | 0,3 s | A short pained grunt, muffled, inhuman but not monstrous, no words. |
| `lanca_estocada_01` a `_03` | 0,3 s | A heavy iron spear thrust: air split by a long shaft, a creak of iron and leather. |
| `empalar` | 0,5 s | A spear point piercing a body and pinning it, then a dull thud. |
| `golpe_carregado_carga` | 0,9 s | A warrior gathering strength for a crushing blow: straining leather and iron, breath held, tension growing. |
| `golpe_carregado_solta` | 0,4 s | The release of that blow: a violent rush of air and a heavy swing. |
| `arremate` | 0,45 s | A finishing blow that throws the enemy back, a deep impact with stone echo. |
| `mergulho_impacto` | 0,7 s | An armoured knight plunging from a height onto a stone floor: a deep boom, cracking stone, scattering gravel. |
| `jump_01` a `_03` | 0,25 s | A knight in plate armour jumping: boots pushing off stone, cloth and cape, plates rattling. No rising pitch. |
| `aterrissagem` | 0,25 s | The same knight landing: boots on stone, armour settling. |
| `roll` | 0,35 s | A heavy roll across a stone floor, cloth and armour scraping. |
| `step_pedra_01` a `_04` | 0,15 s | A heavy armoured footstep on stone. |
| `step_madeira_01` a `_03` | 0,15 s | The same footstep on old wooden planks. |
| `step_agua_01` a `_03` | 0,15 s | The same footstep in shallow water. |
| `step_osso_01` a `_03` | 0,15 s | The same footstep on a floor of bones. |
| `heal` | 0,6 s | Drinking from a small glass vial of holy liquid, a soft glow of relief, no music. |
| `hurt` | 0,35 s | The armoured penitent hit hard, a grunt behind a metal mask. |
| `death` | 1,2 s | The penitent falling dead in armour, a long exhale. |

## Prioridade 2 — o chefe e as criaturas
| Arquivo | Duração | Pedido |
| --- | --- | --- |
| `chefe_pancada` | 0,9 s | A giant fused with a bronze bell smashing the floor: a huge low boom with a bell's dark resonance. |
| `chefe_morte` | 3,0 s | That giant dying: bronze cracking, a bell sinking and fading into silence. |
| `devorador_rugido` / `devorador_bote` | 1,2 s / 0,5 s | A starving brute: a hoarse breath turning into a low roar; then the snap of its lunge. |
| `flagelante_chicote` / `flagelante_investida` | 0,4 s / 0,6 s | A rope scourge cracking; heavy running steps of a penitent flagellant. |
| `bruxa_sussurro` / `bruxa_leque` | 1,5 s / 0,5 s | Dry wordless whispers of old women; three short hisses of thrown tears. |
| `asmodeia_aviso` / `asmodeia_estilhaco` | 0,9 s / 0,4 s | A high ethereal warning that swells; falling shards of glass. |
| `duelista_cacete` | 0,35 s | Two wooden cudgels clashing. |
| `projetil` / `projetil_impacto` | 0,5 s / 0,3 s | A crystal tear flying with a thin whistle; its shattering. |
| `espinho` | 0,35 s | Iron spikes bursting from the stone floor. |

## Prioridade 3 — o mundo, as cenas e a interface
| Arquivo | Duração | Pedido |
| --- | --- | --- |
| `porta` | 0,8 s | A heavy stone door grinding open. |
| `portao_fecha` / `portao_abre` | 1,2 s / 1,4 s | An iron portcullis with chains slamming shut; rising. |
| `coleta` | 0,5 s | Small glass tears clinking into a reliquary. |
| `altar` | 1,5 s | Kneeling at a candlelit altar: wax, cloth, a quiet breath. |
| `bell` / `sino_surdo` | 2,5 s | One deep cathedral bell; the same bell muffled, as if heard through a wall. |
| `knock` | 0,5 s | One knock of a fist on a thick wooden gate. |
| `corrente_cede` | 1,0 s | A great iron chain giving way and falling. |
| `murmurio_01` a `_03` | 2,5 s | Muffled voices behind a door, wordless, pleading. |
| `sangue_compartilhado` | 1,0 s | One slow, deep heartbeat and a soft exhale. |
| `caido` / `levanta` | 0,8 s | An armoured body falling to the ground with a muffled groan; breath returning and armour creaking as it rises. |
| `ui_mover` / `ui_confirmar` | 0,08 s / 0,25 s | A soft tick of a rosary bead; a low muted bell tap. |

## Ambiências (laços de 30 s, estéreo)
`amb_city` wind over a ruined city at dusk, distant bells, crows · `amb_ossuary` bones settling, dripping, deep echo · `amb_cistern` running water and slow drips in a vast cistern · `amb_cloister` distant prayers without words, candles, cold air · `amb_belfry` wind through wooden beams, hanging bells softly brushing · `amb_archive` old paper and creaking shelves · `amb_refuge` embers and a low fire · `amb_nave` near silence in a huge nave, stone breathing · `amb_terrace` high wind and far bells · `amb_court` chains and metal shifting in the wind.

## Músicas (laços de 60 a 90 s, estéreo)
- `ost_exploration`: *"Slow, sparse and melancholic. A distant Holy Week procession: muffled snare and brass far away, a low cathedral organ drone, a wordless female lament. Never loud."*
- `ost_combat`: *"Heavy processional war drums, low brass stabs, tense strings, a solemn male choir humming without words. Driving, never heroic."*
- `ost_boss`: *"Huge tolling bronze bells as percussion, organ and wordless choir, rising dread, for a giant bell-ringer fused with his bell."*
- `ost_temple`: *"Calm and sacred: soft organ, distant candles, a single sustained choir chord."*
- `ost_story`: *"Very quiet and sad: a low cello and a wordless voice, for memories of guilt."*
- `ost_menu`: *"A single slow theme on organ and voice, mournful and solemn."*
- `ost_ending`: *"A slow procession that fades into silence, bells far away."*
