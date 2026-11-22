extends Node2D
## Cena principal: monta a fase, luzes, jogador, HUD, salvamento e narrativa.

const Util = preload("res://scripts/util.gd")
## O mapa: salas em scenes/salas/ (plataformas, inimigos, altares, pontos especiais...).
const Layout = preload("res://scripts/act_one_layout.gd")
const GuiltText = preload("res://scripts/guilt_text.gd")
const PlayerScene = preload("res://scenes/player.tscn")
const EnemyScript = preload("res://scripts/enemy.gd")
const CriaturaGoyaScript = preload("res://scripts/criatura_goya.gd")
const FinalBossScript = preload("res://scripts/penitent_boss.gd")
const Efeitos = preload("res://scripts/efeitos.gd")
## Uma cena por família de inimigo (scenes/inimigos/); os dados de cada tipo ficam em EnemyScript.TYPES.
const ENEMY_SCENES := {
	"walker": preload("res://scenes/inimigos/inimigo_andante.tscn"),
	"flyer": preload("res://scenes/inimigos/inimigo_voador.tscn"),
	"boss": preload("res://scenes/inimigos/inimigo_chefe.tscn"),
	"mirror": preload("res://scenes/inimigos/inimigo.tscn"),
}
const ValeFinale = preload("res://scripts/vale_finale.gd")
const Story = preload("res://scripts/story_text.gd")
const Telemetry = preload("res://scripts/telemetry.gd")

const GROUND_Y := 600.0
const WORLD_W := 30000.0
const SAVE_PATH := "user://lacrimae_save.json"

var narrative
var exploration
## Confessionário (IA) e telemetria local; veja docs/confessionario.md.
var confessor
var confession_panel
var confession_open := false
var calm_t := 0.0
const CALM_BEFORE_CONFESSION := 1.5
## Controle: segurar Y (interagir) abre o Confessionário. O toque continua sendo
## "interagir"; o atalho só completa quando o toque não iniciou nenhuma ação.
const CONFESS_HOLD := 0.6
var confess_hold_t := 0.0
var _confess_hold_used := false
var telemetry
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
var reduced_pulses := false
const SETTINGS_PATH := "user://settings.cfg"
var area_name := ""
var area_t := 0.0
var art: Node2D
var soundscape: Node
## Pontos especiais (nós Pontos em scenes/salas/): editados no editor, lidos ao iniciar.
var TOMB_POS: Vector2 = Layout.ponto("tumulo")
var SWORD_POS: Vector2 = Layout.ponto("espada")
var IRIA_POS: Vector2 = Layout.ponto("iria")
var MEMORIAL_POS: Vector2 = Layout.ponto("memorial")
## Diante dos portões: descida ao Vale depois do Guardião (ou o encerramento, se o Vale já foi vencido).
var VALE_GATE_POS: Vector2 = Layout.ponto("portao_do_vale")
var GUARDIAN_POS: Vector2 = Layout.ponto("chefe_guardiao")
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
## O menu do altar mostra as penitências ou as oferendas (vida, força, frasco).
var menu_altar := "penitencias"
var stain_amount := 0
var stain_pos := Vector2.ZERO
var has_save := false
var prompt := ""
## Onde o aviso de tecla aparece no mundo (acima do objeto, da pessoa ou da criatura). INF = acima do Penitente.
var prompt_at := Vector2.INF
var message_title := ""
var message_text := ""
var message_t := 0.0
var toast_text := ""
var toast_t := 0.0
var fx_list: Array = []
var flicker: Array = []

var relic_pos: Vector2 = Layout.ponto("reliquia")

## Altares, plataformas, inimigos, velas e inscrições da Cidade: editados em scenes/salas/city.tscn.
## exploration.gd acrescenta os altares das outras salas a altars e altar_names.
var altars: Array[Vector2] = Layout.city_altars()
var altar_names: Array[String] = Layout.city_altar_names()

var platforms: Array[Rect2] = Layout.city_platforms()
## O vão da ponte quebrada (nó Abismo da Cidade): sem chão de x até y.
var abyss_span: Vector2 = Layout.city_abyss()

# [tipo, x, y, alcance]  (0 = devoto, 1 = chorão)
var enemy_defs: Array = Layout.city_enemies()

var candle_xs: Array[float] = Layout.city_candles()

## Inscrições: {"x", "title", "text"}.
var lore: Array = Layout.city_lore()


func _ready() -> void:
	if get_child_count() == 0: _adotar_cena()
	add_to_group("game")
	_crisp_fonts()
	has_save = FileAccess.file_exists(SAVE_PATH)
	_load_settings()
	_setup_input()
	telemetry = Telemetry.new()
	telemetry.load_data()
	telemetry.start_session()
	confessor = _camada("Confessor")
	soundscape = _camada("Som")
	_build_art()
	_build_world()
	_build_player()
	_build_fx_layer()
	_build_hud()
	_build_lights()
	narrative = _camada("Narrativa")
	exploration = _camada("Exploracao")
	exploration.build()
	state = "title"
	player.revive(TOMB_POS)
	exploration.set_camera()
	player.controllable = false


## main.gd sem a cena (Fixture.new() nos testes): adota os nós da main.tscn, para que o jogo seja o mesmo.
func _adotar_cena() -> void:
	var cena: Node = load("res://scenes/main.tscn").instantiate()
	for filho in cena.get_children():
		cena.remove_child(filho)
		add_child(filho)
	cena.free()


## Um nó da main.tscn, ligado à main e posto no fim da lista de filhos. As peças são chamadas na ordem
## em que o jogo sempre as montou; como a ordem dos filhos é a de desenho, nada passa à frente de nada.
func _camada(nome: String) -> Node:
	var no := get_node(nome)
	move_child(no, -1)
	if "game" in no: no.game = self
	return no


func _build_art() -> void:
	# A pintura de cada sala, animada por shader, fica atrás de tudo.
	pintura = _camada("Pintura")
	art = _camada("Arte")
	vale_back = _camada("ValeFundo")
	vale_front = _camada("ValeFrente")
	# A camada viva das demais salas: o que balança, flutua, pinga e queima.
	life_back = _camada("VidaFundo")
	life_front = _camada("VidaFrente")
	# Bichos que reagem ao Penitente e silhuetas de primeiro plano, mais rápidas que a câmera.
	bichos = _camada("Bichos")
	primeiro_plano = _camada("PrimeiroPlano")


## Acessibilidade: remove clarões, oscilação de luz e tremor de câmera das cenas de culpa e do Guardião.
## Sons, legendas, durações e tudo que afeta a jogabilidade permanecem iguais. A escolha é global
## e persiste em novos jogos; fica separada do arquivo de salvamento.
func _load_settings() -> void:
	var cfg := ConfigFile.new()
	var loaded := cfg.load(SETTINGS_PATH) == OK
	if loaded:
		reduced_pulses = bool(cfg.get_value("accessibility", "reduced_pulses", false))
	if loaded and cfg.has_section_key("display", "fullscreen"):
		set_fullscreen(bool(cfg.get_value("display", "fullscreen")), false)
	elif not is_fullscreen():
		# Primeira vez: se a janela 1280×720 não cabe (notebook 1366×768), abre em tela
		# cheia, onde o jogo é ampliado e o texto fica regular; reduzir o jogo para caber
		# numa janela menor deixaria letras irregulares.
		if _window_fits(): _fit_window()
		else: set_fullscreen(true, false)


## Texto nítido em qualquer resolução. O jogo é desenhado em 1280×720 e ampliado
## (ex.: 1,067× num notebook 1366×768). Com posicionamento subpixel, cada letra caía
## numa fração de pixel e o filtro "nearest" arredondava umas para um lado e outras
## para o outro: "DES LIGADO", "s om". Sem subpixel, cada letra começa num pixel
## inteiro da tela e o espaçamento fica regular. Só as fontes mudam; as imagens não.
## Os recursos ficam guardados aqui para que todo load() receba a mesma instância.
var ui_fonts: Array[Font] = []

func _crisp_fonts() -> void:
	ui_fonts = [ThemeDB.fallback_font, load("res://assets/title_font.ttf")]
	if ResourceLoader.exists("res://assets/fonts/UnifrakturMaguntia-Book.ttf"):
		ui_fonts.append(load("res://assets/fonts/UnifrakturMaguntia-Book.ttf"))
	for f in ui_fonts:
		if f is FontFile:
			f.subpixel_positioning = TextServer.SUBPIXEL_POSITIONING_DISABLED


## Tela: F11 alterna entre tela cheia e janela; a escolha fica em settings.cfg.
## O jogo é desenhado em 1280×720 e ampliado com filtragem suave para qualquer
## resolução (stretch canvas_items, proporção mantida com faixas pretas se preciso).
func _can_control_window() -> bool:
	if DisplayServer.get_name() == "headless": return false
	if Engine.has_method("is_embedded_in_editor") and Engine.call("is_embedded_in_editor"): return false
	return true

func is_fullscreen() -> bool:
	var mode := DisplayServer.window_get_mode()
	return mode == DisplayServer.WINDOW_MODE_FULLSCREEN or mode == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN

func set_fullscreen(enabled: bool, remember: bool = true) -> void:
	if _can_control_window():
		if enabled:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			_fit_window()
	if remember:
		var cfg := ConfigFile.new()
		cfg.load(SETTINGS_PATH)
		cfg.set_value("display", "fullscreen", enabled)
		cfg.save(SETTINGS_PATH)

func toggle_fullscreen() -> void:
	set_fullscreen(not is_fullscreen())

func _window_fits() -> bool:
	if not _can_control_window(): return true
	var area := DisplayServer.screen_get_usable_rect(DisplayServer.window_get_current_screen())
	return area.size.x >= 1280 + 16 and area.size.y >= 720 + 48

## Em janela, abre no maior 16:9 que caiba na área útil do monitor (sem passar de
## 1280×720), centralizado. Só reduz se o jogador escolher janela numa tela pequena.
func _fit_window() -> void:
	if not _can_control_window(): return
	var screen := DisplayServer.window_get_current_screen()
	var area := DisplayServer.screen_get_usable_rect(screen)
	var base := Vector2(1280, 720)
	var room := Vector2(area.size) - Vector2(16, 48)
	var k := minf(1.0, minf(room.x / base.x, room.y / base.y))
	var fitted := Vector2i(base * k)
	DisplayServer.window_set_size(fitted)
	DisplayServer.window_set_position(area.position + (area.size - fitted) / 2)

func set_reduced_pulses(enabled: bool) -> void:
	reduced_pulses = enabled
	var cfg := ConfigFile.new()
	cfg.load(SETTINGS_PATH)
	cfg.set_value("accessibility", "reduced_pulses", enabled)
	cfg.save(SETTINGS_PATH)
	# Aplicação imediata: qualquer clarão ou tremor em andamento é interrompido.
	if narrative != null:
		narrative.flash = 0.0
		narrative.pulse = 0.0
	if player != null:
		player.shake = 0.0

func is_reduced_pulses_enabled() -> bool:
	return reduced_pulses

## Modo de desenvolvimento (F3): escolhe e visita salas, atravessa paredes e evita dano durante a apresentação.
var dev_mode := false
var dev_index := 0

func dev_rooms() -> Array:
	return exploration.rooms.keys()

func dev_spawn(id: String) -> Vector2:
	# Chega pela primeira passagem da sala para posicionar o Penitente sobre o piso.
	if id == "city": return Vector2(900, 600)
	for link in exploration.passages:
		if link.a == id: return link.pa
		if link.b == id: return link.pb
	var r: Dictionary = exploration.rooms[id]
	return Vector2(r.bounds.position.x + 240.0, r.floor)

func dev_teleport(id: String) -> void:
	if not exploration.rooms.has(id): return
	exploration.abort_arena()
	if id == "vale":
		# O Vale tem a sua própria entrada: Beatriz fica à beira e a luta final é armada.
		enter_vale()
	else:
		exploration.travel(id, dev_spawn(id))
	player.velocity = Vector2.ZERO
	toast("MODO DEV · " + str(exploration.rooms[id].name))

func toggle_dev() -> void:
	dev_mode = not dev_mode
	if not dev_mode:
		_leave_dev_fly()
		player.dev_god = false
	toast("MODO DEV " + ("LIGADO · ↑↓ sala · ENTER ir · G invencível · N voar · B chefe" if dev_mode else "DESLIGADO"))

func dev_input(event: InputEvent) -> bool:
	if not (event is InputEventKey and event.pressed and not event.echo):
		return false
	if event.keycode == KEY_F4 and state == "play" and partner != null and is_instance_valid(partner):
		partner.ai = not partner.ai
		toast("Beatriz: " + ("o jogo controla" if partner.ai else "Jogador 2 controla"))
		return true
	if event.keycode == KEY_F3 and state == "play":
		toggle_dev()
		return true
	# F6 desliga ou religa a pintura viva (para computadores em que o shader pesar).
	if event.keycode == KEY_F6 and state == "play" and pintura != null:
		pintura.desligada = not pintura.desligada
		toast("Pintura viva: " + ("desligada" if pintura.desligada else "ligada"))
		return true
	if not dev_mode or state != "play":
		return false
	var rooms := dev_rooms()
	match event.keycode:
		KEY_UP: dev_index = (dev_index - 1 + rooms.size()) % rooms.size()
		KEY_DOWN: dev_index = (dev_index + 1) % rooms.size()
		KEY_ENTER, KEY_KP_ENTER: dev_teleport(rooms[dev_index])
		KEY_G: player.dev_god = not player.dev_god
		KEY_N:
			if player.dev_fly: _leave_dev_fly()
			else: player.dev_fly = true
		KEY_B:
			exploration.travel("city", Vector2(3700, 600))
		_: return false
	return true

func _leave_dev_fly() -> void:
	if not player.dev_fly: return
	player.dev_fly = false
	# Se o voo terminou dentro de alvenaria, recupera o último apoio válido.
	for child in player.get_children():
		if not child is CollisionShape2D: continue
		var query := PhysicsShapeQueryParameters2D.new()
		query.shape = child.shape
		query.transform = child.global_transform
		query.collision_mask = 1
		query.exclude = [player.get_rid()]
		query.margin = 0.0
		if not player.get_world_2d().direct_space_state.intersect_shape(query, 1).is_empty():
			var safe: Vector2 = player.safe_pos
			exploration.travel(exploration.room_at(safe), safe)
			break

func toggle_pause() -> void:
	if confession_open: return
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
		player._clear_combat_input()
		player.input_release_gate = true


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
	_add_action("down", [KEY_S])
	_add_action("penitence_menu", [KEY_V])
	_add_action("penitence_none", [KEY_1])
	_add_action("penitence_nails", [KEY_2])
	_add_action("penitence_chains", [KEY_3])
	_add_action("pause", [KEY_ESCAPE])
	_add_action("mute", [KEY_M])
	_add_action("reduce_pulses", [KEY_P])
	_add_action("parry", [KEY_L])
	_add_action("heavy", [KEY_I])
	_add_action("swap", [KEY_T])
	_add_action("share_blood", [KEY_H])
	_add_action("prece", [KEY_U])
	_add_action("p2_prece", [KEY_KP_7, KEY_EQUAL])
	# Jogador 2 (Beatriz): setas e teclado numérico, ou o segundo controle.
	# Em notebook sem teclado numérico: as teclas à direita do M e do L (no ABNT2: , . ; ç ~ ´ [).
	_add_action("p2_left", [KEY_LEFT])
	_add_action("p2_right", [KEY_RIGHT])
	_add_action("p2_jump", [KEY_UP, KEY_KP_8])
	_add_action("p2_down", [KEY_DOWN, KEY_KP_2])
	_add_action("p2_attack", [KEY_KP_1, KEY_PERIOD])
	_add_action("p2_roll", [KEY_KP_3, KEY_COMMA])
	_add_action("p2_parry", [KEY_KP_4, KEY_SLASH])
	_add_action("p2_heavy", [KEY_KP_5, KEY_SEMICOLON])
	_add_action("p2_heal", [KEY_KP_6, KEY_APOSTROPHE])
	_add_action("p2_share_blood", [KEY_KP_0, KEY_BRACKETRIGHT])
	_add_action("p2_interact", [KEY_KP_ENTER, KEY_BRACKETLEFT])
	_add_action("p2_swap", [])
	_add_action("left", [KEY_A])
	_add_action("right", [KEY_D])
	_add_action("jump", [KEY_SPACE, KEY_W])
	_add_action("attack", [KEY_J, KEY_X])
	_add_action("roll", [KEY_K, KEY_SHIFT])
	_add_action("heal", [KEY_F])
	_add_action("penance", [KEY_Q])
	_add_action("interact", [KEY_E])
	_add_action("offer", [KEY_R])
	_add_action("confirm", [KEY_ENTER, KEY_KP_ENTER])
	_add_action("continue_game", [KEY_C])
	_add_action("confess", [KEY_C])
	_add_action("toggle_fullscreen", [KEY_F11])
	_add_action("pause_confess", [KEY_C])
	_setup_gamepads()


# ---------------------------------------------------------------- controles
## O 1º controle conectado (device 0) é o Penitente; o 2º (device 1) é Beatriz.
## Botões na posição do controle de Xbox; no de PlayStation: A=✕, B=○, X=□, Y=△.
const PAD_BUTTONS := {
	"jump": JOY_BUTTON_A, "attack": JOY_BUTTON_X, "roll": JOY_BUTTON_B, "interact": JOY_BUTTON_Y,
	"parry": JOY_BUTTON_RIGHT_SHOULDER, "heal": JOY_BUTTON_LEFT_SHOULDER, "share_blood": JOY_BUTTON_DPAD_UP,
	"prece": JOY_BUTTON_RIGHT_STICK,
	"left": JOY_BUTTON_DPAD_LEFT, "right": JOY_BUTTON_DPAD_RIGHT, "down": JOY_BUTTON_DPAD_DOWN,
}
const PAD_TRIGGERS := {"heavy": JOY_AXIS_TRIGGER_RIGHT, "penance": JOY_AXIS_TRIGGER_LEFT}
## Só o Penitente: menus e altar. Start e Back valem para qualquer controle.
const PAD_P1_ONLY := {
	"penitence_menu": JOY_BUTTON_LEFT_STICK, "offer": JOY_BUTTON_RIGHT_STICK,
	"confirm": JOY_BUTTON_A, "continue_game": JOY_BUTTON_Y,
	"penitence_none": JOY_BUTTON_X, "penitence_nails": JOY_BUTTON_Y, "penitence_chains": JOY_BUTTON_B,
}
const PAD_ANY := {"pause": JOY_BUTTON_START, "map": JOY_BUTTON_BACK, "pause_confess": JOY_BUTTON_Y}

## Ao jogar com controle, as dicas na tela mostram os botões em vez das teclas.
var using_pad := false
const PAD_LABELS := [
	["[J / X]", "[X]"], ["[K / SHIFT]", "[B]"], ["[E]", "[Y]"], ["[R]", "[R3]"], ["[V]", "[L3]"],
	["segure H", "segure ↑"], ["H · ", "↑ · "], ["Pressione PULO", "Pressione A"],
]

func pad_text(text: String) -> String:
	if not using_pad: return text
	for pair in PAD_LABELS: text = text.replace(pair[0], pair[1])
	return text

func _pad_button(action: String, device: int, button: int) -> void:
	var ev := InputEventJoypadButton.new()
	ev.device = device
	ev.button_index = button
	InputMap.action_add_event(action, ev)

func _pad_axis(action: String, device: int, axis: int, value: float) -> void:
	var ev := InputEventJoypadMotion.new()
	ev.device = device
	ev.axis = axis
	ev.axis_value = value
	InputMap.action_add_event(action, ev)

func _setup_gamepads() -> void:
	for device in [0, 1]:
		var prefix := "" if device == 0 else "p2_"
		for action in PAD_BUTTONS:
			if InputMap.has_action(prefix + action): _pad_button(prefix + action, device, PAD_BUTTONS[action])
		for action in PAD_TRIGGERS:
			if InputMap.has_action(prefix + action): _pad_axis(prefix + action, device, PAD_TRIGGERS[action], 1.0)
		_pad_axis(prefix + "left", device, JOY_AXIS_LEFT_X, -1.0)
		_pad_axis(prefix + "right", device, JOY_AXIS_LEFT_X, 1.0)
		_pad_axis(prefix + "down", device, JOY_AXIS_LEFT_Y, 1.0)
		# Analógico: movimento responde cedo; "baixo" só com o analógico bem inclinado,
		# para uma diagonal não virar descida de galeria por engano.
		for action in ["left", "right"]: InputMap.action_set_deadzone(prefix + action, 0.25)
		InputMap.action_set_deadzone(prefix + "down", 0.6)
	for action in PAD_P1_ONLY: _pad_button(action, 0, PAD_P1_ONLY[action])
	for action in PAD_ANY: _pad_button(action, -1, PAD_ANY[action])


# ---------------------------------------------------------------- construção
## Corpo de colisão retangular em coordenadas do mundo, filho de `onde` (a main ou uma sala).
func _add_solid(r: Rect2, one_way: bool, onde: Node2D = self) -> StaticBody2D:
	var b := StaticBody2D.new()
	b.set_meta("one_way",one_way)
	b.collision_layer = 1
	b.collision_mask = 0
	var cs := CollisionShape2D.new()
	var rs := RectangleShape2D.new()
	rs.size = r.size
	cs.shape = rs
	cs.position = r.position + r.size / 2.0 - onde.position
	cs.one_way_collision = one_way
	b.add_child(cs)
	onde.add_child(b)
	return b


## As salas instanciadas na main.tscn (nó Salas), na ordem do mapa.
func _salas() -> Array[Node2D]:
	var lista: Array[Node2D] = []
	for id in Layout.SALAS:
		var sala: Node2D = null
		for filho in get_node("Salas").get_children():
			if filho.get("id") == id: sala = filho
		if sala == null:
			push_error("A sala %s não está no nó Salas da main.tscn." % id)
			continue
		if sala.position != sala.origem:
			push_warning("Sala %s fora da origem na main.tscn; volta para %s." % [id, sala.origem])
		sala.position = sala.origem
		lista.append(sala)
	return lista


func _build_world() -> void:
	# Tinta: o CanvasModulate que escurece o mundo inteiro (cor na main.tscn).
	_camada("Tinta")
	# Cada sala da cena cria o próprio chão, paredes, plataformas e alvenaria.
	for sala in _salas():
		for c in sala.colisoes(): _add_solid(c[0], c[1], sala)
	dyn = _camada("Dinamico")
	dyn.draw.connect(_draw_dynamic)


func _build_player() -> void:
	# O Penitente está na main.tscn (nó Player), depois do cenário: a pintura das salas não o cobre.
	player = _camada("Player")
	player.position = altars[0]
	player.died.connect(_on_player_died)


## Cria um inimigo do tipo `kind` a partir da cena da sua família, ainda fora da árvore.
## Chame setup() com o mesmo tipo antes de add_child(). `script` troca enemy.gd por uma
## subclasse (criatura_goya.gd, penitent_boss.gd) mantendo a estrutura da cena.
func new_enemy(kind: int, script: Script = null) -> CharacterBody2D:
	var e: CharacterBody2D = ENEMY_SCENES[EnemyScript.TYPES[kind].family].instantiate()
	if script != null:
		e.set_script(script)
	return e


# ------------------------------------------------------------------ O Vale dos Flagelados e o chefe final
## O Vale fica além dos portões: só se desce depois que o Guardião dos Sinos cai e a memória dos portões volta.
## Lá espera o Flagelado (scripts/penitent_boss.gd), que só a revelação mostra ser o próprio Penitente. Beatriz não entra com ele: o vale só deixa passar
## quem carrega aquela culpa. Ela só atravessa quando a segunda parte da armadura cai.
var VALE_ENTRANCE: Vector2 = Layout.ponto("entrada_vale")
var VALE_BOSS_POS: Vector2 = Layout.ponto("chefe_vale")
const VALE_LINES := {
	"enter": "VALE DOS FLAGELADOS\nOnde a culpa permanece.",
	"held": "Beatriz para à beira do vale. A névoa não a deixa passar:\n\"Ninguém atravessa a culpa de outro.\"",
	"wake": "Alguém espera entre as forcas, de joelhos, coberto de ferro e dos pecados de outros.",
	"mirror_first": "Ele ergue a cabeça, olha para você — e veste a sua forma.",
	"reflect": "O golpe volta para você. Enquanto ele vestir a sua forma, ferir é ferir-se.\nApare o golpe dele (L) — ou espere que ele recolha a sua culpa e reze.",
	"parry": "O aparo arranca o reflexo. Por um tempo, ele é só o que é.",
	"prayer": "Ele reza para se perdoar — e, ao rezar, volta a ser quem é.",
	"mirror": "Ele veste de novo a sua forma.",
	1: "Cai a primeira placa: a desculpa.\n\"Eu só obedecia.\"",
	2: "Cai a segunda: o esquecimento.\nQuem não lembra não precisa responder.",
	3: "Cai a terceira: o castigo.\nPunir-se também é uma maneira de não olhar.",
	"beatriz": "A névoa se abre. Beatriz atravessa o vale:\nsó se divide o fardo que se admite.",
	"fallen": "Sem armadura, ele cai de joelhos. Resta o capacete.",
}
var final_boss = null
var final_defeated := false
var vale_back = null
var vale_front = null
var life_back = null
var life_front = null
var pintura = null
var bichos = null
var primeiro_plano = null
var vale_stage_seen := 0
var vale_told := {}
var beatriz_held := false
var finale = null
var duo_default := not OS.get_cmdline_args().has("--script")

func _vale_say(key) -> void:
	if vale_told.has(key): return
	vale_told[key] = true
	toast(str(VALE_LINES[key]))

func enter_vale() -> void:
	exploration.travel("vale", VALE_ENTRANCE, 1)
	area_name = "VALE DOS FLAGELADOS"
	area_t = 5.0
	vale_told.clear()
	_vale_say("enter")
	if partner != null and is_instance_valid(partner):
		# Beatriz fica à beira do vale.
		beatriz_held = true
		enable_duo(false)
		toast(str(VALE_LINES["held"]))

func _update_vale(_delta: float) -> void:
	if exploration.room != "vale":
		if beatriz_held and (final_boss == null or not is_instance_valid(final_boss) or final_boss.stage < 2):
			# Fora do vale, Beatriz volta a caminhar ao lado dele.
			beatriz_held = false
			duo_wanted = duo_default
		return
	if final_boss == null or not is_instance_valid(final_boss) or final_boss.fallen:
		return
	if not final_boss.awake and player.global_position.x > VALE_BOSS_POS.x - 620.0:
		final_boss.awaken()
		_vale_say("wake")
		soundscape.play_sfx("sino_surdo")

func boss_reflected() -> void:
	_vale_say("reflect")

func boss_revealed(by_prayer: bool) -> void:
	toast(str(VALE_LINES["prayer" if by_prayer else "parry"]))

func boss_mirrored() -> void:
	_vale_say("mirror" if vale_told.has("mirror_first") else "mirror_first")

func vale_impulse(at_x: float, strength: float) -> void:
	if vale_back != null: vale_back.impulse(at_x, strength)
	if vale_front != null: vale_front.impulse(at_x, strength)

func boss_armor_broke(stage: int) -> void:
	vale_stage_seen = stage
	# O vale reage: o céu escurece e o vento aumenta a cada placa que cai.
	if vale_back != null: vale_back.set_mood(stage / 4.0)
	if vale_front != null: vale_front.set_mood(stage / 4.0)
	vale_impulse(final_boss.global_position.x, 3.0)
	toast(str(VALE_LINES[stage]))
	if stage == 2:
		beatriz_arrives()

## Com a segunda placa no chão, Beatriz entra na luta.
func beatriz_arrives() -> void:
	beatriz_held = false
	enable_duo(true)
	if partner != null and is_instance_valid(partner):
		partner.global_position = VALE_ENTRANCE + Vector2(40, 0)
		partner.velocity = Vector2.ZERO
		partner.hp = partner.max_hp
		spawn_effect("dust", partner.global_position + Vector2(0, -30), 1, 0.9)
	soundscape.play_sfx("bell")
	soundscape.play_sfx("beatriz_chega")
	get_tree().create_timer(2.6).timeout.connect(func(): toast(str(VALE_LINES["beatriz"])))

## O chefe caiu de joelhos: a luta acabou. Segue a revelação (scripts/vale_finale.gd) e, depois, o encerramento.
func final_boss_fallen(b) -> void:
	if finale != null and is_instance_valid(finale): return
	if vale_back != null: vale_back.set_mood(1.0)
	if vale_front != null: vale_front.set_mood(1.0)
	toast(str(VALE_LINES["fallen"]))
	player.controllable = false
	if partner == null or not is_instance_valid(partner):
		# A revelação é dela: se ainda não estava na luta, ela chega agora.
		beatriz_arrives()
	finale = ValeFinale.new()
	finale.game = self
	finale.boss = b
	add_child(finale)

func finish_finale() -> void:
	final_defeated = true
	if finale != null and is_instance_valid(finale): finale.queue_free()
	finale = null
	duo_wanted = duo_default
	_save()
	state = "ending"
	ending_t = 0
	player.controllable = false

## Beatriz caminha ao lado do Penitente desde o início. Os testes automáticos de um
## penitente rodam sozinhos (--script), exceto quando ativam a dupla com enable_duo(true).
var partner = null
var duo_wanted := not OS.get_cmdline_args().has("--script")

func enable_duo(on: bool) -> void:
	duo_wanted = on
	if on and (partner == null or not is_instance_valid(partner)):
		player.character = "penitente"
		player.apply_character()
		partner = PlayerScene.instantiate()
		partner.is_partner = true
		partner.prefix = "p2_"
		partner.ai = true
		partner.character = "beatriz"
		partner.position = player.global_position + Vector2(-70.0, 0.0)
		add_child(partner)
		partner.apply_character()
		partner.maldicao_parcas=player.maldicao_parceira
		partner.apply_penitence(partner.penitence)
		partner.has_weapon = player.has_weapon
		partner.hp = clampf(player.partner_hp, 1.0, partner.max_hp)
		partner.lance_weight = player.lance_weight
		partner.died.connect(_on_player_died)
		_sincronizar_progresso()
	elif not on and partner != null and is_instance_valid(partner):
		player.maldicao_parceira=partner.maldicao_parcas
		partner.remove_from_group("players")
		partner.queue_free()
		partner = null

func _update_duo(delta: float) -> void:
	if duo_wanted and (partner == null or not is_instance_valid(partner)):
		enable_duo(true)
	if partner == null or not is_instance_valid(partner):
		return
	partner.has_weapon = player.has_weapon
	var gameplay_input: bool = not paused and not dev_mode and message_text.is_empty() and narrative.mode.is_empty() and not penitence_menu and not exploration.map_open and not exploration.is_transitioning()
	if partner.ai and gameplay_input:
		for a in ["left", "right", "jump", "attack", "roll", "parry", "heavy", "heal", "share_blood", "prece", "interact"]:
			if Input.is_action_just_pressed("p2_" + a):
				partner.ai = false
				toast("Jogador 2 assumiu Beatriz. (F4 devolve ao jogo)")
				break
	# Uma câmera para os dois: aproxima o foco do ponto médio entre eles.
	var cam: Camera2D = player.camera
	if narrative.mode == "" and not player.cinematic_focus and player.state != "execution":
		var mid := clampf((partner.global_position.x - player.global_position.x) * 0.5, -260.0, 260.0) if partner.standing() else 0.0
		player.camera_focus_x = lerpf(player.camera_focus_x, mid, minf(delta * 4.0, 1.0))
	# Se ficar muito longe ou em outra sala, ela reaparece ao lado do Penitente.
	if not exploration.is_transitioning() and partner.state != "fallen" and player.standing():
		var far: float = partner.global_position.distance_to(player.global_position)
		if far > 900.0 or exploration.room_at(partner.global_position) != exploration.room:
			partner.global_position = player.global_position + Vector2(-60.0 * player.facing, -10.0)
			partner.velocity = Vector2.ZERO
			spawn_effect("dust", partner.global_position + Vector2(0.0, -30.0), 1, 0.7)

func _build_fx_layer() -> void:
	# Efeitos desenhados por _draw_fx, à frente do mundo (z 10 na main.tscn).
	fxn = _camada("Efeitos")
	fxn.draw.connect(_draw_fx)


func _build_hud() -> void:
	# HUD e Confessionário vêm de scenes/interface.tscn, instanciada na main.tscn (nó Interface).
	var interface: CanvasLayer = _camada("Interface")
	hud = interface.get_node("HUD")
	hud.game = self
	confession_panel = interface.get_node("ConfessionPanel")
	confession_panel.game = self
	confession_panel.conectar(confessor)


## Luzes tremulantes das salas (scenes/salas/luz.tscn): as filhas das velas, dos altares e dos pontos (a da
## relíquia) e as do grupo Luzes, nessa ordem e sala a sala. A energia de cada uma é a média do tremor;
## a frequência e a fase são sorteadas aqui.
func _build_lights() -> void:
	for grupo in ["Velas", "Altares", "Pontos", "Luzes"]:
		for sala in _salas():
			if not sala.has_node(grupo): continue
			for no in sala.get_node(grupo).get_children():
				var luzes: Array = [no] if no is PointLight2D else no.get_children().filter(func(f): return f is PointLight2D)
				for luz in luzes:
					flicker.append([luz, luz.energy, randf_range(4.0, 9.0), randf_range(0.0, 6.0)])
					if no.get("ponto") == "reliquia": relic_light = luz
	if relic_light == null: push_error("A relíquia (ponto reliquia) não tem Luz filha na sala.")
	# O fragmento de culpa deixado na morte e a sua luz ficam na main.tscn, ocultos até haver mancha.
	stain_light = _camada("LuzDaMancha")
	stain_anchor = _camada("Fragmento")
	stain_animation = stain_anchor.get_node("Animacao")
	stain_animation.configure("fragmento", 0.72)


# ---------------------------------------------------------------- jogo
func _start_game(load_save: bool, cinematic: bool = true) -> void:
	exploration.reset()
	# Lágrimas que ainda voavam na partida anterior não atravessam um carregamento.
	lagrimas_ar.clear()
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
	player.maldicao_parcas = 0
	player.maldicao_parceira = 0
	player.max_hp = 100.0
	player.upgrades = 0
	player.culpa = 0.0
	player.lagrimas = 0
	player.has_double_jump = false
	relic_taken = false
	boss_defeated = false
	final_defeated = false
	beatriz_held = false
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
	final_boss = null
	for drop in get_tree().get_nodes_in_group("guilt_drops"): drop.queue_free()
	for d in enemy_defs:
		var e = new_enemy(d[0])
		e.setup(d[0], Vector2(d[1], d[2]), d[3], player)
		e.killed.connect(_on_enemy_killed)
		add_child(e)
	exploration.spawn_enemies()
	_criar_criaturas_aprovadas()
	if not boss_defeated:
		var b = new_enemy(2)
		b.setup(2, GUARDIAN_POS, 0.0, player)
		b.killed.connect(_on_enemy_killed)
		add_child(b)
		b.display_name = "Guardião dos Sinos"
		boss = b
	# O chefe final é criado por último: fica no Vale e só desperta lá.
	if not final_defeated:
		var fb = new_enemy(9, FinalBossScript)
		fb.setup(9, VALE_BOSS_POS, 0.0, player)
		fb.room_id = "vale"
		fb.killed.connect(_on_enemy_killed)
		add_child(fb)
		final_boss = fb
		vale_stage_seen = 0
		if vale_back != null: vale_back.set_mood(0.0)
		if vale_front != null: vale_front.set_mood(0.0)


func _on_enemy_killed(e) -> void:
	# Cada vida tomada pela lança aumenta seu peso (contrapasso); o peso vai para quem matou.
	var killer = e.get("last_hitter")
	if killer != null and is_instance_valid(killer): killer.add_weight(6.0)
	else: player.add_weight(6.0)
	if e.kind == 2:
		boss_defeated = true
		ending_countdown = 3.5
		toast("O Guardião dos Sinos silencia.")
		if narrative.mode != "": narrative.finish()
		# Primeiro o sino silencia; a memória dos portões vem em seguida por conta própria.
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
	telemetry.record_death(exploration.room)
	death_t = 3.0


func _respawn() -> void:
	recolher_lagrimas()
	stain_active = true
	stain_amount = player.lagrimas
	stain_pos = death_pos
	player.lagrimas = 0
	player.add_culpa(25)
	player.revive(altars[respawn_index])
	if partner != null and is_instance_valid(partner):
		partner.revive(altars[respawn_index] + Vector2(-70.0, 0.0))
	var died_in_vale: bool = exploration.room == "vale" and not final_defeated
	exploration.room = exploration.room_at(player.position)
	exploration.set_camera()
	_spawn_enemies()
	state = "play"
	if died_in_vale:
		# Quem cai no Vale recomeça à beira dele: a luta volta ao início.
		enter_vale()
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


## O fragmento recuperado se desfaz em luz no local onde estava.
func _dissolve_fragment(pos: Vector2) -> void:
	var anchor: Node2D = Efeitos.EFEITO_ANIMADO.instantiate()
	anchor.position = pos + FRAGMENT_LIFT
	anchor.z_index = 5
	var animation = anchor.get_node("Animacao")
	animation.configure("fragmento", 0.72)
	add_child(anchor)
	animation.select("dissolve", 1)
	animation.animation_finished.connect(anchor.queue_free)

## Efeito de combate de execução única no atlas pintado: faíscas da espada, sangue, clarão de aparo e poeira de aterrissagem.
## Respingos de sangue que caem e ficam no chão: manchas irregulares, umas maiores, outras em gotas,
## espalhadas à frente do golpe e aparecendo aos poucos, como se ainda estivessem caindo.
const BLOOD_SPLATS_MAX := 90
var splat_sound_ms := 0

func blood_splats(ground: Vector2, flip: int, count: int, spread: float = 1.0) -> void:
	for k in range(count):
		var dx := (randf() * 150.0 - 25.0) * spread * float(flip)
		var delay := 0.08 + randf() * 0.45
		var size := lerpf(4.0, 15.0, randf()) * (1.15 if k == 0 else 1.0)
		get_tree().create_timer(delay, true, false, true).timeout.connect(_place_splat.bind(Vector2(ground.x + dx, ground.y), size))

func _place_splat(at: Vector2, size: float) -> void:
	# Projeta a mancha no chão ou na galeria, inclusive quando o alvo está no ar.
	var query := PhysicsRayQueryParameters2D.create(at - Vector2(0, 4), at + Vector2(0, 1200), 1)
	var floor_hit := get_world_2d().direct_space_state.intersect_ray(query)
	if floor_hit.is_empty(): return
	at = floor_hit.position
	if size > 9.0 and Time.get_ticks_msec() - splat_sound_ms > 130:
		splat_sound_ms = Time.get_ticks_msec()
		soundscape.play_sfx("respingo_chao")
	var old := get_tree().get_nodes_in_group("blood_splats")
	while old.size() >= BLOOD_SPLATS_MAX:
		var oldest = old.pop_front()
		oldest.remove_from_group("blood_splats")
		oldest.queue_free()
	var splat: Sprite2D = Efeitos.MANCHA_CHAO.instantiate()
	splat.position = at + Vector2(0.0, -1.0)
	splat.add_to_group("blood_splats")
	splat.texture.region = Rect2(randi_range(0, 7) * 128, 0, 128, 64)
	splat.scale = Vector2(size * 3.2 / 128.0, size * 0.8 / 64.0)
	splat.flip_h = randf() < 0.5
	add_child(splat)
	soundscape.play_sfx_at("respingo_chao", at)
	var fade := splat.create_tween()
	fade.tween_interval(40.0)
	fade.tween_property(splat, "modulate:a", 0.0, 5.0)
	fade.tween_callback(splat.queue_free)

## Respingos verticais só aparecem quando uma parede real está a até 60 pixels do ferimento.
func wall_splat(at: Vector2) -> void:
	var wall := {}
	for direction in [-1.0, 1.0]:
		var query := PhysicsRayQueryParameters2D.create(at, at + Vector2(direction * 60, 0), 1)
		var hit := get_world_2d().direct_space_state.intersect_ray(query)
		if not hit.is_empty() and absf(hit.normal.x) > 0.7:
			wall = hit
			break
	if wall.is_empty(): return
	var old := get_tree().get_nodes_in_group("blood_walls")
	while old.size() >= 45:
		var first = old.pop_front()
		first.remove_from_group("blood_walls")
		first.queue_free()
	var stain: Sprite2D = Efeitos.MANCHA_PAREDE.instantiate()
	stain.texture.region = Rect2(randi_range(0, 3) * 256, 0, 256, 256)
	stain.position = wall.position
	stain.flip_h = wall.normal.x < 0
	add_child(stain)
	var fade := stain.create_tween()
	fade.tween_interval(40.0)
	fade.tween_property(stain, "modulate:a", 0.0, 5.0)
	fade.tween_callback(stain.queue_free)

func spawn_effect(kind: String, pos: Vector2, flip: int = 1, size: float = 0.55, actor: String = "efeitos", tint: Color = Color.WHITE) -> void:
	var anchor: Node2D = Efeitos.EFEITO_ANIMADO.instantiate()
	anchor.position = pos
	anchor.modulate = tint
	var animation = anchor.get_node("Animacao")
	animation.configure(actor, size)
	add_child(anchor)
	animation.select(kind, flip)
	animation.animation_finished.connect(anchor.queue_free)

## Lágrimas visíveis: saem do corpo da criatura e voam até quem estiver mais perto (o Penitente
## ou Beatriz). A bolsa é uma só, a do Penitente: tanto faz quem matou ou quem pegou.
var lagrimas_ar: Array = []
var lagrima_textura: Texture2D
var coleta_ms := 0
func lagrimas_voando(de: Vector2, valor: int) -> void:
	if valor <= 0: return
	var n := clampi(valor / 10, 3, 12)
	var resto := valor
	for i in range(n):
		var parte := resto if i == n - 1 else valor / n
		resto -= parte
		var ang := randf_range(-PI * 0.9, -PI * 0.1)
		lagrimas_ar.append({"p": de + Vector2(randf_range(-10, 10), randf_range(-10, 10)), "v": Vector2(cos(ang), sin(ang)) * randf_range(180, 360), "valor": parte, "t": -randf() * 0.25})

## Entrega de uma vez as lágrimas que ainda voam (troca de sala, morte).
func recolher_lagrimas() -> void:
	for l in lagrimas_ar: player.lagrimas += int(l.valor)
	lagrimas_ar.clear()

func _atualizar_lagrimas(delta: float) -> void:
	if lagrimas_ar.is_empty(): return
	var alvos: Array = [player]
	if partner != null and is_instance_valid(partner) and partner.standing(): alvos.append(partner)
	var vivas: Array = []
	for l in lagrimas_ar:
		l.t += delta
		var alvo = alvos[0]
		for a in alvos:
			if a.global_position.distance_to(l.p) < alvo.global_position.distance_to(l.p): alvo = a
		var destino: Vector2 = alvo.global_position + Vector2(0, -52)
		if l.t > 0.28:
			# Depois de espirrar, a lágrima é puxada para quem a recolhe, cada vez mais rápido.
			var puxa: float = 1400.0 + 2600.0 * minf(l.t, 1.2)
			l.v = l.v.move_toward((destino - l.p).normalized() * minf(1300.0, 300.0 + l.t * 900.0), puxa * delta)
		else:
			l.v.y += 500.0 * delta
		l.p += l.v * delta
		if l.p.distance_to(destino) < 26.0 or l.t > 3.0:
			player.lagrimas += int(l.valor)
			if Time.get_ticks_msec() - coleta_ms > 60:
				coleta_ms = Time.get_ticks_msec()
				soundscape.play_sfx("lagrima_coleta")
		else:
			vivas.append(l)
	lagrimas_ar = vivas

## Clarão de tela inteira (aparo perfeito, golpe mortal). A interface desenha e apaga.
var clarao_cor := Color(1, 1, 1, 0)
var clarao_t := 0.0
var clarao_dur := 0.1
func clarao(cor: Color, duracao: float) -> void:
	if reduced_pulses: return
	clarao_cor = cor
	clarao_dur = maxf(duracao, 0.01)
	clarao_t = clarao_dur

## Gotas de sangue que espirram na "lente" e escorrem devagar pela tela.
var gotas_tela: Array = []
func sangue_na_tela(quantas: int) -> void:
	if reduced_pulses: return
	var vs := get_viewport_rect().size
	for i in range(quantas):
		if gotas_tela.size() >= 40: gotas_tela.pop_front()
		var borda := randf() < 0.7
		var x := randf_range(0.0, vs.x) if not borda else (randf_range(0.0, vs.x * 0.22) if randf() < 0.5 else randf_range(vs.x * 0.78, vs.x))
		gotas_tela.append({"p": Vector2(x, randf_range(vs.y * 0.05, vs.y * 0.75)), "r": randf_range(8.0, 30.0), "t": 0.0, "vida": randf_range(2.2, 3.6), "escorre": randf_range(10.0, 34.0)})

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
	# Uma pancada forte faz balançar o que está pendurado no cenário.
	if amount >= 5.0 and life_back != null and player != null:
		life_back.impulse(player.global_position.x, amount / 6.0)
		if pintura != null: pintura.impulse(player.global_position.x, amount / 6.0)
		if bichos != null: bichos.susto(player.global_position, 420.0)
		if primeiro_plano != null: primeiro_plano.impulse(amount / 6.0)
		vale_impulse(player.global_position.x, amount / 8.0)
	if player:
		player.shake = maxf(player.shake, amount)


# ---------------------------------------------------------------- salvamento
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
		"character": player.character,
		"partner_hp": partner.hp if partner != null and is_instance_valid(partner) else player.partner_hp,
		"lance_weight": partner.lance_weight if partner != null and is_instance_valid(partner) else player.lance_weight,
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
		"final": final_defeated,
		"maldicao_parcas": player.maldicao_parcas,
		"maldicao_parceira": partner.maldicao_parcas if partner!=null and is_instance_valid(partner) else player.maldicao_parceira,
		"upgrades": player.upgrades,
		"forca": player.forca,
		"frascos_extra": player.frascos_extra,
		"calices": player.calices,
		"espinhos": player.espinhos,
	}
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(data))
		f.close()


## O carregamento nunca confia no arquivo: salvamentos danificados, antigos ou editados usam valores seguros em vez de causar falhas.
func _clean_int(value, fallback: int, lo: int, hi: int) -> int:
	if value is int or value is float:
		if is_nan(float(value)) or is_inf(float(value)): return fallback
		return clampi(int(clampf(float(value), float(lo), float(hi))), lo, hi)
	if value is String and value.is_valid_float():
		return clampi(int(clampf(value.to_float(), float(lo), float(hi))), lo, hi)
	return fallback

func _clean_float(value, fallback: float, lo: float, hi: float) -> float:
	if value is int or value is float:
		if is_nan(float(value)) or is_inf(float(value)): return fallback
		return clampf(float(value), lo, hi)
	if value is String and value.is_valid_float():
		return clampf(value.to_float(), lo, hi)
	return fallback

func _clean_bool(value, fallback: bool) -> bool:
	if value is bool: return value
	if value is int or value is float: return value != 0
	return fallback

func _load() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if f == null:
		return
	var text := f.get_as_text()
	f.close()
	var reader := JSON.new()
	if reader.parse(text) != OK or typeof(reader.data) != TYPE_DICTIONARY:
		return
	var parsed: Dictionary = reader.data
	story_flags.clear()
	var saved_story = parsed.get("story_flags", [])
	if saved_story is Array:
		for flag in saved_story:
			if flag is String and flag in ["names_read", "memorial_named"] and not story_flags.has(flag): story_flags.append(flag)
	respawn_index = _clean_int(parsed.get("altar", 0), 0, 0, altars.size() - 1)
	memory_seen = _clean_bool(parsed.get("memory_seen", false), false)
	echo_count = _clean_int(parsed.get("echo_count", 0), 0, 0, 99)
	iria_met = _clean_bool(parsed.get("iria_met", false), false)
	doll_found = _clean_bool(parsed.get("doll_found", false), false)
	memorial_honored = _clean_bool(parsed.get("memorial_honored", false), false)
	player.has_weapon = _clean_bool(parsed.get("weapon", true), true)
	player.lagrimas = _clean_int(parsed.get("lagrimas", 0), 0, 0, 999999)
	player.culpa = _clean_float(parsed.get("culpa", 0.0), 0.0, 0.0, 100.0)
	player.has_double_jump = _clean_bool(parsed.get("double_jump", false), false)
	relic_taken = _clean_bool(parsed.get("relic", false), false)
	boss_defeated = _clean_bool(parsed.get("boss", false), false)
	final_defeated = _clean_bool(parsed.get("final", false), false)
	player.upgrades = _clean_int(parsed.get("upgrades", 0), 0, 0, 50)
	player.forca = _clean_int(parsed.get("forca", 0), 0, 0, 5)
	player.frascos_extra = _clean_int(parsed.get("frascos_extra", 0), 0, 0, 2)
	player.calices = _clean_int(parsed.get("calices", 0), 0, 0, 3)
	player.espinhos = _clean_int(parsed.get("espinhos", 0), 0, 0, 2)
	player.maldicao_parcas=_clean_float(parsed.get("maldicao_parcas",0),0,0,36)
	player.maldicao_parceira=_clean_float(parsed.get("maldicao_parceira",0),0,0,36)
	var saved_penitence = parsed.get("penitence", "none")
	player.apply_penitence(saved_penitence if saved_penitence is String and saved_penitence in ["none", "nails", "chains"] else "none")
	stain_active = _clean_bool(parsed.get("stain_active", false), false)
	stain_amount = _clean_int(parsed.get("stain_amount", 0), 0, 0, 999999)
	var saved_stain = parsed.get("stain_pos", [0, 600])
	if saved_stain is Array and saved_stain.size() == 2:
		stain_pos = Vector2(_clean_float(saved_stain[0], 0.0, 20.0, WORLD_W - 20.0), _clean_float(saved_stain[1], 600.0, -600.0, 1300.0))
	var saved_character = parsed.get("character", "penitente")
	player.character = saved_character if saved_character is String and player.CHARACTERS.has(saved_character) else "penitente"
	player.partner_hp = _clean_float(parsed.get("partner_hp", player.max_hp), player.max_hp, 1.0, player.max_hp)
	player.lance_weight = _clean_float(parsed.get("lance_weight", 0.0), 0.0, 0.0, 100.0)
	player.apply_character()
	if partner != null and is_instance_valid(partner):
		player.character = "penitente"
		player.apply_character()
		partner.maldicao_parcas=player.maldicao_parceira
		partner.apply_penitence(partner.penitence)
		partner.hp = clampf(player.partner_hp, 1.0, partner.max_hp)
		partner.lance_weight = player.lance_weight
	player.add_culpa(0)
	var saved_exploration = parsed.get("exploration", {})
	exploration.restore(saved_exploration if typeof(saved_exploration) == TYPE_DICTIONARY else {})
	if _clean_int(parsed.get("layout_version", 1), 1, 1, 99) < 2 and boss_defeated:
		exploration.bells = ["water", "vigil"]
		exploration.update_gate()


func _delete_save() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))


# ---------------------------------------------------------------- ciclo
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
	_atualizar_lagrimas(delta)
	clarao_t = maxf(clarao_t - delta / maxf(Engine.time_scale, 0.05), 0.0)
	for g in gotas_tela: g["t"] = float(g["t"]) + delta / maxf(Engine.time_scale, 0.05)
	gotas_tela = gotas_tela.filter(func(g): return float(g["t"]) < float(g["vida"]))
	for f in fx_list:
		f["t"] += delta
	fx_list = fx_list.filter(func(f): return f["t"] < 0.4)


func _play_update(delta: float) -> void:
	_update_duo(delta)
	_update_vale(delta)
	play_time += delta
	telemetry.tick(delta, exploration.room)
	prompt = ""
	prompt_at = Vector2.INF
	if exploration.has_method("is_transitioning") and exploration.is_transitioning(): return
	if narrative.mode != "":
		return
	if penitence_menu:
		if menu_altar == "oferendas":
			for i in range(3):
				if Input.is_action_just_pressed(["penitence_none", "penitence_nails", "penitence_chains"][i]):
					comprar_oferenda(i)
			if Input.is_action_just_pressed("offer"):
				penitence_menu = false
				player._clear_combat_input()
			return
		for choice in ["none", "nails", "chains"]:
			if Input.is_action_just_pressed("penitence_" + choice):
				player.apply_penitence(choice)
				penitence_menu = false
				# X/Y/B escolhem a penitência; não podem virar ataque ou esquiva ao fechar.
				player._clear_combat_input()
				_save()
		return
	if player.state == "execution": return
	if message_text != "":
		player.controllable = false
		if message_t <= 0.0 and (Input.is_action_just_pressed("interact") or Input.is_action_just_pressed("jump") or Input.is_action_just_pressed("confirm") or Input.is_action_just_pressed("attack")):
			advance_message()
		return
	# Confessionário: C em qualquer lugar, desde que fora de combate há um instante.
	calm_t = 0.0 if combat_reason() != "" else calm_t + delta
	if Input.is_action_just_pressed("confess") and not exploration.map_open:
		try_open_confession()
		return
	if Input.is_joy_button_pressed(0, JOY_BUTTON_Y) and not exploration.map_open and player.state == "idle":
		if not _confess_hold_used:
			confess_hold_t += delta
			if confess_hold_t >= CONFESS_HOLD:
				_confess_hold_used = true
				confess_hold_t = 0.0
				try_open_confession()
				return
	else:
		confess_hold_t = 0.0
		_confess_hold_used = false

	if boss_defeated and ending_countdown > 0.0:
		ending_countdown -= delta
		if ending_countdown <= 0.0: toast("O Guardião caiu. Você pode voltar às passagens ou contemplar a Lágrima junto aos portões.")

	var pp: Vector2 = player.global_position
	# A recuperação precede interações opcionais, incluindo personagens e altares.
	if stain_active and pp.distance_to(stain_pos) < 50:
		_dissolve_fragment(stain_pos)
		player.lagrimas += stain_amount
		stain_active = false
		stain_amount = 0
		toast("Fragmento recuperado. A capacidade da penitência foi restaurada.")
		if echo_count < GuiltText.ECHO.size() and player.state == "idle" and narrative.mode == "":
			# As primeiras recuperações revelam um pouco mais do que foi ouvido. Os valores numéricos permanecem iguais.
			narrative.begin("echo", echo_count)
			echo_count += 1
		else:
			toast("Fragmento recuperado. A capacidade da penitência foi restaurada.\n" + GuiltText.whisper(echo_count))
			echo_count += 1
		_save()
	if partner != null and is_instance_valid(partner) and partner.state == "idle" and partner.is_on_floor():
		var qp: Vector2 = partner.global_position
		for alvo in get_tree().get_nodes_in_group("enemies"):
			if not alvo.dead and alvo.state == "stagger" and not alvo.executing and absf(alvo.position.x - qp.x) < 72 and absf(alvo.position.y - qp.y) < (170 if alvo.family == "flyer" else 80):
				if partner.pressed("interact"): partner.begin_execution(alvo)
				break
	for target in get_tree().get_nodes_in_group("enemies"):
		if not target.dead and target.state == "stagger" and not target.executing and absf(target.position.x - pp.x) < 72 and absf(target.position.y - pp.y) < (170 if target.family == "flyer" else 80) and player.state == "idle" and player.is_on_floor():
			prompt = "[E] Executar"
			prompt_at = target.global_position + Vector2(0, -target.body_size.y - 30.0)
			if Input.is_action_just_pressed("interact"): player.begin_execution(target)
			return
	if exploration.room == "city" and boss_defeated and memory_seen and pp.distance_to(VALE_GATE_POS) < 65:
		if not final_defeated:
			# Além dos portões fica o Vale, e nele a última luta.
			prompt = "[E] Descer ao Vale dos Flagelados"
			prompt_at = VALE_GATE_POS + Vector2(0, -130)
			if Input.is_action_just_pressed("interact"):
				enter_vale()
			return
		prompt = "[E] Contemplar a primeira Lágrima · encerrar a vigília"
		prompt_at = VALE_GATE_POS + Vector2(0, -130)
		if Input.is_action_just_pressed("interact"):
			state = "ending"
			ending_t = 0
			player.controllable = false
		return
	if exploration.update(delta): return
	var new_area := Layout.city_area_at(pp.x)
	if area_name != new_area:
		area_name = new_area
		area_t = 4.5

	if not player.has_weapon and pp.distance_to(SWORD_POS) < 70.0:
		prompt = "[E] Empunhar a espada"
		prompt_at = SWORD_POS + Vector2(0, -70)
		if Input.is_action_just_pressed("interact"):
			soundscape.chime()
			player.has_weapon = true
			_save()
			show_message("A ESPADA DIANTE DO TÚMULO", "O metal parece reconhecer sua mão.\nEspinhos e sangue antigo cobrem a lâmina.\n\n[J / X] Atacar   ·   [K / SHIFT] Rolar\nProcure o altar iluminado adiante.")
		return


	if pp.distance_to(IRIA_POS) < 65:
		prompt = "[E] Falar com Iria" if not iria_met else "[E] Ouvir Iria"
		prompt_at = IRIA_POS + Vector2(0, -130)
		if Input.is_action_just_pressed("interact"):
			iria_met = true
			var has_register: bool = exploration.collected.has("register")
			show_dialogue(Story.iria_pages(has_register, story_flags.has("names_read"), memorial_honored, story_flags.has("memorial_named"), memory_seen), "names_read" if has_register and not story_flags.has("names_read") else "")
			_save()
		return
	if doll_found and pp.distance_to(MEMORIAL_POS) < 60:
		var known_name: bool = exploration.collected.has("register")
		var can_name: bool = known_name and not story_flags.has("memorial_named")
		if not memorial_honored or can_name:
			prompt = "[E] Gravar o nome de Alba no memorial" if memorial_honored else "[E] Deixar a boneca no memorial"
			prompt_at = MEMORIAL_POS + Vector2(0, -120)
			if Input.is_action_just_pressed("interact"):
				memorial_honored = true
				if known_name and not story_flags.has("memorial_named"): story_flags.append("memorial_named")
				_save()
				# Uma cena, não uma janela: o jogador se ajoelha, o sino soa uma vez e nenhuma recompensa interrompe o silêncio.
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
		prompt = altar_prompt()
		prompt_at = altars[near_altar] + Vector2(0, -150)
		if player.state == "idle":
			if Input.is_action_just_pressed("interact"):
				_pray(near_altar)
			elif Input.is_action_just_pressed("offer"):
				abrir_oferendas()
	elif near_lore >= 0:
		prompt = "[E] Examinar"
		prompt_at = Vector2(float(lore[near_lore]["x"]), GROUND_Y - 90.0)
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
	player.remover_maldicao()
	player.maldicao_parceira=0
	player.hp = player.max_hp
	player.flasks = player.max_flasks
	# A oração restaura os dois penitentes e alivia o peso da lança.
	player.partner_hp = player.max_hp
	player.lance_weight = 0.0
	if partner != null and is_instance_valid(partner):
		partner.remover_maldicao()
		partner.hp = partner.max_hp
		partner.flasks = partner.max_flasks
		partner.lance_weight = 0.0
	player.invuln = 1.2
	soundscape.chime()
	_spawn_enemies()
	_save()
	spawn_fx(player.global_position + Vector2(0, -50), Color(1.0, 0.85, 0.5))
	toast("%s — descanso concluído. Os inimigos comuns retornaram." % altar_names[respawn_index])


## Motivo pelo qual o peregrino está em combate agora, ou "" se estiver livre.
## Usa o mesmo critério da música de combate: chefe desperto, arena fechada,
## inimigo perseguindo ou atacando perto de um dos penitentes, ou o próprio
## penitente no meio de um golpe, esquiva, cura ou ferimento.
func combat_reason() -> String:
	if boss != null and is_instance_valid(boss) and boss.awake and not boss.dead and exploration.room == "city":
		return "O Guardião está desperto. O Confessor não ouve sob os sinos."
	if finale != null and is_instance_valid(finale):
		return "Agora não há grade nem voz. Só o que você vê."
	if exploration.room == "vale" and not final_defeated:
		return "No Vale o Confessor se cala. Ninguém atravessa a culpa de outro."
	if exploration.arena_active != "":
		return "A arena ainda não foi vencida."
	if player.state not in ["idle", "pray"]:
		return "Termine o que começou antes de se confessar."
	var penitents: Array = [player]
	if partner != null and is_instance_valid(partner): penitents.append(partner)
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if enemy.dead or enemy.room_id != exploration.room: continue
		if enemy.state not in ["chase", "windup", "strike", "recover", "cast", "hurt", "stagger"]: continue
		for who in penitents:
			if enemy.global_position.distance_to(who.global_position) < 420.0:
				return "Há inimigos à sua procura. Afaste-se antes de se confessar."
	return ""


## Abre o Confessionário se o peregrino estiver fora de combate; senão, explica por quê.
## Por que o Confessionário não pode abrir agora, ou "" se pode.
func confession_block_reason() -> String:
	if state != "play": return "O Confessor só ouve durante a peregrinação."
	var reason := combat_reason()
	if reason == "" and calm_t < CALM_BEFORE_CONFESSION:
		reason = "Recupere o fôlego por um instante antes de se confessar."
	return reason


func try_open_confession() -> bool:
	if confession_open or state != "play": return false
	var reason := confession_block_reason()
	if reason != "":
		toast(reason)
		return false
	var where: String = str(exploration.rooms[exploration.room].name)
	for i in range(altars.size()):
		if player.global_position.distance_to(altars[i]) < 80.0: where = altar_names[i]
	open_confession(where)
	return true


## Pelo menu de pausa (Y no controle, C no teclado). Se não puder, a pausa continua
## e o motivo volta para ser mostrado ali, sem devolver o jogador ao combate.
func confess_from_pause() -> String:
	var reason := confession_block_reason()
	if reason != "": return reason
	toggle_pause()
	try_open_confession()
	return ""


## O Confessionário pausa o mundo: nenhum inimigo age enquanto o peregrino conversa.
func open_confession(where: String) -> void:
	if confession_open: return
	confession_open = true
	get_tree().paused = true
	confession_panel.open(where)


func close_confession() -> void:
	if not confession_open: return
	confession_open = false
	get_tree().paused = false
	player._clear_combat_input()
	player.input_release_gate = true
	telemetry.save()


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
	if lagrima_textura == null and ResourceLoader.exists("res://assets/ui/lagrima_gema.png"): lagrima_textura = load("res://assets/ui/lagrima_gema.png")
	for l in lagrimas_ar:
		var brilho := 0.75 + 0.25 * sin(l.t * 30.0)
		fxn.draw_circle(l.p, 9.0, Color(0.9, 0.12, 0.14, 0.18 * brilho))
		if lagrima_textura != null:
			fxn.draw_texture_rect(lagrima_textura, Rect2(l.p - Vector2(5, 8), Vector2(10, 16)), false, Color(1, 1, 1, brilho))
		else:
			fxn.draw_circle(l.p, 4.0, Color(0.8, 0.05, 0.08))
		fxn.draw_line(l.p, l.p - l.v.normalized() * 14.0, Color(0.85, 0.15, 0.15, 0.35), 2.0)
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

## Texto do altar (a interface desenha cada tecla acima do altar).
func altar_prompt() -> String:
	return "[E] Orar  ·  [R] Oferendas  ·  [V] Penitências"

func abrir_oferendas() -> void:
	if player.state != "idle" or not at_altar(): return
	menu_altar = "oferendas"
	penitence_menu = true
	soundscape.play_sfx("ui_confirmar")

## Oferendas no altar: lágrimas em troca de vida, força ou mais um frasco.
const OFERENDAS := [
	{"nome": "Carne que suporta", "efeito": "+15 de vida máxima", "base": 100, "max": 5},
	{"nome": "Braço da penitência", "efeito": "+10% de dano", "base": 150, "max": 5},
	{"nome": "Frasco da vigília", "efeito": "+1 frasco de cura", "base": 400, "max": 2},
]
func nivel_oferenda(i: int) -> int:
	return [player.upgrades, player.forca, player.frascos_extra][i]

func custo_oferenda(i: int) -> int:
	return int(OFERENDAS[i].base) * (nivel_oferenda(i) + 1)

func comprar_oferenda(i: int) -> void:
	var o: Dictionary = OFERENDAS[i]
	if nivel_oferenda(i) >= int(o.max):
		toast("Nada mais pode ser oferecido aqui.")
		return
	var custo := custo_oferenda(i)
	if player.lagrimas < custo:
		toast("Lágrimas insuficientes (precisa de %d)." % custo)
		soundscape.play_sfx("ui_mover")
		return
	player.lagrimas -= custo
	match i:
		0:
			player.upgrades += 1
			player.apply_penitence(player.penitence)
			player.hp = player.max_hp
		1: player.forca += 1
		2:
			player.frascos_extra += 1
			player.max_flasks += 1
			player.flasks = player.max_flasks
	_sincronizar_progresso()
	soundscape.play_sfx("oferenda")
	spawn_fx(player.global_position + Vector2(0, -50), Color(0.9, 0.2, 0.2))
	toast("%s · %s" % [o.nome, o.efeito])
	_save()

## Beatriz recebe as mesmas melhorias que o Penitente.
func _sincronizar_progresso() -> void:
	if partner == null or not is_instance_valid(partner): return
	partner.upgrades = player.upgrades
	partner.forca = player.forca
	partner.calices = player.calices
	partner.espinhos = player.espinhos
	if partner.max_flasks != player.max_flasks:
		partner.max_flasks = player.max_flasks
		partner.flasks = mini(partner.flasks + 1, partner.max_flasks)
	partner.apply_penitence(partner.penitence)

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

## As criaturas aprovadas usam o mesmo ciclo de descanso e reaparecimento do restante do ato.
func _criar_criaturas_aprovadas() -> void:
	for dados in preload("res://scripts/act_one_layout.gd").criaturas_aprovadas():
		var criatura=new_enemy(dados[1], CriaturaGoyaScript)
		criatura.setup(dados[1],Vector2(dados[2],dados[3]),dados[4],player)
		criatura.room_id=dados[0]
		if dados.size()>5:criatura.group=int(dados[5])
		criatura.killed.connect(_on_enemy_killed)
		add_child(criatura)
