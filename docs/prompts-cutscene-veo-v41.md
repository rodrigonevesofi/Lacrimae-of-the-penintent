# Cutscene da revelação — prompts para vídeo (Flow / Gemini)

A revelação vira um filme de seis clipes de 8 segundos. O jogo já está pronto para isso: com os clipes na pasta, a cena passa a ser o filme (52 s, com as falas como legenda, a música da revelação e os sons do jogo); sem eles, continua como está.

## Precisa enviar imagem? Sim
Use **imagem para vídeo** ("Frames to Video", só o primeiro quadro). Cada clipe parte de um quadro inicial que eu preparei a partir dos closes do jogo, já em 16:9. É isso que garante que **o rosto do filme seja o mesmo rosto do jogo** e que os seis clipes pareçam a mesma obra. Só com texto, cada clipe sairia com um homem diferente.

Os quadros estão em `cutscene-quadros-iniciais.zip`:

| Clipe | Quadro inicial | Cena | Entra aos |
| --- | --- | --- | --- |
| `revelacao_01` | `quadro_01_elmo.png` | O elmo-gaiola do Flagelado | 3 s |
| `revelacao_02` | `quadro_02_maos.png` | As mãos de Beatriz erguem o capirote | 11 s |
| `revelacao_03` | `quadro_03_rosto.png` | O rosto, pela primeira vez | 19 s |
| `revelacao_04` | `quadro_04_dois_rostos.png` | Os dois rostos | 27 s |
| `revelacao_05` | `quadro_03_rosto.png` (o mesmo) | Ele olha para quem joga | 35 s |
| `revelacao_06` | `quadro_06_beatriz.png` | Beatriz | 43 s |

## Como fazer
1. No Flow, escolha **Frames to Video**, proporção **16:9 (paisagem)**, duração **8 segundos**.
2. Anexe o quadro inicial do clipe como **primeiro quadro** e cole o prompt (em inglês).
3. Gere duas ou três vezes e escolha. Descarte o que **mudar o rosto**, tiver **texto na tela** ou **cortar para outra cena**.
4. Baixe o MP4 e renomeie: `revelacao_01.mp4` ... `revelacao_06.mp4`.
5. Me envie os MP4 num zip. Eu converto para o formato do Godot e testo. Para fazer sozinho: `python3 tools/preparar_cutscene.py <pasta com os MP4>`.

O som que o gerador criar é descartado: na cena tocam a música da revelação, a corrente, o capacete e o sino do jogo. Não precisa fazer os seis: **cada clipe que faltar aparece como o close parado**. Se o tempo for curto, a ordem de importância é **3, 5, 2, 4, 1, 6**.

## Os prompts

### Clipe 1 — `revelacao_01` (quadro `quadro_01_elmo.png`)
```
Dark gothic painting come to life, same style and colours as the image. Extremely slow camera push-in toward the iron cage helmet. The candle flames on the shoulder flicker and drip wax. Thin dark red tears seep slowly down through the grille. The padlock under the chin sways very slightly; the chains and parchment strips stir in a faint draft. Fine ash drifts through the air. The figure breathes slowly, shoulders rising and falling, head bowed and still.
Single continuous shot, no cuts. No text, no captions, no logos. The figure does not speak. The helmet stays closed. Sombre, silent, oppressive mood.
```

### Clipe 2 — `revelacao_02` (quadro `quadro_02_maos.png`)
```
Dark gothic painting come to life, same style and colours as the image. Two bandaged hands slowly and carefully lift the pointed iron helmet with the crown of thorns straight upward, as if it were very heavy. As it rises, matted sweat-soaked hair and a forehead marked by a deep red groove are revealed underneath. The camera stays still and close. The candle flame trembles. The hands shake slightly with effort. The shot ends before the eyes and the rest of the face are visible.
Single continuous shot, no cuts. No text, no captions. Nobody speaks. Slow, reverent, tense.
```

### Clipe 3 — `revelacao_03` (quadro `quadro_03_rosto.png`)
```
Dark gothic painting come to life, same style and colours as the image. Keep this exact face: same man, same beard, same marks. Very slow camera push-in on his face. His eyes are lowered; he breathes unevenly, as if air were new to him. One dark red tear rolls slowly down from his eye into his beard. His raised hand trembles slightly, the burn mark visible on the palm. The candle behind him flickers and the light moves across his skin. He does not look at the camera yet.
Single continuous shot, no cuts. No text, no captions. He does not speak; his mouth stays closed. Mood: shame, exhaustion, relief.
```

### Clipe 4 — `revelacao_04` (quadro `quadro_04_dois_rostos.png`)
```
Dark gothic painting come to life, same style and colours as the image. Two identical men face each other in profile, very close. Keep both faces exactly as in the image: the same man twice. The camera drifts very slowly sideways around them. The man on the right, in armour, stares without blinking. The man on the left slowly raises his eyes until their gazes meet. Both breathe slowly; dark red tears glisten on their cheeks. Candlelight flickers between them; ash floats down.
Single continuous shot, no cuts. No text, no captions. Neither man speaks; they never touch. Mood: recognition, dread, stillness.
```

### Clipe 5 — `revelacao_05` (quadro `quadro_03_rosto.png`)
```
Dark gothic painting come to life, same style and colours as the image. Keep this exact face: same man, same beard, same marks. The camera is still, close on his face. He slowly lowers his raised hand out of frame. Then he lifts his eyes and looks straight into the camera, and holds the gaze without blinking for the rest of the shot. A dark red tear runs down his cheek. His expression is shame and relief together, with no anger. The candle flickers softly.
Single continuous shot, no cuts. No text, no captions. He does not speak; his mouth stays closed. Quiet, human, devastating.
```

### Clipe 6 — `revelacao_06` (quadro `quadro_06_beatriz.png`)
```
Dark gothic painting come to life, same style and colours as the image. Keep the figure exactly as in the image, including the closed mask. She stays almost still, then slowly bows her head and lowers her shoulders, like someone accepting a weight. Her lance rests against her. The camera pulls back very slowly. Ash drifts down; the light dims gradually toward the end of the shot until the image is almost black.
Single continuous shot, no cuts. No text, no captions. She does not speak and does not remove the mask. Mood: grief, resolve, companionship.
```

## Se der problema
- **O gerador recusa por causa de sangue:** troque `dark red tears` por `dark tears` e tire `seep`/`rolls`. O quadro inicial já mostra o que precisa.
- **O rosto muda no meio do clipe:** gere de novo; se insistir, acrescente no começo `Minimal movement. The face must not change at all.`
- **A câmera se mexe demais:** acrescente `Locked-off camera, no camera movement.`
- **Ele abre a boca ou fala:** acrescente `Lips sealed for the entire shot.`
- **As laterais escuras do quadro ganham objetos estranhos:** acrescente `The dark empty areas at the left and right stay dark and empty.`
