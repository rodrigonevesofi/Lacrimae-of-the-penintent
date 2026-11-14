extends SceneTree
## Contratos dos sons opcionais, duração real da mancha e manchas apoiadas no cenário.
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
	for i in range(3):
		game.message_t = 0
		game.advance_message()
	game.exploration.arenas_enabled = false
	for e in get_nodes_in_group("enemies"): e.queue_free()
	await frames(4)
	var sound = game.soundscape
	for family in ["sangue_jato", "carne_rasga", "osso_quebra", "respingo_chao"]:
		var options: Array = sound.FAMILIES[family]
		expect(options.size() == (4 if family == "respingo_chao" else 3), family + ": variações registradas")
		var variant: String = options.back()
		var voice := AudioStreamPlayer.new()
		voice.stream = AudioStreamWAV.new()
		sound.add_child(voice)
		sound.effects[variant] = voice
		expect(sound.resolve(family) == variant, family + ": escolhe somente a gravação disponível")
		sound.effects.erase(variant)
		voice.queue_free()
		expect(sound.resolve(family) == family, family + ": arquivo ausente não quebra o carregamento")
	var p = game.player
	p.revive(Vector2(900, 600))
	p.state = "execution"
	p.state_t = 10.0
	p.hit_pause = 0.16
	p.gore_flash = 0.5
	Engine.time_scale = 0.25
	await frames(31)
	expect(p.gore_flash == 0.0, "mancha termina em meio segundo real durante execução e câmera lenta")
	Engine.time_scale = 1.0
	p.state = "idle"
	game._place_splat(Vector2(900, 400), 8.0)
	var stains := get_nodes_in_group("blood_splats")
	expect(stains.size() == 1 and absf(stains[0].position.y - 599.0) < 1.0, "respingo de alvo no ar encontra o chão")
	for i in range(105): game._place_splat(Vector2(900 + i, 600), 8.0)
	expect(get_nodes_in_group("blood_splats").size() == 90, "limite de 90 respingos vale mesmo no mesmo quadro")
	await frames(3)
	expect(get_nodes_in_group("blood_splats").size() == 90, "respingos permanecem depois do golpe")
	var e = game.EnemyScript.new()
	e.setup(7, Vector2(1000, 600), 0, p)
	game.add_child(e)
	e._die()
	expect(sound.played.get("corpo_cai_armadura", 0) == 1, "morte do duelista solicita queda de armadura")
	e._die()
	expect(sound.played.get("corpo_cai_armadura", 0) == 1, "morte repetida não duplica o som de queda")
	game._delete_save()
	game.queue_free()
	game = null
	await frames(5)
	print("V35_INTEGRATION: %d checks, %d failures" % [checks, failures])
	quit(0 if failures == 0 else 1)
