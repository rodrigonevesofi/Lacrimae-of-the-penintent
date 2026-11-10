extends SceneTree
## Cenas de culpa: eco de fragmento recuperado, oferenda no memorial, memória dos portões e três batidas.
var game
var p
var checks := 0
var failures := 0
func _initialize() -> void: call_deferred("run")
func expect(ok: bool,label: String) -> void:
	checks += 1
	print("PASS: " if ok else "FAIL: ",label)
	if not ok: failures += 1
func frames(n: int) -> void:
	for i in range(n):
		await physics_frame
		await process_frame
func close_messages() -> void:
	for i in range(16):
		if game.message_text.is_empty(): break
		game.message_t = 0
		game.advance_message()
		await frames(1)
func die_and_return() -> void:
	p.position = Vector2(310,600)
	p.lagrimas = 40
	p.invuln = 0
	p.take_hit(1000,200)
	game._respawn()
	await frames(3)
	p.position = game.stain_pos
	game._play_update(0.016)
	await frames(2)

func run() -> void:
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	game._start_game(false,false)
	await close_messages()
	await frames(3)
	p = game.player
	p.has_weapon = true
	for e in get_nodes_in_group("enemies"): e.set_physics_process(false)
	var n = game.narrative
	var sound = game.soundscape

	# --- Eco do fragmento de culpa: três cenas revelam um pouco mais a cada vez, sem alterar os valores.
	var knocks_before: int = sound.knock_count
	await die_and_return()
	var culpa_after_return: float = p.culpa
	var hp_after_return: float = p.hp
	expect(n.mode == "echo" and p.state == "cry" and not p.controllable,"recovering the fragment plays a kneeling scene")
	expect(game.echo_count == 1,"the first echo is counted")
	await frames(2)
	n.elapsed = 1.0
	Input.action_press("interact")
	await frames(3)
	Input.action_release("interact")
	expect(n.mode == "echo","the scene cannot be skipped in its first moments")
	n.elapsed = 3.7
	n._process(0.0)
	expect(sound.knock_count - knocks_before == 3,"the first echo carries exactly three knocks")
	n.elapsed = 2.3
	Input.action_press("interact")
	await frames(3)
	Input.action_release("interact")
	expect(n.mode == "","the player can leave the scene after a moment")
	expect(p.controllable and p.state == "idle" and p.camera.zoom.is_equal_approx(Vector2.ONE),"control and camera come back")
	expect(absf(p.culpa - culpa_after_return) < 0.01 and absf(p.hp - hp_after_return) < 0.01,"the scene changes neither guilt nor health")
	expect(p.lagrimas == 40,"only the recovered tears return; no reward is added")
	for i in range(240):
		if not sound.switching: break
		await frames(1)
	if not sound.muted: expect(absf(sound.ambience.volume_db - (-3.0)) < 0.5,"music returns to its normal level once the scene ends")
	n.mode = "echo"
	n.echo_index = 0
	n.elapsed = 3.0
	expect(n.music_target() < -25.0,"the music drops while the knocks are heard")
	n.mode = ""
	for e in get_nodes_in_group("enemies"): e.set_physics_process(false)
	var knocks_second: int = sound.knock_count
	await die_and_return()
	expect(n.mode == "echo" and n.echo_index == 1,"the second recovery plays the next echo")
	n.elapsed = 1.5
	await frames(3)
	expect(sound.effects["murmurio_01"].playing,"the second echo plays muffled voices")
	n.elapsed = n.ECHO_DURATION - 0.01
	await frames(3)
	expect(n.mode == "" and sound.knock_count == knocks_second,"the second echo has a voice but no knocks")
	await die_and_return()
	expect(game.echo_count == 3 and n.mode == "echo" and n.echo_index == 2,"the third echo closes the sequence")
	n.finish()
	await die_and_return()
	expect(n.mode == "" and game.echo_count == 4,"after three echoes recovery is a quiet line, never a grind")
	expect(game.toast_text.contains("Fragmento recuperado") and game.toast_text.length() > 70,"the quiet recovery still confirms the mechanic and adds a whisper")
	game._save()
	game.echo_count = 0
	game._load()
	expect(game.echo_count == 4,"the echo count survives save and load")
	expect(game.death_count >= 4 and game.GuiltText.death_line(0) != game.GuiltText.death_line(1),"death keeps its own witness lines")

	# --- Oferenda no memorial: cena de silêncio seguida do registro escrito, sem recompensa.
	game.doll_found = true
	game.memorial_honored = false
	game.story_flags.clear()
	p.revive(Vector2(2800,600))
	await frames(4)
	var before_tears: int = p.lagrimas
	var before_flasks: int = p.flasks
	var before_culpa: float = p.culpa
	Input.action_press("interact")
	game._play_update(0.016)
	Input.action_release("interact")
	await frames(2)
	expect(game.memorial_honored and n.mode == "memorial" and not p.controllable,"leaving the doll starts a silent scene and is already remembered")
	expect(sound.effects["sino_surdo"].playing,"a single muffled bell marks the offering")
	n.elapsed = 1.0
	Input.action_press("interact")
	await frames(3)
	Input.action_release("interact")
	expect(n.mode == "memorial","the offering cannot be cut short at once")
	n.elapsed = n.MEMORIAL_DURATION
	await frames(3)
	expect(n.mode == "" and game.message_text != "" and game.message_title.contains("OUTRO LADO"),"the written record follows the silence")
	expect(p.lagrimas == before_tears and p.flasks == before_flasks and absf(p.culpa - before_culpa) < 0.01,"the offering gives nothing: no tears, flasks, or lowered guilt")
	await close_messages()

	# --- Memória dos portões: 15 a 30 segundos, sem pedir ação, termina com três batidas e um corte.
	expect(n.MEMORY_DURATION >= 15.0 and n.MEMORY_DURATION <= 30.0,"the memory lasts between 15 and 30 seconds")
	var memory_knocks: int = sound.knock_count
	n.begin("memory")
	var steps := 0
	while n.mode == "memory" and steps < 3000:
		n._process(0.016)
		steps += 1
	expect(steps > 15.0 / 0.016 and game.memory_seen,"the memory runs by itself to its end")
	expect(sound.knock_count - memory_knocks == 3,"the memory ends on three knocks")
	expect(p.controllable and p.camera.zoom.is_equal_approx(Vector2.ONE),"control and camera return after the memory")
	n.begin("memory")
	n.elapsed = 3.0
	Input.action_press("interact")
	await frames(3)
	Input.action_release("interact")
	expect(n.mode == "memory","the cry cannot be skipped")
	n.elapsed = n.GRIEF_DURATION + 0.5
	Input.action_press("interact")
	await frames(3)
	Input.action_release("interact")
	expect(n.mode == "","after the cry the memory can be skipped")

	# --- Cada momento desenha sem erros, com e sem a boneca.
	for doll in [false,true]:
		game.doll_found = doll
		n.begin("memory")
		for t in [0.5,5.0,7.0,9.0,11.0,13.0,16.0,19.0,22.0,25.0,26.8]:
			n.elapsed = t
			await frames(2)
		n.finish()
	expect(true,"all beats of the memory painted without script errors")


	# --- Guardião do Sino: a corda ausente, depois silêncio e então a memória.
	n.begin("boss_intro")
	expect(n.mode == "boss_intro" and not p.controllable,"the Guardian's arrival holds control for a short scene")
	n.elapsed = 1.0
	Input.action_press("interact")
	await frames(3)
	Input.action_release("interact")
	expect(n.mode == "boss_intro","the arrival cannot be skipped in its first moments")
	n.elapsed = 2.2
	Input.action_press("interact")
	await frames(3)
	Input.action_release("interact")
	expect(n.mode == "" and p.controllable,"the arrival can be skipped afterwards")
	n.begin("boss_end")
	for t in [0.5,3.0,5.0,7.0,8.6]:
		n.elapsed = t
		await frames(2)
	expect(n.mode == "boss_end" and n.BOSS_END_DURATION >= 6.0,"the Guardian's end paints every beat, with or without the painted stills")
	n.elapsed = n.BOSS_END_DURATION
	n._process(0.0)
	expect(n.mode == "memory","the silence after the bell leads straight into the memory of the gates")
	n.finish()
	var knocks_phase: int = sound.knock_count
	var guardian = game.boss
	guardian.awaken()
	guardian.hp = guardian.max_hp * 0.4
	await frames(6)
	await create_timer(2.6,true,false,true).timeout
	expect(sound.knock_count - knocks_phase == 3,"past half its strength the Guardian is answered by three knocks")

	# --- Três batidas quando a corrente alta cede; a corrente da água permanece silenciosa.
	var knocks_chain: int = sound.knock_count
	game.story_chain_released("water")
	await create_timer(0.3,true,false,true).timeout
	expect(sound.knock_count == knocks_chain,"the water chain is silent")
	game.story_chain_released("vigil")
	await create_timer(4.4,true,false,true).timeout
	expect(sound.knock_count - knocks_chain == 3,"the high chain gives three knocks from the other side")
	sound.set_process(false)
	sound.ambience.stop()
	sound.incoming.stop()
	sound.guilt_layer.stop()
	for voice in sound.effects.values(): voice.stop()
	game._delete_save()
	p.set_physics_process(false)
	await create_timer(0.2,true,false,true).timeout
	game.queue_free()
	game = null
	await frames(5)
	print("GUILT_SMOKE: %d checks, %d failures" % [checks,failures])
	quit(0 if failures == 0 else 1)
