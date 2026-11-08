# Penitente e boneca — atlas do memorial

`assets/animation/hero_memorial.png`: 1536×1024 RGBA, grade 6×4, células 256×256, perfil à direita. Referências: hero_grief.png e cloth_doll.png. Foi acrescentado um pequeno sinal de sol dourado no pulso da boneca. A escala e o chão de referência seguem o herói, com âncora proposta [128,250].

| Grupo | Início | Quadros | Uso |
|---|---:|---:|---|
| Ajoelhar segurando a boneca |0|6|uma vez|
| Depositar e manter a mão |6|6|uma vez|
| Cabeça baixa, respirar |12|6|ciclo|
| Levantar e deixar a boneca |18|6|uma vez|

[Folha de contato](imagens/hero-memorial-contato.png), com índices e guia de chão. `tools/review_v13_art.gd` também reproduz os grupos em sequência, a 7,5 quadros/s, repetindo a respiração quatro vezes apenas para inspeção. Isso não fixa a duração do memorial final.

`tests/v13_assets_check.py` confere 24 quadros distintos e não vazios, dimensões e cantos com alfa 0. Reutiliza `tools/check_animation_atlases.py` numa estrutura temporária com quatro clipes, porque o manifesto de produção é protegido. O verificador também foi executado normalmente sobre o manifesto existente, sem erros.

Não foram alterados clips.json ou narrativa. Antes de integrar, o Claude deve conferir a transição do herói atual para o atlas, a posição da boneca no chão e a passagem para o objeto persistente do memorial: a boneca está desenhada dentro dos quadros, portanto desenhar também o objeto separado pode duplicá-la. Há pequenas variações de desenho/posição entre quadros; a folha não comprova fluidez ou alinhamento em todas as escalas e câmeras. O sol é um detalhe pequeno e precisa de conferência na escala final.
