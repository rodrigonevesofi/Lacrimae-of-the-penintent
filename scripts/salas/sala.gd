@tool
extends Node2D
## Uma sala do Ato I (scenes/salas/<id>.tscn). A posição do nó é o canto superior esquerdo dos limites
## da sala no mundo; tudo dentro dela (plataformas, alvenaria, inimigos, arenas, portas) fica em
## coordenadas locais. act_one_layout.gd lê estas cenas e entrega os dados ao jogo.
##
## Filhos esperados: Plataformas (Retangulo, atravessáveis por baixo), Alvenaria (Retangulo, sólidos),
## Inimigos (MarcadorInimigo), Arenas (Arena) e Portas (Porta). Todos são opcionais.

@export var id := ""
@export var nome := ""
## Largura e altura da sala; a posição do nó dá o canto superior esquerdo.
@export var tamanho := Vector2(2000, 1300)
## Altura (y do mundo) do chão de colisão.
@export var piso := 600.0
## Nome da pintura de fundo em assets/ (sem extensão).
@export var arte := ""
## Fração da altura da pintura em que fica o piso pintado. Negativo: usa o padrão do jogo (0,86).
@export var linha_do_chao := -1.0
## Altura da pintura no mundo. Negativo: usa o padrão do jogo.
@export var altura_arte := -1.0
@export var ao_ar_livre := false
## Cenário gerado por código (Vale), sem pintura própria.
@export var procedural := false
## Posição da sala no mapa (aba TAB).
@export var posicao_no_mapa := Vector2.ZERO

func limites() -> Rect2:
	return Rect2(position, tamanho)

## Mesmo formato de act_one_layout.gd rooms(): as chaves opcionais só aparecem quando definidas.
func dados() -> Dictionary:
	var d := {"name": nome, "bounds": limites(), "floor": piso, "art": arte}
	if linha_do_chao >= 0.0: d["ground"] = linha_do_chao
	if altura_arte >= 0.0: d["art_h"] = altura_arte
	if ao_ar_livre: d["outdoor"] = true
	if procedural: d["procedural"] = true
	d["map"] = posicao_no_mapa
	return d

func _ready() -> void:
	if Engine.is_editor_hint(): queue_redraw()

func _draw() -> void:
	if not Engine.is_editor_hint(): return
	draw_rect(Rect2(Vector2.ZERO, tamanho), Color(0.9, 0.75, 0.4, 0.9), false, 4.0)
	var chao := piso - position.y
	draw_line(Vector2(0, chao), Vector2(tamanho.x, chao), Color(0.5, 0.85, 0.5, 0.9), 3.0)
	draw_string(ThemeDB.fallback_font, Vector2(16, 48), "%s  (%s)" % [nome, id], HORIZONTAL_ALIGNMENT_LEFT, -1, 36, Color(0.95, 0.85, 0.6))
	draw_string(ThemeDB.fallback_font, Vector2(16, chao - 10), "piso %.0f" % piso, HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color(0.5, 0.85, 0.5))
