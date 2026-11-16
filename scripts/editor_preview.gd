@tool
extends Node2D
## Pré-visualização do Ato I na aba 2D do editor.
##
## O jogo monta o mundo por código quando roda (main.gd, exploration.gd, world_art.gd),
## por isso a cena main.tscn parecia vazia no editor. Este nó lê os MESMOS dados de
## layout (act_one_layout.gd, main.gd e exploration.gd) e desenha as dez salas com o
## cenário, colisões e marcadores. É só uma visualização: quando o jogo roda, o nó se
## apaga em _ready e não altera nada da jogabilidade.
##
## Para mudar o mapa, edite os dados nos scripts (act_one_layout.gd, main.gd) e clique
## em "Atualizar" no Inspetor; o desenho acompanha.

const Layout = preload("res://scripts/act_one_layout.gd")
const PANORAMA_RECT := Rect2(0, -770, 4800, 1600)
const ENEMY_NAMES := {0: "Devoto", 1: "Chorão", 2: "Guardião", 3: "Devorador", 4: "Flagelante", 5: "Aquelarre", 6: "Asmodeia", 7: "Duelista", 8: "Carregador"}

@export var mostrar_cenario := true:
	set(value):
		mostrar_cenario = value
		queue_redraw()
@export var mostrar_colisoes := true:
	set(value):
		mostrar_colisoes = value
		queue_redraw()
@export var mostrar_marcadores := true:
	set(value):
		mostrar_marcadores = value
		queue_redraw()
@export var mostrar_nomes := true:
	set(value):
		mostrar_nomes = value
		queue_redraw()
## Clique para reler os scripts depois de alterar o layout.
@export var atualizar := false:
	set(value):
		_data.clear()
		queue_redraw()

var _data := {}
var _textures := {}
var _font: Font


## Só existe no editor. (Os testes podem sobrescrever para renderizar a prévia.)
func _active() -> bool:
	return Engine.is_editor_hint()


func _ready() -> void:
	if not _active():
		queue_free()
		return
	_font = ThemeDB.fallback_font
	queue_redraw()


func _load_data() -> void:
	var game = load("res://scripts/main.gd").new()
	var ex = load("res://scripts/exploration.gd").new()
	var altars: Array = []
	for i in range(game.altars.size()): altars.append([game.altars[i], game.altar_names[i]])
	for pos in ex.extra_altars: altars.append([pos, ex.ALTAR_NAMES[int(pos.x)]])
	var lore: Array = []
	for entry in game.lore: lore.append([float(entry.x), str(entry.title)])
	_data = {
		"rooms": Layout.rooms(), "ledges": Layout.platforms(), "blocks": Layout.blocks(),
		"passages": Layout.passages(), "arenas": Layout.arenas(), "branch_enemies": Layout.enemies(),
		"city_platforms": game.platforms.duplicate(), "city_enemies": game.enemy_defs.duplicate(true),
		"altars": altars, "lore": lore, "relic": game.relic_pos, "tomb": game.TOMB_POS, "sword": game.SWORD_POS,
		"pickups": ex.pickups.duplicate(true),
	}
	game.free()
	ex.free()


func _texture(name: String) -> Texture2D:
	if not _textures.has(name):
		var path := "res://assets/%s.png" % name
		_textures[name] = load(path) if ResourceLoader.exists(path) else null
	return _textures[name]


func _label(pos: Vector2, text: String, size: int, color: Color) -> void:
	if not mostrar_nomes or _font == null: return
	draw_string_outline(_font, pos, text, HORIZONTAL_ALIGNMENT_LEFT, -1, size, maxi(4, size / 5), Color(0, 0, 0, 0.85))
	draw_string(_font, pos, text, HORIZONTAL_ALIGNMENT_LEFT, -1, size, color)


func _marker(pos: Vector2, color: Color, radius: float, text: String) -> void:
	draw_circle(pos, radius, Color(color, 0.85))
	draw_arc(pos, radius, 0, TAU, 24, Color.BLACK, 3)
	if not text.is_empty(): _label(pos + Vector2(radius + 6, -radius), text, 22, color)


func _draw() -> void:
	if not _active(): return
	if _data.is_empty(): _load_data()
	var rooms: Dictionary = _data.rooms
	# Cenário de cada sala, posicionado como em world_art.gd.
	for id in rooms:
		var room: Dictionary = rooms[id]
		var b: Rect2 = room.bounds
		draw_rect(b, Color("17181d"))
		if not mostrar_cenario: continue
		if id == "city":
			var pano := _texture("vespera_panorama")
			if pano: draw_texture_rect(pano, PANORAMA_RECT, false)
			var abyss := _texture("abismo_ponte")
			if abyss: draw_texture_rect(abyss, Rect2(2000, 596, 270, 400), false)
		else:
			var tex := _texture(str(room.art))
			var height := float(room.get("art_h", 1900.0 if id == "belfry" else 1100.0))
			var ground := float(room.get("ground", 0.86))
			if tex: draw_texture_rect(tex, Rect2(b.position.x, float(room.floor) - height * ground, b.size.x, height), false)
	if mostrar_colisoes:
		var solid := Color(0.25, 0.85, 0.45, 0.35)
		var ledge := Color(0.3, 0.75, 1.0, 0.55)
		# Chão da cidade com o abismo entre 2000 e 2270, e o chão de cada ramificação.
		for r in [Rect2(0, 600, 2000, 400), Rect2(2270, 600, 2530, 400)]: draw_rect(r, solid)
		for id in rooms:
			if id == "city": continue
			var b: Rect2 = rooms[id].bounds
			draw_rect(Rect2(b.position.x, rooms[id].floor, b.size.x, 120), solid)
		for p in _data.city_platforms: draw_rect(p, ledge)
		for p in _data.ledges: draw_rect(p, ledge)
		for blk in _data.blocks: draw_rect(blk, Color(1.0, 0.6, 0.2, 0.5))
		for arena in _data.arenas:
			var top: float = float(arena.floor) - 600.0
			draw_rect(Rect2(arena.x0, top, arena.x1 - arena.x0, 600), Color(0.9, 0.15, 0.15, 0.12))
			_label(Vector2(arena.x0 + 10, top + 30), "ARENA", 24, Color(1, 0.5, 0.5))
	for id in rooms:
		var b: Rect2 = rooms[id].bounds
		draw_rect(b, Color(0.86, 0.7, 0.38, 0.9), false, 6)
		_label(b.position + Vector2(24, 70), str(rooms[id].name), 64, Color("e8d6b0"))
	if not mostrar_marcadores: return
	for a in _data.altars: _marker(a[0] + Vector2(0, -40), Color("f0c060"), 18, "Altar: " + str(a[1]))
	for link in _data.passages:
		_marker(link.pa + Vector2(0, -60), Color("b48cff"), 14, "→ " + str(rooms[link.b].name).capitalize())
		_marker(link.pb + Vector2(0, -60), Color("b48cff"), 14, "→ " + str(rooms[link.a].name).capitalize())
	for e in _data.city_enemies:
		_marker(Vector2(e[1], e[2]) + Vector2(0, -30), Color("ff5a5a"), 12, ENEMY_NAMES.get(int(e[0]), "?"))
	for e in _data.branch_enemies:
		_marker(Vector2(e[2], e[3]) + Vector2(0, -30), Color("ff5a5a"), 12, ENEMY_NAMES.get(int(e[1]), "?"))
	_marker(Vector2(4380, 560), Color("ff2a2a"), 26, "Guardião dos Sinos (chefe)")
	_marker(_data.relic + Vector2(0, -40), Color("ffe08a"), 20, "Espinho da Contrição (salto duplo)")
	_marker(Vector2(9650, 10), Color("7fe0ff"), 16, "Corrente do sino (cisterna)")
	_marker(Vector2(15120, -290), Color("7fe0ff"), 16, "Corrente do sino (campanário)")
	_marker(_data.tomb + Vector2(0, -30), Color("ffffff"), 14, "Túmulo (início)")
	_marker(_data.sword + Vector2(0, -30), Color("ffffff"), 12, "Espada")
	_marker(Vector2(990, 560), Color("9be29b"), 14, "Iria")
	_marker(Vector2(2800, 560), Color("9be29b"), 12, "Memorial")
	for item in _data.pickups: _marker(item.pos + Vector2(0, -20), Color("6fb8ff"), 10, str(item.name))
	for entry in _data.lore: _marker(Vector2(entry[0], 560), Color("c8b48a"), 8, str(entry[1]))
