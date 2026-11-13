extends SceneTree
## Folhas de contato dos atlas reais e capturas de cada execução em cena.
const Actor = preload("res://scripts/actor_animation.gd")
var game
var directory := ""
func _initialize() -> void: call_deferred("run")
func frames(n: int) -> void:
	for i in range(n):
		await physics_frame
		await process_frame
func contact(actor_name: String, clip: String, columns: int, filename: String) -> void:
	var actor = Actor.new()
	actor.configure(actor_name, 1.0)
	var count: int = actor.sprite_frames.get_frame_count(clip)
	var rows := ceili(float(count) / columns)
	var viewport := SubViewport.new()
	viewport.size = Vector2i(columns * 256, rows * 286)
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(viewport)
	var background := ColorRect.new()
	background.size = Vector2(viewport.size)
	background.color = Color("272b30")
	viewport.add_child(background)
	for i in range(count):
		var sprite := Sprite2D.new()
		sprite.texture = actor.sprite_frames.get_frame_texture(clip, i)
		sprite.position = Vector2((i % columns) * 256 + 128, (i / columns) * 286 + 128)
		viewport.add_child(sprite)
		var label := Label.new()
		label.text = "%02d%s" % [i, " · contato" if i == 8 and count == 12 else ""]
		label.position = Vector2((i % columns) * 256 + 12, (i / columns) * 286 + 258)
		viewport.add_child(label)
	await RenderingServer.frame_post_draw
	var err := viewport.get_texture().get_image().save_png(directory.path_join(filename))
	print("CONTACT: ", filename, " code=", err)
	actor.free()
	viewport.queue_free()
	await frames(2)
func capture(label: String) -> void:
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(directory.path_join(label + ".png"))
	print("CAPTURE: ", label)
func run() -> void:
	directory = OS.get_environment("LACRIMAE_REVIEW_DIR")
	if directory.is_empty(): quit(3); return
	for name in ["devorador", "flagelante", "bruxa", "asmodeia", "duelista", "carregador"]:
		await contact("hero", "execute_" + name, 6, "contato-" + name + ".png")
	await contact("beatriz", "idle_weight", 3, "contato-peso.png")
	for name in ["faiscas", "sangue", "pedra", "osso"]:
		await contact("impactos", name, 6, "contato-impacto-" + name + ".png")
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	game._start_game(false, false)
	for i in range(3):
		game.message_t = 0
		game.advance_message()
	for e in get_nodes_in_group("enemies"): e.queue_free()
	game.message_text = ""
	if game.narrative.mode != "": game.narrative.finish()
	game.exploration.arenas_enabled = false
	var p = game.player
	p.revive(Vector2(900, 600))
	p.has_weapon = true
	await frames(6)
	game.set_process(false)
	p.set_physics_process(false)
	p.set_process(false)
	p.invuln = 0.0
	p.state = "idle"
	p.camera.position_smoothing_enabled = false
	p.camera.zoom = Vector2.ONE
	game.area_t = 0.0
	game.toast_t = 0.0
	for kind in [3, 4, 5, 6, 7, 8]:
		p.revive(Vector2(900, 600))
		p.state = "idle"
		var e = game.EnemyScript.new()
		e.setup(kind, Vector2(950, 600), 0, p)
		e.room_id = "city"
		game.add_child(e)
		e.set_physics_process(false)
		e.spawn_opacity = 1.0
		if kind == 8: e._break_coffin()
		e.state = "stagger"
		e.state_t = 2.0
		p.begin_execution(e)
		for frame_index in [5, 8, 10]:
			p.hit_pause = 0.0
			p.state_t = 1.0 - (frame_index + 0.01) / 12.0
			p._physics_process(0.0)
			p._update_animation()
			await frames(2)
			await capture("cena-%s-%02d" % [str(e.TYPES[kind].actor), frame_index])
		p.hit_pause = 0.0
		p.state_t = 0.0
		p._physics_process(0.0)
		e.queue_free()
		await frames(8)
	game.queue_free()
	game = null
	await frames(5)
	quit()
