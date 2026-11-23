@tool
extends Node2D
## Uma ponta de passagem entre duas salas. A posição do nó é o ponto dos pés de quem chega.
## Toda ligação tem duas portas com o mesmo "ligacao": o lado "a" guarda o rótulo e o trinco.

const Sala = preload("res://scripts/salas/sala.gd")

@export var ligacao := ""
@export_enum("a", "b") var lado := "a"
## Texto mostrado ao se aproximar (só no lado "a").
@export var rotulo := ""
## Só abre por um lado até ser destrancada (só no lado "a").
@export var trinco := false

func _draw() -> void:
	if not Sala.visivel(): return
	var cor := Color(0.95, 0.85, 0.35)
	draw_rect(Rect2(-40, -150, 80, 150), Color(cor, 0.2))
	draw_rect(Rect2(-40, -150, 80, 150), cor, false, 2.0)
	_texto(Vector2(-120, -160), "%s (%s)%s" % [ligacao, lado, " · trinco" if trinco else ""], HORIZONTAL_ALIGNMENT_CENTER, 240, 16, cor)

func _texto(pos: Vector2, texto: String, alinhamento: HorizontalAlignment, largura: float, tamanho_fonte: int, cor: Color) -> void:
	var fonte := ThemeDB.fallback_font
	draw_string_outline(fonte, pos, texto, alinhamento, largura, tamanho_fonte, 5, Color(0, 0, 0, 0.85))
	draw_string(fonte, pos, texto, alinhamento, largura, tamanho_fonte, cor)
