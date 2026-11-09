> Documento recebido do autor, produzido no apoio com Claude. É referência de planejamento; as observações foram conferidas e corrigidas, quando necessário, em [comparativo-blasphemous-v19.md](comparativo-blasphemous-v19.md). As duas tarefas explícitas deste envio estão em [v19-entrega-codex.md](v19-entrega-codex.md).

# Tarefas para o Codex — referências de Blasphemous (partir da v17)

Crie apenas arquivos novos. Não edite scripts do jogo nem `clips.json`. Leia `docs/referencia-blasphemous.md`. Descreva em `docs/` o que criou e o que não foi validado.

## Tarefa 1 — Guardião colossal (atlas e close)
O Guardião dos Sinos precisa parecer de 3 a 4 vezes a altura do Penitente.
- `assets/animation/guardiao_colosso.png`: 2048 × 2048, RGBA, grade 4 × 4 de 512 × 512, personagem de perfil virado para a direita, pés em y = 500. Corpo fundido ao sino de bronze, mesmos traços das ilustrações de `assets/boss/`. Quadros: 0-3 repouso, 4-7 caminhada pesada, 8-11 ataque (0-1 preparação, 2-3 golpe), 12-13 dano, 14-15 queda.
- `assets/boss/guardiao_rosto.png`: 1920 × 1080, close extremo do que seria o rosto sob o sino (metade da face visível, bronze rachado, uma lágrima de metal), paleta curta, para a abertura da luta.

## Tarefa 2 — Efeitos de golpe grandes
`assets/animation/efeitos_golpe.png` (1536 × 1024, RGBA, grade 6 × 4, 256 × 256): arco de corte vermelho e branco em meia-lua (6 quadros), estrela de impacto cor ciano e branca (6), silhueta branca de clarão sobre o inimigo (6), poça de sangue que se espalha no chão (6). Sem texto.

## Tarefa 3 — Close-ups de pixel art para encontros de história
Seis retratos, `assets/close/close_01.png` a `close_06.png` (512 × 512, opaco): rostos humanos em close extremo, expressão intensa (grito, choro, olhar vazio, boca costurada, olho único, mãos sobre o rosto), em pixel art com sombreamento pontilhado, paleta curta, fundo escuro. Sem crianças e sem sangue excessivo.

## Tarefa 4 — Fonte e moldura de lore
`assets/ui/moldura_lore.png` (1280 × 160, RGBA): faixa horizontal escura com moldura dourada fina, cantos em espinhos, para o texto de lore no rodapé. Entregue também `docs/fonte-gotica.md` indicando uma fonte gótica livre (licença aberta, tamanho legível a 18 px) compatível com a Godot, sem incluir o arquivo.

## Tarefa 5 — Inimigo com adereço que quebra
`assets/animation/carregador.png` (1536 × 1024, RGBA, grade 6 × 4, 256 × 256): criatura magra que carrega às costas um caixão de pedra. Quadros: 0-5 caminhada, 6-11 ataque (investida com o caixão à frente), 12-14 dano, 15-17 o caixão se parte e cai, 18-23 a criatura desprotegida em caminhada rápida.
