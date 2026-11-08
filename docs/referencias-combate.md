# Referências de combate — Ato I

Pesquisa em 7 de novembro de 2026. Este documento distingue observação de vídeo, diagnóstico do código e propostas de direção. Não declara movimentos propostos como implementados. O cânone de [campanha.md](campanha.md) prevalece; as propostas não ampliam a entrega para outros atos.

## Fontes e acesso

| Fonte | Acesso nesta pesquisa | Uso permitido pela evidência |
| --- | --- | --- |
| Vídeo anexado pelo autor: `/workspace/attachments/ea76543d-23be-4a41-83fe-bf490ea59ea6/videoplayback.mp4` | Arquivo local aberto e quadros inspecionados. 640 × 360, 30 quadros/s, duração 120,116825 s. Cartelas finais identificam Blasphemous, The Game Kitchen e Team17. | Composição, silhuetas, trajetórias de espada e continuidade visível nos trechos abaixo. |
| [Trailer indicado pelo autor](https://www.youtube.com/watch?v=T3SxYMu5qGY) | URL consultada; proxy retornou 403. | Destino de referência, sem alegar que foi assistido pela web nem que é idêntico ao anexo. |
| [Blasphemous — Steam](https://store.steampowered.com/app/774361/Blasphemous/) | Consulta ao endpoint público `api/appdetails?appids=774361` retornou 403. | Destino para imagens e trailers oficiais; imagens da loja não foram vistas nesta pesquisa. |
| [Blasphemous 2 — Steam](https://store.steampowered.com/app/2114740/Blasphemous_2/) | Consulta ao endpoint público `api/appdetails?appids=2114740` retornou 403. | Referência complementar pendente, sem atribuir sua variedade de armas ao vídeo do primeiro jogo. |
| [Dante’s Inferno — EA](https://www.ea.com/games/dantes-inferno) | Consulta retornou 403. Nenhum vídeo de Dante’s Inferno foi fornecido localmente. | Referência pedida pelo autor; análise visual específica permanece pendente. Não foi feita medição de combos, câmera ou impacto desse jogo. |

Uma segunda tentativa de consultar Team17, The Game Kitchen, o CDN Steam e Wikipédia **não chegou a executar**: a revisão automática de aprovação falhou por limite de uso. Isso é diferente dos 403 das consultas anteriores e não constitui avaliação de que consultar as páginas seria inseguro. Não houve tentativa de contornar a revisão. O anexo local permitiu concluir a parte observável de Blasphemous.

Identificação reproduzível do anexo, SHA-256: `5a9febf01948cc3230892bd83197ee0c8d11eaae0c661394cd3d2b4ba34058c9`.

Foram examinadas uma prancha geral amostrada a cada cinco segundos e pranchas dos trechos 43–46 s (10 amostras/s), 63–67 s (6 amostras/s) e 64–65 s (todos os 30 quadros). Arquivos de inspeção temporários: `/tmp/lacrimae-reference/overview.jpg`, `combat-43-46.jpg`, `combat-63-67.jpg` e `attack-64-65.jpg`. São instrumentos de análise, não assets do jogo. Nenhum sprite, áudio ou quadro do jogo comercial foi incorporado ao projeto.

## O que os quadros mostram

Os intervalos são aproximados dentro do anexo. O material é um trailer editado, sem registro dos comandos; não permite deduzir regras internas de cancelamento, tamanho de hitbox ou duração exata de hitstop. Uma repetição de pose pode ser uma pose sustentada, cadência de animação ou edição.

| Trecho | Observação direta | Aplicação original em Lacrimae |
| --- | --- | --- |
| 43–44 s | Ataque durante salto contra alvo suspenso. Um arco claro marca a trajetória; faíscas amarelas e sangue localizam o contato. O corpo continua descendo depois do golpe. | Separar pose aérea de pose terrestre e manter o movimento do salto; o efeito acompanha o arco real da espada. |
| Cerca de 44,2–44,9 s | Deslocamento rápido em postura baixa num telhado, seguido de reposicionamento diante de um inimigo. | A saída da esquiva precisa ligar o centro de gravidade baixo à guarda, sem teleporte de mãos/arma. Não se pode provar pelo trailer que a esquiva cancela um ataque. |
| Cerca de 44,9–45,7 s | Cortes próximos ao inimigo alternam orientação da lâmina; corpo, braço, arco e reação do alvo mudam juntos. A montagem corta para outro encontro. | O segundo golpe aproveita a posição final do primeiro, com transferência de peso e trajetória de retorno. Não interpretar esse corte editorial como fim obrigatório do combo. |
| 63–65 s | Uma sequência no corredor varia ataques e elevação corporal; há diferença visível entre arco lateral e arco vertical. | Um finalizador descendente torna a terceira ação reconhecível pela silhueta e direção, mesmo sem efeitos. |
| Cerca de 64,2–64,6 s | Corpo e arma sobem; depois o personagem baixa e surge um arco branco alto. | Antecipação por joelho, ombro e mão; o arco maior aparece durante o movimento rápido, não durante toda a preparação. |
| Cerca de 64,6–64,9 s | O contato concentra faíscas no alvo e uma pose baixa do atacante; o efeito se dissipa em seguida. | Sustentar brevemente o impacto e terminar numa posição que permita recuperar a guarda. A pausa local deve preservar a entrada do jogador. |

A leitura depende de três camadas coordenadas: silhueta antes do golpe, trajetória durante o golpe e reação localizada no contato. Acrescentar partículas sem mudar as poses não produz a mesma variedade. A referência pode orientar clareza e ritmo; a espada relicária, a coroa enferrujada, o tecido gasto e o peso de Vespera sustentam a identidade própria.

## Diagnóstico do código antes desta revisão

Fotografia de `scripts/player.gd`, `scripts/actor_animation.gd` e `assets/animation/clips.json` no início da pesquisa. Outros agentes podem implementar mudanças depois deste registro.

| Área | Implementação observada | Consequência |
| --- | --- | --- |
| Ataques | `attack_a` / `attack_b`, seis desenhos por clipe; ambos duram `ATTACK_TIME = 0.42`. | Dois desenhos de golpe existem, mas compartilham cadência. |
| Janela ativa | `int(progress * 6)` nos índices 2 e 3: aproximadamente 0,14–0,28 s. | Antecipação, contato e recuperação já estão separados no código. |
| Contato | Retângulo de 86 × 66 unidades, mesmo nos dois golpes; dano 20/26 antes do multiplicador. | A diferença mecânica entre golpes é basicamente dano. Não há alcance próprio para um corte vertical ou estocada. |
| Encadeamento | `combo = 1 - combo`; novo ataque e esquiva aceitos a partir de `5/6`, cerca de 0,35 s. | Há ligação no último sexto; porém a alternância persiste mesmo após longa pausa, sem reinício explícito de uma cadeia. |
| Entrada | Buffer de ataque 0,20 s, esquiva 0,16 s. | Melhora o comando antecipado; um comando feito cedo demais expira antes da janela final. |
| Pausa de impacto | 45 ms no atacante e no alvo atingido; a física retorna antes de capturar `just_pressed`. | Existe sensação de impacto, mas comandos pressionados e soltos durante a pausa podem se perder. |
| Ar | Estado de ataque aceita movimento aéreo a 70% da velocidade de corrida; usa os mesmos clipes A/B. | Já é possível atacar no ar; falta linguagem corporal própria, não falta totalmente a ação. |
| Esquiva | 0,34 s a 540 unidades/s; retorna a `idle`. | Não há uma estocada dedicada ao sair da esquiva. |
| Animação | `select()` pausa a reprodução e escolhe o quadro por progresso normalizado. | Nos ataques manuais, o `fps: 12` do manifesto não determina a duração: quem manda é `ATTACK_TIME`. |

O código já possui seis poses por ação, acerto único por alvo por golpe, execução e pausa local. Portanto a evolução necessária é continuidade entre ações, variedade de silhuetas e preservação de comandos; não basta aumentar a velocidade de reprodução dos atlas.

## Proposta executável e prioridade

Todos os números abaixo são parâmetros iniciais de design de Lacrimae, **não medições dos jogos de referência**. Implementação e balanceamento devem ser registrados separadamente.

### P0 — entrada e cadeia de três golpes

1. Capturar ataque/esquiva antes do retorno por `hit_pause`; não consumir nem envelhecer o buffer durante a pausa. Continuar respeitando `controllable`, mensagens e estados cinematográficos. Um pressionamento durante o impacto deve sobreviver até a janela válida seguinte; segurar o botão não deve criar novos ataques infinitamente.
2. Substituir alternância permanente por índice de cadeia A → B → C. Reiniciar em A depois de uma janela curta de repouso, dano, execução ou morte. Proposta inicial de janela entre cadeias: 0,28 s. Não permitir saltar etapas com várias capturas no mesmo quadro.
3. Criar **Peso do Pranto**, terceiro golpe descendente: mão leva a espada para cima do ombro, joelhos cedem, lâmina cruza a frente do corpo, final baixo. A última pose de B prepara essa posição; a recuperação de C recompõe a guarda.
4. Caso a etapa atual exija preservar balanceamento, C pode inicialmente usar dano e hitbox de B, mantendo as janelas existentes. Isso entrega variedade visual sem declarar uma nova cobertura vertical. Uma mudança de alcance vem depois de validação com inimigos.

Desdobramento possível após essa primeira integração:

| Ação | Duração proposta | Preparação / contato / recuperação | Encadeamento proposto |
| --- | --- | --- | --- |
| A — abertura lateral | 0,34 s | 0–0,10 / 0,10–0,19 / 0,19–0,34 s | B após 72% da ação. |
| B — retorno diagonal | 0,37 s | 0–0,11 / 0,11–0,22 / 0,22–0,37 s | C após 70% da ação. |
| C — Peso do Pranto | 0,48 s | 0–0,17 / 0,17–0,29 / 0,29–0,48 s | Esquiva após 80%; terminar a cadeia antes de voltar a A. |

Se essas janelas forem adotadas, pose, janela ativa e duração precisam vir da mesma definição de movimento. Alterar apenas o tempo visual cria dano fora do arco. A esquiva continua uma escolha na recuperação; não sugerimos cancelamento universal da preparação.

### P1 — ligação com salto e deslocamento

- **Corte aéreo próprio:** iniciar com pernas recolhidas, braço em trajetória lateral curta, tecido atrasado pelo movimento; terminar em pose de queda. Conservar gravidade e controle horizontal já existentes. Não reiniciar velocidade vertical a cada golpe. Primeiro entregar silhueta correta; depois avaliar limite por salto, para não criar sustentação infinita acidental.
- **Estocada de saída da esquiva:** comando de ataque registrado perto do fim da esquiva leva a um passo curto com ponta alinhada ao alvo. Preparação baixa aproveita a pose de saída; recuperação exposta impede repetição invulnerável. Deve ter estado, dano e janela próprios se o alcance mudar. Não acumular invulnerabilidade da esquiva por toda a estocada.

### P2 — repertório posterior

Ataque descendente no ar, golpe carregado e defesa com contra-ataque exigem novas regras de contato e novas leituras de inimigos. Adiar até A/B/C e transições estarem estáveis. As execuções existentes continuam separadas: são encontros de curta duração com câmera dedicada, não substituem o ritmo normal da espada.

## Identidade e critérios de revisão

O Penitente das Lágrimas carrega o peso do próprio gesto: quadris e joelhos conduzem a espada, tecido e corrente chegam depois, o relicário permanece preso à arma. A lâmina deve conservar guarda, proporções, empunhadura e ancoragem ao pulso em cada desenho. Não redesenhar um elmo ou uma espada de Blasphemous; os símbolos narrativos continuam os já definidos pelo autor.

Hitstop sugerido: manter os 45 ms existentes nos cortes comuns até comparar uma gravação com e sem correção de buffer. Um finalizador poderia experimentar 55–65 ms somente após testar ritmo; essa faixa é proposta, não requisito. Evitar somar uma pausa completa para cada inimigo atingido no mesmo quadro. A música permanece independente da pausa local.

Revisão mínima de uma implementação:

- Gravar A → B → C dos dois lados, em chão plano e junto de uma parede; observar mão, pé de apoio e direção da lâmina nas transições.
- Pressionar e soltar ataque dentro dos 45 ms de impacto e verificar o próximo golpe na janela válida.
- Conferir ausência de dano na antecipação/recuperação e um único acerto por alvo em cada golpe.
- Interromper a cadeia com dano, morte, diálogo e execução; não deixar um golpe armazenado disparar ao retomar o controle.
- Saltar durante deslocamento, atacar e pousar; conferir continuidade do corpo e conservação da queda.
- Comparar sem arco/partículas: cada novo golpe precisa continuar reconhecível pela pose.

Não foram executados testes de jogabilidade por esta pesquisa. Os números históricos de testes em [animacoes-v04.md](animacoes-v04.md) pertencem à versão ali documentada e não validam automaticamente os movimentos propostos aqui.
