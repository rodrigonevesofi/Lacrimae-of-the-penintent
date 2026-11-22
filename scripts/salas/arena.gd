@tool
extends Node2D
## Combate com saídas bloqueadas: as extremidades x0 e x1 se fecham até a última leva cair.
## A posição do nó é a extremidade esquerda (x0) no piso; "largura" vai até x1.
## Cada filho é uma leva (Node2D) com MarcadorInimigo dentro, na ordem em que entram.

const Sala = preload("res://scripts/salas/sala.gd")

@export var id := ""
@export var largura := 800.0:
	set(valor):
		largura = valor
		queue_redraw()
@export var recompensa := 200

func _draw() -> void:
	if not Sala.visivel(): return
	var cor := Color(0.95, 0.6, 0.2)
	draw_line(Vector2(0, -260), Vector2(0, 0), cor, 4.0)
	draw_line(Vector2(largura, -260), Vector2(largura, 0), cor, 4.0)
	_texto(Vector2(8, -236), "arena %s · %d levas · %d lágrimas" % [id, get_child_count(), recompensa], HORIZONTAL_ALIGNMENT_LEFT, -1, 18, cor)

func _texto(pos: Vector2, texto: String, alinhamento: HorizontalAlignment, largura: float, tamanho_fonte: int, cor: Color) -> void:
	var fonte := ThemeDB.fallback_font
	draw_string_outline(fonte, pos, texto, alinhamento, largura, tamanho_fonte, 5, Color(0, 0, 0, 0.85))
	draw_string(fonte, pos, texto, alinhamento, largura, tamanho_fonte, cor)
