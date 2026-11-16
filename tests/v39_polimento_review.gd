extends SceneTree
## Revisão visual de polimento: a espada em cada quadro, os pés no chão em cada sala, a dupla lado a lado.
## Uso: LACRIMAE_REVIEW_DIR=<pasta> godot --rendering-driver opengl3 --script tests/v39_polimento_review.gd
var game
var directory: String

func _initialize() -> void: call_deferred("run")

func frames(n: int) -> void:
	for i in range(n):
		await physics_frame
		await process_frame

func recorte(name: String, centro: Vector2, tam: Vector2i) -> void:
	await RenderingServer.frame_post_draw
	var img: Image = root.get_texture().get_image()
	var x := clampi(int(centro.x) - tam.x / 2, 0, img.get_width() - tam.x)
	var y := clampi(int(centro.y) - tam.y / 2, 0, img.get_height() - tam.y)
	img.get_region(Rect2i(x, y, tam.x, tam.y)).save_png(directory.path_join(name + ".png"))

func tela(name: String) -> void:
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(directory.path_join(name + ".png"))

## Um x de chão livre na sala: sem alvenaria nem galeria por perto.
func chao_livre(id: String, fracao: float) -> float:
	var b: Rect2 = game.exploration.rooms[id].bounds
	var x := b.position.x + b.size.x * fracao
	for tentativa in range(40):
		var livre := true
		for r in game.exploration.blocks + game.exploration.ledges:
			if x > r.position.x - 170.0 and x < r.end.x + 170.0 and r.position.y > game.exploration.rooms[id].floor - 260.0: livre = false
		if livre: return x
		x += 60.0
	return x

func run() -> void:
	directory = OS.get_environment("LACRIMAE_REVIEW_DIR")
	if directory.is_empty():
		quit(3)
		return
	var parte := OS.get_environment("LACRIMAE_REVIEW_PARTE")
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	game._start_game(false, false)
	await frames(20)
	var p = game.player
	p.dev_god = true
	p.has_weapon = true
	game.message_text = ""
	if parte == "" or parte == "espada":
		# ---- a espada, quadro a quadro, sobre um fundo liso
		game.exploration.travel("court", Vector2(chao_livre("court", 0.3), 600), 1)
		await frames(40)
		game.message_text = ""
		for inimigo in root.get_tree().get_nodes_in_group("enemies"): inimigo.queue_free()
		await frames(3)
		p.set_physics_process(false)
		p.set_process(false)
		var fundo := ColorRect.new()
		fundo.color = Color(0.36, 0.36, 0.40)
		fundo.size = Vector2(420, 300)
		fundo.position = p.global_position + Vector2(-210, -230)
		game.add_child(fundo)
		game.move_child(fundo, p.get_index())
		await frames(3)
		var centro: Vector2 = p.get_global_transform_with_canvas().origin + Vector2(0, -70)
		for clip in ["idle", "run", "jump", "roll", "hurt", "attack_a", "attack_b", "parry", "charged_heavy", "air_attack", "heal"]:
			var n: int = p.animator.sprite_frames.get_frame_count(clip)
			for lado in ([1, -1] if clip in ["idle", "run"] else [1]):
				for i in range(n):
					p.facing = lado
					p.state = "idle" if clip in ["idle", "run"] else "attack"
					p.animator.pose(clip, lado, i)
					p._update_sword()
					p.queue_redraw()
					await frames(1)
					await recorte("espada-%s-%s-%02d" % [clip, "d" if lado > 0 else "e", i], centro, Vector2i(150, 140))
		fundo.queue_free()
		p.set_physics_process(true)
		p.set_process(true)
		p.state = "idle"
	if parte == "" or parte == "salas":
		# ---- cada sala com a dupla no chão livre
		game.enable_duo(true)
		await frames(5)
		for id in ["city", "ossuary", "cistern", "cloister", "belfry", "archive", "refuge", "nave", "terrace", "court"]:
			var piso: float = game.exploration.rooms[id].floor
			var x := chao_livre(id, 0.45) if id != "city" else 3300.0
			game.exploration.travel(id, Vector2(x, piso), 1)
			await frames(50)
			game.message_text = ""
			game.toast_t = 0.0
			game.area_t = 0.0
			p.global_position = Vector2(x, piso)
			p.velocity = Vector2.ZERO
			if game.partner != null:
				game.partner.global_position = Vector2(x - 90.0, piso)
				game.partner.velocity = Vector2.ZERO
			p.camera.reset_smoothing()
			await frames(45)
			await tela("sala-" + id)
			var pe: Vector2 = p.get_global_transform_with_canvas().origin
			await recorte("pes-" + id, pe + Vector2(-40, -30), Vector2i(360, 200))
			print("SALA ", id, " penitente y=", p.global_position.y, " piso=", piso, " no chão=", p.is_on_floor(), " beatriz=", game.partner != null, " beatriz y=", game.partner.global_position.y if game.partner != null else 0.0)
	game._delete_save()
	game.queue_free()
	game = null
	await frames(5)
	quit()
