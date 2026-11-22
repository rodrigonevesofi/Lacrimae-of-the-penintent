@tool
extends Node2D
## Onde um inimigo aparece. A posição do nó é o ponto dos pés (x, y do chão ou da plataforma).
## O tipo segue a tabela TYPES de scripts/enemy.gd.

const TIPOS = preload("res://scripts/enemy.gd").TYPES

@export var tipo := 0:
	set(valor):
		tipo = valor
		queue_redraw()
## Distância que ele patrulha para cada lado.
@export var alcance := 100.0:
	set(valor):
		alcance = valor
		queue_redraw()
## Inimigos do mesmo grupo formam um único encontro (aquelarre, duelistas). -1: sem grupo.
@export var grupo := -1
## Criatura das fichas aprovadas (scripts/criatura_goya.gd) em vez de enemy.gd.
@export var criatura := false

func _draw() -> void:
	if not Engine.is_editor_hint(): return
	var cor := Color(0.95, 0.45, 0.85) if criatura else Color(0.95, 0.35, 0.3)
	draw_line(Vector2(-alcance, 0), Vector2(alcance, 0), Color(cor, 0.5), 2.0)
	draw_circle(Vector2(0, -20), 14.0, cor)
	var nome: String = TIPOS[tipo].name if TIPOS.has(tipo) else "tipo %d?" % tipo
	draw_string(ThemeDB.fallback_font, Vector2(-60, -44), nome + (" · g%d" % grupo if grupo >= 0 else ""), HORIZONTAL_ALIGNMENT_CENTER, 120, 16, cor)
