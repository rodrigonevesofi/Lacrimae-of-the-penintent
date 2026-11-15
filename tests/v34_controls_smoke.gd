extends SceneTree
## Regressões de conflito entre navegação do modo dev e os controles de Beatriz.
var game
var checks := 0
var failures := 0
func _initialize() -> void: call_deferred("run")
func expect(ok: bool, label: String) -> void:
	checks += 1
	print("PASS: " if ok else "FAIL: ", label)
	if not ok: failures += 1
func frames(n: int) -> void:
	for i in range(n):
		await physics_frame
		await process_frame
func run() -> void:
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	game._start_game(false, false)
	game.enable_duo(true)
	for i in range(3):
		game.message_t = 0
		game.advance_message()
	for e in get_nodes_in_group("enemies"): e.queue_free()
	game.exploration.arenas_enabled = false
	game.player.revive(Vector2(900, 600))
	game.partner.revive(Vector2(820, 600))
	await frames(5)
	game.toggle_dev()
	Input.action_press("p2_jump")
	await frames(2)
	Input.action_release("p2_jump")
	expect(game.partner.ai, "seta de navegação do modo dev preserva a IA de Beatriz")
	game.partner.ai = false
	game.partner.revive(Vector2(820, 600))
	await frames(5)
	Input.action_press("p2_jump")
	await frames(8)
	Input.action_release("p2_jump")
	expect(game.partner.is_on_floor(), "seta de navegação do modo dev não faz a jogadora 2 pular")
	game.toggle_dev()
	game.partner.ai = true
	game.exploration.map_open = true
	Input.action_press("p2_attack")
	await frames(2)
	Input.action_release("p2_attack")
	expect(game.partner.ai, "comandos no mapa preservam o controle da IA")
	game.exploration.map_open = false
	await frames(3)
	Input.action_press("p2_attack")
	await frames(2)
	Input.action_release("p2_attack")
	expect(not game.partner.ai, "comandos durante a partida ainda permitem assumir Beatriz")
	var event := InputEventKey.new()
	event.keycode = KEY_F4
	event.pressed = true
	game.dev_input(event)
	expect(game.partner.ai, "F4 devolve Beatriz à IA")
	game.exploration.travel("cistern", Vector2(8800, 600))
	await frames(35)
	for e in get_nodes_in_group("enemies"): e.queue_free()
	game.dev_mode = true
	game.player.safe_pos = Vector2(8800, 600)
	game.player.dev_fly = true
	game.player.position = Vector2(9110, 575)
	event.keycode = KEY_N
	game.dev_input(event)
	await frames(20)
	expect(not game.player.dev_fly and game.player.position.distance_to(Vector2(8800, 600)) < 30.0, "desligar voo dentro de pedra retorna ao piso seguro")
	game.player.dev_fly = true
	game.player.position = Vector2(9110, 575)
	game.toggle_dev()
	await frames(20)
	expect(not game.player.dev_fly and game.player.position.distance_to(Vector2(8800, 600)) < 30.0, "fechar modo dev dentro da pedra também retorna ao piso seguro")
	game._delete_save()
	game.queue_free()
	game = null
	await frames(5)
	print("V34_CONTROLS: %d checks, %d failures" % [checks, failures])
	quit(0 if failures == 0 else 1)
