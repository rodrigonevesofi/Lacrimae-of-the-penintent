# Guardião dos Sinos — atlas maior

`assets/animation/guardiao_grande.png`: RGBA1536×1024, grade6×4, células256×256. O mesmo colosso de carne, bronze gravado e vestes rubras das ilustrações, voltado para a direita em três quartos. O corpo ocupa quase toda a altura nas poses em pé; não é apenas a figura antiga ampliada.

| Quadros | Ação | Taxa inicial para revisão |
|---|---|---|
|0–5|Repouso, peso e respiração|8fps|
|6–11|Caminhada pesada|10fps|
|12–15|Preparação do ataque|Ajustar à preparação real|
|16–17|Golpe|Sincronizar ao instante real do dano|
|18–20|Dano/recuo|10fps|
|21–23|Queda|8fps, terminar no último quadro|

O verificador original confirmou24 poses distintas e não vazias. O pivô nominal de integração é(128,250). Os limites alfa medidos ficam em `v18-arte-medidas.json`; há pequena variação de base entre poses. O mesmo JSON fornece `suggested_per_frame_y_registration` para levar a base visível ao pixel250 na prévia. Isso é ajuste de desenho no teste, não mudança dos pixels do atlas nem de `clips.json`. Conferir os pés e a coroa, especialmente na preparação e na queda, antes da integração definitiva. A margem superior não é uniforme em todas as poses.

A prévia usa esses deslocamentos para a comparação em movimento. Falta confirmar a âncora final dentro do animador de produção e a silhueta em perfil estrito; a arte atual é em três quartos. Não declarar o atlas pronto para substituição automática sem essa conferência. O integrador precisa também revisar escala, tamanho de colisão, arena e barra de vida; aumentar apenas a textura não corrige o combate.

A sonda em [equilibrio-chefe.md](equilibrio-chefe.md) mede o chefe antigo da base v17, com duas fases. Este atlas não cria três fases, novos golpes, maisHP ou uma luta de90–120s. [Prévia de movimento](imagens/v18-atlas.png).
