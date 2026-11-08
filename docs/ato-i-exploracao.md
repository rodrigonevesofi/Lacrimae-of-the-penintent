> Atualizado na v09: o Ato I agora tem dez locais, quinze passagens e nove altares. Veja [expansao-v09.md](expansao-v09.md). O texto abaixo descreve a base anterior (sete locais).

# Ato I — exploração e interface

A versão anterior era um corredor de 4.800 unidades. Os testes daquela versão verificavam funcionamento; não demonstravam exploração, duração adequada ou acabamento comparável a Blasphemous.

## Estrutura atual

Sete locais ocupam 18.600 unidades horizontais de salas, além das galerias verticais. As posições globais ficam separadas para impedir colisões entre salas; entradas ligam os ambientes com uma breve transição.

| Local | Função |
| --- | --- |
| Cidade da Penitência | Túmulo, espada, Iria, memorial, ponte rompida e arena do Guardião |
| Ossuário dos Sem Nome | Acesso inferior à cisterna e desvio superior para o abrigo |
| Cisterna dos Nomes | Primeira corrente, escadaria elevada e atalho para o outro lado da ponte |
| Claustro dos Votos | Caminho inferior ao campanário e galeria superior ao arquivo |
| Campanário da Vigília | Relíquia de salto duplo, subida em dois sentidos, segunda corrente e retorno ao pátio |
| Arquivo das Confissões | Registro opcional, resposta de Iria e passadiço para o meio do campanário |
| Abrigo das Cinzas | Boneca, frasco curativo adicional e retorno alternativo à cisterna |

Há dez conexões, três delas com tranca aberta por dentro, seis altares e 26 inimigos comuns distribuídos entre as salas, além do Guardião. Os inimigos das outras salas não perseguem o jogador através de transições.

O acesso ao Guardião exige liberar as duas correntes. Após a vitória e a memória, é possível revisitar os locais. Encerrar a vigília junto aos portões é uma escolha explícita; a campanha não passa para o Ato II.

## Descobertas

A boneca fica num desvio do abrigo e pode ser entregue ao memorial da cidade. O arquivo contém uma lista de famílias que muda uma fala de Iria. O vaso aumenta os frascos curativos de três para quatro. Uma inscrição opcional no ossuário conta a história de um lugar vazio.

O mapa (TAB) registra locais descobertos, o lugar atual, ligações, atalhos abertos, correntes e vestígios. S + Espaço permite descer pelas galerias de passagem única. Vida, moeda e culpa não são restauradas ao atravessar portas. Oração e ofertas têm as mesmas regras nos altares das diferentes salas.

## Arte e HUD

Quatro fundos originais foram acrescentados para ossuário, cisterna, claustro/arquivo e campanário; o abrigo compartilha a arquitetura funerária do ossuário. O piso e as plataformas continuam coincidindo com as colisões. Túmulo, altar, nicho de inscrição, entrada, roda de corrente e memorial têm arte própria em vez das formas geométricas anteriores.

A interface usa um selo de lágrima rubra, armações de bronze e espinhos para as barras, frascos de vidro, contador em relicário, moldura alada do chefe e veludo escuro para diálogos, equipamento, pausa e cartografia. As informações importantes continuam sendo preenchimentos e textos legíveis; ornamentos não substituem a leitura dos estados.

## O que a validação prova

`tests/exploration_smoke.gd` percorre os sete locais com entradas, movimento, saltos e descida reais. Verifica os desvios superiores, as duas correntes, os três atalhos, os objetos, a entrada da arena e o salvamento. O teste suspende o combate e avança diálogos: sua rota de aproximadamente 57 segundos não é uma estimativa de duração de uma partida humana.

`tests/checkpoints_smoke.gd` verifica oração, morte e continuação no campanário, recuperação de dados, limites da câmera, frascos, congelamento de projéteis no mapa e recursos da interface. Os testes anteriores de combate, animações, oração, culpa e conclusão do capítulo continuam ativos.

A revisão visual gravada tem cortes entre alguns locais e demonstra percursos de plataformas com os controles do jogador. Não é uma partida integral nem uma comparação de qualidade com Blasphemous. Duração humana, dificuldade e interesse por cada descoberta ainda precisam de sessões de teste com jogadores. Esta entrega amplia e refina o Ato I; não declara a campanha ou o ato definitivamente finalizados.
