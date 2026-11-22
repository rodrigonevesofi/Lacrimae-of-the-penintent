@tool
extends Node2D
## Retângulo com nome numa sala (grupo Zonas), usado por um trecho específico do jogo. A posição do nó é o
## canto superior esquerdo. O código pede o retângulo pelo nome, em coordenadas do mundo:
## act_one_layout.gd zona("portao_dos_sinos"). Cada nome deve existir uma única vez entre todas as salas.

const Sala = preload("res://scripts/salas/sala.gd")

## O que cada zona é no jogo (aparece no editor).
const DESCRICAO := {
	"portao_dos_sinos": "Portão dos sinos: parede sólida até as duas correntes caírem",
	"aviso_das_correntes": "Aviso das correntes: vale a faixa de x, enquanto o portão está fechado",
	"parede_do_chefe": "Parede do Guardião: fecha a luta quando ele acorda",
}

@export_enum("portao_dos_sinos", "aviso_das_correntes", "parede_do_chefe") var zona := "portao_dos_sinos":
	set(valor):
		zona = valor
		queue_redraw()
@export var tamanho := Vector2(40, 800):
	set(valor):
		tamanho = valor
		queue_redraw()

func _draw() -> void:
	if not Sala.visivel(): return
	var solida := zona != "aviso_das_correntes"
	var cor := Color(0.95, 0.35, 0.25) if solida else Color(0.95, 0.85, 0.35)
	draw_rect(Rect2(Vector2.ZERO, tamanho), Color(cor, 0.22 if solida else 0.12))
	draw_rect(Rect2(Vector2.ZERO, tamanho), cor, false, 3.0)
	var fonte := ThemeDB.fallback_font
	var texto: String = DESCRICAO.get(zona, zona)
	# O portão e o aviso começam na mesma altura: o rótulo do portão sobe uma linha para não encavalar.
	var linha := Vector2(-170, -34 if zona == "portao_dos_sinos" else -10)
	draw_string_outline(fonte, linha, texto, HORIZONTAL_ALIGNMENT_CENTER, 340 + tamanho.x, 16, 5, Color(0, 0, 0, 0.85))
	draw_string(fonte, linha, texto, HORIZONTAL_ALIGNMENT_CENTER, 340 + tamanho.x, 16, cor)
