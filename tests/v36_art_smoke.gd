extends SceneTree
## Recursos finais e transições que realmente exibem as novas folhas em cena.
const Actor = preload("res://scripts/actor_animation.gd")
const CREATURES := {"devoto":"devotee", "choro":"mourner", "devorador":"devorador", "flagelante":"flagelante", "bruxa":"bruxa", "asmodeia":"asmodeia", "duelista":"duelista", "carregador":"carregador"}
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
	for name in CREATURES:
		var path := "res://assets/animation/reacoes_%s.png" % name
		var image := Image.load_from_file(ProjectSettings.globalize_path(path))
		expect(image.get_size() == Vector2i(1536,1024), name + ": grade 6x4 de 256 pixels")
		var clear := true
		for row in range(4):
			for col in range(6):
				if image.get_pixel(col * 256 + 2, row * 256 + 2).a > 0.05: clear = false
		expect(clear, name + ": cantos transparentes sem fundo retangular")
		var actor = Actor.new()
		actor.configure(CREATURES[name], 1.0)
		for pair in [["hurt",3], ["hurt_heavy",4], ["launched",6], ["stagger",5], ["impaled",6]]:
			expect(actor.sprite_frames.get_frame_count(pair[0]) == pair[1], name + ": quadros de " + pair[0])
			var texture: AtlasTexture = actor.sprite_frames.get_frame_texture(pair[0], 0)
			expect(texture.atlas.resource_path == path and texture.region.size == Vector2(256,256), name + ": usa a folha nova em " + pair[0])
		actor.free()
	for name in ["devorador", "flagelante", "bruxa", "asmodeia", "duelista", "carregador"]:
		var image := Image.load_from_file(ProjectSettings.globalize_path("res://assets/animation/hero_executa_%s.png" % name))
		expect(image.get_size() == Vector2i(1536,512), name + ": herói preserva a grade de 12 quadros")
	var expected := {"assets/efeitos/sangue_chao.png":Vector2i(1024,256), "assets/efeitos/sangue_parede.png":Vector2i(1024,256), "assets/animation/jato_arterial.png":Vector2i(1536,256), "assets/animation/pedacos.png":Vector2i(768,256)}
	for path in expected:
		var image := Image.load_from_file(ProjectSettings.globalize_path("res://" + path))
		expect(image.get_size() == expected[path], path + ": dimensões finais")
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	game._start_game(false,false)
	for i in range(3):
		game.message_t = 0
		game.advance_message()
	game.exploration.arenas_enabled = false
	for e in get_nodes_in_group("enemies"): e.queue_free()
	await frames(4)
	var p = game.player
	p.revive(Vector2(900,600))
	game._place_splat(Vector2(900,600),10)
	var stain = get_nodes_in_group("blood_splats")[0].get_child(0)
	expect(stain is Sprite2D and stain.texture.atlas.resource_path.ends_with("sangue_chao.png"), "manchas no piso usam a pintura, não polígonos")
	game.wall_splat(Vector2(900,560))
	expect(get_nodes_in_group("blood_walls").is_empty(), "sem parede perto não cria sangue suspenso")
	game.wall_splat(Vector2(30,560))
	expect(get_nodes_in_group("blood_walls").size() == 1, "parede a menos de 60 pixels recebe respingo pintado")
	p._blood_burst(Vector2(950,560),1.6,90)
	var debris := false
	for spray in get_nodes_in_group("blood_spray"):
		if spray.texture is AtlasTexture and spray.material is CanvasItemMaterial and spray.material.particles_anim_h_frames == 3 and spray.material.particles_anim_v_frames == 2: debris = true
	expect(debris,"golpe mortal usa os seis fragmentos pintados com rotação e gravidade")
	p._arterial_spray(Vector2(950,560),4)
	await frames(3)
	var pulse := false
	for node in game.get_children():
		for child in node.get_children():
			if child is Actor and child.actor == "jato_arterial": pulse = true
	expect(pulse,"jato arterial desenha o atlas animado durante os pulsos")
	var e = game.EnemyScript.new()
	e.setup(0,Vector2(950,600),0,p)
	game.add_child(e)
	e.set_physics_process(false)
	for pair in [["hurt","hurt"],["launched","launched"],["stagger","stagger"]]:
		e.state = pair[0]
		e.state_t = 0.2
		e._process(0)
		expect(e.animator.animation == pair[1], "estado " + pair[0] + " realmente seleciona a reação")
	e.impaled_t = 1.0
	e.state_t = 1.0
	e._process(0)
	expect(e.animator.animation == "impaled", "empalar seleciona a reação de lança")
	game._delete_save()
	game.queue_free()
	game = null
	await frames(5)
	print("V36_ART: %d checks, %d failures" % [checks, failures])
	quit(0 if failures == 0 else 1)
