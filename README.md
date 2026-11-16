# Lacrimae of the Penitent

Jogo de ação e exploração 2D, sombrio e gótico, sobre **culpa e fé**. Feito no Godot 4.6.

Um guerreiro sem memória desperta num túmulo. A inscrição diante dele o acusa de ter condenado milhares de pessoas. Ao lado de Beatriz, uma carrasca que nunca olhou o rosto de quem feriu, ele atravessa uma cidade que não consegue enterrar os seus mortos para descobrir o que fez.

> A culpa não queria castigo. Queria ser olhada.

![O Confessionário](docs/confessionario-tela.png)

## Como jogar

1. Instale o **Godot 4.6.3 Standard** (não precisa da versão .NET).
2. No Godot, escolha **Importar** e abra o arquivo `project.godot` desta pasta.
3. Espere a importação terminar e aperte **F5**.

No Windows, também dá para usar `Jogar-Windows.cmd`.

## O que há no jogo

- **Onze lugares** interligados: a Cidade da Penitência, seis salas do percurso principal, três salas secretas e o Vale dos Flagelados.
- **Dois personagens jogáveis ao mesmo tempo:** o Penitente (espada) e Beatriz (lança). Beatriz luta sozinha ou nas mãos de uma segunda pessoa.
- **Combate:** combo de três golpes, golpe carregado, golpe descendente, aparo com contra-ataque, esquiva e execuções.
- **Dois chefes:** o Guardião dos Sinos e o Flagelado.
- **Dezessete criaturas**, muitas inspiradas nas Pinturas Negras de Goya, cada uma com aviso, ataque e abertura próprios.
- **Confessionário com IA:** um personagem que responde às perguntas de quem joga (veja abaixo).
- **História com começo, meio e fim**, com uma cutscene de revelação no final.
- Altares para salvar, penitências equipáveis, mapa, trilha sonora com coro e cenários animados.

## Controles

| Ação | Teclado | Controle |
|---|---|---|
| Mover | A / D | Analógico ou direcional |
| Pular (S + pulo desce de uma galeria) | Espaço ou W | A |
| Atacar (combo de 3) | J ou X | X |
| Golpe carregado (segurar e soltar) | I | RT |
| Golpe descendente | S + J no ar | ↓ + X no ar |
| Aparar (golpes com anel dourado) | L | RB |
| Esquivar | K ou Shift | B |
| Interagir, orar, executar | E | Y |
| Curar | F | LB |
| Penitência (com a culpa acima da metade) | Q | LT |
| Doar sangue / levantar a parceira | H | ↑ |
| Confessionário (fora de combate) | C | Segurar Y |
| Mapa | TAB | Back |
| Pausa | Esc | Start |

No altar: **E** ora (salva, cura e traz os inimigos de volta), **R** oferece lágrimas por mais vida, **V** troca de penitência.

Outras teclas: **M** som, **F11** tela cheia, **P** reduz clarões e tremores, **F6** liga ou desliga os cenários animados (use se o jogo ficar lento).

### Segunda pessoa (Beatriz)

O primeiro comando da segunda pessoa assume Beatriz; **F4** devolve o controle ao jogo.

- **Teclado numérico:** setas movem, ↑ pula, **1** ataca, **3** esquiva, **4** apara, **5** golpe carregado, **6** cura, **0** doa sangue, **Enter** interage.
- **Notebook sem teclado numérico:** **.** ataca, **,** esquiva, **;** apara, **Ç** golpe carregado, **~** cura, **´** interage, **[** doa sangue.
- **Segundo controle:** os mesmos botões do primeiro.

## O Confessionário (IA)

A tecla **C**, em qualquer lugar e fora de combate, abre o Confessionário. O jogador escreve uma pergunta, ou escolhe uma das perguntas prontas, e o **Confessor** responde no tom do jogo: explica controles, dá pistas de caminho, dá dicas de combate e reconta a história já descoberta, sem entregar o final.

O Confessor é um modelo de linguagem (Gemini) que recebe, a cada pergunta, o estado real da partida: onde o jogador está, o que falta fazer, quantas vezes morreu e onde.

Para ligar a IA:

1. Crie uma chave gratuita em <https://aistudio.google.com/apikey>.
2. Copie `ia_local.cfg.exemplo` como `ia_local.cfg` e cole a chave.
3. Jogue e aperte **C**.

**Sem chave ou sem internet o Confessionário continua funcionando**, com respostas prontas por assunto. O rodapé do painel mostra quem respondeu. O arquivo da chave fica fora do repositório. Detalhes em [docs/confessionario.md](docs/confessionario.md).

## Para avaliar

- **F3** abre o modo de desenvolvimento: ↑/↓ escolhem a sala, Enter transporta, **B** vai ao chefe, **G** liga a invencibilidade e **N** o voo.
- [Guia de apresentação](docs/guia-de-apresentacao.md): um roteiro de dez minutos para mostrar o jogo.
- [Documentação do jogo](docs/documentacao/) e [pranchas de conceito](docs/pranchas/).

## Como foi feito

Projeto acadêmico de Rodrigo. Código em GDScript, com testes automáticos em `tests/`.

O projeto usou ferramentas de IA como apoio, sob direção do autor: Claude e Codex (código, integração, testes e documentação), geração de imagens e Argon (arte e efeitos sonoros), Lyria (trilha) e Flow/Veo (clipes da cutscene). A história, as decisões de design e a aprovação de cada peça são do autor. Nenhuma arte, código ou personagem de outro jogo foi copiado; Blasphemous foi referência de clima e de gênero.

## O que vem depois

O jogo termina com uma verdade e deixa uma pergunta. O Penitente descobre **de quem eram as mãos** que fecharam os portões. Falta saber **de quem foi a ordem**. Os portões levam à Grande Basílica.
