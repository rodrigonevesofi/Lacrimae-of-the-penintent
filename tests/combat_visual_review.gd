extends SceneTree
## Capturas renderizadas para conferir leitura dos golpes e efeitos.
var game
func _initialize() -> void: call_deferred("run")
func frames(n: int) -> void:
	for i in range(n):
		await physics_frame
		await process_frame
func capture(label: String) -> void:
	await RenderingServer.frame_post_draw
	var image := root.get_texture().get_image()
	var directory := OS.get_environment("LACRIMAE_REVIEW_DIR")
	if directory.is_empty():
		push_error("Defina LACRIMAE_REVIEW_DIR para salvar as capturas.")
		quit(3)
		return
	image.save_png(directory.path_join(label + ".png"))
	print("CAPTURE: ", label)
func run() -> void:
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	game._start_game(false, false)
	game.enable_duo(true)
	for i in range(3):
		game.message_t = 0
		game.advance_message()
	for e in get_nodes_in_group("enemies"): e.queue_free()
	var p = game.player
	p.revive(Vector2(1450, 600))
	p.has_weapon = true
	p.dev_god = true
	p.facing = 1
	game.area_t = 0
	game.toast_t = 0
	await frames(30)
	var e = game.EnemyScript.new()
	e.setup(3, Vector2(1530, 600), 0, p)
	e.room_id = "city"
	game.add_child(e)
	e.spawn_opacity = 1
	e.set_physics_process(false)
	await frames(3)
	p._start_attack()
	await frames(8)
	await capture("01-golpe-leve")
	await frames(25)
	p._start_charge()
	Input.action_press("heavy")
	await frames(58)
	await capture("02-carga-pronta")
	Input.action_release("heavy")
	await frames(7)
	await capture("03-golpe-carregado")
	await frames(30)
	p._plunge_impact()
	await frames(4)
	await capture("04-onda-descendente")
	await frames(30)
	for foe in get_nodes_in_group("enemies"): foe.queue_free()
	await frames(2)
	var b = game.partner
	b.ai = false
	b.set_physics_process(false)
	p.set_physics_process(false)
	p.revive(Vector2(1450, 600))
	p.state = "idle"
	b.position = Vector2(1580, 600)
	b.has_weapon = true
	b.facing = 1
	b._start_attack()
	b.state_t = b.attack_len * 0.55
	game.toast_t = 0
	await frames(3)
	await capture("05-beatriz-estocada")
	b.state = "fallen"
	await frames(3)
	await capture("06-beatriz-caida")
	b.state = "idle"
	b.revive_t = 0.55
	p.state = "fallen"
	await frames(3)
	await capture("07-sangue-compartilhado")
	game.queue_free()
	game = null
	await frames(10)
	quit()
