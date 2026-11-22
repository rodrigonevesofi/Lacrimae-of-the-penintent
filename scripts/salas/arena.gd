@tool
extends Node2D
## Combate com saídas bloqueadas: as extremidades x0 e x1 se fecham até a última leva cair.
## A posição do nó é a extremidade esquerda (x0) no piso; "largura" vai até x1.
## Cada filho é uma leva (Node2D) com MarcadorInimigo dentro, na ordem em que entram.

@export var id := ""
@export var largura := 800.0:
	set(valor):
		largura = valor
		queue_redraw()
@export var recompensa := 200

func _draw() -> void:
	if not Engine.is_editor_hint(): return
	var cor := Color(0.95, 0.6, 0.2)
	draw_line(Vector2(0, -260), Vector2(0, 0), cor, 4.0)
	draw_line(Vector2(largura, -260), Vector2(largura, 0), cor, 4.0)
	draw_string(ThemeDB.fallback_font, Vector2(8, -236), "arena %s · %d levas · %d lágrimas" % [id, get_child_count(), recompensa], HORIZONTAL_ALIGNMENT_LEFT, -1, 18, cor)
