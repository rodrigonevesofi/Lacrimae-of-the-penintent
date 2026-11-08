extends Node2D
## Cena principal: monta a fase, luzes, jogador, HUD, save e narrativa.

const Util = preload("res://scripts/util.gd")
const GuiltText = preload("res://scripts/guilt_text.gd")
const PlayerScript = preload("res://scripts/player.gd")
const EnemyScript = preload("res://scripts/enemy.gd")
const HudScript = preload("res://scripts/hud.gd")
const WorldArt = preload("res://scripts/world_art.gd")
const Story = preload("res://scripts/story_text.gd")

const GROUND_Y := 600.0
const WORLD_W := 30000.0
const SAVE_PATH := "user://lacrimae_save.json"

var narrative
var exploration
var pending_altar := -1
var prayer_cooldown := 0.0
var memory_seen := false
var echo_count := 0
var death_count := 0
var iria_met := false
var memorial_honored := false
var doll_found := false
var story_flags: Array[String] = []
var dialogue_pages: Array[Dictionary] = []
var dialogue_complete_flag := ""
var state := "title"
var prologue_page := -1
var paused := false
var area_name := ""
var area_t := 0.0
var art: Node2D
var soundscape: Node
const TOMB_POS := Vector2(150, 600)
const SWORD_POS := Vector2(340, 600)
const PROLOGUE: Array[Dictionary] = [
	{"title": "O TÚMULO SEM NOME", "text": "Você desperta em um túmulo de pedra, nas profundezas\nde uma catedral abandonada. Não se lembra do seu nome.\n\nMarcas de antigos rituais cobrem seu corpo. Ao seu lado,\numa coroa enferrujada repousa entre espinhos."},
	{"title": "A INSCRIÇÃO", "text": "Aquele que condenou milhares deverá carregar\no peso de cada lágrima.\n\nQue sua morte seja negada até que sua culpa\nencontre repouso."},
	{"title": "O PENITENTE DAS LÁGRIMAS", "text": "Uma espada foi fincada diante de seu túmulo.\nAlém da cripta, um reino que não consegue morrer espera.\n\nEncontre a espada e procure um altar de penitência.\nSua história permanece enterrada em Vespera."},
]
var t := 0.0
var play_time := 0.0
var player
var hud
var dyn: Node2D
var fxn: Node2D
var boss = null
var boss_wall = null
var boss_defeated := false
var ending_countdown := -1.0
var ending_t := 0.0
var death_t := 0.0
var respawn_index := 0
var relic_taken := false
var relic_light: PointLight2D
var stain_light: PointLight2D
var stain_anchor: Node2D
var stain_animation
const FRAGMENT_LIFT := Vector2(0, -46)
var stain_active := false
var death_pos := Vector2.ZERO
var penitence_menu := false
var stain_amount := 0
var stain_pos := Vector2.ZERO
var has_save := false
var prompt := ""
var message_title := ""
var message_text := ""
var message_t := 0.0
var toast_text := ""
var toast_t := 0.0
var fx_list: Array = []
var flicker: Array = []

var relic_pos := Vector2(14580, 1100)

var altars: Array[Vector2] = [Vector2(540, 600), Vector2(1810, 600), Vector2(3620, 600)]

var platforms: Array[Rect2] = [
	Rect2(380, 520, 140, 22),
	Rect2(1350, 520, 120, 22),
	Rect2(1500, 440, 120, 22),
	Rect2(1650, 360, 220, 22),
	Rect2(2700, 520, 160, 22),
	Rect2(2950, 440, 160, 22),
	Rect2(3200, 520, 140, 22),
	Rect2(4000, 515, 150, 22),
	Rect2(4500, 515, 150, 22),
]

# [tipo, x, y, alcance]  (0 = devoto, 1 = chorão)
var enemy_defs: Array = [
	[0, 800.0, 600.0, 140.0],
	[0, 1250.0, 600.0, 160.0],
	[1, 1750.0, 480.0, 110.0],
	[0, 2600.0, 600.0, 150.0],
	[0, 2950.0, 600.0, 160.0],
	[1, 3100.0, 470.0, 130.0],
	[0, 3350.0, 600.0, 110.0],
]

var candle_xs: Array[float] = [
	150.0, 330.0, 540.0, 700.0, 960.0, 1180.0, 1420.0, 1700.0, 1860.0,
	2330.0, 2520.0, 2800.0, 3050.0, 3300.0, 3560.0, 3700.0, 3900.0, 4150.0, 4450.0, 4700.0,
]

var lore: Array = [
	{"x": 730.0, "title": "A Primeira Mártir",
	"text": "Diante de um antigo altar, ela chorou sangue.\nOs registros dizem que centenas receberam absolvição.\n\nDesde então, Vespera passou a medir a culpa em lágrimas."},
	{"x": 1390.0, "title": "A Regra do Confessor",
	"text": "Bem-aventurados os que choram.\n\nDecreto de Edran: quem não chora deverá aprender a dor.\nUma segunda mão riscou: misericórdia quero, não sacrifício.\n\nÀ margem: procure no campanário aquilo que ainda o ergue."},
	{"x": 2630.0, "title": "A Pedra e a Sentença",
	"text": "Quem está sem pecado, atire a primeira pedra.\n\nA Ordem raspou a primeira linha. Conservou as pedras.\nAs lágrimas levaram o remorso. Os atos permaneceram."},
	{"x": 3860.0, "title": "Os Portões Fechados",
	"text": "Foi a justiça que ergueu estes portões.\n\nA sentença foi gravada acima da tranca.\nEmbaixo, alguém riscou: aqui também esperavam crianças.\n\nA assinatura foi raspada. Sua mão treme ao tocar a pedra."},
]

var altar_names: Array[String] = ["Altar das Primeiras Lágrimas", "Altar do Limiar", "Altar da Última Vela"]


func _ready() -> void:
	add_to_group("game")
	has_save = FileAccess.file_exists(SAVE_PATH)
	_setup_input()
	soundscape = preload("res://scripts/soundscape.gd").new()
	add_child(soundscape)
	_build_art()
	_build_world()
	_build_player()
	_build_fx_layer()
	_build_hud()
	_build_lights()
	narrative = preload("res://scripts/narrative.gd").new()
	narrative.game = self
	add_child(narrative)
	exploration = preload("res://scripts/exploration.gd").new()
	exploration.game = self
	add_child(exploration)
	exploration.build()
	state = "title"
	player.revive(TOMB_POS)
	exploration.set_camera()
	player.controllable = false


func _build_art() -> void:
	art = WorldArt.new()
	art.game = self
	add_child(art)


func toggle_pause() -> void:
	if state == "title" or state == "ending" or (narrative != null and narrative.mode != ""):
		return
	paused = not paused
	get_tree().paused = paused


func advance_message() -> void:
	if message_t > 0.0:
		return
	if not dialogue_pages.is_empty():
		var next_page: Dictionary = dialogue_pages.pop_front()
		show_message(str(next_page.title), str(next_page.text))
		return
	if not dialogue_complete_flag.is_empty():
		if not story_flags.has(dialogue_complete_flag): story_flags.append(dialogue_complete_flag)
		dialogue_complete_flag = ""
		_save()
	if prologue_page >= 0 and prologue_page < PROLOGUE.size() - 1:
		prologue_page += 1
		show_message(PROLOGUE[prologue_page]["title"], PROLOGUE[prologue_page]["text"])
	else:
		prologue_page = -1
		message_text = ""
		player.controllable = true


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("map") and state == "play" and narrative.mode == "" and message_text == "" and not penitence_menu and player.state == "idle":
		exploration.map_open = not exploration.map_open
	if event.is_action_pressed("penitence_menu") and state == "play" and narrative.mode == "" and message_text == "":
		if penitence_menu:
			penitence_menu = false
		elif player.state == "idle" and player.is_on_floor() and at_altar():
			penitence_menu = true
		else:
			toast("As penitências só podem ser trocadas em um altar.")
	if event.is_action_pressed("mute"):
		soundscape.toggle_mute()
	if event.is_action_pressed("pause"):
		toggle_pause()
		get_viewport().set_input_as_handled()


# ---------------------------------------------------------------- entrada
func _add_action(action: String, keys: Array) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	for k in keys:
		var ev := InputEventKey.new()
		ev.physical_keycode = k
		InputMap.action_add_event(action, ev)


func _setup_input() -> void:
	_add_action("map", [KEY_TAB])
	_add_action("down", [KEY_S, KEY_DOWN])
	_add_action("penitence_menu", [KEY_V])
	_add_action("penitence_none", [KEY_1])
	_add_action("penitence_nails", [KEY_2])
	_add_action("penitence_chains", [KEY_3])
	_add_action("pause", [KEY_ESCAPE])
	_add_action("mute", [KEY_M])
	_add_action("left", [KEY_A, KEY_LEFT])
	_add_action("right", [KEY_D, KEY_RIGHT])
	_add_action("jump", [KEY_SPACE, KEY_W, KEY_UP])
	_add_action("attack", [KEY_J, KEY_X])
	_add_action("roll", [KEY_K, KEY_SHIFT])
	_add_action("heal", [KEY_F])
	_add_action("penance", [KEY_Q])
	_add_action("interact", [KEY_E])
	_add_action("offer", [KEY_R])
	_add_action("confirm", [KEY_ENTER, KEY_KP_ENTER])
	_add_action("continue_game", [KEY_C])


# ---------------------------------------------------------------- construção
func _add_solid(r: Rect2, one_way: bool) -> StaticBody2D:
	var b := StaticBody2D.new()
	b.set_meta("one_way",one_way)
	b.collision_layer = 1
	b.collision_mask = 0
	var cs := CollisionShape2D.new()
	var rs := RectangleShape2D.new()
	rs.size = r.size
	cs.shape = rs
	cs.position = r.position + r.size / 2.0
	cs.one_way_collision = one_way
	b.add_child(cs)
	add_child(b)
	return b


func _build_world() -> void:
	var mod := CanvasModulate.new()
	mod.color = Color(0.76, 0.74, 0.80)
	add_child(mod)
	_add_solid(Rect2(0, GROUND_Y, 2000, 400), false)
	_add_solid(Rect2(2270, GROUND_Y, 2530, 400), false)
	_add_solid(Rect2(-60, -600, 60, 2000), false)
	_add_solid(Rect2(4800, -600, 60, 2000), false)
	for p in platforms:
		_add_solid(p, true)
	dyn = Node2D.new()
	dyn.draw.connect(_draw_dynamic)
	add_child(dyn)


func _build_player() -> void:
	player = PlayerScript.new()
	player.position = altars[0]
	add_child(player)
	player.died.connect(_on_player_died)


func _build_fx_layer() -> void:
	fxn = Node2D.new()
	fxn.z_index = 10
	fxn.draw.connect(_draw_fx)
	add_child(fxn)


func _build_hud() -> void:
	var cl := CanvasLayer.new()
	cl.layer = 10
	add_child(cl)
	hud = HudScript.new()
	hud.game = self
	cl.add_child(hud)


func _add_flicker_light(pos: Vector2, col: Color, energy: float, sc: float) -> PointLight2D:
	var l := Util.make_light(col, energy, sc)
	l.position = pos
	add_child(l)
	flicker.append([l, energy, randf_range(4.0, 9.0), randf_range(0.0, 6.0)])
	return l


func _build_lights() -> void:
	for i in range(0, candle_xs.size(), 3):
		_add_flicker_light(Vector2(candle_xs[i], GROUND_Y - 24.0), Color(1.0, 0.68, 0.38), 0.35, 1.7)
	for a in altars:
		_add_flicker_light(a + Vector2(0, -60), Color(1.0, 0.78, 0.5), 0.65, 2.6)
	relic_light = _add_flicker_light(relic_pos + Vector2(0, -30), Color(1.0, 0.85, 0.5), 1.1, 1.8)
	_add_flicker_light(Vector2(2135, 780), Color(0.75, 0.2, 0.2), 0.8, 3.0)
	_add_flicker_light(Vector2(4290, 380), Color(0.9, 0.3, 0.25), 0.6, 5.0)
	stain_light = Util.make_light(Color(0.6, 0.8, 1.0), 0.9, 1.5)
	stain_light.visible = false
	add_child(stain_light)
	stain_anchor = Node2D.new()
	stain_anchor.visible = false
	stain_anchor.z_index = 5
	stain_animation = preload("res://scripts/actor_animation.gd").new()
	stain_animation.configure("fragmento", 0.72)
	stain_anchor.add_child(stain_animation)
	add_child(stain_anchor)


# ---------------------------------------------------------------- jogo
func _start_game(load_save: bool, cinematic: bool = true) -> void:
	exploration.reset()
	story_flags.clear()
	dialogue_pages.clear()
	dialogue_complete_flag = ""
	player.max_flasks = 3
	memory_seen = false
	echo_count = 0
	death_count = 0
	iria_met = false
	doll_found = false
	memorial_honored = false
	player.has_weapon = false
	penitence_menu = false
	player.penitence = "none"
	player.max_hp = 100.0
	player.upgrades = 0
	player.culpa = 0.0
	player.lagrimas = 0
	player.has_double_jump = false
	relic_taken = false
	boss_defeated = false
	respawn_index = 0
	stain_amount = 0
	stain_active = false
	ending_countdown = -1.0
	play_time = 0.0
	if load_save:
		_load()
	else:
		_delete_save()
	player.revive(altars[respawn_index] if load_save else TOMB_POS)
	exploration.room = exploration.room_at(player.position)
	exploration.set_camera()
	area_name = ""
	message_text = ""
	prologue_page = -1
	relic_light.visible = not relic_taken
	_spawn_enemies()
	state = "play"
	if load_save and boss_defeated:
		if memory_seen:
			toast("A primeira Lágrima permanece. Ainda há caminhos por percorrer.")
		else:
			ending_countdown = 3.5
			narrative.begin("memory")
	if not load_save:
		prologue_page = 0
		show_message(PROLOGUE[0]["title"], PROLOGUE[0]["text"])
		if cinematic:
			message_text = ""
			narrative.begin("opening")



func _spawn_enemies() -> void:
	for hazard in get_tree().get_nodes_in_group("hazards"): hazard.queue_free()
	for e in get_tree().get_nodes_in_group("enemies"):
		e.queue_free()
	if boss_wall != null and is_instance_valid(boss_wall):
		boss_wall.queue_free()
	boss_wall = null
	boss = null
	for d in enemy_defs:
		var e = EnemyScript.new()
		e.setup(d[0], Vector2(d[1], d[2]), d[3], player)
		e.killed.connect(_on_enemy_killed)
		add_child(e)
	exploration.spawn_enemies()
	if not boss_defeated:
		var b = EnemyScript.new()
		b.setup(2, Vector2(4380.0, GROUND_Y), 0.0, player)
		b.killed.connect(_on_enemy_killed)
		add_child(b)
		b.display_name = "Guardião dos Sinos"
		boss = b


func _on_enemy_killed(e) -> void:
	if e.kind == 2:
		boss_defeated = true
		ending_countdown = 3.5
		toast("O Guardião dos Sinos silencia.")
		if narrative.mode != "": narrative.finish()
		# The bell goes quiet first; the memory of the gates follows on its own.
		narrative.begin("boss_end")
		if boss_wall != null and is_instance_valid(boss_wall):
			boss_wall.queue_free()
		boss_wall = null
		_save()


func _on_player_died() -> void:
	death_pos = player.global_position if player.global_position.y <= exploration.rooms[exploration.room].bounds.end.y else player.safe_pos
	penitence_menu = false
	state = "dead"
	death_count += 1
	death_t = 3.0


func _respawn() -> void:
	stain_active = true
	stain_amount = player.lagrimas
	stain_pos = death_pos
	player.lagrimas = 0
	player.add_culpa(25)
	player.revive(altars[respawn_index])
	exploration.room = exploration.room_at(player.position)
	exploration.set_camera()
	_spawn_enemies()
	state = "play"
	toast("Recupere o fragmento: capacidade limitada e inimigos próximos fortalecidos.")
	_save()


func show_message(title: String, text: String) -> void:
	message_title = title
	message_text = text
	message_t = 0.25
	player.controllable = false


var seen_kinds: Array = []

func announce_enemy(kind: int) -> void:
	if seen_kinds.has(kind) or not EnemyScript.BESTIARY.has(kind): return
	seen_kinds.append(kind)
	toast(EnemyScript.BESTIARY[kind])

func toast(s: String) -> void:
	toast_text = s
	toast_t = 5.0 if s.length() > 70 else 3.0


## The recovered fragment comes apart into light where it lay.
func _dissolve_fragment(pos: Vector2) -> void:
	var anchor := Node2D.new()
	anchor.position = pos + FRAGMENT_LIFT
	anchor.z_index = 5
	var animation = preload("res://scripts/actor_animation.gd").new()
	animation.configure("fragmento", 0.72)
	anchor.add_child(animation)
	add_child(anchor)
	animation.select("dissolve", 1)
	animation.animation_finished.connect(anchor.queue_free)

func spawn_fx(pos: Vector2, col: Color) -> void:
	var effect_anchor := Node2D.new()
	effect_anchor.position = pos
	var animation = preload("res://scripts/actor_animation.gd").new()
	animation.configure("fx", 0.28)
	effect_anchor.add_child(animation)
	add_child(effect_anchor)
	animation.select("impact", 1)
	animation.modulate = col
	animation.animation_finished.connect(effect_anchor.queue_free)
	fx_list.append({"p": pos, "t": 0.0, "c": col})


func shake_cam(amount: float) -> void:
	if player:
		player.shake = maxf(player.shake, amount)


# ---------------------------------------------------------------- save
func _save() -> void:
	var data := {
		"story_flags": story_flags,
		"layout_version": 2,
		"exploration": exploration.serialize(),
		"altar": respawn_index,
		"penitence": player.penitence,
		"stain_active": stain_active,
		"stain_amount": stain_amount,
		"stain_pos": [stain_pos.x, stain_pos.y],
		"memory_seen": memory_seen,
		"echo_count": echo_count,
		"iria_met": iria_met,
		"doll_found": doll_found,
		"memorial_honored": memorial_honored,
		"weapon": player.has_weapon,
		"lagrimas": player.lagrimas,
		"culpa": player.culpa,
		"double_jump": player.has_double_jump,
		"relic": relic_taken,
		"boss": boss_defeated,
		"upgrades": player.upgrades,
	}
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(data))
		f.close()


func _load() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if f == null:
		return
	var parsed = JSON.parse_string(f.get_as_text())
	f.close()
	if typeof(parsed) != TYPE_DICTIONARY:
		return
	story_flags.clear()
	var saved_story = parsed.get("story_flags", [])
	if saved_story is Array:
		for flag in saved_story:
			if flag in ["names_read", "memorial_named"] and not story_flags.has(str(flag)): story_flags.append(str(flag))
	respawn_index = clampi(int(parsed.get("altar", 0)), 0, altars.size() - 1)
	memory_seen = bool(parsed.get("memory_seen", false))
	echo_count = clampi(int(parsed.get("echo_count", 0)), 0, 99)
	iria_met = bool(parsed.get("iria_met", false))
	doll_found = bool(parsed.get("doll_found", false))
	memorial_honored = bool(parsed.get("memorial_honored", false))
	player.has_weapon = bool(parsed.get("weapon", true))
	player.lagrimas = int(parsed.get("lagrimas", 0))
	player.culpa = float(parsed.get("culpa", 0.0))
	player.has_double_jump = bool(parsed.get("double_jump", false))
	relic_taken = bool(parsed.get("relic", false))
	boss_defeated = bool(parsed.get("boss", false))
	player.upgrades = int(parsed.get("upgrades", 0))
	player.apply_penitence(str(parsed.get("penitence", "none")))
	stain_active = bool(parsed.get("stain_active", false))
	stain_amount = maxi(int(parsed.get("stain_amount", 0)), 0)
	var saved_stain: Array = parsed.get("stain_pos", [0, 600])
	if saved_stain.size() == 2:
		stain_pos = Vector2(clampf(float(saved_stain[0]), 20, WORLD_W - 20), clampf(float(saved_stain[1]), -600, 1300))
	player.add_culpa(0)
	exploration.restore(parsed.get("exploration",{}))
	if int(parsed.get("layout_version",1)) < 2 and boss_defeated:
		exploration.bells = ["water","vigil"]
		exploration.update_gate()


func _delete_save() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))


# ---------------------------------------------------------------- loop
func _process(delta: float) -> void:
	t += delta
	prayer_cooldown = maxf(prayer_cooldown - delta, 0.0)
	area_t = maxf(area_t - delta, 0.0)
	toast_t = maxf(toast_t - delta, 0.0)
	message_t = maxf(message_t - delta, 0.0)
	_update_lights()
	_update_fx(delta)
	dyn.queue_redraw()
	fxn.queue_redraw()
	match state:
		"title":
			if Input.is_action_just_pressed("confirm"):
				_start_game(false)
			elif Input.is_action_just_pressed("continue_game") and has_save:
				_start_game(true)
		"play":
			_play_update(delta)
		"dead":
			death_t -= delta
			if death_t <= 0.0:
				_respawn()
		"ending":
			ending_t += delta
			if ending_t > 15.0 and Input.is_action_just_pressed("confirm"):
				get_tree().reload_current_scene()


func _update_lights() -> void:
	for f in flicker:
		var l: PointLight2D = f[0]
		l.energy = f[1] * (0.92 + 0.08 * sin(t * f[2] + f[3]) + randf() * 0.04)
	if stain_light:
		stain_light.visible = stain_active
		stain_light.position = stain_pos + Vector2(0, -24)
		stain_anchor.visible = stain_active
		stain_anchor.position = stain_pos + FRAGMENT_LIFT + Vector2(0, sin(t * 2.0) * 3.0)
		if stain_active: stain_animation.select("idle", 1)


func _update_fx(delta: float) -> void:
	for f in fx_list:
		f["t"] += delta
	fx_list = fx_list.filter(func(f): return f["t"] < 0.4)


func _play_update(delta: float) -> void:
	play_time += delta
	prompt = ""
	if exploration.has_method("is_transitioning") and exploration.is_transitioning(): return
	if narrative.mode != "":
		return
	if penitence_menu:
		for choice in ["none", "nails", "chains"]:
			if Input.is_action_just_pressed("penitence_" + choice):
				player.apply_penitence(choice)
				penitence_menu = false
				_save()
		return
	if player.state == "execution": return
	if message_text != "":
		player.controllable = false
		if message_t <= 0.0 and (Input.is_action_just_pressed("interact") or Input.is_action_just_pressed("jump") or Input.is_action_just_pressed("confirm") or Input.is_action_just_pressed("attack")):
			advance_message()
		return

	if boss_defeated and ending_countdown > 0.0:
		ending_countdown -= delta
		if ending_countdown <= 0.0: toast("O Guardião caiu. Você pode voltar às passagens ou contemplar a Lágrima junto aos portões.")

	var pp: Vector2 = player.global_position
	# Recovery precedes optional interactions, including NPCs and altars.
	if stain_active and pp.distance_to(stain_pos) < 50:
		_dissolve_fragment(stain_pos)
		player.lagrimas += stain_amount
		stain_active = false
		stain_amount = 0
		toast("Fragmento recuperado. A capacidade da penitência foi restaurada.")
		if echo_count < GuiltText.ECHO.size() and player.state == "idle" and narrative.mode == "":
			# The first recoveries each reveal a little more of what was heard. Nothing changes in the numbers.
			narrative.begin("echo", echo_count)
			echo_count += 1
		else:
			toast("Fragmento recuperado. A capacidade da penitência foi restaurada.\n" + GuiltText.whisper(echo_count))
			echo_count += 1
		_save()
	for target in get_tree().get_nodes_in_group("enemies"):
		if not target.dead and target.state == "stagger" and not target.executing and absf(target.position.x - pp.x) < 72 and absf(target.position.y - pp.y) < (170 if target.family == "flyer" else 80) and player.state == "idle" and player.is_on_floor():
			prompt = "[E] Executar — recupera 8 de vida e 12 de culpa"
			if Input.is_action_just_pressed("interact"): player.begin_execution(target)
			return
	if exploration.room == "city" and boss_defeated and memory_seen and pp.distance_to(Vector2(4700,600)) < 65:
		prompt = "[E] Contemplar a primeira Lágrima · encerrar a vigília"
		if Input.is_action_just_pressed("interact"):
			state = "ending"
			ending_t = 0
			player.controllable = false
		return
	if exploration.update(delta): return
	var new_area := "CRIPTA DO DESPERTAR" if pp.x < 1250.0 else (("PÁTIO DOS NOMES RISCADOS" if pp.x < 2270 else "GALERIA DAS CONFISSÕES") if pp.x < 3300.0 else "PORTÕES DO SILÊNCIO")
	if area_name != new_area:
		area_name = new_area
		area_t = 4.5

	if not player.has_weapon and pp.distance_to(SWORD_POS) < 70.0:
		prompt = "[E] Empunhar a espada"
		if Input.is_action_just_pressed("interact"):
			soundscape.chime()
			player.has_weapon = true
			_save()
			show_message("A ESPADA DIANTE DO TÚMULO", "O metal parece reconhecer sua mão.\nEspinhos e sangue antigo cobrem a lâmina.\n\n[J / X] Atacar   ·   [K / SHIFT] Rolar\nProcure o altar iluminado adiante.")
		return


	if pp.distance_to(Vector2(990, 600)) < 65:
		prompt = "[E] Falar com Iria" if not iria_met else "[E] Ouvir Iria"
		if Input.is_action_just_pressed("interact"):
			iria_met = true
			var has_register: bool = exploration.collected.has("register")
			show_dialogue(Story.iria_pages(has_register, story_flags.has("names_read"), memorial_honored, story_flags.has("memorial_named"), memory_seen), "names_read" if has_register and not story_flags.has("names_read") else "")
			_save()
		return
	if doll_found and pp.distance_to(Vector2(2800, 600)) < 60:
		var known_name: bool = exploration.collected.has("register")
		var can_name: bool = known_name and not story_flags.has("memorial_named")
		if not memorial_honored or can_name:
			prompt = "[E] Gravar o nome de Alba no memorial" if memorial_honored else "[E] Deixar a boneca no memorial"
			if Input.is_action_just_pressed("interact"):
				memorial_honored = true
				if known_name and not story_flags.has("memorial_named"): story_flags.append("memorial_named")
				_save()
				# A scene, not a window: the player kneels, the bell sounds once, and no reward interrupts the silence.
				narrative.begin("memorial", 1 if known_name else 0)
			return

	# relíquia
	if not relic_taken and pp.distance_to(relic_pos) < 50.0:
		_take_relic()
		return

	# altares e lápides
	var near_altar := -1
	for i in range(altars.size()):
		if absf(pp.x - altars[i].x) < 70.0 and absf(pp.y - altars[i].y) < 80.0:
			near_altar = i
	var near_lore := -1
	for i in range(lore.size()):
		var lx: float = lore[i]["x"]
		if absf(pp.x - lx) < 60.0 and absf(pp.y - GROUND_Y) < 80.0:
			near_lore = i

	if near_altar >= 0:
		var cost: int = 100 * (player.upgrades + 1)
		prompt = "[E] Orar  ·  [R] Oferecer %d lágrimas (+15 de vida base)  ·  [V] Penitências" % cost
		if player.state == "idle":
			if Input.is_action_just_pressed("interact"):
				_pray(near_altar)
			elif Input.is_action_just_pressed("offer"):
				offer_health()
	elif near_lore >= 0:
		prompt = "[E] Examinar"
		if Input.is_action_just_pressed("interact"):
			show_message(lore[near_lore]["title"], lore[near_lore]["text"])

	# gatilho do chefe
	if boss != null and is_instance_valid(boss) and not boss.awake and not boss.dead and pp.x > 3900.0 and exploration.bells.size() == 2:
		boss.awaken()
		boss_wall = _add_solid(Rect2(3790, -600, 40, 1200), false)
		if narrative.mode == "": narrative.begin("boss_intro")
		toast("Os sinos tocam. O Guardião reconhece sua presença.")


func _pray(i: int) -> void:
	if i < 0 or i >= altars.size() or narrative.mode != "" or player.state != "idle" or prayer_cooldown > 0:
		return
	pending_altar = i
	player.velocity = Vector2.ZERO
	narrative.begin("prayer")
	soundscape.chime()

func complete_prayer() -> void:
	if pending_altar < 0:
		return
	prayer_cooldown = 0.8
	respawn_index = pending_altar
	exploration.room = exploration.room_at(altars[respawn_index])
	pending_altar = -1
	player.hp = player.max_hp
	player.flasks = player.max_flasks
	player.invuln = 1.2
	soundscape.chime()
	_spawn_enemies()
	_save()
	spawn_fx(player.global_position + Vector2(0, -50), Color(1.0, 0.85, 0.5))
	toast("%s — descanso concluído. Os inimigos comuns retornaram." % altar_names[respawn_index])


func _take_relic() -> void:
	soundscape.chime()
	relic_taken = true
	player.has_double_jump = true
	relic_light.visible = false
	shake_cam(6.0)
	show_message("Relíquia: Espinho da Contrição",
		"Você se ergue uma segunda vez, mesmo depois de cair.\n\nPressione PULO novamente no ar para dar um salto duplo.\n\nA penitência também pode ser um recomeço.")
	_save()


# ---------------------------------------------------------------- desenho dinâmico
func _draw_dynamic() -> void:
	if not relic_taken:
		var bob := sin(t * 2.2) * 6.0
		var c := relic_pos + Vector2(0, -34.0 + bob)
		dyn.draw_circle(c, 15.0, Color(1.0, 0.8, 0.4, 0.25))
		dyn.draw_circle(c, 8.0, Color(1.0, 0.85, 0.5, 0.9))
		for i in range(8):
			var ang := t * 0.8 + float(i) * TAU / 8.0
			var dv := Vector2(cos(ang), sin(ang))
			dyn.draw_line(c + dv * 9.0, c + dv * 17.0, Color(0.9, 0.7, 0.3), 2.0)


func _draw_fx() -> void:
	for f in fx_list:
		var tt: float = f["t"]
		var col: Color = f["c"]
		var a := 1.0 - tt / 0.4
		var c2 := Color(col.r, col.g, col.b, a)
		var p: Vector2 = f["p"]
		fxn.draw_arc(p, 6.0 + tt * 70.0, 0.0, TAU, 14, c2, 3.0)
		for i in range(6):
			var ang := float(i) * TAU / 6.0 + 0.4
			var d1 := Vector2(cos(ang), sin(ang))
			fxn.draw_line(p + d1 * (4.0 + tt * 60.0), p + d1 * (10.0 + tt * 95.0), c2, 2.0)




func play_sfx(name: String) -> void:
	soundscape.play_sfx(name)


func _exit_tree() -> void:
	preload("res://scripts/actor_animation.gd").frames_cache.clear()
	preload("res://scripts/actor_animation.gd").manifest_cache.clear()
	Util.shared_light_texture = null


func at_altar() -> bool:
	for altar in altars:
		if player.position.distance_to(altar) < 70: return true
	return false

func offer_health() -> void:
	if player.state != "idle" or not at_altar(): return
	var cost: int = 100 * (player.upgrades + 1)
	if player.upgrades >= 5: toast("Seu corpo não suporta mais dor.")
	elif player.lagrimas >= cost:
		player.lagrimas -= cost
		player.upgrades += 1
		player.apply_penitence(player.penitence)
		player.hp = player.max_hp
		toast("Sua carne suporta mais dor. (+15 de vida base)")
		_save()
	else: toast("Lágrimas insuficientes.")


func show_dialogue(pages: Array[Dictionary], complete_flag: String = "") -> void:
	dialogue_pages.clear()
	dialogue_complete_flag = complete_flag
	if pages.is_empty(): return
	for i in range(1, pages.size()): dialogue_pages.append(pages[i])
	show_message(str(pages[0].title), str(pages[0].text))

func story_pickup_text(id: String, fallback: String) -> String:
	return Story.pickup_text(id, fallback)

func story_chain_released(id: String) -> void:
	soundscape.play_sfx("corrente_cede")
	toast(Story.chain_line(id))
	if id == "vigil": soundscape.play_knocks(2.4)

func knows_alba() -> bool:
	return exploration.collected.has("register") and doll_found
