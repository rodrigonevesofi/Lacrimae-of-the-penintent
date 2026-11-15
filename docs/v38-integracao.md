# Versão 38 — integração, arte e efeitos

Os dois pacotes v38 foram reunidos sobre a versão 36 publicada, preservando o combate e os sons existentes. A versão 37/38 recebida acrescenta o Vale dos Flagelados, seu chefe, a revelação e vida nas salas. Esta integração entrega os cinco itens de `prompts-codex-v38.md`, com a etapa de criaturas limitada às fichas para aprovação.

Há **42 PNGs finais**, registrados com dimensões e SHA-256 em [v38-assets.json](v38-assets.json). A arte semântica foi produzida pela ferramenta integrada de geração de imagens; o processamento posterior apenas redimensiona, recorta células e organiza atlas. [Prompts e processamento](v38-prompts-arte.md).

## 1. O Flagelado e a revelação

O chefe tem elmo-gaiola fechado com grade e cadeado, ferro escuro, pergaminhos, cera e tranca de ferro nas mãos. A forma verdadeira usa as folhas novas, sem o capirote provisório do Argon. O nome exibido permanece **O FLAGELADO**.

As três folhas principais e os quatro estados adicionais têm 1536 × 1024, grade 6 × 4, células de 256 e âncora nos pés em (128, 250). O chefe usa escala **0,62**, contra **0,44** do protagonista; a altura visível fica aproximadamente 1,25 vez a dele. A colisão da forma verdadeira mede 56 × 110; o reflexo mantém a colisão do protagonista.

`flagelado_estados.png` reúne a primeira fileira de parados das quatro folhas de estado. Cada estado também anda, ataca e se ajoelha. As folhas resumidas usam 0–5 parado, 6–11 andar, 12–14 golpe lateral, 15–17 pancada, 18–20 ajoelhar, 21–23 oração. As reações após perder placas permanecem na aparência da etapa atual, evitando que a armadura volte a aparecer ao receber dano. A transição para ajoelhar precede o laço de oração. As janelas de dano, os dois caminhos de revelação, a chegada de Beatriz e a conclusão da luta foram preservados.

As placas pintadas acompanham as sete partículas já existentes; uma peça de cada queda fica no chão por 24 segundos e desaparece suavemente. A gota tem queda, pulsação e coleta em atlas próprio; sai da lógica de coleta ao começar sua animação final. As trocas de forma dissolvem a anterior e recompõem a seguinte durante 0,6 s, com a pintura de transformação como máscara. O efeito representa cera e ferro se desfazendo; não inclui detalhes anatômicos explícitos.

O retrato `close_01.png` foi substituído por um homem comum, raspado, com barba curta falhada e marcas do capacete. A revelação usa três imagens distintas: elmo do Flagelado, mãos de Beatriz erguendo o capirote e dois rostos iguais. O rosto permanece restrito a `vale_finale.gd`.

Contatos: [folhas principais](v38-capturas/01-chefe-contato.png), [quatro estados e gota](v38-capturas/02-estados-contato.png), [closes](v38-capturas/03-closes-contato.png). Capturas: [estado inicial](v38-capturas/08-chefe-estado-0.png), [terceira queda](v38-capturas/08-chefe-estado-3.png), [última queda](v38-capturas/08-chefe-estado-4.png), [ida](v38-capturas/10-transformacao-ida.png), [volta](v38-capturas/11-transformacao-volta.png), [elmo](v38-capturas/18-revelacao-7.png), [mãos](v38-capturas/18-revelacao-14.png), [rostos](v38-capturas/18-revelacao-18.png).

Verificado: recursos, seleção de cada aparência, máscara, coleta, pesos dos closes, 33 verificações da luta e regras da história. Falta uma partida humana completa para avaliar dificuldade, continuidade perceptiva dos movimentos e ritmo das falas. As capturas são dirigidas por script.

## 2. Vale pintado em peças

Céu opaco, três desfiladeiros transparentes, seis forcas, oito figuras/gaiolas, quatro árvores, piso e seis quadros de corvo. As rochas e o piso se repetem com espelhamento alternado para casar exatamente a borda da textura. A margem superior do piso foi recortada tecnicamente para a superfície pintada coincidir com a colisão.

As profundidades de paralaxe continuam em 0,22 / 0,40 / 0,62. As peças suspensas continuam com o pêndulo amortecido, vento e impulso de golpes. `set_mood` escurece a cena conforme caem as placas. Permanecem **90 cinzas e 26 brasas**, além da névoa.

[Contato das camadas](v38-capturas/04-vale-contato.png), [vale calmo](v38-capturas/07-vale-calmo.png), [vale escurecido](v38-capturas/09-vale-culpa.png). Importação, dimensões, partículas, impulso e enquadramento foram conferidos. Não houve medição de FPS em outros computadores nem avaliação humana de visibilidade durante uma luta completa.

## 3. Vida nas salas e monumentos

Oito pendentes, seis quadros de chama, seis de fumaça e três monumentos com base e camada móvel. A luz das lamparinas é local e limitada às próximas da câmera. As rotas e colisões não mudam. [Localização e funcionamento dos monumentos](monumentos.md), com [contato das peças](v38-capturas/05-vida-contato.png) e capturas das três salas.

Dimensões, transparência e renderização foram conferidas. Os movimentos de cabeças e relicário são projeções 2D; falta verificar sua leitura em uma navegação humana sem pausa.

## 4. Nove criaturas propostas

[Fichas, salas, avisos e contra-jogo](fichas/fichas-goya.md), com [contato geral](v38-capturas/06-fichas-contato.png). São desenhos originais baseados nos temas do briefing. Glutão, Disciplinantes e Viúva receberam as adaptações visuais descritas no documento. Não há crianças.

**A aprovação do autor vem antes da animação.** Não foram adicionadas novas inteligências, colisões ou efeitos de vida máxima. O jogo mantém os inimigos atuais. A validação desta etapa é visual e de recursos; o combate das propostas ainda não foi implementado nem testado.

## 5. Efeitos do Godot

`combat_visuals.gd` concentra os efeitos locais. `dissolve_ash.gdshader` preserva a cor do ator, respeita a região do quadro e dissolve de baixo para cima. A altura opaca de cada quadro é armazenada em cache, para um corpo deitado não desaparecer antes de a dissolução atravessá-lo.

O rastro `Line2D` guarda amostras por 0,12 s, afina pela curva de largura, fica vermelho em golpes fortes e dourado no contra-ataque. Espada e lança têm comprimentos próprios; não altera alcance nem dano. O aparo recebe `PointLight2D` suave, desativado em reduzir pulsos. O `CanvasModulate` existente continua separado do HUD. Criaturas paradas respiram por `Tween` de +1,2% na altura; ataques interrompem essa deformação. A câmera recebe deslocamento na direção do golpe, mantendo a opção de reduzir tremores.

Evidências: [espada](v38-capturas/12-rastro-penitente.png), [lança](v38-capturas/12-rastro-beatriz.png), [luz do aparo](v38-capturas/13-luz-aparo.png), [reduzir pulsos](v38-capturas/14-reduzir-pulsos.png), [cinzas](v38-capturas/15-cinza-morte.png), [progressão das cinzas](v38-capturas/20-cinza-progressao.png), [direção do impacto](v38-capturas/16-impacto-direcional.png), [respiração](v38-capturas/19-respiracao.png). `v38_effects_smoke.gd` confere o comportamento e `v38_art_smoke.gd` confere os recursos. Falta avaliação humana da sensação dos efeitos e desempenho em GPUs diferentes.

## Validação e limites da entrega

Engine: **Godot 4.6.3**, a mesma pedida no briefing. [Resultado de todas as suítes](v38-testes.json). Capturas no renderizador Compatibility/OpenGL, Intel Iris Xe, com dados de salvamento isolados dos do jogador. O teste visual é reproduzível com `tests/v38_visual_review.gd` e a variável `LACRIMAE_REVIEW_DIR` apontando para uma pasta de saída.

Os testes antigos que enumeram efeitos voltaram a passar após o componente novo deixar de usar `actor` como nome de uma referência a objeto: esse campo é a identificação textual dos atlas no projeto. Alguns testes ainda avisam sobre recursos retidos ao encerrar; esses avisos de encerramento estão indicados no relatório, sem serem apresentados como erro de jogo resolvido. Não há ensaio humano nem exportação executável validada nesta rodada.

`amb_vale.wav` veio no pacote. Os nove sons finais e as duas músicas opcionais do [pedido ao Argon](prompts-sons-vale-argon.md) não vieram: os pontos continuam prontos, com o comportamento de ausência definido no código recebido. Nenhum desses onze arquivos foi inventado nesta integração. Os WAVs anteriores foram preservados; [inventário técnico](v38-audio.json). Não houve escuta humana ou medição perceptiva de zumbido.

Foram removidas chamadas duplicadas de retirada da lâmina e de queda do corpo no código recebido, para tocar uma vez por evento. A queda usa armadura para Guardião, Devorador, Duelista e Carregador; os demais usam carne. Os arquivos de áudio não foram modificados.
