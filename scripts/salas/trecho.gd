@tool
extends Node2D
## Começo de um trecho da Cidade: daqui (posição x do nó) até o próximo trecho, o título de área é "nome".
## Só a Cidade é lida pelo jogo (main.gd); nas outras salas o título é o nome da sala.

const Sala = preload("res://scripts/salas/sala.gd")

@export var nome := "":
	set(valor):
		nome = valor
		queue_redraw()

func _draw() -> void:
	if not Sala.visivel(): return
	var cor := Color(0.85, 0.8, 0.95)
	draw_line(Vector2(0, -900), Vector2(0, 0), Color(cor, 0.7), 2.0)
	var fonte := ThemeDB.fallback_font
	draw_string_outline(fonte, Vector2(8, -860), nome, HORIZONTAL_ALIGNMENT_LEFT, -1, 22, 6, Color(0, 0, 0, 0.85))
	draw_string(fonte, Vector2(8, -860), nome, HORIZONTAL_ALIGNMENT_LEFT, -1, 22, cor)
