> A estrutura posterior de cinco atos, personagens e finais está em [campanha.md](campanha.md), que prevalece sobre as questões em aberto desta versão inicial.

# Lacrimae of the Penitent — referência narrativa

Fonte: história fornecida diretamente pelo usuário nesta conversa. Organização editorial do conteúdo recebido, sem acrescentar eventos ou definir finais. Este documento descreve requisitos narrativos; não significa que já estejam implementados no protótipo.

## O Reino de Vespera

Vespera acreditava que todo ser humano nascia carregando pecados herdados dos antepassados e que somente a penitência permitiria alcançar a absolvição. Durante séculos, a religião dominou o reino: sacerdotes ouviam confissões, monges dedicavam suas vidas ao sofrimento voluntário e peregrinos atravessavam terras devastadas em busca de um milagre.

Uma figura conhecida como A Primeira Mártir chorou lágrimas de sangue diante do altar de uma antiga catedral. Segundo os registros sagrados, essas lágrimas purificaram os pecados de centenas de pessoas. A Igreja declarou o acontecimento uma manifestação divina. As lágrimas passaram a ser consideradas a manifestação física da culpa humana. Assim nasceu a Ordem da Sagrada Absolvição.

## O Milagre das Lágrimas

A Ordem criou um ritual chamado Lacrimae Sacramentum para extrair a culpa dos fiéis. Pecadores confessavam seus atos diante de grandes altares e ofereciam suas lágrimas como sacrifício. Inicialmente, pessoas atormentadas encontravam paz, doentes relatavam curas e criminosos abandonavam suas antigas vidas.

Entretanto, as lágrimas retiravam a sensação de culpa sem apagar os atos cometidos. O sofrimento extraído permanecia armazenado sob a Grande Basílica, alimentando uma entidade formada pelas dores de milhares de pessoas.

Quando essa entidade começou a despertar, o milagre tornou-se maldição. Os mortos deixaram de descansar; fiéis sofreram mutações grotescas; monges fundiram-se aos instrumentos de penitência. Morrer já não significava o fim do sofrimento. Esse acontecimento ficou conhecido como O Grande Pranto.

## Premissa e temas

Em um mundo devastado pela fé distorcida, o sofrimento tornou-se devoção e a penitência é o único caminho conhecido para o perdão. Os conceitos centrais são culpa, pecado, penitência e perdão.

O jogador controla O Penitente das Lágrimas, também chamado apenas O Penitente: um guerreiro sem memórias e incapaz de descansar na morte, condenado a vagar por Vespera. Sua jornada envolve criaturas, figuras religiosas corrompidas e manifestações da própria culpa. Aos poucos, descobre que também foi responsável pela tragédia.

## Prólogo definido

O Penitente desperta dentro de um túmulo de pedra, nas profundezas de uma catedral abandonada. Seu corpo tem marcas de antigos rituais. Próxima à sua cabeça repousa uma coroa de metal enferrujado envolta em espinhos.

Ele não se lembra do próprio nome, de quanto tempo permaneceu morto ou do motivo pelo qual foi enterrado ali. Encontra uma espada fincada diante do túmulo e esta inscrição:

> Aquele que condenou milhares deverá carregar o peso de cada lágrima. Que sua morte seja negada até que sua culpa encontre repouso.

Cada derrota o devolve ao último altar de penitência, mantendo as marcas do sofrimento. O retorno é sua condenação.

## Segredo do protagonista — revelação gradual

O Penitente participou da criação do ritual que condenou Vespera. Seu objetivo original era libertar as pessoas do sofrimento, mas suas descobertas permitiram que a Igreja transformasse a culpa humana em ferramenta de poder.

Quando começou O Grande Pranto, recebeu a ordem de fechar os portões da cidade para impedir a propagação da maldição. Ele obedeceu, aprisionando milhares de inocentes, inclusive pessoas que havia jurado proteger.

Incapaz de suportar o peso do que fez, submeteu-se ao ritual da absolvição e entregou as próprias memórias. Sua culpa, porém, era grande demais para desaparecer.

Essa verdade pertence ao arco de descoberta do jogador. Não expor todos esses fatos no prólogo.

## Pontos ainda não definidos no material recebido

- Nome anterior do protagonista e identidade das pessoas que havia jurado proteger.
- Identidade e nome próprios da entidade sob a Grande Basílica.
- Relação entre A Primeira Mártir e A Mãe das Lágrimas, chefe existente no ZIP.
- Desfecho, escolhas finais e condições de perdão.
- Design visual do personagem: a imagem mencionada no chat de origem não ficou acessível.

## Diferenças em relação ao protótipo recebido

- A introdução de `scripts/main.gd`, em `_start_game`, diz que o protagonista desperta aos pés de uma santa de pedra. A abertura canônica exige o túmulo, a coroa, a espada e a inscrição.
- A fase já usa uma nave gótica e altares, mas a ambientação precisa apresentar Vespera, a Ordem, o Lacrimae Sacramentum e O Grande Pranto ao longo da exploração.
- Os textos de `lore` em `scripts/main.gd` precisam ser revisados à luz da participação do protagonista no ritual e do fechamento dos portões.
- A revelação e o final em `scripts/hud.gd`, função `_draw_ending`, devem ser avaliados antes de serem considerados canônicos. O material recebido não define um final.
- Culpa, penitência, retorno aos altares e perda/recuperação de lágrimas já existem como mecânicas no protótipo. A validação técnica anterior não substitui a avaliação da narrativa nem uma partida completa.

Na preparação inicial do ambiente, os scripts foram preservados. Após o usuário autorizar o início do jogo, o capítulo inicial passou a implementar o prólogo canônico, a espada para recolher e os textos revisados de exploração. O encerramento do capítulo é provisório e não define o desfecho da história. Os tópicos acima registram a comparação com o ZIP original.
