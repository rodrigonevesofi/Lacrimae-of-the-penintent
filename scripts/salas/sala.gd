@tool
extends Node2D
## Uma sala do Ato I (scenes/salas/<id>.tscn). A sala começa no canto (0, 0) da cena e vai até
## "tamanho"; tudo dentro dela (plataformas, alvenaria, inimigos, arenas, portas, piso) usa essas
## coordenadas locais. "origem" diz onde esse canto fica no mundo do jogo, que põe as salas lado a lado.
## act_one_layout.gd lê estas cenas e entrega os dados ao jogo já em coordenadas do mundo.
##
## Filhos esperados: Plataformas (Retangulo, atravessáveis por baixo), Alvenaria (Retangulo, sólidos),
## Inimigos (MarcadorInimigo), Arenas (Arena), Portas (Porta), Altares (Altar) e Vestigios (Vestigio).
## Só na Cidade: Inscricoes (Inscricao) e Velas (Vela). Todos são opcionais.
##
## No editor, a sala mostra a pintura de fundo posicionada como em world_art.gd, o chão e os limites.

## Liga o desenho de editor fora do editor (para capturas de conferência).
static var desenhar_fora_do_editor := false

const PANORAMA_RECT := Rect2(0, -770, 4800, 1600)  # o mesmo de world_art.gd, em coordenadas do mundo
const ABISMO_RECT := Rect2(2000, 596, 270, 400)

@export var id := ""
@export var nome := ""
## Onde o canto superior esquerdo da sala fica no mundo do jogo.
@export var origem := Vector2.ZERO:
	set(valor):
		origem = valor
		queue_redraw()
## Largura e altura da sala.
@export var tamanho := Vector2(2000, 1300):
	set(valor):
		tamanho = valor
		queue_redraw()
## Altura do chão de colisão, medida do topo da sala.
@export var piso := 950.0:
	set(valor):
		piso = valor
		queue_redraw()
## Nome da pintura de fundo em assets/ (sem extensão).
@export var arte := "":
	set(valor):
		arte = valor
		queue_redraw()
## Fração da altura da pintura em que fica o piso pintado. Negativo: usa o padrão do jogo (0,86).
@export var linha_do_chao := -1.0:
	set(valor):
		linha_do_chao = valor
		queue_redraw()
## Altura da pintura no mundo. Negativo: usa o padrão do jogo.
@export var altura_arte := -1.0:
	set(valor):
		altura_arte = valor
		queue_redraw()
@export var ao_ar_livre := false
## Cenário gerado por código (Vale), sem pintura própria: o fundo mostrado no editor é só referência.
@export var procedural := false
## Posição da sala no mapa (aba TAB).
@export var posicao_no_mapa := Vector2.ZERO

## Texturas desenhadas no editor. Ficam guardadas aqui: se só uma variável local de _draw() as segurasse,
## seriam liberadas antes de o quadro ser desenhado e apareceriam brancas.
var _texturas := {}

static func visivel() -> bool:
	return Engine.is_editor_hint() or desenhar_fora_do_editor

func limites() -> Rect2:
	return Rect2(origem, tamanho)

## Mesmo formato de act_one_layout.gd rooms(), em coordenadas do mundo; as chaves opcionais só aparecem
## quando definidas.
func dados() -> Dictionary:
	var d := {"name": nome, "bounds": limites(), "floor": origem.y + piso, "art": arte}
	if linha_do_chao >= 0.0: d["ground"] = linha_do_chao
	if altura_arte >= 0.0: d["art_h"] = altura_arte
	if ao_ar_livre: d["outdoor"] = true
	if procedural: d["procedural"] = true
	d["map"] = posicao_no_mapa
	return d

func _ready() -> void:
	if visivel(): queue_redraw()

func _textura(nome_arte: String) -> Texture2D:
	if not _texturas.has(nome_arte):
		var caminho := "res://assets/%s.png" % nome_arte
		_texturas[nome_arte] = load(caminho) if ResourceLoader.exists(caminho) else null
	return _texturas[nome_arte]

func _draw() -> void:
	if not visivel(): return
	var sala := Rect2(Vector2.ZERO, tamanho)
	draw_rect(sala, Color("17181d"))
	# Pintura de fundo, posicionada como em world_art.gd (e na prévia da main).
	if id == "city":
		var pano := _textura("vespera_panorama")
		if pano: draw_texture_rect(pano, Rect2(PANORAMA_RECT.position - origem, PANORAMA_RECT.size), false)
		var abismo := _textura("abismo_ponte")
		if abismo: draw_texture_rect(abismo, Rect2(ABISMO_RECT.position - origem, ABISMO_RECT.size), false)
	else:
		var fundo := _textura(arte) if not arte.is_empty() else null
		var altura := altura_arte if altura_arte >= 0.0 else (1900.0 if id == "belfry" else 1100.0)
		var chao_pintado := linha_do_chao if linha_do_chao >= 0.0 else 0.86
		if fundo: draw_texture_rect(fundo, Rect2(0, piso - altura * chao_pintado, tamanho.x, altura), false)
	# Chão de colisão e limites (as paredes ficam logo fora das bordas).
	# A Cidade tem o abismo da ponte entre x 2000 e 2270 (main.gd); as outras salas têm chão inteiro.
	var trechos := [Vector2(0, 2000 - origem.x), Vector2(2270 - origem.x, tamanho.x)] if id == "city" else [Vector2(0, tamanho.x)]
	for t in trechos:
		var x0: float = t.x
		var x1: float = t.y
		draw_rect(Rect2(x0, piso, x1 - x0, 120), Color(0.25, 0.85, 0.45, 0.35))
		draw_line(Vector2(x0, piso), Vector2(x1, piso), Color(0.5, 0.85, 0.5, 0.9), 3.0)
	draw_rect(sala, Color(0.86, 0.7, 0.38, 0.9), false, 6.0)
	var fonte := ThemeDB.fallback_font
	var titulo := "%s  (%s)%s" % [nome, id, "  · cenário procedural" if procedural else ""]
	draw_string_outline(fonte, Vector2(24, 70), titulo, HORIZONTAL_ALIGNMENT_LEFT, -1, 48, 10, Color(0, 0, 0, 0.85))
	draw_string(fonte, Vector2(24, 70), titulo, HORIZONTAL_ALIGNMENT_LEFT, -1, 48, Color("e8d6b0"))
	draw_string_outline(fonte, Vector2(24, piso - 12), "piso", HORIZONTAL_ALIGNMENT_LEFT, -1, 22, 6, Color(0, 0, 0, 0.85))
	draw_string(fonte, Vector2(24, piso - 12), "piso", HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color(0.5, 0.85, 0.5))
