@tool
extends Node2D
## Vestígio coletável (item, relíquia ou inscrição que se recolhe com E). A posição do nó é onde ele fica.

const Sala = preload("res://scripts/salas/sala.gd")

## Identificador único, guardado no salvamento quando o vestígio é recolhido.
@export var id_vestigio := ""
@export var nome := "":
	set(valor):
		nome = valor
		queue_redraw()
@export_multiline var texto := ""
## Lágrimas ganhas ao recolher. Negativo: o vestígio não dá lágrimas.
@export var recompensa := -1
## Relíquia (Cálice de Sangue, Espinho da Ira): aplica o efeito descrito no texto.
@export var reliquia := false

func _draw() -> void:
	if not Sala.visivel(): return
	var cor := Color("ffd27f") if reliquia else Color("6fb8ff")
	draw_circle(Vector2(0, -20), 10.0, Color(cor, 0.85))
	draw_arc(Vector2(0, -20), 10.0, 0, TAU, 20, Color.BLACK, 2.0)
	var fonte := ThemeDB.fallback_font
	draw_string_outline(fonte, Vector2(-150, -38), nome, HORIZONTAL_ALIGNMENT_CENTER, 300, 15, 5, Color(0, 0, 0, 0.85))
	draw_string(fonte, Vector2(-150, -38), nome, HORIZONTAL_ALIGNMENT_CENTER, 300, 15, cor)
