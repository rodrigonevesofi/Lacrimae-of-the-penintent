# Prompts de arte — versão 36

## Correção final — Flagelante

A inspeção da folha de contato mostrou o maior respingo no quadro 7. Foi movido para o quadro 8, preservando as poses e os demais quadros.

```text
Use case: precise-object-edit. Edit target: attached original game sprite atlas flagelante_executado.png. Preserve exact 6 columns by 4 rows, the empty transparent upper two rows, all 12 character poses in lower rows, scale, colors, foot registration and silhouette. One targeted timing correction: in the BOTTOM ROW, remove the airborne red splash from COLUMN TWO (local execution frame 7), leaving only dark red stains on the intact character. Put the largest stylized dark red splash behind the shoulders in BOTTOM ROW COLUMN THREE (local execution frame 8), spreading within that one cell. Bottom row columns 4,5,6 retain the stains and a small red pool. Keep bodies intact: no open wounds, no exposed anatomy, no severed parts. Genuine transparent RGBA background, no brown haze, no black backdrop, no grid lines, no text. All other sprites unchanged. Final atlas aspect ratio 3:2, 1536x1024.
```


Ferramenta: geração de imagens integrada, usando os atlas originais do projeto como referências. O tratamento técnico posterior apenas redimensiona, recorta células e reorganiza os atlas RGBA. Não foram copiados sprites de outros jogos.

Foram produzidos 24 atlas: seis execuções do Penitente, seis reações à execução, oito folhas de reações e quatro efeitos. O sangue é estilizado; os corpos permanecem inteiros, sem mutilação anatômica explícita. As correções de fundo foram feitas pela mesma ferramenta de imagens.

## assets/animation/hero_executa_devorador.png

### Geração

```text
Edit target: the supplied original game sprite atlas hero_executa_devorador.png. Precise-object-edit, identity-preserve. Preserve all twelve poses, their exact scale, layout SIX columns by TWO rows, same silver armor, fully closed narrow conical helmet with no visible face, dusty dark red tattered cape and weapon/object. Output RGBA sprite atlas 1536 x 512, twelve 256 x 256 cells, transparent empty background, no grid lines or labels. Registration: feet at (128,250) inside every cell. Change only the stylized dark-crimson paint-like blood effects: cell index 8 (row 2 column 3) has an expressive dark red impact splash arcing to the right, one third of cell; wet crimson accents on sword, gloves and cape. Cells 9,10,11 keep those same crimson stains on armor and cape with red drops trailing from weapon/object. Earlier cells unchanged. These are small stylized fantasy videogame sprites; NO anatomical detail, no open wounds, no organs or explicit mutilation. Keep the original fine painted gothic videogame art, no backgrounds, no glow/cloud around silhouettes, preserve true alpha. Each cell isolated, no spill across cell borders.
```

## assets/animation/hero_executa_flagelante.png

### Geração

```text
Edit target: the supplied original game sprite atlas hero_executa_flagelante.png. Precise-object-edit, identity-preserve. Preserve all twelve poses, their exact scale, layout SIX columns by TWO rows, same silver armor, fully closed narrow conical helmet with no visible face, dusty dark red tattered cape and weapon/object. Output RGBA sprite atlas 1536 x 512, twelve 256 x 256 cells, transparent empty background, no grid lines or labels. Registration: feet at (128,250) inside every cell. Change only the stylized dark-crimson paint-like blood effects: cell index 8 (row 2 column 3) has an expressive dark red impact splash arcing to the right, one third of cell; wet crimson accents on sword, gloves and cape. Cells 9,10,11 keep those same crimson stains on armor and cape with red drops trailing from weapon/object. Earlier cells unchanged. These are small stylized fantasy videogame sprites; NO anatomical detail, no open wounds, no organs or explicit mutilation. Keep the original fine painted gothic videogame art, no backgrounds, no glow/cloud around silhouettes, preserve true alpha. Each cell isolated, no spill across cell borders.
```

## assets/animation/hero_executa_bruxa.png

### Geração

```text
Edit target: the supplied original game sprite atlas hero_executa_bruxa.png. Precise-object-edit, identity-preserve. Preserve all twelve poses, their exact scale, layout SIX columns by TWO rows, same silver armor, fully closed narrow conical helmet with no visible face, dusty dark red tattered cape and weapon/object. Output RGBA sprite atlas 1536 x 512, twelve 256 x 256 cells, transparent empty background, no grid lines or labels. Registration: feet at (128,250) inside every cell. Change only the stylized dark-crimson paint-like blood effects: cell index 8 (row 2 column 3) has an expressive dark red impact splash arcing to the right, one third of cell; wet crimson accents on sword, gloves and cape. Cells 9,10,11 keep those same crimson stains on armor and cape with red drops trailing from weapon/object. Earlier cells unchanged. These are small stylized fantasy videogame sprites; NO anatomical detail, no open wounds, no organs or explicit mutilation. Keep the original fine painted gothic videogame art, no backgrounds, no glow/cloud around silhouettes, preserve true alpha. Each cell isolated, no spill across cell borders.
```

## assets/animation/hero_executa_asmodeia.png

### Geração

```text
Edit target: the supplied original game sprite atlas hero_executa_asmodeia.png. Precise-object-edit, identity-preserve. Preserve all twelve poses, their exact scale, layout SIX columns by TWO rows, same silver armor, fully closed narrow conical helmet with no visible face, dusty dark red tattered cape and weapon/object. Output RGBA sprite atlas 1536 x 512, twelve 256 x 256 cells, transparent empty background, no grid lines or labels. Registration: feet at (128,250) inside every cell. Change only the stylized dark-crimson paint-like blood effects: cell index 8 (row 2 column 3) has an expressive dark red impact splash arcing to the right, one third of cell; wet crimson accents on sword, gloves and cape. Cells 9,10,11 keep those same crimson stains on armor and cape with red drops trailing from weapon/object. Earlier cells unchanged. These are small stylized fantasy videogame sprites; NO anatomical detail, no open wounds, no organs or explicit mutilation. Keep the original fine painted gothic videogame art, no backgrounds, no glow/cloud around silhouettes, preserve true alpha. Each cell isolated, no spill across cell borders.
```

### Correção

```text
Precise edit of this exact twelve-pose game atlas. Preserve hero identity, armor, helmet, cape, scale, alignment and poses. The stylized dark-crimson paint splash belongs in BOTTOM ROW THIRD COLUMN, the NINTH drawing, frame8: make the red impact fan at this cell large, arcing right within its cell. Bottom-row second column has only small stains. Last three drawings keep the stained gloves, armor/cape and dripping red weapon as now. No anatomy or injury depiction, no other characters, no backdrop/haze/grid. Same6columns2rows transparent RGBA,1536x512, feet128,250.
```

## assets/animation/hero_executa_duelista.png

### Geração

```text
Edit target: the supplied original game sprite atlas hero_executa_duelista.png. Precise-object-edit, identity-preserve. Preserve all twelve poses, their exact scale, layout SIX columns by TWO rows, same silver armor, fully closed narrow conical helmet with no visible face, dusty dark red tattered cape and weapon/object. Output RGBA sprite atlas 1536 x 512, twelve 256 x 256 cells, transparent empty background, no grid lines or labels. Registration: feet at (128,250) inside every cell. Change only the stylized dark-crimson paint-like blood effects: cell index 8 (row 2 column 3) has an expressive dark red impact splash arcing to the right, one third of cell; wet crimson accents on sword, gloves and cape. Cells 9,10,11 keep those same crimson stains on armor and cape with red drops trailing from weapon/object. Earlier cells unchanged. These are small stylized fantasy videogame sprites; NO anatomical detail, no open wounds, no organs or explicit mutilation. Keep the original fine painted gothic videogame art, no backgrounds, no glow/cloud around silhouettes, preserve true alpha. Each cell isolated, no spill across cell borders.
```

## assets/animation/hero_executa_carregador.png

### Geração

```text
Edit target: the supplied original game sprite atlas hero_executa_carregador.png. Precise-object-edit, identity-preserve. Preserve all twelve poses, their exact scale, layout SIX columns by TWO rows, same silver armor, fully closed narrow conical helmet with no visible face, dusty dark red tattered cape and weapon/object. Output RGBA sprite atlas 1536 x 512, twelve 256 x 256 cells, transparent empty background, no grid lines or labels. Registration: feet at (128,250) inside every cell. Change only the stylized dark-crimson paint-like blood effects: cell index 8 (row 2 column 3) has an expressive dark red impact splash arcing to the right, one third of cell; wet crimson accents on sword, gloves and cape. Cells 9,10,11 keep those same crimson stains on armor and cape with red drops trailing from weapon/object. Earlier cells unchanged. These are small stylized fantasy videogame sprites; NO anatomical detail, no open wounds, no organs or explicit mutilation. Keep the original fine painted gothic videogame art, no backgrounds, no glow/cloud around silhouettes, preserve true alpha. Each cell isolated, no spill across cell borders.
```

## assets/animation/devorador_executado.png

### Geração

```text
Use supplied devorador sprite sheet as the edit target and exact character identity reference. Original gothic painted fantasy videogame sprite art. Produce a 1536x1024 RGBA atlas, 6 columns x4 rows, each cell256x256. First two rows completely transparent/empty. Bottom two rows contain exactly the same twelve creature poses from the execution sequence, preserving position scale and silhouette.  Change the creature's execution reactions to include stylized dark crimson splashes and clothing stains: progressive red accents from local frame 5, expressive red impact splash in local frame8, continued drops/stains in frames9-11 with a small flattened red pool below. Keep the same body intact with NO anatomical injury, no exposed wounds, no organs or severed parts. Fantasy game art only; motion and wet dark red color carry the impact. All characters adults. Real transparent alpha everywhere outside each subject and red effect; REMOVE the brown/grey haze/background of the reference. No backdrop, floor, lighting cloud, grid or text. Exact registration same as original subject, feet/ground at cell y=250, x=128. Do not draw the hero.
```

### Correção

```text
Precise edit of this exact RGBA game atlas. Keep EVERYTHING except the timing of the red stylized impact effect. There are six columns four rows. The BIGGEST paint-like dark-crimson splash must appear in BOTTOM ROW, THIRD COLUMN (the ninth visible creature pose, global tile20, local animation frame8). The bottom-row SECOND column should have only small red stains; the THIRD has the broad impact splash and droplets; fourth/fifth/sixth keep red stains and pool as before. Do not change poses or costume, no anatomical detail or wounds, no other content. First two rows stay empty and transparent. Remove any remaining background/haze; true alpha outside isolated sprites. Same1536x1024, exact6x4 grid.
```

## assets/animation/flagelante_executado.png

### Geração

```text
Use supplied flagelante sprite sheet as the edit target and exact character identity reference. Original gothic painted fantasy videogame sprite art. Produce a 1536x1024 RGBA atlas, 6 columns x4 rows, each cell256x256. First two rows completely transparent/empty. Bottom two rows contain exactly the same twelve creature poses from the execution sequence, preserving position scale and silhouette.  Change the creature's execution reactions to include stylized dark crimson splashes and clothing stains: progressive red accents from local frame 5, expressive red impact splash in local frame8, continued drops/stains in frames9-11 with a small flattened red pool below. Keep the same body intact with NO anatomical injury, no exposed wounds, no organs or severed parts. Fantasy game art only; motion and wet dark red color carry the impact. All characters adults. Real transparent alpha everywhere outside each subject and red effect; REMOVE the brown/grey haze/background of the reference. No backdrop, floor, lighting cloud, grid or text. Exact registration same as original subject, feet/ground at cell y=250, x=128. Do not draw the hero.
```

## assets/animation/bruxa_executado.png

### Geração

```text
Use supplied bruxa sprite sheet as the edit target and exact character identity reference. Original gothic painted fantasy videogame sprite art. Produce a 1536x1024 RGBA atlas, 6 columns x4 rows, each cell256x256. First two rows completely transparent/empty. Bottom two rows contain exactly the same twelve creature poses from the execution sequence, preserving position scale and silhouette.  Change the creature's execution reactions to include stylized dark crimson splashes and clothing stains: progressive red accents from local frame 5, expressive red impact splash in local frame8, continued drops/stains in frames9-11 with a small flattened red pool below. Keep the same body intact with NO anatomical injury, no exposed wounds, no organs or severed parts. Fantasy game art only; motion and wet dark red color carry the impact. All characters adults. Real transparent alpha everywhere outside each subject and red effect; REMOVE the brown/grey haze/background of the reference. No backdrop, floor, lighting cloud, grid or text. Exact registration same as original subject, feet/ground at cell y=250, x=128. Do not draw the hero.
```

### Correção

```text
Precise edit of this exact RGBA game atlas. Keep EVERYTHING except the timing of the red stylized impact effect. There are six columns four rows. The BIGGEST paint-like dark-crimson splash must appear in BOTTOM ROW, THIRD COLUMN (the ninth visible creature pose, global tile20, local animation frame8). The bottom-row SECOND column should have only small red stains; the THIRD has the broad impact splash and droplets; fourth/fifth/sixth keep red stains and pool as before. Do not change poses or costume, no anatomical detail or wounds, no other content. First two rows stay empty and transparent. Remove any remaining background/haze; true alpha outside isolated sprites. Same1536x1024, exact6x4 grid.
```

## assets/animation/asmodeia_executado.png

### Geração

```text
Use supplied asmodeia sprite sheet as the edit target and exact character identity reference. Original gothic painted fantasy videogame sprite art. Produce a 1536x1024 RGBA atlas, 6 columns x4 rows, each cell256x256. First two rows completely transparent/empty. Bottom two rows contain exactly the same twelve creature poses from the execution sequence, preserving position scale and silhouette.  Change the creature's execution reactions to include stylized dark crimson splashes and clothing stains: progressive red accents from local frame 5, expressive red impact splash in local frame8, continued drops/stains in frames9-11 with a small flattened red pool below. Keep the same body intact with NO anatomical injury, no exposed wounds, no organs or severed parts. Fantasy game art only; motion and wet dark red color carry the impact. All characters adults. Real transparent alpha everywhere outside each subject and red effect; REMOVE the brown/grey haze/background of the reference. No backdrop, floor, lighting cloud, grid or text. Exact registration same as original subject, feet/ground at cell y=250, x=128. Do not draw the hero.
```

### Correção

```text
Precise edit of this exact RGBA game atlas. Keep EVERYTHING except the timing of the red stylized impact effect. There are six columns four rows. The BIGGEST paint-like dark-crimson splash must appear in BOTTOM ROW, THIRD COLUMN (the ninth visible creature pose, global tile20, local animation frame8). The bottom-row SECOND column should have only small red stains; the THIRD has the broad impact splash and droplets; fourth/fifth/sixth keep red stains and pool as before. Do not change poses or costume, no anatomical detail or wounds, no other content. First two rows stay empty and transparent. Remove any remaining background/haze; true alpha outside isolated sprites. Same1536x1024, exact6x4 grid.
```

## assets/animation/duelista_executado.png

### Geração

```text
Use supplied duelista sprite sheet as the edit target and exact character identity reference. Original gothic painted fantasy videogame sprite art. Produce a 1536x1024 RGBA atlas, 6 columns x4 rows, each cell256x256. First two rows completely transparent/empty. Bottom two rows contain exactly the same twelve creature poses from the execution sequence, preserving position scale and silhouette.  Change the creature's execution reactions to include stylized dark crimson splashes and clothing stains: progressive red accents from local frame 5, expressive red impact splash in local frame8, continued drops/stains in frames9-11 with a small flattened red pool below. Keep the same body intact with NO anatomical injury, no exposed wounds, no organs or severed parts. Fantasy game art only; motion and wet dark red color carry the impact. All characters adults. Real transparent alpha everywhere outside each subject and red effect; REMOVE the brown/grey haze/background of the reference. No backdrop, floor, lighting cloud, grid or text. Exact registration same as original subject, feet/ground at cell y=250, x=128. Do not draw the hero.
```

### Correção

```text
Precise edit of this exact RGBA game atlas. Keep EVERYTHING except the timing of the red stylized impact effect. There are six columns four rows. The BIGGEST paint-like dark-crimson splash must appear in BOTTOM ROW, THIRD COLUMN (the ninth visible creature pose, global tile20, local animation frame8). The bottom-row SECOND column should have only small red stains; the THIRD has the broad impact splash and droplets; fourth/fifth/sixth keep red stains and pool as before. Do not change poses or costume, no anatomical detail or wounds, no other content. First two rows stay empty and transparent. Remove any remaining background/haze; true alpha outside isolated sprites. Same1536x1024, exact6x4 grid.
```

## assets/animation/carregador_executado.png

### Geração

```text
Use supplied carregador sprite sheet as the edit target and exact character identity reference. Original gothic painted fantasy videogame sprite art. Produce a 1536x1024 RGBA atlas, 6 columns x4 rows, each cell256x256. First two rows completely transparent/empty. Bottom two rows contain exactly the same twelve creature poses from the execution sequence, preserving position scale and silhouette. Use the twelve falling/kneeling poses in the bottom half of the source, blindfold and torn ochre robes, no coffin in this sequence. Change the creature's execution reactions to include stylized dark crimson splashes and clothing stains: progressive red accents from local frame 5, expressive red impact splash in local frame8, continued drops/stains in frames9-11 with a small flattened red pool below. Keep the same body intact with NO anatomical injury, no exposed wounds, no organs or severed parts. Fantasy game art only; motion and wet dark red color carry the impact. All characters adults. Real transparent alpha everywhere outside each subject and red effect; REMOVE the brown/grey haze/background of the reference. No backdrop, floor, lighting cloud, grid or text. Exact registration same as original subject, feet/ground at cell y=250, x=128. Do not draw the hero.
```

### Correção

```text
Precise edit of this exact RGBA game atlas. Keep EVERYTHING except the timing of the red stylized impact effect. There are six columns four rows. The BIGGEST paint-like dark-crimson splash must appear in BOTTOM ROW, THIRD COLUMN (the ninth visible creature pose, global tile20, local animation frame8). The bottom-row SECOND column should have only small red stains; the THIRD has the broad impact splash and droplets; fourth/fifth/sixth keep red stains and pool as before. Do not change poses or costume, no anatomical detail or wounds, no other content. First two rows stay empty and transparent. Remove any remaining background/haze; true alpha outside isolated sprites. Same1536x1024, exact6x4 grid.
```

## assets/animation/reacoes_devoto.png

### Geração

```text
Reference image: supplied ORIGINAL game character devoto, use only for exact creature identity, proportions, costume, color and fine painted gothic art. Generate a NEW reaction animation sprite sheet, 1536x1024 RGBA, exactly SIX columns FOUR rows, 24 equal256x256 cells, TRUE transparent background. Same adult fantasy creature in all frames, facing right; full body contained in each cell, normal standing height220pixels, feet registration (128,250), same scale throughout. Sequential index0-2: light hit recoil and regain balance. 3-6: heavy impact, fold torso deeper and red stylized clothing stains. 7-12: launched upward, lean back, rotate body through falling poses, land flat on back in12. 13-17: dazed/staggering, five subtle distinct swaying poses with dark crimson stains. 18-23: held horizontally by a lance impact, small struggling poses then slump; show only the short dark spear shaft near torso and red stains/drops. No anatomical injuries, open wounds, severed parts or organs. Character remains intact. Expressive motion, readable silhouettes and paint-like red drops convey impact. Keep original creature identity; do not replace it with the hero. No atmosphere, haze, ground, shadows, boxes, text or numbers. Every cell separate, evenly spaced, exactly 24 poses.
```

### Correção

```text
Background extraction only. Edit this EXACT sprite sheet; preserve all 24 creatures, poses, scale, placement, costume, red droplets, lance shafts, art details unchanged. REMOVE every background pixel, including the white/brown/grey gradient, atmospheric haze, floor shadows and grid lines between cells. Replace all empty areas with alpha ZERO, including inside gaps between limbs. Isolate hard-edged painted game sprites, with anti-aliasing only along the immediate contour. NO semi-opaque backdrop, NO fog, NO white matte. True clean transparent RGBA1536x1024, exact 6 columns4rows same registration. Do not add or remove creature poses; only erase background.
```

## assets/animation/reacoes_flagelante.png

### Geração

```text
Reference image: supplied ORIGINAL game character flagelante, use only for exact creature identity, proportions, costume, color and fine painted gothic art. Generate a NEW reaction animation sprite sheet, 1536x1024 RGBA, exactly SIX columns FOUR rows, 24 equal256x256 cells, TRUE transparent background. Same adult fantasy creature in all frames, facing right; full body contained in each cell, normal standing height220pixels, feet registration (128,250), same scale throughout. Sequential index0-2: light hit recoil and regain balance. 3-6: heavy impact, fold torso deeper and red stylized clothing stains. 7-12: launched upward, lean back, rotate body through falling poses, land flat on back in12. 13-17: dazed/staggering, five subtle distinct swaying poses with dark crimson stains. 18-23: held horizontally by a lance impact, small struggling poses then slump; show only the short dark spear shaft near torso and red stains/drops. No anatomical injuries, open wounds, severed parts or organs. Character remains intact. Expressive motion, readable silhouettes and paint-like red drops convey impact. Keep original creature identity; do not replace it with the hero. No atmosphere, haze, ground, shadows, boxes, text or numbers. Every cell separate, evenly spaced, exactly 24 poses.
```

### Correção

```text
Background extraction only. Edit this EXACT sprite sheet; preserve all 24 creatures, poses, scale, placement, costume, red droplets, lance shafts, art details unchanged. REMOVE every background pixel, including the white/brown/grey gradient, atmospheric haze, floor shadows and grid lines between cells. Replace all empty areas with alpha ZERO, including inside gaps between limbs. Isolate hard-edged painted game sprites, with anti-aliasing only along the immediate contour. NO semi-opaque backdrop, NO fog, NO white matte. True clean transparent RGBA1536x1024, exact 6 columns4rows same registration. Do not add or remove creature poses; only erase background.
```

## assets/animation/reacoes_devorador.png

### Geração

```text
Reference image: supplied ORIGINAL game character devorador, use only for exact creature identity, proportions, costume, color and fine painted gothic art. Generate a NEW reaction animation sprite sheet, 1536x1024 RGBA, exactly SIX columns FOUR rows, 24 equal256x256 cells, TRUE transparent background. Same adult fantasy creature in all frames, facing right; full body contained in each cell, normal standing height220pixels, feet registration (128,250), same scale throughout. Sequential index0-2: light hit recoil and regain balance. 3-6: heavy impact, fold torso deeper and red stylized clothing stains. 7-12: launched upward, lean back, rotate body through falling poses, land flat on back in12. 13-17: dazed/staggering, five subtle distinct swaying poses with dark crimson stains. 18-23: held horizontally by a lance impact, small struggling poses then slump; show only the short dark spear shaft near torso and red stains/drops. No anatomical injuries, open wounds, severed parts or organs. Character remains intact. Expressive motion, readable silhouettes and paint-like red drops convey impact. Keep original creature identity; do not replace it with the hero. No atmosphere, haze, ground, shadows, boxes, text or numbers. Every cell separate, evenly spaced, exactly 24 poses.
```

### Correção

```text
Background extraction only. Edit this EXACT sprite sheet; preserve all 24 creatures, poses, scale, placement, costume, red droplets, lance shafts, art details unchanged. REMOVE every background pixel, including the white/brown/grey gradient, atmospheric haze, floor shadows and grid lines between cells. Replace all empty areas with alpha ZERO, including inside gaps between limbs. Isolate hard-edged painted game sprites, with anti-aliasing only along the immediate contour. NO semi-opaque backdrop, NO fog, NO white matte. True clean transparent RGBA1536x1024, exact 6 columns4rows same registration. Do not add or remove creature poses; only erase background.
```

## assets/animation/reacoes_duelista.png

### Geração

```text
Reference image: supplied ORIGINAL game character duelista, use only for exact creature identity, proportions, costume, color and fine painted gothic art. Generate a NEW reaction animation sprite sheet, 1536x1024 RGBA, exactly SIX columns FOUR rows, 24 equal256x256 cells, TRUE transparent background. Same adult fantasy creature in all frames, facing right; full body contained in each cell, normal standing height220pixels, feet registration (128,250), same scale throughout. Sequential index0-2: light hit recoil and regain balance. 3-6: heavy impact, fold torso deeper and red stylized clothing stains. 7-12: launched upward, lean back, rotate body through falling poses, land flat on back in12. 13-17: dazed/staggering, five subtle distinct swaying poses with dark crimson stains. 18-23: held horizontally by a lance impact, small struggling poses then slump; show only the short dark spear shaft near torso and red stains/drops. No anatomical injuries, open wounds, severed parts or organs. Character remains intact. Expressive motion, readable silhouettes and paint-like red drops convey impact. Keep original creature identity; do not replace it with the hero. No atmosphere, haze, ground, shadows, boxes, text or numbers. Every cell separate, evenly spaced, exactly 24 poses.
```

### Correção

```text
Background extraction only. Edit this EXACT sprite sheet; preserve all 24 creatures, poses, scale, placement, costume, red droplets, lance shafts, art details unchanged. REMOVE every background pixel, including the white/brown/grey gradient, atmospheric haze, floor shadows and grid lines between cells. Replace all empty areas with alpha ZERO, including inside gaps between limbs. Isolate hard-edged painted game sprites, with anti-aliasing only along the immediate contour. NO semi-opaque backdrop, NO fog, NO white matte. True clean transparent RGBA1536x1024, exact 6 columns4rows same registration. Do not add or remove creature poses; only erase background.
```

## assets/animation/reacoes_carregador.png

### Geração

```text
Reference image: supplied ORIGINAL game character carregador, use only for exact creature identity, proportions, costume, color and fine painted gothic art. Generate a NEW reaction animation sprite sheet, 1536x1024 RGBA, exactly SIX columns FOUR rows, 24 equal256x256 cells, TRUE transparent background. Same adult fantasy creature in all frames, facing right; full body contained in each cell, normal standing height220pixels, feet registration (128,250), same scale throughout. Sequential index0-2: light hit recoil and regain balance. 3-6: heavy impact, fold torso deeper and red stylized clothing stains. 7-12: launched upward, lean back, rotate body through falling poses, land flat on back in12. 13-17: dazed/staggering, five subtle distinct swaying poses with dark crimson stains. 18-23: held horizontally by a lance impact, small struggling poses then slump; show only the short dark spear shaft near torso and red stains/drops. No anatomical injuries, open wounds, severed parts or organs. Character remains intact. Expressive motion, readable silhouettes and paint-like red drops convey impact. Keep original creature identity; do not replace it with the hero. No atmosphere, haze, ground, shadows, boxes, text or numbers. Every cell separate, evenly spaced, exactly 24 poses.
```

### Correção

```text
Background extraction only. Edit this EXACT sprite sheet; preserve all 24 creatures, poses, scale, placement, costume, red droplets, lance shafts, art details unchanged. REMOVE every background pixel, including the white/brown/grey gradient, atmospheric haze, floor shadows and grid lines between cells. Replace all empty areas with alpha ZERO, including inside gaps between limbs. Isolate hard-edged painted game sprites, with anti-aliasing only along the immediate contour. NO semi-opaque backdrop, NO fog, NO white matte. True clean transparent RGBA1536x1024, exact 6 columns4rows same registration. Do not add or remove creature poses; only erase background.
```

## assets/animation/reacoes_bruxa.png

### Geração

```text
Reference image: supplied ORIGINAL game character bruxa, use only for exact creature identity, proportions, costume, color and fine painted gothic art. Generate a NEW reaction animation sprite sheet, 1536x1024 RGBA, exactly SIX columns FOUR rows, 24 equal256x256 cells, TRUE transparent background. Same adult fantasy creature in all frames, facing right; full body contained in each cell, normal standing height220pixels, feet registration (128,250), same scale throughout. Sequential index0-2: light hit recoil and regain balance. 3-6: heavy impact, fold torso deeper and red stylized clothing stains. 7-12: launched upward, lean back, rotate body through falling poses, land flat on back in12. 13-17: dazed/staggering, five subtle distinct swaying poses with dark crimson stains. 18-23: held horizontally by a lance impact, small struggling poses then slump; show only the short dark spear shaft near torso and red stains/drops. No anatomical injuries, open wounds, severed parts or organs. Character remains intact. Expressive motion, readable silhouettes and paint-like red drops convey impact. Keep original creature identity; do not replace it with the hero. No atmosphere, haze, ground, shadows, boxes, text or numbers. Every cell separate, evenly spaced, exactly 24 poses.
```

### Correção

```text
Background extraction only. Edit this EXACT sprite sheet; preserve all 24 creatures, poses, scale, placement, costume, red droplets, lance shafts, art details unchanged. REMOVE every background pixel, including the white/brown/grey gradient, atmospheric haze, floor shadows and grid lines between cells. Replace all empty areas with alpha ZERO, including inside gaps between limbs. Isolate hard-edged painted game sprites, with anti-aliasing only along the immediate contour. NO semi-opaque backdrop, NO fog, NO white matte. True clean transparent RGBA1536x1024, exact 6 columns4rows same registration. Do not add or remove creature poses; only erase background.
```

## assets/animation/reacoes_asmodeia.png

### Geração

```text
Reference image: supplied ORIGINAL game character asmodeia, use only for exact creature identity, proportions, costume, color and fine painted gothic art. Generate a NEW reaction animation sprite sheet, 1536x1024 RGBA, exactly SIX columns FOUR rows, 24 equal256x256 cells, TRUE transparent background. Same adult fantasy creature in all frames, facing right; full body contained in each cell, normal standing height220pixels, feet registration (128,250), same scale throughout. Sequential index0-2: light hit recoil and regain balance. 3-6: heavy impact, fold torso deeper and red stylized clothing stains. 7-12: launched upward, lean back, rotate body through falling poses, land flat on back in12. 13-17: dazed/staggering, five subtle distinct swaying poses with dark crimson stains. 18-23: held horizontally by a lance impact, small struggling poses then slump; show only the short dark spear shaft near torso and red stains/drops. No anatomical injuries, open wounds, severed parts or organs. Character remains intact. Expressive motion, readable silhouettes and paint-like red drops convey impact. Keep original creature identity; do not replace it with the hero. No atmosphere, haze, ground, shadows, boxes, text or numbers. Every cell separate, evenly spaced, exactly 24 poses.
```

### Correção

```text
Background extraction only. Edit this EXACT sprite sheet; preserve all 24 creatures, poses, scale, placement, costume, red droplets, lance shafts, art details unchanged. REMOVE every background pixel, including the white/brown/grey gradient, atmospheric haze, floor shadows and grid lines between cells. Replace all empty areas with alpha ZERO, including inside gaps between limbs. Isolate hard-edged painted game sprites, with anti-aliasing only along the immediate contour. NO semi-opaque backdrop, NO fog, NO white matte. True clean transparent RGBA1536x1024, exact 6 columns4rows same registration. Do not add or remove creature poses; only erase background.
```

## assets/animation/reacoes_choro.png

### Geração

```text
Reference image: supplied ORIGINAL game character choro, use only for exact creature identity, proportions, costume, color and fine painted gothic art. Generate a NEW reaction animation sprite sheet, 1536x1024 RGBA, exactly SIX columns FOUR rows, 24 equal256x256 cells, TRUE transparent background. Same adult fantasy creature in all frames, facing right; full body contained in each cell, normal standing height220pixels, feet registration (128,250), same scale throughout. Sequential index0-2: light hit recoil and regain balance. 3-6: heavy impact, fold torso deeper and red stylized clothing stains. 7-12: launched upward, lean back, rotate body through falling poses, land flat on back in12. 13-17: dazed/staggering, five subtle distinct swaying poses with dark crimson stains. 18-23: held horizontally by a lance impact, small struggling poses then slump; show only the short dark spear shaft near torso and red stains/drops. No anatomical injuries, open wounds, severed parts or organs. Character remains intact. Expressive motion, readable silhouettes and paint-like red drops convey impact. Keep original creature identity; do not replace it with the hero. No atmosphere, haze, ground, shadows, boxes, text or numbers. Every cell separate, evenly spaced, exactly 24 poses.
```

### Correção

```text
Background extraction only. Edit this EXACT sprite sheet; preserve all 24 creatures, poses, scale, placement, costume, red droplets, lance shafts, art details unchanged. REMOVE every background pixel, including the white/brown/grey gradient, atmospheric haze, floor shadows and grid lines between cells. Replace all empty areas with alpha ZERO, including inside gaps between limbs. Isolate hard-edged painted game sprites, with anti-aliasing only along the immediate contour. NO semi-opaque backdrop, NO fog, NO white matte. True clean transparent RGBA1536x1024, exact 6 columns4rows same registration. Do not add or remove creature poses; only erase background.
```

## assets/efeitos/sangue_chao.png

### Geração

```text
Original painted gothic fantasy game FX sprite sheet on TRUE transparent background. Eight distinct dark-crimson stylized blood ground stains/pools seen from side, flattened horizontal silhouettes with sparse droplets, no body, no anatomy. Arrange exactly FOUR columns by TWO rows, eight isolated equal square tiles. Each flattened pool centered horizontally near tile bottom, shapes range small to large, wet near-black red core and subtle deep red wet highlights. No grey backdrop, no ground plane, no shadows beyond stain, no text/grid. Keep droplets within own cell. 1536x1024 output.
```

## assets/efeitos/sangue_parede.png

### Geração

```text
Original painted gothic fantasy game FX sprite sheet TRUE transparent alpha. Four different stylized dark red splatter decals, vertical wall orientation with long drips downward, maroon pools with subtle red wet highlights, from sparse small spots to broad irregular impact. No body or anatomy. Exactly TWO columns TWO rows, four isolated equal square tiles 1024x1024. No wall/background, no mist/clouds, no labels or grid. Isolated individual decals bounded by each tile.
```

## assets/animation/jato_arterial.png

### Geração

```text
Original stylized painted gothic fantasy videogame effect animation atlas, TRUE transparent background. SIX sequential frames of a dark-crimson liquid splash arcing from left towards right: 0 compact initial streak, 1 expands curving fan, 2 fullest fan, 3 separates into broad droplets, 4 scattered smaller drops, 5 last sparse drops. This is an isolated paint-like red liquid game effect, no wounds, no character or anatomy. Exactly THREE columns TWO rows; six equal square cells. Shape starts near cell (35,160) and follows consistent rightward arc, stays inside cell. Dark maroon with subtle wet highlights, no glow/mist/grey backdrop, no text/grid. 1536x1024.
```

### Correção

```text
Background extraction ONLY of this exact six-cell game effect atlas. Keep all six isolated red liquid/debris shapes unchanged, exact same positions and details. Completely remove ALL white/grey/brown cloudy background and every grid line; alpha must be ZERO everywhere except solid effect shapes and droplets, with thin antialiased contour. No red fog, no glowing haze, no cast shadows, no matte. Preserve1536x1024 THREE columns TWO rows and all original sprite content. Output clean transparent RGBA.
```

## assets/animation/pedacos.png

### Geração

```text
Original gothic fantasy game debris sprite atlas, stylized painted tiny irregular dark-crimson fragments and small ivory chips, non-anatomical abstract shapes, no recognizable body parts or organs. SIX distinct rotated debris clumps, exactly THREE columns TWO rows of equal square cells; each centered, about 40 percent cell area, isolated TRUE transparent alpha. Deep maroon, tiny dull ivory edges, wet red highlights. This is a small fantasy combat effect asset, not a scene. No backdrop, haze, shadows, labels or grid. 1536x1024.
```

### Correção

```text
Background extraction ONLY of this exact six-cell game effect atlas. Keep all six isolated red liquid/debris shapes unchanged, exact same positions and details. Completely remove ALL white/grey/brown cloudy background and every grid line; alpha must be ZERO everywhere except solid effect shapes and droplets, with thin antialiased contour. No red fog, no glowing haze, no cast shadows, no matte. Preserve1536x1024 THREE columns TWO rows and all original sprite content. Output clean transparent RGBA.
```
