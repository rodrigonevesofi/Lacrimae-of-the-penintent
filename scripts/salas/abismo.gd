@tool
extends Node2D
## Vão no chão da Cidade (a ponte quebrada): ali não há chão de colisão e world_art.gd pinta o abismo.
## A posição do nó é a borda esquerda, na altura do piso; "largura" vai até a borda direita.
## Só a Cidade é lida pelo jogo; as outras salas têm chão inteiro.

const Sala = preload("res://scripts/salas/sala.gd")

@export var largura := 270.0:
	set(valor):
		largura = valor
		queue_redraw()

func _draw() -> void:
	if not Sala.visivel(): return
	var cor := Color(0.95, 0.3, 0.3)
	draw_rect(Rect2(0, 0, largura, 400), Color(0.05, 0.05, 0.08, 0.6))
	draw_rect(Rect2(0, 0, largura, 400), cor, false, 3.0)
	var fonte := ThemeDB.fallback_font
	draw_string_outline(fonte, Vector2(0, 40), "abismo", HORIZONTAL_ALIGNMENT_CENTER, largura, 20, 5, Color(0, 0, 0, 0.85))
	draw_string(fonte, Vector2(0, 40), "abismo", HORIZONTAL_ALIGNMENT_CENTER, largura, 20, cor)
