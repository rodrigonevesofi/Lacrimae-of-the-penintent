@tool
extends Node2D
## Altar de descanso. A posição do nó é o ponto dos pés de quem ora (no chão ou na plataforma).
## A ordem dos altares (Cidade primeiro, depois as salas na ordem do mapa e a ordem dos nós) é a ordem
## guardada no salvamento: acrescente altares novos no fim, sem reordenar os existentes.

const Sala = preload("res://scripts/salas/sala.gd")

@export var nome := "":
	set(valor):
		nome = valor
		queue_redraw()

func _draw() -> void:
	if not Sala.visivel(): return
	var cor := Color("f0c060")
	draw_circle(Vector2(0, -40), 18.0, Color(cor, 0.85))
	draw_arc(Vector2(0, -40), 18.0, 0, TAU, 24, Color.BLACK, 3.0)
	var fonte := ThemeDB.fallback_font
	draw_string_outline(fonte, Vector2(-150, -68), nome, HORIZONTAL_ALIGNMENT_CENTER, 300, 18, 5, Color(0, 0, 0, 0.85))
	draw_string(fonte, Vector2(-150, -68), nome, HORIZONTAL_ALIGNMENT_CENTER, 300, 18, cor)
