@tool
extends Node2D
## Luz de cenário que tremula de leve (main.gd _build_lights). A posição do nó é o centro da luz.
## Vale em qualquer sala; as luzes de velas, altares e relíquia são criadas a partir desses objetos.

const Sala = preload("res://scripts/salas/sala.gd")

@export var cor := Color(1.0, 0.78, 0.5):
	set(valor):
		cor = valor
		queue_redraw()
@export var energia := 0.6
## Tamanho da luz (texture_scale da PointLight2D; 1 equivale a 256 unidades de diâmetro).
@export var alcance := 2.0:
	set(valor):
		alcance = valor
		queue_redraw()

func _draw() -> void:
	if not Sala.visivel(): return
	draw_circle(Vector2.ZERO, 128.0 * alcance, Color(cor, 0.12))
	draw_arc(Vector2.ZERO, 128.0 * alcance, 0, TAU, 48, Color(cor, 0.6), 2.0)
	draw_circle(Vector2.ZERO, 8.0, cor)
