@tool
extends Node2D
## Elemento de cenário desenhado por world_art.gd na Cidade, sem colisão:
## - gaiola: gaiola vazia pendurada; a posição é onde ela fica (a corda desce do alto da sala).
## - pano: pano rasgado pendurado; a posição é o ponto de onde ele cai.
## - corrente: corrente vertical diante dos portões, visível até as duas correntes do sino serem soltas;
##   vale só a posição x.

const Sala = preload("res://scripts/salas/sala.gd")

@export_enum("gaiola", "pano", "corrente") var tipo := "gaiola":
	set(valor):
		tipo = valor
		queue_redraw()

func _draw() -> void:
	if not Sala.visivel(): return
	var cor := Color(0.8, 0.7, 0.55)
	match tipo:
		"gaiola":
			draw_rect(Rect2(-22, 22, 44, 60), cor, false, 2.0)
			draw_arc(Vector2(0, 22), 22, PI, TAU, 16, cor, 2.0)
		"pano":
			draw_line(Vector2.ZERO, Vector2(6, 136), Color(0.6, 0.25, 0.28), 6.0)
		"corrente":
			draw_line(Vector2(0, -60), Vector2(0, 60), cor, 3.0)
	var fonte := ThemeDB.fallback_font
	draw_string_outline(fonte, Vector2(-60, -8), tipo, HORIZONTAL_ALIGNMENT_CENTER, 120, 14, 4, Color(0, 0, 0, 0.85))
	draw_string(fonte, Vector2(-60, -8), tipo, HORIZONTAL_ALIGNMENT_CENTER, 120, 14, cor)
