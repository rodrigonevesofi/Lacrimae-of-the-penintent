extends Control
## HUD: vida, culpa, lágrimas, chefe, mensagens, título e final

var game = null
var font: Font
var title_font: Font
var title_art: Texture2D
var ui_art: Texture2D
var ui_regions: Dictionary = {}

const GOLD := Color(0.86, 0.7, 0.38)


func _ready() -> void:
	ui_art = load("res://assets/reliquary_ui.png")
	for path in ["res://assets/ending/ato1_portoes_v2.png", "res://assets/ending/ato1_portoes.png"]:
		if ending_art == null and ResourceLoader.exists(path): ending_art = load(path)
	var regions := {"bar":Rect2(0,190,512,135),"seal":Rect2(580,0,430,510),"flask":Rect2(1190,0,260,480),"boss":Rect2(0,660,512,240),"panel":Rect2(535,580,540,345),"tear":Rect2(1160,555,300,410)}
	for key in regions:
		var atlas := AtlasTexture.new()
		atlas.atlas = ui_art
		atlas.region = regions[key]
		atlas.filter_clip = true
		ui_regions[key] = atlas
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


var ending_art: Texture2D

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
	if game.exploration.map_open: _draw_map(vs)
	if game.exploration.transition > 0: draw_rect(Rect2(Vector2.ZERO,vs),Color(0.02,0.015,0.02,game.exploration.transition/0.4))
	if game.penitence_menu: _draw_penitences(vs)
	if game.paused:
		_draw_pause(vs)


func _heading(pos: Vector2, text: String, font_size: int, color: Color, width: float) -> void:
	draw_string(title_font, pos + Vector2(0, 3), text, HORIZONTAL_ALIGNMENT_CENTER, width, font_size, Color(0, 0, 0, 0.7))
	draw_string(title_font, pos, text, HORIZONTAL_ALIGNMENT_CENTER, width, font_size, color)


func _unhandled_input(event: InputEvent) -> void:
	if (game.state == "title" or game.paused) and event.is_action_pressed("reduce_pulses"):
		game.set_reduced_pulses(not game.reduced_pulses)
		get_viewport().set_input_as_handled()
	if game.paused and event.is_action_pressed("mute"):
		game.soundscape.toggle_mute()
	if game.paused and event.is_action_pressed("pause"):
		game.toggle_pause()
		get_viewport().set_input_as_handled()
	if game.state == "title" and event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if Rect2(360, 420, 560, 56).has_point(event.position):
			game._start_game(false)
		elif Rect2(320, 654, 640, 28).has_point(event.position):
			game.set_reduced_pulses(not game.reduced_pulses)
		elif game.has_save and Rect2(360, 480, 560, 48).has_point(event.position):
			game._start_game(true)


func _draw_title(vs: Vector2) -> void:
	draw_texture_rect(title_art, Rect2(Vector2.ZERO, vs), false)
	for i in range(36):
		var f := float(i) / 35.0
		draw_rect(Rect2(0, i * 20, vs.x, 20), Color(0.015, 0.018, 0.022, 0.22 + f * 0.73))
	draw_texture_rect(ui_regions.seal,Rect2(vs.x/2-36,49,72,85),false)
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
	_text(Vector2(0, 672), "P  ·  Reduzir pulsos e tremores nas cenas: %s" % ("LIGADO" if game.reduced_pulses else "DESLIGADO"), 14, Color("c2bba8") if game.reduced_pulses else Color("888b88"), HORIZONTAL_ALIGNMENT_CENTER, vs.x)


func _bar(pos: Vector2, w: float, h: float, frac: float, col: Color) -> void:
	draw_rect(Rect2(pos.x - 3, pos.y - 3, w + 6, h + 6), Color(0.05, 0.03, 0.03, 0.85))
	draw_rect(Rect2(pos.x, pos.y, w * clampf(frac, 0.0, 1.0), h), col)
	draw_rect(Rect2(pos.x - 3, pos.y - 3, w + 6, h + 6), GOLD, false, 2.0)


func _draw_play(vs: Vector2) -> void:
	var p = game.player
	if p.damage_flash > 0: draw_rect(Rect2(Vector2.ZERO,vs),Color(0.5,0.015,0.025,p.damage_flash*0.5))
	# The two vessels share an ornamental frame, but retain clear fill and labels.
	draw_texture_rect(ui_regions.seal,Rect2(18,20,84,100),false)
	_ornate_bar(Rect2(80,-4,370,96),p.hp/p.max_hp,Color("8f182b"))
	_ornate_bar(Rect2(80,29,330,82),p.culpa/100.0,Color("aa874d"))
	_text(Vector2(126,23),"VIGÍLIA",11,Color("dfc8a0"))
	_text(Vector2(314,46),"%d / %d" % [ceil(p.hp),p.max_hp],12,Color("f2dfc7"))
	_text(Vector2(123,98),"CULPA",11,Color("c8ad83"))
	if game.stain_active:
		draw_rect(Rect2(80+330*0.122+330*0.785*0.75,29+82*0.48,330*0.785*0.25,82*0.17),Color("342f38"))
		_text(Vector2(259,98),"Culpa pendente · capacidade 75%",11,Color("c79c97"))
	elif p.culpa >= 50:
		_text(Vector2(278,98),"Q · PENITÊNCIA",11,Color("e9c991"))
	for i in range(p.max_flasks):
		draw_texture_rect(ui_regions.flask,Rect2(122+i*30,104,20,37),false,Color.WHITE if i<p.flasks else Color(0.35,0.32,0.34,0.75))
	if p.penitence != "none":
		_text(Vector2(122,159),"Pregos da Contrição" if p.penitence == "nails" else "Correntes do Voto",13,Color("c6af8b"))
	# A small relic counter, rather than large detached UI text.
	_panel(Rect2(vs.x-222,18,198,67))
	draw_texture_rect(ui_regions.tear,Rect2(vs.x-212,28,30,43),false)
	_text(Vector2(vs.x-170,61),str(p.lagrimas),28,Color("e8d8bd"))
	_text(Vector2(vs.x-171,34),"LÁGRIMAS",10,Color("beaa88"))
	_panel(Rect2(vs.x-370,88,350,78))
	var objective: String = game.exploration.objective()
	var objective_x: float = vs.x-350
	for i in range(_wrap(objective,320,14).size()):
		_text(Vector2(objective_x,111+i*20),_wrap(objective,320,14)[i],14,Color("ded1b9"))
	_text(Vector2(vs.x-176,170),"TAB · CARTOGRAFIA",11,Color("c6af8b"))
	if game.area_t > 0:
		var opacity := minf(game.area_t,1)
		_heading(Vector2(200,205),game.area_name,23,Color(0.86,0.8,0.68,opacity),vs.x-400)
		for sign_value in [-1,1]:
			var center := Vector2(vs.x/2+sign_value*230,218)
			draw_line(center,center+Vector2(sign_value*90,0),Color(0.65,0.5,0.3,opacity),1)
			draw_colored_polygon(PackedVector2Array([center+Vector2(-4,0),center+Vector2(0,-4),center+Vector2(4,0),center+Vector2(0,4)]),Color(0.65,0.5,0.3,opacity))
	var b = game.boss
	if b != null and is_instance_valid(b) and b.awake and not b.dead and game.exploration.room == "city":
		_ornate_bar(Rect2(vs.x/2-300,10,600,112),b.hp/b.max_hp,Color("872a32"),true)
		_heading(Vector2(0,132),b.display_name,22,Color("d5bd92"),vs.x)
	if game.prompt != "" and game.message_text == "" and game.state == "play":
		_panel(Rect2(150,vs.y-51,vs.x-300,41))
		_text(Vector2(0,vs.y-24),game.prompt,16,Color("eedcc0"),HORIZONTAL_ALIGNMENT_CENTER,vs.x)
	elif game.play_time < 18 and game.message_text == "":
		_text(Vector2(0,vs.y-24),"A/D · mover     ESPAÇO · saltar     J · espada     L · aparo     K · esquiva     E · examinar     TAB · mapa",14,Color("c7baa4"),HORIZONTAL_ALIGNMENT_CENTER,vs.x)
	if game.toast_t > 0:
		var text_lines := _wrap(game.toast_text,800,17)
		for i in range(text_lines.size()):
			_text(Vector2(240,259+i*24),text_lines[i],17,Color(0.94,0.84,0.69,minf(game.toast_t,1)),HORIZONTAL_ALIGNMENT_CENTER,800)
	if game.message_text != "": _draw_message(vs)
	if game.state == "dead":
		var opacity := clampf((3-game.death_t)/1.2,0,1)
		draw_rect(Rect2(Vector2.ZERO,vs),Color(0.02,0,0.01,0.65*opacity))
		_heading(Vector2(0,vs.y/2),"A CARNE CEDE",50,Color(0.67,0.2,0.21,opacity),vs.x)
		_heading(Vector2(0,vs.y/2+40),"A culpa permanece.",23,Color(0.85,0.77,0.65,opacity),vs.x)
		var witness := clampf((1.8-game.death_t)/1.0,0,1)
		_text(Vector2(0,vs.y/2+88),game.GuiltText.death_line(game.death_count-1),19,Color(0.78,0.66,0.55,witness),HORIZONTAL_ALIGNMENT_CENTER,vs.x)

func _ornate_bar(rect: Rect2, amount: float, color: Color, boss: bool = false) -> void:
	draw_texture_rect(ui_regions.boss if boss else ui_regions.bar,rect,false)
	var inside := Rect2(rect.position + rect.size*Vector2(0.157 if boss else 0.122,0.42 if boss else 0.48),rect.size*Vector2(0.69 if boss else 0.785,0.10 if boss else 0.17))
	inside.size.x *= clampf(amount,0,1)
	if inside.size.x > 0:
		draw_rect(inside,color)
		draw_rect(Rect2(inside.position,Vector2(inside.size.x,2)),color.lightened(0.28))
		draw_rect(Rect2(inside.position+Vector2(0,inside.size.y-2),Vector2(inside.size.x,2)),color.darkened(0.45))

func _panel(rect: Rect2) -> void:
	draw_texture_rect(ui_regions.panel,rect,false)
	draw_rect(rect.grow(-8),Color(0.015,0.009,0.015,0.72))

func _wrap(text: String, width: float, size_px: int) -> Array[String]:
	var lines: Array[String] = []
	for paragraph in text.split("\n"):
		var line := ""
		for word in paragraph.split(" "):
			var candidate: String = word if line.is_empty() else line+" "+word
			if font.get_string_size(candidate,HORIZONTAL_ALIGNMENT_LEFT,-1,size_px).x > width and not line.is_empty():
				lines.append(line)
				line = word
			else: line = candidate
		lines.append(line)
	return lines

func _draw_message(vs: Vector2) -> void:
	var rect := Rect2(200,160,vs.x-400,390)
	_panel(rect)
	_heading(Vector2(rect.position.x+24,rect.position.y+62),game.message_title,24,Color("d3b58a"),rect.size.x-48)
	draw_line(rect.position+Vector2(68,79),rect.position+Vector2(rect.size.x-68,79),Color("765b3d"),1)
	var lines := _wrap(game.message_text,rect.size.x-110,19)
	for i in range(lines.size()): _text(rect.position+Vector2(55,115+i*25),lines[i],19,Color("e4d6c0"))
	_text(Vector2(rect.position.x,rect.end.y-25),"E · Continuar",14,Color("bba27c"),HORIZONTAL_ALIGNMENT_CENTER,rect.size.x)

func _draw_map(vs: Vector2) -> void:
	draw_rect(Rect2(Vector2.ZERO,vs),Color(0.015,0.012,0.018,0.96))
	_panel(Rect2(50,50,vs.x-100,620))
	_heading(Vector2(0,102),"CARTOGRAFIA DOS CONDENADOS",28,Color("d2b78d"),vs.x)
	var ex = game.exploration
	var positions: Dictionary = {}
	for id in ex.rooms: positions[id] = ex.rooms[id].map*Vector2(1,0.72)+Vector2(50,70)
	for link in ex.passages:
		if not ex.visited.has(link.a) and not ex.visited.has(link.b): continue
		draw_line(positions[link.a]+Vector2(75,25),positions[link.b]+Vector2(75,25),Color("b99a62") if ex.opened.has(link.id) else Color("554b42"),3)
	for id in ex.rooms:
		var pos: Vector2 = positions[id]
		var known: bool = ex.visited.has(id)
		var rect := Rect2(pos,Vector2(155,56))
		draw_rect(rect,Color("3b272c") if id == ex.room else Color("201e24"))
		draw_rect(rect,Color("d1b185") if known else Color("564b43"),false,2)
		var label: String = ex.rooms[id].name if known else "NÃO EXPLORADO"
		var words := _wrap(label,145,12)
		for i in range(words.size()): _text(pos+Vector2(5,21+i*15),words[i],12,Color("e0cfb3") if known else Color("8d8174"),HORIZONTAL_ALIGNMENT_CENTER,145)
		if id == ex.room: _text(pos+Vector2(0,-8),"VOCÊ",12,Color("e6b8a0"),HORIZONTAL_ALIGNMENT_CENTER,155)
	_text(Vector2(0,620),"%d / %d lugares · %d / 2 correntes · %d / %d vestígios" % [ex.visited.size(),ex.rooms.size(),ex.bells.size(),ex.collected.size(),ex.pickups.size()],17,Color("cbb493"),HORIZONTAL_ALIGNMENT_CENTER,vs.x)
	_text(Vector2(0,650),"Linhas douradas: atalhos abertos    ·    TAB: retornar",14,Color("aa987b"),HORIZONTAL_ALIGNMENT_CENTER,vs.x)


func _draw_ending(vs: Vector2) -> void:
	var fa := clampf(game.ending_t / 1.5, 0.0, 1.0)
	var lines: Array = [
		"O Guardião dos Sinos silencia. A cidade ainda não descansa.",
		"A primeira Lágrima Sagrada desperta uma lembrança dos portões.",
		"Você viu suas mãos fechando os portões. Ainda não sabe por quê.",
		"Esta é apenas a primeira etapa da peregrinação.",
	]
	if ending_art != null:
		# The closing picture holds the whole screen. The Penitente and the lantern stay clear; the four lines
		# come one at a time in the dark strip below, and the end card arrives when ENTER becomes available.
		draw_rect(Rect2(Vector2.ZERO, vs), Color(0, 0, 0, 1.0))
		draw_texture_rect(ending_art, Rect2(Vector2.ZERO, vs), false, Color(1, 1, 1, fa))
		draw_rect(Rect2(0, vs.y - 120, vs.x, 120), Color(0, 0, 0, 0.5 * fa))
		for i in range(lines.size()):
			var start := 1.2 + float(i) * 3.2
			var la := smoothstep(start, start + 0.7, game.ending_t) * (1.0 - smoothstep(start + 2.5, start + 3.2, game.ending_t))
			_text(Vector2(0, vs.y - 62.0), lines[i], 21, Color(0.92, 0.88, 0.8, la), HORIZONTAL_ALIGNMENT_CENTER, vs.x)
		var tb := clampf((game.ending_t - 15.0) / 1.5, 0.0, 1.0)
		_heading(Vector2(0, 84), "— FIM DO CAPÍTULO JOGÁVEL —", 30, Color(GOLD, tb), vs.x)
		_text(Vector2(0, vs.y - 60.0), "ENTER  —  voltar ao título", 20, Color(0.88, 0.84, 0.78, tb), HORIZONTAL_ALIGNMENT_CENTER, vs.x)
		return
	draw_rect(Rect2(Vector2.ZERO, vs), Color(0, 0, 0, 0.94 * fa))
	for i in range(lines.size()):
		var la := clampf((game.ending_t - 1.5 - float(i) * 2.6) / 1.2, 0.0, 1.0)
		draw_multiline_string(font, Vector2(180, 170.0 + float(i) * 78.0), lines[i], HORIZONTAL_ALIGNMENT_CENTER, vs.x - 360.0, 22, -1, Color(0.9, 0.87, 0.82, la))
	var ta := clampf((game.ending_t - 15.0) / 1.5, 0.0, 1.0)
	_text(Vector2(0, vs.y - 120.0), "— FIM DO CAPÍTULO JOGÁVEL —", 30, Color(GOLD, ta), HORIZONTAL_ALIGNMENT_CENTER, vs.x)
	_text(Vector2(0, vs.y - 80.0), "ENTER  —  voltar ao título", 20, Color(0.85, 0.8, 0.78, ta), HORIZONTAL_ALIGNMENT_CENTER, vs.x)


func _draw_pause(vs: Vector2) -> void:
	draw_rect(Rect2(Vector2.ZERO, vs), Color(0.015, 0.018, 0.024, 0.95))
	_panel(Rect2(220,95,vs.x-440,590))
	_heading(Vector2(0, 182), "A PEREGRINAÇÃO AGUARDA", 30, GOLD, vs.x)
	_text(Vector2(0, 228), "PAUSA", 14, Color("a6a49e"), HORIZONTAL_ALIGNMENT_CENTER, vs.x)
	var controls := ["A / D ou ← / →    Mover", "ESPAÇO / W / ↑    Saltar", "J / X    Ataque com espada", "K / SHIFT    Esquiva", "L    Aparo (aperte quando o golpe chegar)", "F    Lágrima curativa", "Q    Penitência (50% de culpa)", "E    Examinar / orar / continuar", "R    Oferecer lágrimas no altar", "V    Trocar penitências no altar", "M    Ativar / silenciar som", "TAB    Cartografia · S+ESPAÇO    Descer"]
	for i in range(controls.size()):
		_text(Vector2(430, 268 + i * 27), controls[i], 18, Color("c5c0b3"))
	_text(Vector2(430, 574), "P    Reduzir pulsos e tremores: %s" % ("LIGADO" if game.reduced_pulses else "DESLIGADO"), 18, Color("e0d3b0") if game.reduced_pulses else Color("c5c0b3"))
	_text(Vector2(0, 605), "O progresso é salvo ao orar e ao obter a espada ou a relíquia.", 15, Color("8f918e"), HORIZONTAL_ALIGNMENT_CENTER, vs.x)
	_heading(Vector2(0, 650), "ESC  ·  Retomar", 22, GOLD, vs.x)


func _draw_penitences(vs: Vector2) -> void:
	draw_rect(Rect2(Vector2.ZERO, vs), Color(0.02, 0.016, 0.022, 0.96))
	_heading(Vector2(0, 154), "RELÍQUIAS DE PENITÊNCIA", 30, GOLD, vs.x)
	_text(Vector2(0, 196), "Uma penitência por vez. A troca não restaura a vida.", 18, Color("b9afa1"), HORIZONTAL_ALIGNMENT_CENTER, vs.x)
	var rows := [
		["1  ·  Abandonar o fardo", "Vida e ataques sem modificadores."],
		["2  ·  Pregos da Contrição", "Espada +40% de dano. Vida máxima −30%."],
		["3  ·  Correntes do Voto", "Penitência +55% de dano. Recuperação da esquiva +0,65s."],
	]
	for i in range(3):
		var y := 246 + i * 115
		_panel(Rect2(220,y,840,93))
		if game.player.penitence == ["none", "nails", "chains"][i]: draw_rect(Rect2(220, y, 840, 93), GOLD, false, 2)
		_text(Vector2(250, y + 34), rows[i][0], 23, GOLD)
		_text(Vector2(250, y + 68), rows[i][1], 18, Color("d7cbbd"))
	_text(Vector2(0, 650), "V  ·  Fechar     ESC  ·  Pausar", 18, Color("aea493"), HORIZONTAL_ALIGNMENT_CENTER, vs.x)
