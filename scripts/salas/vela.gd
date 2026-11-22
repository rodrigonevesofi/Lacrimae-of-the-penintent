@tool
extends Node2D
## Vela no chão da Cidade. Vale a posição x: world_art.gd a desenha no chão. Uma Luz filha
## (scenes/salas/luz.tscn) é a chama que ilumina em volta; na Cidade, uma vela a cada três tem a sua.

const Sala = preload("res://scripts/salas/sala.gd")

func _draw() -> void:
	if not Sala.visivel(): return
	draw_rect(Rect2(-3, -16, 6, 16), Color("e8dcc0"))
	draw_circle(Vector2(0, -20), 4.0, Color(1.0, 0.68, 0.38))
