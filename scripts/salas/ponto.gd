@tool
extends Node2D
## Ponto especial de uma sala, usado por um trecho específico do jogo. A posição do nó é o ponto dos pés
## (no chão ou na plataforma). O código pede a posição pelo nome: act_one_layout.gd ponto("tumulo").
## Cada nome deve existir uma única vez entre todas as salas.

const Sala = preload("res://scripts/salas/sala.gd")

## O que cada ponto é no jogo (aparece no editor).
const DESCRICAO := {
	"tumulo": "Túmulo: início da jornada",
	"espada": "Espada diante do túmulo",
	"iria": "Iria, a testemunha",
	"memorial": "Memorial sem nomes",
	"portao_do_vale": "Portões: descida ao Vale / encerramento",
	"chefe_guardiao": "Guardião dos Sinos (chefe)",
	"reliquia": "Espinho da Contrição (salto duplo)",
	"corrente_agua": "Corrente do sino (cisterna)",
	"corrente_vigilia": "Corrente do sino (campanário)",
	"entrada_vale": "Chegada ao Vale",
	"chefe_vale": "O Flagelado (chefe final)",
}

@export_enum("tumulo", "espada", "iria", "memorial", "portao_do_vale", "chefe_guardiao", "reliquia", "corrente_agua", "corrente_vigilia", "entrada_vale", "chefe_vale") var ponto := "tumulo":
	set(valor):
		ponto = valor
		queue_redraw()

func _draw() -> void:
	if not Sala.visivel(): return
	var cor := Color("9be29b")
	if ponto.begins_with("chefe"): cor = Color("ff2a2a")
	elif ponto.begins_with("corrente"): cor = Color("7fe0ff")
	elif ponto == "reliquia": cor = Color("ffe08a")
	draw_line(Vector2(-12, 0), Vector2(12, 0), cor, 3.0)
	draw_line(Vector2(0, 0), Vector2(0, -40), cor, 2.0)
	draw_circle(Vector2(0, -40), 12.0, Color(cor, 0.85))
	draw_arc(Vector2(0, -40), 12.0, 0, TAU, 20, Color.BLACK, 2.0)
	var fonte := ThemeDB.fallback_font
	var texto: String = DESCRICAO.get(ponto, ponto)
	draw_string_outline(fonte, Vector2(-160, -62), texto, HORIZONTAL_ALIGNMENT_CENTER, 320, 16, 5, Color(0, 0, 0, 0.85))
	draw_string(fonte, Vector2(-160, -62), texto, HORIZONTAL_ALIGNMENT_CENTER, 320, 16, cor)
