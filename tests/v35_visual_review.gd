extends SceneTree
## Capturas do painel de pausa e do golpe mortal com os recursos reais do jogo.
var game
var directory := ""
func _initialize() -> void: call_deferred("run")
func frames(n: int) -> void:
	for i in range(n):
		await physics_frame
		await process_frame
func capture(filename: String) -> void:
	await RenderingServer.frame_post_draw
	var err := root.get_texture().get_image().save_png(directory.path_join(filename + ".png"))
	print("CAPTURE: ", filename, " code=", err)
func run() -> void:
	directory = OS.get_environment("LACRIMAE_REVIEW_DIR")
	if directory.is_empty(): quit(3); return
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
	game.player.has_weapon = true
	await frames(8)
	game.set_process(false)
	game.player.set_physics_process(false)
	game.partner.set_physics_process(false)
	game.paused = true
	await frames(2)
	await capture("pausa-controles")
	game.paused = false
	var p = game.player
	p.camera.position_smoothing_enabled = false
	game.area_t = 0.0
	game.toast_t = 0.0
	var e = game.new_enemy(3)
	e.setup(3, Vector2(950, 600), 0, p)
	game.add_child(e)
	e.set_physics_process(false)
	e.spawn_opacity = 1.0
	e.state = "stagger"
	e.state_t = 2.0
	p.begin_execution(e)
	p.hit_pause = 0.0
	p.state_t = 1.0 - 8.01 / 12.0
	p._physics_process(0.0)
	p._update_animation()
	await frames(5)
	await capture("execucao-golpe")
	await frames(35)
	await capture("execucao-respingos")
	game.reduced_pulses = true
	p.gore_flash = 0.5
	await capture("execucao-reduzir-pulsos")
	game.reduced_pulses = false
	p.gore_flash = 0.0
	game.partner.gore_flash = 0.5
	await capture("execucao-beatriz-borda")
	Engine.time_scale = 1.0
	game.queue_free()
	game = null
	await frames(5)
	quit()
