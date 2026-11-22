@tool
extends Node2D
## Uma ponta de passagem entre duas salas. A posição do nó é o ponto dos pés de quem chega.
## Toda ligação tem duas portas com o mesmo "ligacao": o lado "a" guarda o rótulo e o trinco.

@export var ligacao := ""
@export_enum("a", "b") var lado := "a"
## Texto mostrado ao se aproximar (só no lado "a").
@export var rotulo := ""
## Só abre por um lado até ser destrancada (só no lado "a").
@export var trinco := false

func _draw() -> void:
	if not Engine.is_editor_hint(): return
	var cor := Color(0.95, 0.85, 0.35)
	draw_rect(Rect2(-40, -150, 80, 150), Color(cor, 0.2))
	draw_rect(Rect2(-40, -150, 80, 150), cor, false, 2.0)
	draw_string(ThemeDB.fallback_font, Vector2(-120, -160), "%s (%s)%s" % [ligacao, lado, " · trinco" if trinco else ""], HORIZONTAL_ALIGNMENT_CENTER, 240, 16, cor)
