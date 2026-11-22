extends Control
## HUD: vida, culpa, lágrimas, chefe, mensagens, título e final

var game = null
var font: Font
var title_font: Font
var title_art: Texture2D
var ui_art: Texture2D
var ui_regions: Dictionary = {}

const GOLD := Color(0.86, 0.7, 0.38)


## Fica em scenes/interface.tscn (camada 10, processa mesmo em pausa, ignora o mouse, 1280 x 720).
## O desenho continua em _draw: barras, molduras, mapa e telas são compostos por código.
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


var pause_notice := ""

func _process(_delta: float) -> void:
	if game != null and not game.paused: pause_notice = ""
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
	if game.narrative != null and (game.narrative.has_focus() or game.narrative.encounter_on):
		return
	_draw_play(vs)
	if game.dev_mode: _draw_dev(vs)
	if game.exploration.map_open: _draw_map(vs)
	if game.exploration.transition > 0: draw_rect(Rect2(Vector2.ZERO,vs),Color(0.02,0.015,0.02,game.exploration.transition/0.4))
	if game.penitence_menu:
		if game.menu_altar == "oferendas": _draw_oferendas(vs)
		else: _draw_penitences(vs)
	if game.paused:
		_draw_pause(vs)


func _heading(pos: Vector2, text: String, font_size: int, color: Color, width: float) -> void:
	draw_string(title_font, pos + Vector2(0, 3), text, HORIZONTAL_ALIGNMENT_CENTER, width, font_size, Color(0, 0, 0, 0.7))
	draw_string(title_font, pos, text, HORIZONTAL_ALIGNMENT_CENTER, width, font_size, color)


## Troca as dicas entre teclado e controle conforme o último aparelho usado.
func _input(event: InputEvent) -> void:
	if game == null: return
	if event is InputEventJoypadButton and event.pressed: game.using_pad = true
	elif event is InputEventJoypadMotion and absf(event.axis_value) > 0.5: game.using_pad = true
	elif (event is InputEventKey and event.pressed) or (event is InputEventMouseButton and event.pressed): game.using_pad = false


## Rótulo da tecla ou do botão, conforme o aparelho em uso.
func _k(keyboard: String, pad: String) -> String:
	return pad if game.using_pad else keyboard


func _unhandled_input(event: InputEvent) -> void:
	if game.dev_input(event):
		get_viewport().set_input_as_handled()
		return
	if (game.state == "title" or game.paused) and event.is_action_pressed("reduce_pulses"):
		game.set_reduced_pulses(not game.reduced_pulses)
		get_viewport().set_input_as_handled()
	if event.is_action_pressed("toggle_fullscreen"):
		game.toggle_fullscreen()
		get_viewport().set_input_as_handled()
		return
	if game.paused and event.is_action_pressed("mute"):
		game.soundscape.toggle_mute()
	if game.paused and event.is_action_pressed("pause"):
		game.toggle_pause()
		get_viewport().set_input_as_handled()
	elif game.paused and event.is_action_pressed("pause_confess"):
		pause_notice = game.confess_from_pause()
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
	_heading(Vector2(360, 456), _k("ENTER", "A") + "  ·  Iniciar peregrinação", 22, Color("e4d3af"), 560)
	if game.has_save:
		_heading(Vector2(360, 513), _k("C", "Y") + "  ·  Continuar jornada", 19, Color("b6b2a8"), 560)
	_text(Vector2(0, 613), _k("A / D  mover     ESPAÇO  saltar     J  atacar     K  esquivar     E  interagir", "ANALÓGICO  mover     A  saltar     X  atacar     B  esquivar     Y  interagir"), 15, Color("aaa69a"), HORIZONTAL_ALIGNMENT_CENTER, vs.x)
	_text(Vector2(0, 642), _k("F  curar     Q  penitência     C  confessar     ESC  pausa     M  som     F11  tela cheia", "LB  curar     LT  penitência     RB  aparar     RT  carregado     START  pausa     BACK  mapa"), 14, Color("888b88"), HORIZONTAL_ALIGNMENT_CENTER, vs.x)
	_text(Vector2(0, 672), "P  ·  Reduzir pulsos e tremores nas cenas: %s" % ("LIGADO" if game.reduced_pulses else "DESLIGADO"), 14, Color("c2bba8") if game.reduced_pulses else Color("888b88"), HORIZONTAL_ALIGNMENT_CENTER, vs.x)


func _bar(pos: Vector2, w: float, h: float, frac: float, col: Color) -> void:
	draw_rect(Rect2(pos.x - 3, pos.y - 3, w + 6, h + 6), Color(0.05, 0.03, 0.03, 0.85))
	draw_rect(Rect2(pos.x, pos.y, w * clampf(frac, 0.0, 1.0), h), col)
	draw_rect(Rect2(pos.x - 3, pos.y - 3, w + 6, h + 6), GOLD, false, 2.0)


func _draw_play(vs: Vector2) -> void:
	var p = game.player
	if p.damage_flash > 0: draw_rect(Rect2(Vector2.ZERO,vs),Color(0.5,0.015,0.025,p.damage_flash*0.5))
	var gore: float = p.gore_flash
	if game.partner != null and is_instance_valid(game.partner): gore = maxf(gore, game.partner.gore_flash)
	if gore > 0.0 and not game.reduced_pulses:
		# Golpe mortal de execução: sangue nas bordas da tela, mais forte nos cantos.
		var g: float = clampf(gore / 0.5, 0.0, 1.0)
		var edge := Color(0.42, 0.0, 0.02, 0.55 * g)
		var clear := Color(0.42, 0.0, 0.02, 0.0)
		var band: float = vs.y * 0.22
		draw_polygon(PackedVector2Array([Vector2(0,0),Vector2(vs.x,0),Vector2(vs.x,band),Vector2(0,band)]),PackedColorArray([edge,edge,clear,clear]))
		draw_polygon(PackedVector2Array([Vector2(0,vs.y-band),Vector2(vs.x,vs.y-band),Vector2(vs.x,vs.y),Vector2(0,vs.y)]),PackedColorArray([clear,clear,edge,edge]))
		draw_polygon(PackedVector2Array([Vector2(0,0),Vector2(band,0),Vector2(band,vs.y),Vector2(0,vs.y)]),PackedColorArray([edge,clear,clear,edge]))
		draw_polygon(PackedVector2Array([Vector2(vs.x-band,0),Vector2(vs.x,0),Vector2(vs.x,vs.y),Vector2(vs.x-band,vs.y)]),PackedColorArray([clear,edge,edge,clear]))
	# Sangue na lente: gotas que espirraram na tela e escorrem.
	for g in game.gotas_tela:
		var k: float = g.t / g.vida
		var a: float = (1.0 - smoothstep(0.55, 1.0, k)) * 0.85
		var c: Vector2 = g.p + Vector2(0.0, g.escorre * g.t)
		var r: float = g.r * (1.0 + 0.15 * minf(g.t * 6.0, 1.0))
		draw_circle(c, r, Color(0.36, 0.0, 0.02, a * 0.9))
		draw_circle(c + Vector2(-r * 0.25, -r * 0.2), r * 0.62, Color(0.55, 0.02, 0.05, a * 0.8))
		draw_rect(Rect2(c.x - r * 0.18, c.y, r * 0.36, g.escorre * g.t * 1.6 + r * 0.6), Color(0.38, 0.0, 0.02, a * 0.75))
		draw_circle(c + Vector2(-r * 0.35, -r * 0.4), r * 0.16, Color(0.95, 0.5, 0.5, a * 0.35))
	if game.clarao_t > 0.0:
		var ca: Color = game.clarao_cor
		ca.a *= game.clarao_t / game.clarao_dur
		draw_rect(Rect2(Vector2.ZERO, vs), ca)
	# Os dois recipientes compartilham uma moldura ornamental, mantendo preenchimento e rótulos legíveis.
	draw_texture_rect(ui_regions.seal,Rect2(18,20,84,100),false)
	_ornate_bar(Rect2(80,-4,370,96),p.hp/p.max_hp,Color("8f182b"))
	_ornate_bar(Rect2(80,29,330,82),p.culpa/100.0,Color("aa874d"))
	_text(Vector2(126,23),"VIGÍLIA",11,Color("dfc8a0"))
	_text(Vector2(314,46),"%d / %d" % [ceil(p.hp),p.max_hp],12,Color("f2dfc7"))
	_text(Vector2(123,98),"CULPA",11,Color("c8ad83"))
	# Mostra a vida da parceira e o peso da lança de Beatriz.
	var duo: bool = game.partner != null and is_instance_valid(game.partner)
	var q = game.partner if duo else null
	var other: String = "beatriz" if p.character == "penitente" else "penitente"
	_text(Vector2(200,23),"· " + str(p.CHARACTERS[p.character].name),11,Color("e8d6b0"))
	var other_ratio: float = (q.hp / q.max_hp) if duo else (p.partner_hp / p.max_hp)
	draw_rect(Rect2(232,112,130,7),Color(0,0,0,0.6))
	draw_rect(Rect2(232,112,130*clampf(other_ratio,0,1),7),Color("6b2030"))
	var tag: String = ((" (jogo · J2 assume)" if q.ai else " (Jogador 2)") if duo else " (T)")
	_text(Vector2(368,119),str(p.CHARACTERS[other].name).capitalize() + tag,10,Color("b9ad98"))
	var lance_holder = q if duo else (p if p.character == "beatriz" else null)
	if lance_holder != null:
		draw_rect(Rect2(232,124,130,5),Color(0,0,0,0.6))
		draw_rect(Rect2(232,124,130*lance_holder.lance_weight/100.0,5),Color("8a8a90"))
		_text(Vector2(368,130),"Peso da lança",10,Color("a8a8ae"))
	if duo and q.state == "fallen":
		_text(Vector2(232,146),game.pad_text("Beatriz caiu · chegue perto e segure H"),12,Color("e05a5a"))
	elif duo and p.state == "fallen":
		_text(Vector2(232,146),"Você caiu · Beatriz pode te levantar",12,Color("e05a5a"))
	elif not duo and p.hp <= p.max_hp * 0.25 and p.partner_hp > p.max_hp * 0.30 and p.share_cd <= 0.0:
		_text(Vector2(232,146),game.pad_text("H · Sangue compartilhado"),12,Color("e05a5a"))
	if game.stain_active:
		draw_rect(Rect2(80+330*0.122+330*0.785*0.75,29+82*0.48,330*0.785*0.25,82*0.17),Color("342f38"))
		_text(Vector2(259,98),"Culpa pendente · capacidade 75%",11,Color("c79c97"))
	elif p.culpa >= 50:
		_text(Vector2(278,98),_k("Q", "LT") + " · PENITÊNCIA",11,Color("e9c991"))
	for i in range(p.max_flasks):
		draw_texture_rect(ui_regions.flask,Rect2(122+i*30,104,20,37),false,Color.WHITE if i<p.flasks else Color(0.35,0.32,0.34,0.75))
	if p.penitence != "none":
		_text(Vector2(122,159),"Pregos da Contrição" if p.penitence == "nails" else "Correntes do Voto",13,Color("c6af8b"))
	# Um pequeno contador de relíquias, em vez de texto grande e isolado na interface.
	_panel(Rect2(vs.x-222,18,198,67))
	draw_texture_rect(ui_regions.tear,Rect2(vs.x-212,28,30,43),false)
	_text(Vector2(vs.x-170,61),str(p.lagrimas),28,Color("e8d8bd"))
	_text(Vector2(vs.x-171,34),"LÁGRIMAS",10,Color("beaa88"))
	_panel(Rect2(vs.x-370,88,350,78))
	var objective: String = game.exploration.objective()
	var objective_x: float = vs.x-350
	for i in range(_wrap(objective,320,14).size()):
		_text(Vector2(objective_x,111+i*20),_wrap(objective,320,14)[i],14,Color("ded1b9"))
	_text(Vector2(vs.x-176,170),_k("TAB", "BACK") + " · CARTOGRAFIA",11,Color("c6af8b"))
	# O Confessionário abre em qualquer lugar; a dica se apaga enquanto houver combate.
	var can_confess: bool = game.calm_t >= game.CALM_BEFORE_CONFESSION
	_text(Vector2(vs.x-345,170),_k("C", "Y (segurar)") + " · CONFESSAR",11,Color("c6af8b") if can_confess else Color(0.45,0.4,0.36,0.6))
	if game.confess_hold_t > 0.08:
		# Barra de progresso enquanto Y está pressionado.
		var hold: float = clampf(game.confess_hold_t / game.CONFESS_HOLD, 0.0, 1.0)
		draw_rect(Rect2(vs.x-345,175,130,3),Color(0,0,0,0.5))
		draw_rect(Rect2(vs.x-345,175,130*hold,3),Color("e0c88f"))
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
	var fb = game.final_boss
	if fb != null and is_instance_valid(fb) and fb.awake and not fb.fallen and game.exploration.room == "vale":
		# O chefe do Vale: quatro partes de armadura, uma por quarto da barra. O nome não revela quem ele é.
		_ornate_bar(Rect2(vs.x/2-300,10,600,112),fb.hp/fb.max_hp,Color("872a32"),true)
		for k in range(1,4):
			var tick_x: float = vs.x/2-300+600.0*k/4.0
			draw_line(Vector2(tick_x,52),Vector2(tick_x,82),Color(0.92,0.8,0.55,0.9 if fb.stage < 4-k+1 else 0.35),2)
		_heading(Vector2(0,132),fb.NOME,22,Color("d5bd92"),vs.x)
		if fb.intro:
			_text(Vector2(0,156),"Ele ergue a cabeça.",13,Color("c5c0b3"),HORIZONTAL_ALIGNMENT_CENTER,vs.x)
		elif fb.form == "mirror":
			_text(Vector2(0,156),"REFLEXO · seus golpes voltam para você · apare (L) ou espere a oração",13,Color("e05a5a"),HORIZONTAL_ALIGNMENT_CENTER,vs.x)
		else:
			_text(Vector2(0,156),"FORMA VERDADEIRA · vulnerável por %d s" % int(ceil(maxf(fb.form_t,0.0))),13,Color("e8c873"),HORIZONTAL_ALIGNMENT_CENTER,vs.x)
	_draw_npc(vs)
	_draw_aviso_mundo(vs)
	# Os avisos de tecla agora aparecem no mundo (_draw_aviso_mundo); a faixa de baixo só ensina os controles no começo.
	if game.prompt == "" and game.play_time < 18 and game.message_text == "":
		_text(Vector2(0,vs.y-24),_k("A/D · mover     ESPAÇO · saltar     J · espada (4 golpes)     I · toque ascendente / segure carregado     L · aparo     K · esquiva     U · lâmina de sangue     TAB · mapa", "ANALÓGICO · mover     A · saltar     X · espada (4 golpes)     RT · toque ascendente / segure carregado     RB · aparo     B · esquiva     R3 · lâmina     BACK · mapa"),13,Color("c7baa4"),HORIZONTAL_ALIGNMENT_CENTER,vs.x)
	if game.toast_t > 0:
		var text_lines := _wrap(game.pad_text(game.toast_text),800,17)
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
	var lines := _wrap(game.pad_text(game.message_text),rect.size.x-110,19)
	for i in range(lines.size()): _text(rect.position+Vector2(55,115+i*25),lines[i],19,Color("e4d6c0"))
	_text(Vector2(rect.position.x,rect.end.y-25),_k("E", "A") + " · Continuar",14,Color("bba27c"),HORIZONTAL_ALIGNMENT_CENTER,rect.size.x)

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
	_text(Vector2(0,650),"Linhas douradas: atalhos abertos    ·    " + _k("TAB", "BACK") + ": retornar",14,Color("aa987b"),HORIZONTAL_ALIGNMENT_CENTER,vs.x)


func _draw_ending(vs: Vector2) -> void:
	var fa := clampf(game.ending_t / 1.5, 0.0, 1.0)
	var lines: Array = [
		"O Guardião dos Sinos silencia. A cidade ainda não descansa.",
		"A primeira Lágrima Sagrada desperta uma lembrança dos portões.",
		"Você viu suas mãos fechando os portões. Ainda não sabe por quê.",
		"Esta é apenas a primeira etapa da peregrinação.",
	]
	var fim := "— FIM DO CAPÍTULO JOGÁVEL —"
	if game.final_defeated:
		# Depois do Vale, o encerramento fecha a história e deixa a pergunta da continuação.
		lines = [
			"O Flagelado não se levanta. Não havia outro no vale.",
			"Você olhou o que fez. Atrás de você, os portões ficam abertos.",
			"Beatriz caminha ao seu lado. O que é de um, carregam os dois.",
			"Agora você sabe de quem eram as mãos. Falta saber de quem era a ordem.",
		]
		fim = "— FIM —"
	if ending_art != null:
		# A imagem de encerramento ocupa a tela inteira. O Penitente e a lanterna permanecem nítidos; as quatro linhas
		# surgem uma por vez na faixa escura inferior, e a tela final aparece quando ENTER fica disponível.
		draw_rect(Rect2(Vector2.ZERO, vs), Color(0, 0, 0, 1.0))
		draw_texture_rect(ending_art, Rect2(Vector2.ZERO, vs), false, Color(1, 1, 1, fa))
		draw_rect(Rect2(0, vs.y - 120, vs.x, 120), Color(0, 0, 0, 0.5 * fa))
		for i in range(lines.size()):
			var start := 1.2 + float(i) * 3.2
			var la := smoothstep(start, start + 0.7, game.ending_t) * (1.0 - smoothstep(start + 2.5, start + 3.2, game.ending_t))
			_text(Vector2(0, vs.y - 62.0), lines[i], 21, Color(0.92, 0.88, 0.8, la), HORIZONTAL_ALIGNMENT_CENTER, vs.x)
		var tb := clampf((game.ending_t - 15.0) / 1.5, 0.0, 1.0)
		_heading(Vector2(0, 84), fim, 30, Color(GOLD, tb), vs.x)
		_text(Vector2(0, vs.y - 60.0), _k("ENTER", "A") + "  —  voltar ao título", 20, Color(0.88, 0.84, 0.78, tb), HORIZONTAL_ALIGNMENT_CENTER, vs.x)
		return
	draw_rect(Rect2(Vector2.ZERO, vs), Color(0, 0, 0, 0.94 * fa))
	for i in range(lines.size()):
		var la := clampf((game.ending_t - 1.5 - float(i) * 2.6) / 1.2, 0.0, 1.0)
		draw_multiline_string(font, Vector2(180, 170.0 + float(i) * 78.0), lines[i], HORIZONTAL_ALIGNMENT_CENTER, vs.x - 360.0, 22, -1, Color(0.9, 0.87, 0.82, la))
	var ta := clampf((game.ending_t - 15.0) / 1.5, 0.0, 1.0)
	_text(Vector2(0, vs.y - 120.0), fim, 30, Color(GOLD, ta), HORIZONTAL_ALIGNMENT_CENTER, vs.x)
	_text(Vector2(0, vs.y - 80.0), _k("ENTER", "A") + "  —  voltar ao título", 20, Color(0.85, 0.8, 0.78, ta), HORIZONTAL_ALIGNMENT_CENTER, vs.x)


func _draw_dev(vs: Vector2) -> void:
	var rooms: Array = game.dev_rooms()
	var box := Rect2(vs.x - 330, 140, 310, 40 + rooms.size() * 22 + 70)
	draw_rect(box, Color(0, 0, 0, 0.72))
	draw_rect(box, Color(1.0, 0.82, 0.42, 0.9), false, 2.0)
	_text(Vector2(box.position.x + 12, box.position.y + 24), "MODO DEV  (F3)", 16, Color("e8c873"))
	for k in range(rooms.size()):
		var sel: bool = k == game.dev_index
		var here: bool = rooms[k] == game.exploration.room
		var label: String = ("▶ " if sel else "   ") + str(game.exploration.rooms[rooms[k]].name).capitalize() + ("  •" if here else "")
		_text(Vector2(box.position.x + 12, box.position.y + 48 + k * 22), label, 14, Color("ffffff") if sel else Color("c5c0b3"))
	var y := box.position.y + 52 + rooms.size() * 22
	var pos: Vector2 = game.player.global_position
	_text(Vector2(box.position.x + 12, y), "↑↓ sala · ENTER ir · B chefe", 13, Color("a8a397"))
	_text(Vector2(box.position.x + 12, y + 20), "G invencível: %s · N voar: %s" % ["SIM" if game.player.dev_god else "não", "SIM" if game.player.dev_fly else "não"], 13, Color("a8a397"))
	_text(Vector2(box.position.x + 12, y + 40), "posição %d, %d" % [int(pos.x), int(pos.y)], 13, Color("7f7b72"))

func _draw_pause(vs: Vector2) -> void:
	draw_rect(Rect2(Vector2.ZERO, vs), Color(0.015, 0.018, 0.024, 0.95))
	_panel(Rect2(170, 75, vs.x - 340, 600))
	_heading(Vector2(0, 132), "A PEREGRINAÇÃO AGUARDA", 28, GOLD, vs.x)
	_text(Vector2(215, 182), "PENITENTE · JOGADOR 1", 17, GOLD)
	_text(Vector2(665, 182), "BEATRIZ · JOGADORA 2", 17, GOLD)
	var first := ["A / D  ·  mover     ESPAÇO / W  ·  saltar", "J  ·  4 golpes: corte, contracorte, estocada, descendente", "I  ·  toque: corte ascendente     segure: carregado", "K e logo J  ·  investida     S + J no ar  ·  mergulho", "J J no ar  ·  dois cortes     U  ·  Lâmina de Sangue", "L  ·  aparar no brilho dourado     K / SHIFT  ·  esquivar", "F  ·  curar     Q  ·  penitência     H  ·  doar sangue", "E  ·  examinar, orar ou executar", "R  ·  oferendas no altar     V  ·  penitências", "S + ESPAÇO  ·  descer de uma galeria"]
	var second := ["← / →  ·  mover     ↑ / Num8  ·  saltar", "↓ / Num2  ·  baixo     Num1 ou .  ·  atacar", "Num5 ou Ç  ·  toque ascendente / segure carregado", "Num3 ou ,  ·  esquivar     Num4 ou ;  ·  aparar", "Num6 ou ~  ·  curar     Num7 ou =  ·  lâmina", "ENTER numérico ou ´  ·  interagir e executar", "Num0 ou [  ·  doar sangue / levantar parceiro", "F4  ·  alternar entre IA e jogadora 2", "O primeiro comando de J2 assume Beatriz", "Também aceita o segundo controle"]
	if game.using_pad:
		first = ["ANALÓGICO / DIRECIONAL  ·  mover", "A  ·  saltar     X  ·  4 golpes", "RT  ·  toque: ascendente     segure: carregado", "B e logo X  ·  investida     ↓ + X no ar  ·  mergulho", "X X no ar  ·  dois cortes     R3  ·  Lâmina de Sangue", "RB  ·  aparar no brilho dourado     B  ·  esquivar", "LB  ·  curar     LT  ·  penitência     ↑  ·  doar sangue", "Y  ·  examinar, orar ou executar", "R3 no altar  ·  oferendas     L3  ·  penitências", "↓ + A  ·  descer de uma galeria"]
		second = ["2º controle, mesmos botões do 1º:", "A saltar · X atacar · B esquivar", "Y interagir · RB aparar · RT carregado", "LB curar · ↑ doar sangue", "", "Teclado: setas e teclado numérico", "F4  ·  alternar entre IA e jogadora 2", "O primeiro comando de J2 assume Beatriz", "", ""]
	for i in range(first.size()):
		_text(Vector2(215, 217 + i * 27), first[i], 16, Color("c5c0b3"))
		_text(Vector2(665, 217 + i * 27), second[i], 16, Color("c5c0b3"))
	_text(Vector2(0, 518), _k("TAB  ·  mapa     M  ·  som     F3  ·  modo dev", "BACK  ·  mapa     (teclado: M som · F3 modo dev)"), 16, Color("c5c0b3"), HORIZONTAL_ALIGNMENT_CENTER, vs.x)
	_text(Vector2(0, 550), "P  ·  reduzir pulsos e tremores: %s" % ("LIGADO" if game.reduced_pulses else "DESLIGADO"), 16, Color("e0d3b0"), HORIZONTAL_ALIGNMENT_CENTER, vs.x)
	_text(Vector2(0, 582), _k("C", "Y") + "  ·  Confessionário (fora de combate)", 17, Color("e0c88f"), HORIZONTAL_ALIGNMENT_CENTER, vs.x)
	if pause_notice != "":
		_text(Vector2(0, 608), pause_notice, 15, Color("e08a7a"), HORIZONTAL_ALIGNMENT_CENTER, vs.x)
	else:
		_text(Vector2(0, 608), "O progresso é salvo ao orar e ao obter a espada ou a relíquia.", 15, Color("8f918e"), HORIZONTAL_ALIGNMENT_CENTER, vs.x)
	_heading(Vector2(0, 640), _k("ESC", "START") + "  ·  Retomar", 22, GOLD, vs.x)


## Oferendas no altar: vida, força e frasco, com o preço em lágrimas e o nível atual.
func _draw_oferendas(vs: Vector2) -> void:
	draw_rect(Rect2(Vector2.ZERO, vs), Color(0.02, 0.016, 0.022, 0.96))
	_heading(Vector2(0, 150), "OFERENDAS", 30, GOLD, vs.x)
	_text(Vector2(0, 192), "As lágrimas recolhidas viram força no altar. Beatriz recebe o mesmo.", 18, Color("b9afa1"), HORIZONTAL_ALIGNMENT_CENTER, vs.x)
	draw_texture_rect(ui_regions.tear, Rect2(vs.x / 2 - 70, 210, 21, 30), false)
	_text(Vector2(vs.x / 2 - 42, 233), "%d lágrimas" % game.player.lagrimas, 20, Color("e8d8bd"))
	for i in range(3):
		var o: Dictionary = game.OFERENDAS[i]
		var nivel: int = game.nivel_oferenda(i)
		var y := 262 + i * 112
		_panel(Rect2(220, y, 840, 92))
		var cheio: bool = nivel >= int(o.max)
		var pode: bool = not cheio and game.player.lagrimas >= game.custo_oferenda(i)
		if pode: draw_rect(Rect2(220, y, 840, 92), GOLD, false, 2)
		var tecla: String = (["X", "Y", "B"][i] if game.using_pad else str(i + 1))
		_text(Vector2(250, y + 36), "%s  ·  %s" % [tecla, o.nome], 23, GOLD if not cheio else Color("8a8070"))
		_text(Vector2(250, y + 70), str(o.efeito), 18, Color("d7cbbd"))
		for k in range(int(o.max)):
			var c := Vector2(760 + k * 26, y + 30)
			draw_circle(c, 8, Color("2b2023"))
			if k < nivel: draw_circle(c, 6, Color(0.75, 0.08, 0.1))
			draw_arc(c, 8, 0, TAU, 16, GOLD, 1.5)
		_text(Vector2(760, y + 72), "completo" if cheio else "%d lágrimas" % game.custo_oferenda(i), 17, Color("e8d8bd") if pode else Color("9c8f80"))
	_text(Vector2(0, 640), "Relíquias espalhadas pelo caminho também fortalecem: Cálices de Sangue (vida) e Espinhos da Ira (dano).", 15, Color("a99a86"), HORIZONTAL_ALIGNMENT_CENTER, vs.x)
	_text(Vector2(0, 670), _k("R  ·  Fechar", "R3  ·  Fechar"), 18, Color("aea493"), HORIZONTAL_ALIGNMENT_CENTER, vs.x)

## Aviso de tecla no mundo: a tecla (ou o botão do controle) aparece acima do que pode ser usado.
const BOTAO_PAD := {"E": "Y", "R": "R3", "V": "L3", "J": "X", "J / X": "X", "K": "B", "K / SHIFT": "B", "L": "RB", "I": "RT", "F": "LB", "Q": "LT", "H": "↑", "U": "R3"}
const COR_PAD := {"A": Color("5aa04e"), "B": Color("c0473f"), "X": Color("4f7fc2"), "Y": Color("d6b13e")}
var _regex_aviso: RegEx

func _itens_aviso(texto: String) -> Array:
	if _regex_aviso == null:
		_regex_aviso = RegEx.new()
		_regex_aviso.compile("\\[([^\\]]+)\\]\\s*([^\\[]*)")
	var itens: Array = []
	for m in _regex_aviso.search_all(texto):
		var rotulo := m.get_string(2).strip_edges()
		while rotulo.ends_with("·"): rotulo = rotulo.left(rotulo.length() - 1).strip_edges()
		itens.append([m.get_string(1).strip_edges(), rotulo])
	if itens.is_empty(): itens.append(["", texto])
	return itens

func _tecla(centro: Vector2, tecla: String) -> float:
	var nome := tecla
	if game.using_pad: nome = BOTAO_PAD.get(tecla, tecla)
	var fonte := get_theme_default_font()
	var tam := 16
	var largura: float = maxf(28.0, fonte.get_string_size(nome, HORIZONTAL_ALIGNMENT_LEFT, -1, tam).x + 14.0)
	if game.using_pad and COR_PAD.has(nome):
		draw_circle(centro, 15, Color(0.06, 0.05, 0.05, 0.92))
		draw_arc(centro, 15, 0, TAU, 28, COR_PAD[nome], 2.5)
		draw_string(fonte, centro + Vector2(-largura / 2.0, 6), nome, HORIZONTAL_ALIGNMENT_CENTER, largura, tam, COR_PAD[nome])
		return 30.0
	var r := Rect2(centro - Vector2(largura / 2.0, 14), Vector2(largura, 28))
	draw_rect(Rect2(r.position + Vector2(0, 3), r.size), Color(0, 0, 0, 0.5))
	draw_rect(r, Color(0.09, 0.06, 0.07, 0.94))
	draw_rect(r, GOLD, false, 2.0)
	draw_line(r.position + Vector2(3, 3), Vector2(r.end.x - 3, r.position.y + 3), Color(1, 0.9, 0.7, 0.25), 1.0)
	draw_string(fonte, Vector2(r.position.x, centro.y + 6), nome, HORIZONTAL_ALIGNMENT_CENTER, largura, tam, Color("f1e3c4"))
	return largura

func _draw_aviso_mundo(vs: Vector2) -> void:
	if game.prompt == "" or game.message_text != "" or game.state != "play" or game.penitence_menu or game.exploration.map_open: return
	var alvo: Vector2 = game.prompt_at if game.prompt_at != Vector2.INF else game.player.global_position + Vector2(0, -150)
	var tela: Vector2 = game.get_viewport().get_canvas_transform() * alvo
	tela.y += sin(game.t * 3.0) * 3.0
	var itens := _itens_aviso(game.prompt)
	var fonte := get_theme_default_font()
	var y := tela.y - (itens.size() - 1) * 36.0
	for item in itens:
		var rotulo: String = item[1]
		var larg_txt: float = fonte.get_string_size(rotulo, HORIZONTAL_ALIGNMENT_LEFT, -1, 15).x
		var larg_tecla: float = 0.0 if item[0] == "" else 34.0
		var total: float = larg_tecla + larg_txt + (10.0 if item[0] != "" else 0.0)
		var x0: float = clampf(tela.x - total / 2.0, 12.0, vs.x - total - 12.0)
		var fundo := Rect2(x0 - 8, y - 17, total + 16, 34)
		draw_rect(fundo, Color(0.03, 0.02, 0.025, 0.72))
		draw_line(Vector2(fundo.position.x, fundo.end.y), Vector2(fundo.end.x, fundo.end.y), Color(GOLD, 0.5), 1.0)
		var tx := x0
		if item[0] != "":
			var w := _tecla(Vector2(x0 + 15, y), item[0])
			tx = x0 + maxf(w, 30.0) + 10.0
		draw_string(fonte, Vector2(tx + 1, y + 7), rotulo, HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color(0, 0, 0, 0.8))
		draw_string(fonte, Vector2(tx, y + 6), rotulo, HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color("eedcc0"))
		y += 36.0
	# Uma seta fina aponta para o que o aviso descreve.
	draw_colored_polygon(PackedVector2Array([Vector2(tela.x - 7, y - 18), Vector2(tela.x + 7, y - 18), Vector2(tela.x, y - 9)]), Color(GOLD, 0.85))

## Iria não é inimiga: um losango dourado e o nome dela aparecem quando o Penitente se aproxima.
func _draw_npc(vs: Vector2) -> void:
	if game.state != "play" or game.exploration.room != "city" or game.message_text != "": return
	var iria := Vector2(990, 600)
	var dist: float = game.player.global_position.distance_to(iria)
	if dist > 640.0: return
	var a: float = clampf((640.0 - dist) / 260.0, 0.0, 1.0)
	var tela: Vector2 = game.get_viewport().get_canvas_transform() * (iria + Vector2(0, -132))
	var bob := sin(game.t * 2.0) * 3.0
	var c := tela + Vector2(0, bob)
	draw_colored_polygon(PackedVector2Array([c + Vector2(0, -9), c + Vector2(7, 0), c + Vector2(0, 9), c + Vector2(-7, 0)]), Color(0.96, 0.85, 0.55, 0.9 * a))
	draw_arc(c, 13, 0, TAU, 24, Color(1, 0.92, 0.7, 0.35 * a), 1.5)
	if dist < 360.0 and game.prompt.find("Iria") < 0:
		var fonte := get_theme_default_font()
		draw_string(fonte, c + Vector2(-100, -18), "IRIA", HORIZONTAL_ALIGNMENT_CENTER, 200, 16, Color(1, 0.92, 0.72, a))
		draw_string(fonte, c + Vector2(-100, -2) + Vector2(0, -2), "a testemunha", HORIZONTAL_ALIGNMENT_CENTER, 200, 12, Color(0.85, 0.78, 0.62, 0.8 * a))

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
		var row_title: String = rows[i][0]
		if game.using_pad: row_title = ["X", "Y", "B"][i] + row_title.substr(1)
		_text(Vector2(250, y + 34), row_title, 23, GOLD)
		_text(Vector2(250, y + 68), rows[i][1], 18, Color("d7cbbd"))
	_text(Vector2(0, 650), _k("V  ·  Fechar     ESC  ·  Pausar", "L3  ·  Fechar     START  ·  Pausar"), 18, Color("aea493"), HORIZONTAL_ALIGNMENT_CENTER, vs.x)
