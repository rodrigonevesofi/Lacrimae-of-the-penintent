extends RefCounted
## Cenas dos efeitos de combate (scenes/efeitos/). Cada emissor guarda na cena tudo o que é fixo
## (textura, cores, gravidade, duração, material); quem cria só ajusta o que depende do golpe
## (quantidade, direção, força, posição) antes de adicionar à árvore e ligar "emitting".

const SANGUE_JATO = preload("res://scenes/efeitos/sangue_jato.tscn")
const SANGUE_PEDACOS = preload("res://scenes/efeitos/sangue_pedacos.tscn")
const SANGUE_NEVOA = preload("res://scenes/efeitos/sangue_nevoa.tscn")
const LAGRIMA_SANGUE = preload("res://scenes/efeitos/lagrima_sangue.tscn")
const GORE_JATO = preload("res://scenes/efeitos/gore_jato.tscn")
const GORE_CORTINA = preload("res://scenes/efeitos/gore_cortina.tscn")
const GORE_OSSOS = preload("res://scenes/efeitos/gore_ossos.tscn")
const GORE_MASSA = preload("res://scenes/efeitos/gore_massa.tscn")
const PLACAS_FLAGELADO = preload("res://scenes/efeitos/placas_flagelado.tscn")
const LAMINA_SANGUE = preload("res://scenes/efeitos/lamina_sangue.tscn")
