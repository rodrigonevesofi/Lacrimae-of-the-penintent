@tool
extends Node2D
## Retângulo de colisão de uma sala. A posição do nó é o canto superior esquerdo.
## Dentro de "Plataformas" vira plataforma atravessável por baixo; dentro de "Alvenaria", bloco sólido.

@export var tamanho := Vector2(140, 24):
	set(valor):
		tamanho = valor
		queue_redraw()

func retangulo_no_mundo(sala: Node2D) -> Rect2:
	return Rect2(sala.position + get_parent().position + position, tamanho)

func _draw() -> void:
	if not Engine.is_editor_hint(): return
	var solido := get_parent() != null and get_parent().name == "Alvenaria"
	var cor := Color(0.75, 0.45, 0.3) if solido else Color(0.35, 0.65, 0.95)
	draw_rect(Rect2(Vector2.ZERO, tamanho), Color(cor, 0.35))
	draw_rect(Rect2(Vector2.ZERO, tamanho), cor, false, 2.0)
