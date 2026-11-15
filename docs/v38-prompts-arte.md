# Arte v38 — prompts e preparação técnica

Ferramenta: gerador de imagens integrado nesta conversa (`image_gen`). As pinturas são originais. O Argon forneceu referências no projeto recebido; os novos desenhos não copiam sprites nem cenários de jogos.

42 PNGs finais em `v38-assets.json`, com tamanho, transparência e SHA-256. O processamento com Pillow apenas redimensionou, recortou células e remontou faixas; não desenhou personagens ou efeitos. O tamanho solicitado no prompt nem sempre foi retornado pelo gerador, por isso o tamanho final foi ajustado tecnicamente.

As faixas de seis quadros vieram em 3 × 2 e foram reorganizadas em 6 × 1; os pendurados e pendentes vieram em 4 × 2 e viraram 8 × 1; as placas vieram em 2 × 2 e viraram 4 × 1. Cada célula conserva seus próprios pixels redimensionados. As folhas principais e os estados mantêm a grade 6 × 4, sem cortar personagens individualmente.

`flagelado_estados.png` é derivado: as primeiras seis células de `flagelado_estado1.png` a `flagelado_estado4.png` foram empilhadas em quatro fileiras. O primeiro resultado para estados não organizou os estados por fileira e foi substituído por essa montagem. Seu prompt inicial continua registrado abaixo. O piso recebeu recorte vertical de 22% a 78% da fonte antes de ser redimensionado; as repetições horizontais de piso e rochas são espelhadas pelo código para casar bordas.

Um pedido inicial de efeito foi bloqueado pelo gerador. O resultado entregue usa armadura vazia, ferro e cera se desfazendo, sem anatomia explícita. As adaptações das criaturas são detalhadas em `fichas/fichas-goya.md`.

Os caminhos abaixo são relativos à raiz do repositório. Os prompts são o registro dos pedidos, não uma afirmação de que cada detalhe ficou perfeito. Os contatos e as capturas mostram o resultado real; animações novas de criaturas aguardam aprovação.

## 1. flagelado_movimento

Arquivo final: `assets/animation/flagelado_movimento.png`.

```text
Original gothic painted pixel-art GAME SPRITE ATLAS. EXACT six columns four rows, 24 separate 256x256 cells in 1536x1024. Every sprite full body side view facing RIGHT, feet centered at cell x128,y250; consistent scale occupying 220 pixels height. SAME adult hunched boss in every cell: round closed BELL CAGE iron helmet, confessional lattice grille, tiny padlock at chin, no pointed cone, no visible face. Black iron bulky mismatched armor, tarnished bronze, parchment strips nailed to plates, melted yellow candle wax, crossed chains and unreachable keys. Both hands hold long thick iron GATE LOCK BAR, a rectangular heavy crossbar, NOT sword. Red cloth entirely hidden under initial armor. ROW1 six breathing idle poses, ROW2 six slow heavy walking steps, ROW3 six stages kneeling until knees on ground hands resting on crossbar, ROW4 six subtle praying poses kneeling, hands on bar. Genuine transparent alpha, no backdrop or haze, no shadows behind cells, no text, no grid lines, no empty cells, no cropped feet. Strong distinct readable silhouettes, coherent anatomy, original character. Deep dark red tear stains on grille only, no explicit injuries.
```

## 2. close_01

Arquivo final: `assets/close/close_01.png`.

```text
Original square 512x512 gothic stippled pixel-art closeup portrait for a game's final revelation. Ordinary gaunt man about 45, shaved head with uneven tiny grey stubble, patchy short beard of a few days, tired brown eyes looking directly toward viewer, hollow cheekbones, pale skin, a red pressed groove across forehead and temples from iron helmet. Two narrow dried dark red tear tracks from eyes to chin with a fresh red tear. Raised right palm beside cheek has a small old dark burn shaped like a gate latch bar. Expression relief mixed with shame, understated. NO long hair, NO full beard, NO crown, NO thorns, NO helmet. Black warm-grey background, side candlelight. Dense precise stippled pixel texture, limited bronze/ivory/black/crimson palette, close framing head and right hand, subdued, human, never heroic. No explicit wounds, no text.
```

## 3. ceu

Arquivo final: `assets/vale/ceu.png`.

```text
Original painted pixel-art side-scrolling gothic game SKY layer only. Very wide panoramic 2048x720 dusk sky, dark crimson horizon, pallid low ivory sun off-center, long torn grey purple clouds, darkening upward. Quiet mournful valley atmosphere, subdued dark colors with readable sky. NO terrain, NO buildings, NO characters, NO trees, NO text, no photographic gradients. Opaque background, detailed stippled painterly pixels. Sky must fill all canvas.
```

## 4. flagelado_combate

Arquivo final: `assets/animation/flagelado_combate.png`.

```text
Original gothic painted pixel-art sprite atlas, EXACT 6 columns x4 rows, 1536x1024, 256x256 cells, full body side view facing RIGHT, feet registration128250, character scale220px tall. Reference image supplies boss identity ONLY: same hunched heavy iron figure, rounded closed bell-cage confessional grille helmet and chin padlock, candlewax/parchment/keys, heavy rectangular iron gatebar with both hands. NO capirote, NO face, no text or grid. Genuine fully transparent RGBA between sprites, no cloudy colored background. 24 DISTINCT poses smoothly sequenced per row: row1 six horizontal two-handed gatebar swings (windup, anticipation, sweep, impact, followthrough, recovery); row2 six overhead gatebar smash poses; row3 six long forward thrusts using end of gatebar; row4 six doublehand ground slam poses. Each row includes strong anticipation, active contact, settling recovery. Gatebar fits fully inside each cell. Keep exact same boss armor and rounded helmet in all frames.
```

## 5. flagelado_reacoes

Arquivo final: `assets/animation/flagelado_reacoes.png`.

```text
Original gothic painted pixel-art sprite atlas, EXACT 6 columns x4 rows, 1536x1024, 256x256 cells, full body side view facing RIGHT, feet registration128250, character scale220px tall. Reference image supplies boss identity ONLY: same hunched heavy iron figure, rounded closed bell-cage confessional grille helmet and chin padlock, candlewax/parchment/keys, heavy rectangular iron gatebar with both hands. NO capirote, NO face, no text or grid. Genuine fully transparent RGBA between sprites, no cloudy colored background. 24 poses, read left to right top to bottom: frames0-2 light hurt with loose parchment; frames3-8 shoulder plate detaching and dropping to floor in a clear arc, intact person underneath; frames9-14 slowly collapsing onto knees; frames15-17 head bowed kneeling subtle loop; frames18-23 heavy charged gatebar attack from windup to release. Dark red stylized blood flecks and wax only, no anatomical wounds. All hands hold or rest on gatebar.
```

## 6. flagelado_estados

Arquivo final: `assets/animation/flagelado_estados.png`.

```text
Original gothic painted pixel-art sprite atlas, EXACT 6 columns x4 rows, 1536x1024, 256x256 cells, full body side view facing RIGHT, feet registration128250, character scale220px tall. Reference image supplies boss identity ONLY: same hunched heavy iron figure, rounded closed bell-cage confessional grille helmet and chin padlock, candlewax/parchment/keys, heavy rectangular iron gatebar with both hands. NO capirote, NO face, no text or grid. Genuine fully transparent RGBA between sprites, no cloudy colored background. FOUR progressive ARMOR LOSS STATES, each row six idle breathing frames of SAME individual with same rounded CLOSED bell cage helmet. ROW1 state1 shoulderplates and parchment cloak removed, revealing protagonist's torn dark-red cape over heavy black torso armor. ROW2 state2 outer breastplate and chains removed, showing protagonist's tarnished bronze cuirass and torn red cape. ROW3 state3 black bracers and greaves removed, revealing protagonist bronze gloves and boots, lean clothed figure, red cape. ROW4 state4 ALL body armor removed, thin adult in ragged pale tunic and red cape KNEELING, ONLY bell cage helmet remains. No visible face in any state. Entirebody intact, no open wounds. Hold gatebar on knees in row4, upright at waist otherwise.
```

## 7. close_flagelado_elmo

Arquivo final: `assets/close/close_flagelado_elmo.png`.

Pedido usou a referência visual do personagem ou peça já produzida nesta rodada.

```text
Original square 512x512 closeup, dense gothic stippled pixel art, same boss helmet as reference: rounded closed iron bell-cage with confessional lattice visor and padlock on chin, wax and parchment at shoulders, dark red narrow tears slipping through grille. Fill frame with helmet and dark upper shoulders. No visible face, no pointed capirote. Subdued candlelight on black iron and tarnished bronze, dark empty background, solemn. No text.
```

## 8. close_revelacao_maos

Arquivo final: `assets/close/close_revelacao_maos.png`.

Pedido usou a referência visual do personagem ou peça já produzida nesta rodada.

```text
Original square 512x512 final reveal closeup in dense gothic stippled pixel art. Two adult woman's bandaged hands enter from sides and gently LIFT a tall pointed iron conical capirote with thorn ring, identical to hero reference. Beneath its bottom rim, ONLY the shaved pale forehead and red helmet pressure groove of the ordinary middle-aged man reference are visible; eyebrows, eyes, nose, mouth remain hidden in deep shadow below framing. The lifted iron helmet fills upper half, bandaged fingers grip its rim naturally. No face visible in this transitional image. Dark background, candlelit iron, weathered linen, restrained crimson marks. No text, no exposed injuries.
```

## 9. close_dois_rostos

Arquivo final: `assets/close/close_dois_rostos.png`.

Pedido usou a referência visual do personagem ou peça já produzida nesta rodada.

```text
Original square 512x512 cinematic final revelation, dense gothic stippled pixel art matching reference. TWO profiles of EXACTLY THE SAME ordinary gaunt 45-year-old man facing each other across a narrow dark gap, left facing right and right facing left. Identical shaved grey-stubble head, patchy days-old short beard, cheekbones, nose, red groove on forehead and temples, tired brown eyes. Left has eyes already open and fresh narrow crimson tear tracks; right is just opening eyelids, dried dark red tear tracks with one fresh tear. Same anatomy and facial identity, both adult, no helmets or crowns or long hair. Left shoulder a scrap of dark cloth, right shoulder tarnished bronze and torn red cloth. Expressions shame and quiet relief. Dark background and warm side candlelight. No text, no anatomical injury.
```

## 10. flagelado_estado1

Arquivo final: `assets/animation/flagelado_estado1.png`.

```text
Original gothic painted pixel-art animation sheet, SAME boss face-covering rounded bell-cage helmet and rectangular iron gatebar identity as image1, hero clothing motifs from image2. State1: shoulderplates and parchment mantle REMOVED, red torn cape now revealed; black chest plate and leg armor remain, closed bell helmet. EXACT six columns FOUR rows=24 fullbody sprites, 1536x1024, feet x128 y250 per256cell, side facing RIGHT, consistent height220px, no text, no grid, no background haze, TRUE transparent alpha. Row1 six standing idle breathing frames. Row2 six slow walking frames. Row3 first THREE frames lateral gatebar swing (windup contact recovery), last THREE overhead smash (windup contact recovery). Row4 six stages kneel to pray, last frame kneeling head bowed hands resting on gatebar. Clearly preserve the specified stripped armor state in EVERY frame. No pointed capirote or face.
```

## 11. flagelado_estado2

Arquivo final: `assets/animation/flagelado_estado2.png`.

```text
Original gothic painted pixel-art animation sheet, SAME boss face-covering rounded bell-cage helmet and rectangular iron gatebar identity as image1, hero clothing motifs from image2. State2: shoulderplates AND black chestplate and chestchains REMOVED, tarnished BRONZE HERO CUIRASS visible, red cape, original hero bronze gauntlets and boots under remaining black bracers/greaves, closed bell helmet. No wax shoulder candles. EXACT six columns FOUR rows=24 fullbody sprites, 1536x1024, feet x128 y250 per256cell, side facing RIGHT, consistent height220px, no text, no grid, no background haze, TRUE transparent alpha. Row1 six standing idle breathing frames. Row2 six slow walking frames. Row3 first THREE frames lateral gatebar swing (windup contact recovery), last THREE overhead smash (windup contact recovery). Row4 six stages kneel to pray, last frame kneeling head bowed hands resting on gatebar. Clearly preserve the specified stripped armor state in EVERY frame. No pointed capirote or face.
```

## 12. flagelado_estado3

Arquivo final: `assets/animation/flagelado_estado3.png`.

```text
Original gothic painted pixel-art animation sheet, SAME boss face-covering rounded bell-cage helmet and rectangular iron gatebar identity as image1, hero clothing motifs from image2. State3: all outer black armor, bracers, greaves, shoulder waxcandles REMOVED. Lean clothed adult wearing the HERO bronze gauntlets and bronze boots, ragged pale tunic and red torn cape, closed bell cage helmet. No chestplate, no black armor. EXACT six columns FOUR rows=24 fullbody sprites, 1536x1024, feet x128 y250 per256cell, side facing RIGHT, consistent height220px, no text, no grid, no background haze, TRUE transparent alpha. Row1 six standing idle breathing frames. Row2 six slow walking frames. Row3 first THREE frames lateral gatebar swing (windup contact recovery), last THREE overhead smash (windup contact recovery). Row4 six stages kneel to pray, last frame kneeling head bowed hands resting on gatebar. Clearly preserve the specified stripped armor state in EVERY frame. No pointed capirote or face.
```

## 13. flagelado_estado4

Arquivo final: `assets/animation/flagelado_estado4.png`.

```text
Original gothic painted pixel-art animation sheet, SAME boss face-covering rounded bell-cage helmet and rectangular iron gatebar identity as image1, hero clothing motifs from image2. State4: NO armor anywhere on body, NO candles, NO chains, NO wax, NO bronze gauntlets or boots. Thin adult in ragged beige tunic and torn red cloth, barefoot bandaged hands. ONLY closed bell cage helmet remains. Body intact, no open wounds. EXACT six columns FOUR rows=24 fullbody sprites, 1536x1024, feet x128 y250 per256cell, side facing RIGHT, consistent height220px, no text, no grid, no background haze, TRUE transparent alpha. Row1 six standing idle breathing frames. Row2 six slow walking frames. Row3 first THREE frames lateral gatebar swing (windup contact recovery), last THREE overhead smash (windup contact recovery). Row4 six stages kneel to pray, last frame kneeling head bowed hands resting on gatebar. Clearly preserve the specified stripped armor state in EVERY frame. No pointed capirote or face.
```

## 14. flagelado_transformacao

Arquivo final: `assets/animation/flagelado_transformacao.png`.

Grade recebida para reorganização: [3, 2].

```text
Fantasy magical object animation. SIX panels in THREE columns TWO rows on1536x1024 transparent sprite atlas. INANIMATE empty black iron suit of armor with round bell-shaped cage helmet, no wearer, no body, no skin. It magically dissolves into ivory candlewax and deep red sealing-wax droplets then reforms: panel1 empty armored shell with gatebar,2 armor softening with wax,3 low abstract wax ribbons,4 abstract wax puddle,5 rising empty armor silhouette,6 empty dark knight shell forming. Each square cell contains separate isolated object, consistent baseline, no text no grids no backdrop, genuine transparent alpha. Gothic painted pixel art, black iron, old bronze, parchment ivory, red sealingwax. No anatomy.
```

## 15. gota_culpa

Arquivo final: `assets/animation/gota_culpa.png`.

Grade recebida para reorganização: [3, 2].

```text
Fantasy red liquid droplet icon animation in gothic pixel art. SIX panels in THREE columns TWO rows,1536x1024 transparent atlas; each square cell is one isolated glossy burgundy droplet. Panel1 narrow falling droplet uppercenter,2 round falling drop lower,3 flattened tiny puddle bottomcenter,4 glossy pulsing darkred drop on floor,5 taller pulse,6 tiny drop rising. No character, no injury, no scene or labels or borders. Genuine fully transparent RGBA. Each sprite centered, baselines nearbottom. Simple stylized game effect.
```

## 16. placas_flagelado

Arquivo final: `assets/efeitos/placas_flagelado.png`.

Grade recebida para reorganização: [2, 2].

```text
Four discarded medieval fantasy ARMOR objects, gothic painted pixel-art prop atlas TWO columns TWO rows1024x1024, each square cell one separate object on genuine transparent alpha: black iron shoulder plate with parchment strips and candlewax, bronze breastplate with crossed chains, battered iron bracer, iron greave. No wearer, no body, no skin, no weapons, no injuries. Small objects lying flat atbottomcenter of each squarecell, consistent lighting and scale. Dirty parchment ivory, old bronze, black iron, dull yellow wax. No ground shadows, no backdrop, no haze, no text or grid.
```

## 17. desfiladeiro_longe

Arquivo final: `assets/vale/desfiladeiro_longe.png`.

```text
Original gothic painted pixel-art side-scroller background layer. VERY WIDE4096x720 panoramic horizontally repeating ravine ROCK WALL RIDGE only, terrain from uneven jagged skyline down to bottomedge. Sky ABOVE ridge is genuinely TRANSPARENT, no sky color backdrop. Distant low jagged spires, dusty muted mauve/brown ochre, atmospheric soft contrast, peaks no taller than middle canvas. Left edge and right edge SAME height and matching strata for seamless horizontal repeat. Flat sideview backdrop, NO receding central path, no symmetrical valley opening, no sun, no clouds, no characters, no structures, no text. Fine stippled pixels, original composition.
```

## 18. desfiladeiro_meio

Arquivo final: `assets/vale/desfiladeiro_meio.png`.

```text
Original gothic painted pixel-art side-scroller background layer. VERY WIDE4096x720 panoramic horizontally repeating ravine ROCK WALL RIDGE only, terrain from uneven jagged skyline down to bottomedge. Sky ABOVE ridge is genuinely TRANSPARENT, no sky color backdrop. Middle distance dark red-brown broken ravine escarpments, crags, long narrow spires and eroded strata, medium contrast. Left edge and right edge SAME height and matching strata for seamless horizontal repeat. Flat sideview backdrop, NO receding central path, no symmetrical valley opening, no sun, no clouds, no characters, no structures, no text. Fine stippled pixels, original composition.
```

## 19. desfiladeiro_perto

Arquivo final: `assets/vale/desfiladeiro_perto.png`.

```text
Original gothic painted pixel-art side-scroller background layer. VERY WIDE4096x720 panoramic horizontally repeating ravine ROCK WALL RIDGE only, terrain from uneven jagged skyline down to bottomedge. Sky ABOVE ridge is genuinely TRANSPARENT, no sky color backdrop. Near dark charcoal and deep burgundy ravine rock faces, eroded ledges and cracks, strong coarse silhouettes. Left edge and right edge SAME height and matching strata for seamless horizontal repeat. Flat sideview backdrop, NO receding central path, no symmetrical valley opening, no sun, no clouds, no characters, no structures, no text. Fine stippled pixels, original composition.
```

## 20. forcas

Arquivo final: `assets/vale/forcas.png`.

```text
Original gothic painted pixel-art prop atlas, SIX separate gallows posts and crossbeams WITHOUT bodies or hanging people, six columns one row1536x512, each narrow256x512cell. Weathered crooked timber, rope lashings, broken angled struts, old iron hooks. Full height wooden post centered base atbottom middle, crossbeam at top extends to RIGHT. No hanging rope loops: separate suspended assets added later. Isolated genuine transparent alpha, no groundplane, no fog or background, no text or grid. Dark weathered brown wood with stippled grey edge light.
```

## 21. enforcados

Arquivo final: `assets/vale/enforcados.png`.

Grade recebida para reorganização: [4, 2].

```text
Original gothic painted pixel-art separate hanging scene props, exactly FOUR columns TWO rows1024x1024, each cell256x512. Eight separate narrow assets, suspension rope/chain at TOP CENTER of every cell, object hangs below. Cells1-4 four adult anonymous fully cloaked figures in ragged pale/dark tunics and pointed penitential hoods, motionless silhouettes with feet hanging, no injuries visible. Cells5-8 four different iron cages suspended from central chains, with a tiny huddled clothed ADULT silhouette inside each. No children. No open wounds or explicit anatomy. Solemn distant set dressing. TRUE TRANSPARENT RGBA background with no brown haze, no gallows beams, no text or frames. Entireobject fitscell, consistent lighting and palette.
```

## 22. arvores_mortas

Arquivo final: `assets/vale/arvores_mortas.png`.

```text
Original gothic painted pixel-art environment prop atlas FOUR columns ONE row1024x512, each256x512. Four distinct tall dead trees with twisted bare branches, weathered bark and exposed roots, isolated genuine transparent alpha, no ground shadows/no backdrop, fulltrees within owncell, base centered atbottom. Dark charcoal burgundy wood, fine muted ochre edge light, stippled pixels. No people, no skull faces, no text or grid.
```

## 23. chao

Arquivo final: `assets/vale/chao.png`.

```text
Original gothic painted pixel-art ground texture strip for horizontal side-scroller. 1024x128 verywide strip, walkable topedge straight and level, dark compressed earth in side view with small weathered stones, old loose anonymous ivory bone chips and cut rope ends, deeper brokensoil below. Low contrast dark burgundy/charcoal, stippled earthen texture. Seamlessly repeatable horizontally with matching left/right edge. NO characters, NO identifiable human remains, no backgroundscene, no text. Opaque texture fills canvas.
```

## 24. corvo

Arquivo final: `assets/animation/corvo.png`.

Grade recebida para reorganização: [3, 2].

```text
Original gothic pixel-art black crow flight animation atlas SIX square cells THREE columns TWO rows1536x1024, each frame adult raven SIDE VIEW facingRIGHT with six distinct wing beats: high open wings,upstroke,levelwings,downstroke,lowwingtips,recovery. Strong inky charcoal silhouette and tiny muted grey rimlight, coherentbody matching eachframe. Bird entirewings fitcell, centered, transparentRGBA, no sky, no branches, no text or grids.
```

## 25. pendentes

Arquivo final: `assets/vida/pendentes.png`.

Grade recebida para reorganização: [4, 2].

```text
Original gothic painted pixel-art prop atlas EIGHT separate pendants in FOUR columns TWO rows1024x1024, each narrow256x512cell, suspension pivot at topcenter and FULL object below. Readlefttoright: chain with small bell, chain with old candle lantern, hanging incense censer, empty iron cage, torn red cloth banner on bar, giant old rosary, rope with votive metal charms, iron meat hook WITHOUT flesh. Darkiron, oldbronze, worn linen, dim warm light. No characters, no people, no injury, no text, no grid, genuine TRANSPARENT alpha everywhere outsideobjects, no backdrop/haze. Full lengthfitscell.
```

## 26. chama_vela

Arquivo final: `assets/animation/chama_vela.png`.

Grade recebida para reorganização: [3, 2].

```text
Six-frame candle FLAME ONLY pixel-art game animation atlas, THREE columns TWO rows1536x1024. One small warm ivory flame with orange lower edge, six subtly different shapes bendingleft/upright/right, samecenterbaseline, smoothloop. No candle base, no scene. No dark smoke or huge glow background. Genuine transparent alpha beyond flame and verythin light halo. No text/grid. Mutedgothicpaintedpixels.
```

## 27. fumaca_incenso

Arquivo final: `assets/animation/fumaca_incenso.png`.

Grade recebida para reorganização: [3, 2].

```text
Original gothic game incense smoke effect animation atlas SIX cells THREE columns TWO rows1536x1024. Wispy muted grey blue incense plume rising and curling, six progressive subtle positions continuous loop. No censer, no fire, no scene. Separate isolated smoke plumes with translucent edges on genuine transparent RGBA, alpha zero across empty cellsbackground. No white matte, no greybackdrop, no labels/grid. Painterly fine stippled pixel-art texture. Low contrast subtle smoke.
```

## 28. santo_base

Arquivo final: `assets/vida/santo_base.png`.

```text
Original gothic painted pixel-art environment monument,1024x1024 transparent isolated asset. Colossal weathered stone saint in heavy robes seated on a narrow plinth, sorrowful eroded face with TWO eye sockets, carved channels from eyes down cheeks leading into stone basins at feet. WATER NOT INCLUDED: separate animated overlay will add tears. Tall thin silhouette filling850pxheight, base centerbottom, no halo, no text, no background or floor shadow. Dark old limestone with muted grey-green edge light, mournful original sculpture not copied from a real monument.
```

## 29. ossuario_base

Arquivo final: `assets/vida/ossuario_base.png`.

```text
Original gothic painted pixel-art environment monument1024x1024 transparent isolated prop. Tall ossuary pillar built of weathered old limestone blocks and small decorative ivory skull carvings, three large circular EMPTY sockets stacked vertically alongcenter at y300,y480,y660; matching separate skullstone heads will animate there. Base centerbottom, narrow tallcolumn850pxheight. Fantasy architectural carved stone, no flesh, no injuries, no people, no backdrop/shadow/grid/text. Fine stippled dark bone-grey stone with bronze candle stains.
```

## 30. relicario_base

Arquivo final: `assets/vida/relicario_base.png`.

```text
Original gothic painted pixel-art environment monument1024x1024 transparent isolated asset. Fixed pointed architectural arch and high stone crossbeam with two long hanging IRON CHAINS extending fromtop toward center y450. Empty space belowcenter where a rotating relic cage will attach. No cage included, no people. Dark limestone arch, tarnishedironchain, muted candlewax gold. Tallverticalobject fillsframe, true transparent RGBA outside stone and chain, no backdrop or floor shadow, no text.
```

## 31. santo_movimento

Arquivo final: `assets/vida/santo_movimento.png`.

Pedido usou a referência visual do personagem ou peça já produzida nesta rodada.

```text
Edit/compositing input is stone monument reference. Create ONLY its animated WATER OVERLAY on same1024x1024 registered canvas: two slim pale blue-grey translucent tear streams running from eye sockets along existing cheek channels, descending robe channels into basins at feet, with tiny scattered droplets. ALL stone sculpture and background completely REMOVED to alpha zero. Keep water at exactly the referenced eye and channel positions; no other objects. Genuine transparent RGBA with subtle water glints, gothic painted pixel-art, no text or haze.
```

## 32. ossuario_movimento

Arquivo final: `assets/vida/ossuario_movimento.png`.

Pedido usou a referência visual do personagem ou peça já produzida nesta rodada.

```text
Compositing input is ossuary pillar reference. Return ONLY THREE large weathered carved STONE SKULL HEADS positioned exactly inside the three empty circular sockets in reference, on SAME1024x1024registeredcanvas. Heads fill eachhole, front threequarterlookingright, old limestone grey ivory, hollow eyes, fantasy architectural carved skulls, no flesh. Everything else including pillar and candles and background MUST be transparent alpha zero. Three isolated heads remain on otherwise emptycanvas in correct positions. Matching gothic stippled pixelart texture, no text.
```

## 33. relicario_movimento

Arquivo final: `assets/vida/relicario_movimento.png`.

Pedido usou a referência visual do personagem ou peça já produzida nesta rodada.

```text
Compositing input is stone arch and two chain reference. Return ONLY a suspended tall narrow ornamental bronze RELIQUARY CAGE, centeredx512 and top exactly where hanging chains end in reference, occupying centerlower space. Old octagonal filigree lantern with sealed ivory relic inside, small wax seals and glass panels, no anatomy/no flesh. Register on SAME1024x1024canvas, all stonearch, chains andbackgroundREMOVED completely to transparentalpha zero. Solemn gothic painted stippled pixels, tarnishedbronze and dirty ivory, no text.
```

## 34. glutao

Arquivo final: `docs/fichas/glutao.png`.

```text
Original CREATURE DESIGN SHEET,1600x900 landscape, gothic painted pixel-art, darkparchment background. NOT a screenshot, NOT a sprite animation yet. Layout: large SIDE PROFILE creature atLEFT, enlarged distinctive DETAIL upperRIGHT, THREE smaller distinct KEY POSES bottomRIGHT with Portuguese labels 'AVISO','ATAQUE','ABERTURA'. Name title atTOP. Cohesive dirty ivory, charcoal, ochre, muted burgundy palette, strong silhouette, subtle stippled pixels. All characters ADULT, no children, no explicit wounds, no exposed anatomy. Original composition inspired only by bleak themes of Goya, don't reproduce any painting. TITLE: 'O GLUTÃO'. An extremely tall gaunt adult giant with wide startled eyes, hunched shoulders, loose ragged black tunic, one arm wrapped in long food-stained bandages that he compulsively chews at WITHOUT injury; carries a sack of old ivory bone-like carved spoons and spits those as projectiles. All limbs intact and no wounds. Anticipation: draws his wrappedforearm near closedmouth. Attack: wideopenmouth launches ivory spoons. Vulnerable: exhausted bowed posture tangled in bandages. Theme: insatiable selfconsumption conveyed symbolically, dread of hunger.
```

## 35. disciplinantes

Arquivo final: `docs/fichas/disciplinantes.png`.

```text
Original CREATURE DESIGN SHEET,1600x900 landscape, gothic painted pixel-art, darkparchment background. NOT a screenshot, NOT a sprite animation yet. Layout: large SIDE PROFILE creature atLEFT, enlarged distinctive DETAIL upperRIGHT, THREE smaller distinct KEY POSES bottomRIGHT with Portuguese labels 'AVISO','ATAQUE','ABERTURA'. Name title atTOP. Cohesive dirty ivory, charcoal, ochre, muted burgundy palette, strong silhouette, subtle stippled pixels. All characters ADULT, no children, no explicit wounds, no exposed anatomy. Original composition inspired only by bleak themes of Goya, don't reproduce any painting. TITLE: 'DISCIPLINANTES'. A row of three anonymous ADULT penitential walkers in white pointed hoods and long ragged white tunics marked with darkcrimson stains over cloth, no skin wounds. Lead carries broad iron processional shield; followers hold knotted ritual ropes. Anticipation: frontwalker plants shield while rearfigure raises rope. Attack: synchronized low rope snap. Vulnerable: processionbroken when leadlosesbalance and gap opens between them. Profile shows allthree clearly. Theme: oppressive ritual repetition.
```

## 36. meio_enterrado

Arquivo final: `docs/fichas/meio_enterrado.png`.

```text
Original CREATURE DESIGN SHEET,1600x900 landscape, gothic painted pixel-art, darkparchment background. NOT a screenshot, NOT a sprite animation yet. Layout: large SIDE PROFILE creature atLEFT, enlarged distinctive DETAIL upperRIGHT, THREE smaller distinct KEY POSES bottomRIGHT with Portuguese labels 'AVISO','ATAQUE','ABERTURA'. Name title atTOP. Cohesive dirty ivory, charcoal, ochre, muted burgundy palette, strong silhouette, subtle stippled pixels. All characters ADULT, no children, no explicit wounds, no exposed anatomy. Original composition inspired only by bleak themes of Goya, don't reproduce any painting. TITLE: 'O MEIO-ENTERRADO'. An adult gaunt stone-grey humanoid almost completely buried in dark soil, initially ONLY anxious long face aboveground, no dog copying. Fullprofile mainview shows thin clothed figure half-emerging from earth, long roots clinging to raggedcoat. Anticipation: dirtcracks in crescent around head. Attack: entireadult lurches up reaching forward. Vulnerable: torsoentangled in roots leaningback. No injury, no bodyhorror anatomy. Theme: isolation and dread of what liesbelow.
```

## 37. parcas

Arquivo final: `docs/fichas/parcas.png`.

```text
Original creature DESIGN SHEET 1600x900 landscape, gothic painted pixelart on darkparchment background, NOT game screenshot or animation yet. Large side profile atLEFT, enlarged identifying detail upperRIGHT, three keyposes bottomRIGHT with labels 'AVISO','ATAQUE','ABERTURA'. Name title atTOP. Stippledcharcoal, dirtyivory, mutedochre/burgundy, originalcomposition inspired only by bleakGoya themes, no copying paintingcomposition. Allhumanfigures ADULT, no children, no explicitanatomy or wounds. TITLE 'AS PARCAS'. Three elderly ADULT women floating side by side in long ragged dark robes, one spins an ivory thread, second stretches it, third holds large old shears. Subtle verylong thin fingers, original silhouettes, no exposed bodies. Detail: thread tied to dull bronze heart-shaped token. Anticipation: tautthread lights ivory, shearsopen high. Attack: shears close on thread. Vulnerable: thread slack and trio bound to one knot. Theme: fate and shared dependence.
```

## 38. sono

Arquivo final: `docs/fichas/sono.png`.

```text
Original creature DESIGN SHEET 1600x900 landscape, gothic painted pixelart on darkparchment background, NOT game screenshot or animation yet. Large side profile atLEFT, enlarged identifying detail upperRIGHT, three keyposes bottomRIGHT with labels 'AVISO','ATAQUE','ABERTURA'. Name title atTOP. Stippledcharcoal, dirtyivory, mutedochre/burgundy, originalcomposition inspired only by bleakGoya themes, no copying paintingcomposition. Allhumanfigures ADULT, no children, no explicitanatomy or wounds. TITLE 'O SONO'. An exhausted ADULT scribe asleep seated at narrow wooden desk, head on folded arms, enormous ragged inkstained coat. Tiny inky owl and bat silhouettes seem to emerge from drifting paper behind him, magical dream shapes rather than anatomy. Detail: quill pen asleep over closedledger. Anticipation: paper lifts around sleeping head. Attack: swirl of owls and bats leaves desk. Vulnerable: scribe startled awake and swarm collapses into loosepapers. Theme: reason asleep gives form to dread.
```

## 39. romaria

Arquivo final: `docs/fichas/romaria.png`.

```text
Original creature DESIGN SHEET 1600x900 landscape, gothic painted pixelart on darkparchment background, NOT game screenshot or animation yet. Large side profile atLEFT, enlarged identifying detail upperRIGHT, three keyposes bottomRIGHT with labels 'AVISO','ATAQUE','ABERTURA'. Name title atTOP. Stippledcharcoal, dirtyivory, mutedochre/burgundy, originalcomposition inspired only by bleakGoya themes, no copying paintingcomposition. Allhumanfigures ADULT, no children, no explicitanatomy or wounds. TITLE 'A ROMARIA'. A single crawling PROCESSIONAL MASS of ADULT cloaked pilgrims huddled under one enormous ragged black processional mantle. Many tired faces and open chanting mouths visible between fabricfolds, intact human figures, no fusion wounds or exposed anatomy. Detail: a face among votive candles. Anticipation: chanting faces lean back together. Attack: mantle and mass surge forward. Vulnerable: one adult pilgrim steps away leaving a break in procession. Theme: collective despair and loss of individuality.
```

## 40. espantalho

Arquivo final: `docs/fichas/espantalho.png`.

```text
Original creature DESIGN SHEET 1600x900 landscape, gothic painted pixelart on darkparchment background, NOT a screenshot or runtime animation. Large sideprofile atLEFT, enlarged distinctive DETAIL upperRIGHT, three keyposes bottomRIGHT labelled 'AVISO','ATAQUE','ABERTURA'. Name title atTOP. Stippledcharcoal/dirtyivory/mutedochre/burgundy palette, originalcomposition inspired only by bleakGoya themes without copying paintingcomposition. Allhumanfigures ADULT, no children, no explicitinjury or anatomy. TITLE 'O ESPANTALHO DO MEDO'. An enormous upright ragged grey funeral shroud conceals a SMALL ADULT man walking on very long wooden stilts. Tiny adult shoes and the stilt mechanism visible under cloth, absolutely not a child. Distinct tower-like silhouette, shadow of false giant. Detail reveals wooden knee hinges beneath shroud. Anticipation: giant raises billowingclotharms. Attack: longstilt stomps downward. Vulnerable: broken woodenstilt makes ADULT puppeteer fall sitting, unharmed but exposed. Theme: manufactured fear and disproportionate power.
```

## 41. dois_velhos

Arquivo final: `docs/fichas/dois_velhos.png`.

```text
Original creature DESIGN SHEET 1600x900 landscape, gothic painted pixelart on darkparchment background, NOT a screenshot or runtime animation. Large sideprofile atLEFT, enlarged distinctive DETAIL upperRIGHT, three keyposes bottomRIGHT labelled 'AVISO','ATAQUE','ABERTURA'. Name title atTOP. Stippledcharcoal/dirtyivory/mutedochre/burgundy palette, originalcomposition inspired only by bleakGoya themes without copying paintingcomposition. Allhumanfigures ADULT, no children, no explicitinjury or anatomy. TITLE 'OS DOIS VELHOS'. Two grotesquely weary elderly ADULT men in old ragged dinnercoats seated on low stools: one clutches cracked steaming soup bowl, other leans forward pointing longfinger. Both clearly adult, intact, clothed, no wounds. Detail: bowl with old ceramic pattern and steam, pointingfinger. Anticipation: pointingone marks target while eater liftsbowl. Attack: eater throws bowl in shortarc with thin steamtrail. Vulnerable: pair quarrel over empty hands turnedtowardeachother. Theme: ritual appetite and accusation.
```

## 42. viuva

Arquivo final: `docs/fichas/viuva.png`.

```text
Original creature DESIGN SHEET 1600x900 landscape, gothic painted pixelart on darkparchment background, NOT a screenshot or runtime animation. Large sideprofile atLEFT, enlarged distinctive DETAIL upperRIGHT, three keyposes bottomRIGHT labelled 'AVISO','ATAQUE','ABERTURA'. Name title atTOP. Stippledcharcoal/dirtyivory/mutedochre/burgundy palette, originalcomposition inspired only by bleakGoya themes without copying paintingcomposition. Allhumanfigures ADULT, no children, no explicitinjury or anatomy. TITLE 'A VIÚVA DA LÂMINA'. Adult widow in heavy black mourningveil and long fitted ragged dress, short worn iron sword heldlow, lantern shaped as an INANIMATE carved BRONZE FACE MASK, not a severed head. Concealedeyes under veil. Detail: lamp's mask grille casts narrow cone of light. Anticipation: lifts masklantern and steadiesblade. Attack: short precise swordlunge toward illuminatedtarget. Vulnerable: lanternlight pointsaway while blade stuck in stone. Theme: judgment by selective illumination. No gore, no exposed anatomy, no injuries.
```
