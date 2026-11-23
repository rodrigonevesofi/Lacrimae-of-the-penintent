@tool
extends Node2D
## Inscrição de lore lida com E diante dela. Por enquanto só as da Cidade são lidas pelo jogo (main.gd):
## vale a posição x; o aviso aparece acima do chão da Cidade.

const Sala = preload("res://scripts/salas/sala.gd")

@export var titulo := "":
	set(valor):
		titulo = valor
		queue_redraw()
@export_multiline var texto := ""

func _draw() -> void:
	if not Sala.visivel(): return
	var cor := Color("d9c7a0")
	draw_rect(Rect2(-14, -60, 28, 60), Color(cor, 0.35))
	draw_rect(Rect2(-14, -60, 28, 60), cor, false, 2.0)
	var fonte := ThemeDB.fallback_font
	draw_string_outline(fonte, Vector2(-150, -70), titulo, HORIZONTAL_ALIGNMENT_CENTER, 300, 16, 5, Color(0, 0, 0, 0.85))
	draw_string(fonte, Vector2(-150, -70), titulo, HORIZONTAL_ALIGNMENT_CENTER, 300, 16, cor)
