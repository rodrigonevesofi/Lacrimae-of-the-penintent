extends Control
## HUD: vida, culpa, lágrimas, chefe, mensagens, título e final

var game = null
var font: Font
var title_font: Font
var title_art: Texture2D

const GOLD := Color(0.86, 0.7, 0.38)


func _ready() -> void:
	font = ThemeDB.fallback_font
	title_font = load("res://assets/title_font.ttf")
	title_art = load("res://assets/monastery.png")
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	size = Vector2(1280, 720)


func _process(_delta: float) -> void:
	queue_redraw()


func _text(pos: Vector2, s: String, fsize: int, col: Color, align: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT, w: float = -1.0) -> void:
	draw_string(font, pos + Vector2(2, 2), s, align, w, fsize, Color(0, 0, 0, col.a * 0.8))
	draw_string(font, pos, s, align, w, fsize, col)


func _draw() -> void:
	if game == null:
		return
	var vs := get_viewport_rect().size
	if game.state == "title":
		_draw_title(vs)
		return
	if game.state == "ending":
		_draw_ending(vs)
		return
	if game.narrative != null and game.narrative.has_focus():
		return
	_draw_play(vs)
	if game.paused:
		_draw_pause(vs)


func _heading(pos: Vector2, text: String, font_size: int, color: Color, width: float) -> void:
	draw_string(title_font, pos + Vector2(0, 3), text, HORIZONTAL_ALIGNMENT_CENTER, width, font_size, Color(0, 0, 0, 0.7))
	draw_string(title_font, pos, text, HORIZONTAL_ALIGNMENT_CENTER, width, font_size, color)


func _unhandled_input(event: InputEvent) -> void:
	if game.paused and event.is_action_pressed("mute"):
		game.soundscape.toggle_mute()
	if game.paused and event.is_action_pressed("pause"):
		game.toggle_pause()
		get_viewport().set_input_as_handled()
	if game.state == "title" and event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if Rect2(360, 420, 560, 56).has_point(event.position):
			game._start_game(false)
		elif game.has_save and Rect2(360, 480, 560, 48).has_point(event.position):
			game._start_game(true)


func _draw_title(vs: Vector2) -> void:
	draw_texture_rect(title_art, Rect2(Vector2.ZERO, vs), false)
	for i in range(36):
		var f := float(i) / 35.0
		draw_rect(Rect2(0, i * 20, vs.x, 20), Color(0.015, 0.018, 0.022, 0.22 + f * 0.73))
	draw_rect(Rect2(28, 28, vs.x - 56, vs.y - 56), Color(GOLD, 0.32), false, 1)
	_heading(Vector2(0, 174), "L A C R I M A E", 72, Color("d4c3a1"), vs.x)
	_heading(Vector2(0, 220), "O F   T H E   P E N I T E N T", 23, Color("bca984"), vs.x)
	draw_line(Vector2(470, 255), Vector2(810, 255), Color(GOLD, 0.5), 1)
	draw_circle(Vector2(640, 255), 4, GOLD)
	_heading(Vector2(0, 306), "Entre o perdão e o abismo.", 22, Color("c2c0b7"), vs.x)
	_text(Vector2(0, 348), "VESPERA  ·  CAPÍTULO I", 13, Color("a5a7a5"), HORIZONTAL_ALIGNMENT_CENTER, vs.x)
	var hover := Rect2(360, 420, 560, 56).has_point(get_local_mouse_position())
	draw_rect(Rect2(360, 420, 560, 56), Color(0.42, 0.32, 0.17, 0.32 if hover else 0.12))
	draw_rect(Rect2(360, 420, 560, 56), Color(GOLD, 0.75 if hover else 0.38), false, 1)
	_heading(Vector2(360, 456), "ENTER  ·  Iniciar peregrinação", 22, Color("e4d3af"), 560)
	if game.has_save:
		_heading(Vector2(360, 513), "C  ·  Continuar jornada", 19, Color("b6b2a8"), 560)
	_text(Vector2(0, 613), "A / D  mover     ESPAÇO  saltar     J  atacar     K  esquivar     E  interagir", 15, Color("aaa69a"), HORIZONTAL_ALIGNMENT_CENTER, vs.x)
	_text(Vector2(0, 642), "F  curar     Q  penitência     ESC  pausa     M  som", 14, Color("888b88"), HORIZONTAL_ALIGNMENT_CENTER, vs.x)


func _bar(pos: Vector2, w: float, h: float, frac: float, col: Color) -> void:
	draw_rect(Rect2(pos.x - 3, pos.y - 3, w + 6, h + 6), Color(0.05, 0.03, 0.03, 0.85))
	draw_rect(Rect2(pos.x, pos.y, w * clampf(frac, 0.0, 1.0), h), col)
	draw_rect(Rect2(pos.x - 3, pos.y - 3, w + 6, h + 6), GOLD, false, 2.0)


func _draw_play(vs: Vector2) -> void:
	var p = game.player
	if p.damage_flash > 0:
		draw_rect(Rect2(Vector2.ZERO, vs), Color(0.65, 0.02, 0.03, p.damage_flash * 0.55))
	# vida
	var w: float = 120.0 + p.max_hp * 2.0
	_bar(Vector2(28, 24), w, 18.0, p.hp / p.max_hp, Color(0.7, 0.1, 0.12))
	# culpa
	var pen_ready: bool = p.culpa >= 50.0
	var cc := Color(0.85, 0.65, 0.2) if pen_ready else Color(0.45, 0.25, 0.6)
	_bar(Vector2(28, 56), 220.0, 10.0, p.culpa / 100.0, cc)
	_text(Vector2(262, 66), "CULPA", 14, Color(0.8, 0.75, 0.85))
	if pen_ready:
		var pa := 0.6 + 0.4 * sin(Time.get_ticks_msec() / 150.0)
		_text(Vector2(318, 66), "[Q] Penitência pronta", 14, Color(1.0, 0.85, 0.4, pa))
	# lágrimas curativas
	for i in range(p.max_flasks):
		var cx := 36.0 + float(i) * 26.0
		var col := Color(0.6, 0.85, 1.0) if i < p.flasks else Color(0.2, 0.25, 0.3)
		draw_circle(Vector2(cx, 92), 7.0, col)
		draw_colored_polygon(PackedVector2Array([Vector2(cx - 5, 90), Vector2(cx, 76), Vector2(cx + 5, 90)]), col)
	# lágrimas (moeda)
	_text(Vector2(0, 40), "Lágrimas  %d" % p.lagrimas, 24, Color(0.75, 0.88, 1.0), HORIZONTAL_ALIGNMENT_RIGHT, vs.x - 28.0)
	if game.stain_amount > 0:
		_text(Vector2(0, 66), "Mancha de culpa: %d" % game.stain_amount, 16, Color(0.7, 0.8, 1.0, 0.8), HORIZONTAL_ALIGNMENT_RIGHT, vs.x - 28.0)

	# dica de controles inicial
	if game.play_time < 18.0 and game.message_text == "" and game.prompt == "":
		_text(Vector2(28, vs.y - 26), "A/D mover · ESPAÇO pular · J atacar · K rolar · F curar · Q penitência · E interagir", 15, Color(0.8, 0.78, 0.74, 0.8))

	var objective := "Encontre a espada diante do túmulo" if not p.has_weapon else ("Explore a cidade e encontre a relíquia" if not game.relic_taken else "Atravesse o abismo e alcance os sinos")
	_text(Vector2(0, 91), objective, 13, Color(0.73, 0.69, 0.59, 0.85), HORIZONTAL_ALIGNMENT_RIGHT, vs.x - 28)
	if game.area_t > 0.0:
		var aa := minf(game.area_t, 1.0)
		_heading(Vector2(0, 190), game.area_name, 25, Color(0.86, 0.80, 0.66, aa), vs.x)
		draw_line(Vector2(vs.x / 2 - 120, 204), Vector2(vs.x / 2 + 120, 204), Color(0.7, 0.57, 0.36, aa * 0.5), 1)

	# chefe
	var b = game.boss
	if b != null and is_instance_valid(b) and b.awake and not b.dead:
		var bw := 640.0
		var bx := (vs.x - bw) / 2.0
		_text(Vector2(0, vs.y - 78), b.display_name, 22, GOLD, HORIZONTAL_ALIGNMENT_CENTER, vs.x)
		_bar(Vector2(bx, vs.y - 62), bw, 14.0, b.hp / b.max_hp, Color(0.62, 0.55, 0.5))

	# prompt
	if game.prompt != "" and game.message_text == "" and game.state == "play":
		draw_rect(Rect2(100, vs.y - 65, vs.x - 200, 45), Color(0.02, 0.02, 0.025, 0.85))
		_text(Vector2(0, vs.y - 36), game.prompt, 18, Color(1.0, 0.9, 0.6), HORIZONTAL_ALIGNMENT_CENTER, vs.x)

	# toast
	if game.toast_t > 0.0:
		var ta := clampf(game.toast_t, 0.0, 1.0)
		_text(Vector2(0, 150), game.toast_text, 22, Color(1, 0.92, 0.75, ta), HORIZONTAL_ALIGNMENT_CENTER, vs.x)

	# mensagem de lore
	if game.message_text != "":
		var pw := 860.0
		var ph := 340.0
		var px := (vs.x - pw) / 2.0
		var py := (vs.y - ph) / 2.0 - 20.0
		draw_rect(Rect2(px, py, pw, ph), Color(0.04, 0.03, 0.04, 0.92))
		draw_rect(Rect2(px, py, pw, ph), GOLD, false, 2.0)
		_heading(Vector2(px, py + 50.0), game.message_title, 24, GOLD, pw)
		draw_line(Vector2(px + 60, py + 66), Vector2(px + pw - 60, py + 66), Color(GOLD, 0.5), 1.0)
		draw_multiline_string(font, Vector2(px + 44, py + 106), game.message_text, HORIZONTAL_ALIGNMENT_LEFT, pw - 88.0, 20, -1, Color(0.9, 0.87, 0.82))
		var next_text := "[E] continuar  ·  %d / 3" % (game.prologue_page + 1) if game.prologue_page >= 0 else "[E] continuar"
		_text(Vector2(px, py + ph - 20.0), next_text, 16, Color(0.7, 0.68, 0.65), HORIZONTAL_ALIGNMENT_CENTER, pw)

	# morte
	if game.state == "dead":
		var da := clampf((3.0 - game.death_t) / 1.2, 0.0, 1.0)
		draw_rect(Rect2(Vector2.ZERO, vs), Color(0, 0, 0, 0.55 * da))
		_text(Vector2(0, vs.y / 2.0 - 10.0), "VOCÊ SUCUMBIU", 54, Color(0.75, 0.12, 0.12, da), HORIZONTAL_ALIGNMENT_CENTER, vs.x)
		_text(Vector2(0, vs.y / 2.0 + 32.0), "A culpa permanece.", 22, Color(0.85, 0.8, 0.8, da), HORIZONTAL_ALIGNMENT_CENTER, vs.x)


func _draw_ending(vs: Vector2) -> void:
	var fa := clampf(game.ending_t / 1.5, 0.0, 1.0)
	draw_rect(Rect2(Vector2.ZERO, vs), Color(0, 0, 0, 0.94 * fa))
	var lines: Array = [
		"O Guardião dos Sinos silencia. A cidade ainda não descansa.",
		"A primeira Lágrima Sagrada desperta uma lembrança dos portões.",
		"Você viu suas mãos fechando os portões. Ainda não sabe por quê.",
		"Esta é apenas a primeira etapa da peregrinação.",
	]

	for i in range(lines.size()):
		var la := clampf((game.ending_t - 1.5 - float(i) * 2.6) / 1.2, 0.0, 1.0)
		draw_multiline_string(font, Vector2(180, 170.0 + float(i) * 78.0), lines[i], HORIZONTAL_ALIGNMENT_CENTER, vs.x - 360.0, 22, -1, Color(0.9, 0.87, 0.82, la))
	var ta := clampf((game.ending_t - 15.0) / 1.5, 0.0, 1.0)
	_text(Vector2(0, vs.y - 120.0), "— FIM DO CAPÍTULO JOGÁVEL —", 30, Color(GOLD, ta), HORIZONTAL_ALIGNMENT_CENTER, vs.x)
	_text(Vector2(0, vs.y - 80.0), "ENTER  —  voltar ao título", 20, Color(0.85, 0.8, 0.78, ta), HORIZONTAL_ALIGNMENT_CENTER, vs.x)


func _draw_pause(vs: Vector2) -> void:
	draw_rect(Rect2(Vector2.ZERO, vs), Color(0.015, 0.018, 0.024, 0.95))
	_heading(Vector2(0, 182), "A PEREGRINAÇÃO AGUARDA", 30, GOLD, vs.x)
	_text(Vector2(0, 228), "PAUSA", 14, Color("a6a49e"), HORIZONTAL_ALIGNMENT_CENTER, vs.x)
	var controls := ["A / D ou ← / →    Mover", "ESPAÇO / W / ↑    Saltar", "J / X    Ataque com espada", "K / SHIFT    Esquiva", "F    Lágrima curativa", "Q    Penitência (50% de culpa)", "E    Examinar / orar / continuar", "R    Oferecer lágrimas no altar", "M    Ativar / silenciar som"]
	for i in range(controls.size()):
		_text(Vector2(430, 284 + i * 31), controls[i], 18, Color("c5c0b3"))
	_text(Vector2(0, 605), "O progresso é salvo ao orar e ao obter a espada ou a relíquia.", 15, Color("8f918e"), HORIZONTAL_ALIGNMENT_CENTER, vs.x)
	_heading(Vector2(0, 650), "ESC  ·  Retomar", 22, GOLD, vs.x)
