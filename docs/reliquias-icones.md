# Ícones de relíquias

`assets/ui/reliquias.png`: RGBA1536×1024, grade6×4 de256px. Cada peça respeita margem de24px medida no conteúdo com alfa>40. A versão bloqueada ocupa a célula correspondente duas linhas abaixo, com aparência apagada; não é um ícone de cadeado diferente.

| Índice ativo | Nome | Índice bloqueado |
|---:|---|---:|
|0|Terço|12|
|1|Prego|13|
|2|Sino pequeno|14|
|3|Sudário|15|
|4|Vela|16|
|5|Lágrima de cera|17|
|6|Cálice|18|
|7|Chave enferrujada|19|
|8|Medalhão de sol|20|
|9|Corda cortada|21|
|10|Fragmento de vitral|22|
|11|Dente de bronze|23|

Arte original seguindo o bronze, os espinhos e os tecidos dos relicários atuais. São ícones, sem atributos, preços ou regras de equipamento definidos. A lágrima e o dente têm tratamento de relicário simbólico; decidir na integração se precisam de um material mais literal. Não foram criadas12relíquias funcionais.

`tests/v18_art_check.py` confere24células ocupadas, margem, tamanho, alfa e brilho menor em cada par bloqueado. Essas medidas não demonstram reconhecimento instantâneo em tamanho de HUD; é necessário conferir a32/48/64px e escrever o estado, sem depender só de cor. Os pares foram gerados como versões da mesma peça, mas não são cópias pixel a pixel. Não usar diferença de brilho como única indicação de bloqueio.
