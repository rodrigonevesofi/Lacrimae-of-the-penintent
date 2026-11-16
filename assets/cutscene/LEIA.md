# Clipes da cutscene da revelação

Coloque aqui os clipes `revelacao_01.ogv` a `revelacao_06.ogv` (8 s cada). Com pelo menos um clipe nesta pasta, a revelação do Vale vira um filme de 52 s; sem nenhum, continua com os closes parados.

Não copie os MP4 direto: o Godot só toca vídeo em Ogg Theora. Use:

```
python3 tools/preparar_cutscene.py <pasta com os MP4>
```

O script espera arquivos chamados `revelacao_01.mp4` ... `revelacao_06.mp4`, converte para 1280 × 720 sem som (o som da cena é o do jogo) e grava aqui.

| Clipe | Cena |
| --- | --- |
| `revelacao_01` | O elmo-gaiola do Flagelado |
| `revelacao_02` | As mãos de Beatriz erguem o capirote |
| `revelacao_03` | O rosto, de olhos fechados |
| `revelacao_04` | Os dois rostos |
| `revelacao_05` | Ele abre os olhos e olha para quem joga |
| `revelacao_06` | Beatriz |
