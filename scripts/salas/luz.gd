@tool
extends PointLight2D
## Luz que tremula de leve (main.gd _update_lights). Fica em scenes/salas/luz.tscn: no grupo Luzes de uma
## sala é uma luz de cenário (a do fundo do abismo, a dos portões); como filha de uma vela, de um altar ou de
## um ponto (a relíquia), é a luz dele. Cor, energia e tamanho são os da própria PointLight2D: a energia é a
## média em torno da qual a luz tremula, e texture_scale 1 equivale a 256 unidades de diâmetro.
## No editor a luz já aparece acesa sobre a pintura; o contorno marca até onde ela chega.

const Sala = preload("res://scripts/salas/sala.gd")

func _draw() -> void:
	if not Sala.visivel(): return
	draw_arc(Vector2.ZERO, 128.0 * texture_scale, 0, TAU, 48, Color(color, 0.6), 2.0)
	draw_circle(Vector2.ZERO, 6.0, color)
