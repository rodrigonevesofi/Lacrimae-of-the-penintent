# Polimento da v39 — pés no chão, pedra da sala, espada e dupla

Revisão feita depois do primeiro vídeo dos cenários vivos, em que os personagens pareciam flutuar e havia plataformas e objetos soltos. Cada item abaixo foi conferido em capturas ampliadas, antes e depois.

## 1. Personagens no chão
**O defeito:** o chão de colisão não coincidia com o piso pintado. Quase todas as salas usavam a mesma proporção (86% da altura da pintura), mas o piso desenhado fica em alturas diferentes. No **Claustro** e no **Campanário** os personagens andavam cerca de 80 a 170 unidades **acima** do piso, na altura do encosto dos bancos e do meio da escada. Nas outras salas pisavam na beirada da calçada.

**A correção:** medi em cada pintura onde começa e termina o piso e pus o chão de colisão no meio dele (`"ground"` em `scripts/act_one_layout.gd`).

| Sala | Antes | Agora | Piso pintado |
| --- | --- | --- | --- |
| Ossuário | 0,860 | 0,880 | 0,86 a 0,90 |
| Cisterna | 0,860 | 0,845 | 0,825 a 0,865 |
| Claustro | 0,860 | **0,940** | 0,925 a 0,95 |
| Campanário | 0,860 | **0,957** | 0,945 a 0,97 |
| Arquivo | 0,756 | 0,735 | 0,66 a 0,757 |
| Abrigo | 0,800 | 0,795 | 0,72 a 0,84 |
| Nave | 0,860 | 0,848 | 0,835 a 0,862 |
| Terraço | 0,860 | 0,835 | 0,805 a 0,86 |
| Pátio | 0,860 | 0,852 | 0,835 a 0,87 |

Também: **sombra de contato** sob inimigos e sob o chefe (antes só os dois protagonistas tinham), e um **rodapé de pedra** que continua a pintura para baixo nas salas em que ela termina antes da borda da tela.

## 2. Plataformas e objetos
- **Galerias:** eram lajes cinzentas com dois triângulos chapados, da mesma cor em todas as salas. Agora têm **a cor do piso de cada sala** (medida na pintura), **mísulas em degraus** e **sombra projetada na parede**.
- **Alvenaria, portas, altares e monumentos:** tomam a cor da pedra da sala e ganharam sombra de contato.
- **Portas no alto:** cinco portas ficavam com parte da largura no ar. Cada uma ganhou **soleira** (piso real, em que se pode pisar) em toda a largura.
- **Portão das arenas:** o pé do portão fechado era desenhado 60 unidades abaixo do chão. Agora apoia no piso.
- **Primeiro plano:** as silhuetas escuras ficaram menores, mais raras e só no terço de cima da tela; saíram o rosário e os ex-votos, que no meio da tela pareciam borrões.

## 3. A espada e as folhas do Penitente
- **Empunhadura:** a espada parada e na corrida era desenhada **na frente** da mão e segura pelo meio do cabo, então a guarda ficava solta, adiante do punho. Agora é desenhada **atrás do corpo** (o punho fecha por cima do cabo) e segura **junto à guarda**.
- **Sujeira nos quadros:** as folhas tinham pontos soltos do recorte do fundo e **pedaços de arco de golpe e de lâmina que invadiam o quadro vizinho**, aparecendo cortados durante o ataque. `tools/polir_folhas.py` apaga isso em 20 folhas do Penitente e de Beatriz. Sangue não é apagado.
- **Lâminas cortadas na borda da célula:** onde havia espaço, o quadro foi **reencaixado**: o pedaço que tinha ido para o vizinho voltou, o desenho foi deslocado para caber, e `clips.json` guarda o deslocamento (`"deslocamentos"`) para o jogo desenhar no lugar de antes.
- **Cor:** as folhas de combate eram cerca de **40% mais claras** e mais rosadas que a de movimento, e o Penitente "acendia" ao aparar ou golpear. Foram igualadas (luminosidade de 80 a 104 para 74). Beatriz também (de 107 a 111 para 96).

## 4. Beatriz
**Ela já joga junto com o Penitente**; no primeiro vídeo ela não aparecia porque as capturas automáticas rodavam sem a segunda personagem. No jogo normal ela entra desde o início, controlada pelo jogo, e **o primeiro comando da segunda pessoa assume o controle** (F4 devolve). O que mudou agora: **teclas para notebook sem teclado numérico** (no ABNT2: `.` atacar, `,` esquivar, `;` aparar, `Ç` golpe carregado, `~` curar, `´` interagir, `[` doar sangue), além das setas, do teclado numérico e do segundo controle, que continuam valendo.

## O que foi verificado
- `tests/v39_polimento_smoke.gd`: 56 verificações (chão dentro do piso pintado em nove salas, soleira sob toda porta alta, deslocamentos, espada atrás do corpo e junto à guarda, Beatriz entrando e sendo assumida, teclas fora do numérico).
- `tests/folhas_limpas_check.py`: 29 verificações (nenhuma sujeira restante, cor igualada).
- `tests/v39_polimento_review.gd` grava a espada quadro a quadro e os pés de cada sala; as capturas foram olhadas ampliadas.

## O que continua errado e depende de arte nova
- **Dois quadros do primeiro golpe** (a estocada e o seguinte) foram pintados com a lâmina saindo da célula. A estocada ganhou ponta, mas a lâmina ficou curta; o seguinte ainda termina cortado no canto.
- **A lança de Beatriz** é mais comprida que a célula em vários quadros e aparece cortada nas pontas.
- **As portas** continuam sendo um módulo colado sobre a pintura; a cor aproxima, mas o recorte ainda se nota.
- **As galerias** seguem um traçado que não acompanha a arquitetura pintada.
- Nada disto foi julgado por uma pessoa jogando.
