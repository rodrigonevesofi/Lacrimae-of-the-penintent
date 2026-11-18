# Prompts de efeitos sonoros — v43

## Qual ferramenta usar

O Flow Music (Lyria) faz **música**: ele não gera bem sons curtos de 0,2 a 1 segundo. Para efeitos, use um destes:

- **ElevenLabs Sound Effects** (elevenlabs.io → Sound Effects). Tem plano gratuito. Escreva o prompt em inglês, ajuste a duração e gere de 2 a 4 variações.
- **Argon**, no Gemini, que você já usou.

Gere em inglês: as duas ferramentas entendem melhor. Baixe em WAV, se der, ou em MP3. Mantenha os nomes da tabela, porque cada nome já está ligado a um momento do jogo. Mande tudo num zip: eu converto, corto o silêncio do começo e ajusto o volume de cada um ao da mixagem nova.

Se um som novo ainda não existir, o jogo toca o mais parecido que já tem. Nada fica mudo.

## Estilo comum (cole antes de cada prompt)

> Dark gothic action game sound effect, medieval, heavy and physical, close-miked, no music, no voice, no reverb tail longer than half a second, dry start with an instant attack.

## Prioridade 1 — combate (o que mais aparece)

| Arquivo | Duração | Prompt |
|---|---|---|
| `swing_01` … `swing_03` | 0,3 s | Fast heavy longsword swing whooshing through air, sharp and metallic, slight cloth rustle |
| `hit_carne_01` … `hit_carne_03` | 0,3 s | Sword blade slicing into flesh and bone, wet meaty impact, short and brutal |
| `hit_metal_01` … `hit_metal_03` | 0,3 s | Sword striking iron armor, bright clang with a dull thud underneath, short ring |
| `aparo` | 0,5 s | Perfect sword parry, two blades colliding with a bright high ring and sparks, heroic and sharp |
| `bloqueio` | 0,35 s | Blade blocked by a sword guard, heavy dull clang, the arm pushed back, no ring |
| `investida` | 0,45 s | Fast forward lunge with a sword thrust, cloth and armor rushing, air ripping past |
| `corte_ascendente` | 0,4 s | Rising upward sword slash, heavy whoosh going up in pitch |
| `lamina_sangue` | 0,8 s | A crescent of blood magic thrown forward, wet liquid whoosh with a deep cursed hum |
| `esquiva_perfeita` | 0,5 s | Time slows down, deep reversed whoosh, heartbeat thump |
| `aviso_aparavel` | 0,4 s | Short golden metallic glint, a bell-like ping that warns of an incoming strike |
| `aviso_perigo` | 0,5 s | Short dark warning sting, low brass hit with distortion, danger |

## Prioridade 2 — gore e execuções

| Arquivo | Duração | Prompt |
|---|---|---|
| `carne_rasga_01` … `carne_rasga_03` | 0,4 s | Flesh tearing apart, wet ripping, sinew snapping |
| `osso_quebra_01` … `osso_quebra_03` | 0,3 s | Bones cracking and breaking, dry snap with a wet crunch |
| `sangue_jato_01` … `sangue_jato_03` | 0,5 s | Arterial blood spray bursting out under pressure, wet hiss and splatter |
| `respingo_chao_01` … `respingo_chao_04` | 0,25 s | Blood splattering on a stone floor, small wet slap |
| `decapitacao` | 1,0 s | Executioner beheading, heavy blade through the neck, crunch of vertebrae, then a gushing blood fountain |
| `corpo_partido` | 1,0 s | A body cleaved in half by a sword, long wet tearing, two heavy halves dropping |
| `coracao_arrancado` | 1,2 s | A hand ripping a beating heart out of a chest, wet squelch, two slow heartbeats, then a drop |
| `cranio_esmagado` | 0,8 s | Skull crushed by a heavy blow, bone shattering, wet splatter |
| `execucao` | 0,7 s | Brutal finishing strike, sword plunged deep into a body, wet and heavy |
| `execucao_impacto` | 0,9 s | Final death impact of an execution, deep boom with flesh and bone crunch, slight slow-motion feel |
| `lamina_sai` | 0,5 s | Sword pulled out of a body, wet sliding scrape |
| `corpo_cai_carne` | 0,6 s | Lifeless body collapsing on stone, heavy thud with a wet slap |
| `corpo_cai_armadura` | 0,6 s | Armored body falling on stone, heavy metal clatter |

## Prioridade 3 — mundo e recompensa

| Arquivo | Duração | Prompt |
|---|---|---|
| `lagrima_coleta` | 0,3 s | A small blood tear absorbed, soft crystalline chime with a faint wet drop, pleasant but dark |
| `oferenda` | 1,2 s | Offering at a candlelit altar, low choir breath and a deep bell, a sense of sacrifice |
| `step_pedra_01` … `step_pedra_04` | 0,15 s | Armored boot step on stone, soft metal clink |
| `aterrissagem` | 0,4 s | Armored knight landing from a jump on stone, heavy thud and armor rattle |
| `dor_01` … `dor_03` | 0,4 s | Muffled male grunt of pain behind a metal helmet, short |
| `morte_01` … `morte_03` | 0,8 s | Grotesque creature death cry, gurgling and fading, no words |

## Depois de gerar

Coloque os arquivos numa pasta, com os nomes da tabela, e mande o zip. Eu integro, meço o volume na mesma luta de teste usada na v43 e devolvo o pacote. Se algum som ficar ruim no jogo, basta apagar o arquivo: o jogo volta a usar o anterior.
