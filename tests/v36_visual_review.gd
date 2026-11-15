extends SceneTree
## Contatos comparativos e capturas dirigidas das mecânicas no renderizador real.
var game
var directory := ""
var label: Label
func _initialize() -> void: call_deferred("run")
func frames(n: int) -> void:
	for i in range(n):
		await physics_frame
		await process_frame
func texture(path: String) -> Texture2D:
	return ImageTexture.create_from_image(Image.load_from_file(path))
func contact(sheets: Array, rows: int, name: String, titles: Array) -> void:
	var viewport := SubViewport.new()
	viewport.size = Vector2i(1536, sheets.size() * rows * 286)
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(viewport)
	var bg := ColorRect.new()
	bg.size = Vector2(viewport.size)
	bg.color = Color("292d34")
	viewport.add_child(bg)
	for sheet_index in range(sheets.size()):
		var art: Texture2D = sheets[sheet_index]
		var count := rows * 6
		var source_rows := int(art.get_height()) / 256
		var start := 12 if source_rows == 4 and rows == 2 else 0
		for i in range(count):
			var sprite := Sprite2D.new()
			var cell := AtlasTexture.new()
			cell.atlas = art
			var index := start + i
			cell.region = Rect2((index % 6) * 256, (index / 6) * 256, 256, 256)
			sprite.texture = cell
			sprite.position = Vector2((i % 6) * 256 + 128, (sheet_index * rows + i / 6) * 286 + 128)
			viewport.add_child(sprite)
			var title := Label.new()
			title.text = str(titles[sheet_index]) + " · %02d" % i
			title.position = sprite.position + Vector2(-120,132)
			viewport.add_child(title)
	await RenderingServer.frame_post_draw
	viewport.get_texture().get_image().save_png(directory.path_join(name + ".png"))
	viewport.queue_free()
	await frames(2)
func capture(name: String, caption: String) -> void:
	label.text = caption
	await frames(2)
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(directory.path_join(name + ".png"))
	print("CAPTURE: ",name)
func effects_contact() -> void:
	var viewport := SubViewport.new()
	viewport.size = Vector2i(1536,1100)
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(viewport)
	var bg := ColorRect.new()
	bg.size = Vector2(viewport.size)
	bg.color = Color("292d34")
	viewport.add_child(bg)
	var paths := ["efeitos/sangue_chao", "efeitos/sangue_parede", "animation/jato_arterial", "animation/pedacos"]
	for i in range(paths.size()):
		var title := Label.new()
		title.text = "A2 · " + paths[i]
		title.position = Vector2(10,i*275)
		viewport.add_child(title)
		var sprite := Sprite2D.new()
		sprite.texture = load("res://assets/" + paths[i] + ".png")
		sprite.centered = false
		sprite.position = Vector2(0,i*275+25)
		viewport.add_child(sprite)
	await RenderingServer.frame_post_draw
	viewport.get_texture().get_image().save_png(directory.path_join("a2-atlas.png"))
	viewport.queue_free()
	await frames(2)
func clear_foes() -> void:
	for e in get_nodes_in_group("enemies"): e.queue_free()
	for h in get_nodes_in_group("hazards"): h.queue_free()
	await frames(2)
func foe(kind: int, pos: Vector2):
	var e = game.EnemyScript.new()
	e.setup(kind,pos,0,game.player)
	game.add_child(e)
	e.set_physics_process(false)
	e.spawn_opacity = 1.0
	return e
func run() -> void:
	directory = OS.get_environment("LACRIMAE_REVIEW_DIR")
	if directory.is_empty(): quit(3); return
	var before := OS.get_environment("LACRIMAE_BEFORE_DIR")
	for name in ["devorador","flagelante","bruxa","asmodeia","duelista","carregador"]:
		await contact([texture(before.path_join("hero_executa_%s.png" % name)), load("res://assets/animation/hero_executa_%s.png" % name)],2,"comparacao-heroi-" + name,["ANTES","ATUAL"])
		var original: String = name + "_executado.png" if name != "carregador" else "carregador_exposto.png"
		await contact([texture(before.path_join(original)),load("res://assets/animation/%s_executado.png" % name)],2,"comparacao-criatura-" + name,["ANTES","ATUAL"])
	for name in ["devoto","flagelante","devorador","duelista","carregador","bruxa","asmodeia","choro"]:
		await contact([load("res://assets/animation/reacoes_%s.png" % name)],4,"reacoes-" + name,[name])
	await effects_contact()
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	game._start_game(false,false)
	for i in range(3):
		game.message_t = 0
		game.advance_message()
	game.exploration.arenas_enabled = false
	await clear_foes()
	var p = game.player
	p.revive(Vector2(900,600))
	p.has_weapon = true
	await frames(5)
	game.set_process(false)
	p.set_physics_process(false)
	p.camera.position_smoothing_enabled = false
	game.area_t = 0
	game.toast_t = 0
	var overlay := CanvasLayer.new()
	root.add_child(overlay)
	label = Label.new()
	label.position = Vector2(320,200)
	label.add_theme_color_override("font_outline_color",Color.BLACK)
	label.add_theme_constant_override("outline_size",6)
	overlay.add_child(label)
	var e = foe(0,Vector2(950,600))
	p._start_attack()
	p.state_t = p.attack_len * 0.64
	p._update_animation()
	await capture("b1-contato", "B1 · primeiro quadro ativo · esquiva já disponível")
	p.roll_buffer = 0.18
	p._physics_process(0)
	p._update_animation()
	await capture("b1-cancelamento", "B1 · ataque cancelado em esquiva")
	p.revive(Vector2(900,600))
	e.state = "windup"
	e.facing = -1
	e.state_t = 0.14
	p._start_roll()
	p._update_animation()
	await capture("b2-esquiva-perfeita", "B2 · esquiva perfeita · silhueta e contra-ataque por 0,8s")
	Engine.time_scale = 1.0
	for kind in [0,1,3,4,5,6,7,8]:
		await clear_foes()
		p.revive(Vector2(900,600))
		e = foe(kind,Vector2(1000,510 if kind in [1,5,6] else 600))
		e.facing = -1
		for variant in range(2):
			e.state = "windup"
			e.state_t = 0.75
			e._begin_pattern()
			e.state_t = e.windup_len * 0.25
			e._process(0)
			await capture("b3-aviso-%d-%d" % [kind,variant], "B3 · %s · padrão %d · %s" % [e.display_name,variant + 1,"APARÁVEL" if e.attack_parryable else "ESQUIVAR"])
	await clear_foes()
	p.revive(Vector2(900,520))
	p.air_attack_used = false
	p.state = "air_attack"
	p.state_t = p.AIR_ATTACK_TIME * 0.45
	p._update_animation()
	e = foe(0,Vector2(950,470))
	p._launch(e,0,-300)
	e.launch_elapsed = 0.25
	p.hit_list.clear()
	p._attack_hits(true)
	e._process(0)
	await capture("b4-suspensao", "B4 · corte aéreo suspende a criatura · máximo de 3 acertos")
	await clear_foes()
	p.revive(Vector2(900,600))
	e = foe(0,Vector2(970,600))
	e.last_hitter = p
	e.take_hit(10000,900)
	e.death_age = 0.6
	e._physics_process(0.0)
	e._process(0)
	await frames(35)
	await capture("b5-queda", "B5 · corpo no chão, sangue e poça persistente")
	await clear_foes()
	p.revive(Vector2(900,600))
	e = foe(3,Vector2(950,600))
	e.state = "stagger"
	e.state_t = 2.0
	p.begin_execution(e)
	p.state_t = 1.0 - 8.01/12.0
	p.hit_pause = 0
	p._physics_process(0)
	p._update_animation()
	e._process(0)
	await frames(4)
	await capture("a1-execucao", "A1/A2 · contato no quadro 8 e jato pintado")
	Engine.time_scale = 1
	game.wall_splat(Vector2(30,560))
	game.queue_free()
	game = null
	await frames(5)
	quit()
