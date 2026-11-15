extends SceneTree
# Controles: simula eventos reais de controle (botões e analógicos) nos devices 0 e 1.
# godot --headless --path . --script res://tests/gamepad_smoke.gd
var game
var failures: Array[String] = []

func _initialize(): call_deferred("run")

func check(ok: bool, label: String) -> void:
	print(("PASS: " if ok else "FAIL: ") + label)
	if not ok: failures.append(label)

func frames(n: int) -> void:
	for i in range(n):
		await physics_frame
		await process_frame

func button(device: int, index: int, down: bool) -> void:
	var ev := InputEventJoypadButton.new()
	ev.device = device
	ev.button_index = index
	ev.pressed = down
	ev.pressure = 1.0 if down else 0.0
	Input.parse_input_event(ev)

func axis(device: int, which: int, value: float) -> void:
	var ev := InputEventJoypadMotion.new()
	ev.device = device
	ev.axis = which
	ev.axis_value = value
	Input.parse_input_event(ev)

func tap(device: int, index: int) -> void:
	button(device, index, true)
	await frames(2)
	button(device, index, false)
	await frames(2)

func run() -> void:
	create_timer(40.0).timeout.connect(func(): print("GAMEPAD_TIMEOUT"); quit(4))
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await frames(3)

	# Mapeamento: cada ação do Penitente tem botão no 1º controle.
	var expected := {"jump": JOY_BUTTON_A, "attack": JOY_BUTTON_X, "roll": JOY_BUTTON_B, "interact": JOY_BUTTON_Y, "parry": JOY_BUTTON_RIGHT_SHOULDER, "heal": JOY_BUTTON_LEFT_SHOULDER, "share_blood": JOY_BUTTON_DPAD_UP, "pause": JOY_BUTTON_START, "map": JOY_BUTTON_BACK, "penitence_menu": JOY_BUTTON_LEFT_STICK, "offer": JOY_BUTTON_RIGHT_STICK, "confirm": JOY_BUTTON_A, "continue_game": JOY_BUTTON_Y}
	for action in expected:
		var found := false
		for ev in InputMap.action_get_events(action):
			if ev is InputEventJoypadButton and ev.button_index == expected[action] and ev.device in [0, -1]: found = true
		check(found, "1º controle: %s" % action)
	for action in ["heavy", "penance"]:
		var trig := false
		for ev in InputMap.action_get_events(action):
			if ev is InputEventJoypadMotion and ev.device == 0: trig = true
		check(trig, "1º controle: %s no gatilho" % action)
	var p2_interact := false
	for ev in InputMap.action_get_events("p2_interact"):
		if ev is InputEventJoypadButton and ev.device == 1 and ev.button_index == JOY_BUTTON_Y: p2_interact = true
	check(p2_interact, "2º controle: Beatriz interage com Y")

	# Título: A inicia a peregrinação.
	await tap(0, JOY_BUTTON_A)
	check(game.state == "play", "A no título inicia o jogo")
	check(game.using_pad, "dicas passam a mostrar botões do controle")
	check(game.pad_text("[E] Orar  ·  [R] Oferecer  ·  [V] Penitências") == "[Y] Orar  ·  [R3] Oferecer  ·  [L3] Penitências", "prompts trocam teclas por botões")
	# A abertura, ao terminar, mostra a página seguinte do prólogo; fecha as duas.
	if game.narrative.mode != "": game.narrative.finish()
	game.message_text = ""
	game.prologue_page = -1
	game.player.has_weapon = true
	game.player.controllable = true
	for e in get_nodes_in_group("enemies"): e.global_position = Vector2(-5000, -5000)
	game.enable_duo(true)   # em execução por script a dupla não entra sozinha
	game.player.revive(Vector2(900, 600))
	game.partner.revive(Vector2(700, 600))
	await frames(20)

	# Analógico move o Penitente; o 2º controle não move o Penitente.
	var x0: float = game.player.global_position.x
	axis(0, JOY_AXIS_LEFT_X, 1.0)
	await frames(20)
	axis(0, JOY_AXIS_LEFT_X, 0.0)
	check(game.player.global_position.x > x0 + 40.0, "analógico do 1º controle anda para a direita")
	await frames(10)
	x0 = game.player.global_position.x
	axis(1, JOY_AXIS_LEFT_X, 1.0)
	await frames(15)
	axis(1, JOY_AXIS_LEFT_X, 0.0)
	check(absf(game.player.global_position.x - x0) < 5.0, "2º controle não move o Penitente")
	check(game.partner != null and not game.partner.ai, "2º controle assume Beatriz")
	await frames(10)

	# A pula.
	await frames(5)
	button(0, JOY_BUTTON_A, true)
	await frames(6)
	check(not game.player.is_on_floor(), "A faz o Penitente pular")
	button(0, JOY_BUTTON_A, false)
	await frames(60)

	# Analógico levemente inclinado para baixo não conta como "baixo".
	axis(0, JOY_AXIS_LEFT_Y, 0.4)
	await frames(2)
	check(not Input.is_action_pressed("down"), "diagonal leve do analógico não aciona baixo")
	axis(0, JOY_AXIS_LEFT_Y, 0.9)
	await frames(2)
	check(Input.is_action_pressed("down"), "analógico bem inclinado aciona baixo")
	axis(0, JOY_AXIS_LEFT_Y, 0.0)
	await frames(2)

	# Back abre e fecha o mapa; Start pausa e retoma.
	await tap(0, JOY_BUTTON_BACK)
	check(game.exploration.map_open, "Back abre o mapa")
	await tap(0, JOY_BUTTON_BACK)
	check(not game.exploration.map_open, "Back fecha o mapa")
	await tap(0, JOY_BUTTON_START)
	check(game.paused, "Start pausa")
	await tap(0, JOY_BUTTON_START)
	check(not game.paused, "Start retoma")

	# Altar: L3 abre as penitências, Y escolhe os Pregos e não vira interação.
	game.player.revive(game.altars[0])
	await frames(15)
	await tap(0, JOY_BUTTON_LEFT_STICK)
	check(game.penitence_menu, "L3 no altar abre as penitências")
	await tap(0, JOY_BUTTON_Y)
	check(not game.penitence_menu and game.player.penitence == "nails", "Y escolhe os Pregos da Contrição")
	check(game.narrative.mode == "", "escolher com Y não começa uma oração")

	# Confessionário pelo controle: Start → Y abre; ↓ escolhe; A pergunta; B fecha.
	game.confessor.api_key = ""
	game.player.revive(Vector2(900, 600))
	await frames(10)
	game.calm_t = 5.0
	await tap(0, JOY_BUTTON_START)
	await tap(0, JOY_BUTTON_Y)
	check(game.confession_open and game.confession_panel.visible and not game.paused, "Y na pausa abre o Confessionário")
	var panel = game.confession_panel
	check(panel.suggestions.size() >= 4, "painel oferece perguntas prontas")
	check(panel.selected == 0, "primeira pergunta começa selecionada")
	await tap(0, JOY_BUTTON_DPAD_DOWN)
	check(panel.selected == 1, "direcional ↓ escolhe a próxima pergunta")
	axis(0, JOY_AXIS_LEFT_Y, -1.0)
	await frames(4)
	axis(0, JOY_AXIS_LEFT_Y, 0.0)
	await frames(2)
	check(panel.selected == 0, "analógico ↑ volta uma pergunta, só uma")
	var before: int = panel.entries.size()
	var question: String = panel.suggestions[0]
	await tap(0, JOY_BUTTON_A)
	await frames(4)
	check(panel.entries.size() == before + 2 and panel.entries[before].text == question, "A envia a pergunta e o Confessor responde")
	check(game.player.state == "idle" and game.player.is_on_floor(), "A no painel não faz o Penitente pular")
	await tap(0, JOY_BUTTON_B)
	check(not game.confession_open and not paused, "B fecha o Confessionário e devolve o jogo")
	# Em combate, Y na pausa não abre: a pausa continua e mostra o motivo.
	var foe = null
	for e in get_nodes_in_group("enemies"):
		if not e.dead and e.room_id == "city" and e != game.boss: foe = e
	foe.global_position = game.player.global_position + Vector2(150, 0)
	foe.state = "chase"
	await tap(0, JOY_BUTTON_START)
	foe.state = "chase"
	await tap(0, JOY_BUTTON_Y)
	check(game.paused and not game.confession_open and game.hud.pause_notice != "", "em combate, Y na pausa explica o motivo e não abre")
	foe.global_position = Vector2(-5000, -5000)
	await tap(0, JOY_BUTTON_START)

	# Teclado volta a mostrar as teclas.
	var key := InputEventKey.new()
	key.keycode = KEY_D
	key.physical_keycode = KEY_D
	key.pressed = true
	Input.parse_input_event(key)
	await frames(2)
	key.pressed = false
	Input.parse_input_event(key)
	await frames(2)
	check(not game.using_pad, "tecla volta as dicas para o teclado")

	print("GAMEPAD_RESULT ", "PASS" if failures.is_empty() else "FAIL " + ", ".join(failures))
	game._delete_save()
	quit(0 if failures.is_empty() else 1)
