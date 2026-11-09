extends SceneTree
## The sound system: buses, limiter, reverb of each place, variation, positional sound, and hooks for events.
var game
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

func run() -> void:
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	game._start_game(false,false)
	for i in range(3):
		game.message_t = 0
		game.advance_message()
	await frames(4)
	var s = game.soundscape
	var master := AudioServer.get_bus_index("Master")
	expect(AudioServer.get_bus_index("Music") != -1 and AudioServer.get_bus_index("SFX") != -1,"music and effects have their own buses")
	var limited := false
	for i in range(AudioServer.get_bus_effect_count(master)):
		var fx := AudioServer.get_bus_effect(master,i)
		if fx.get_class() in ["AudioEffectHardLimiter","AudioEffectLimiter"] and float(fx.get("ceiling_db")) <= -0.5: limited = true
	expect(limited,"the master bus has a limiter below full scale, so a stack of loud sounds cannot clip")
	expect(s.reverb != null,"effects carry a reverb")
	expect(s.ambience.bus == "Music" and s.effects["hit"].bus == "SFX","players are routed to their buses")
	# Reverb follows the place.
	game.exploration.room = "nave"
	for i in range(200): s._process(0.1)
	var nave_wet := float(s.reverb.get("wet"))
	game.exploration.room = "city"
	for i in range(200): s._process(0.1)
	var city_wet := float(s.reverb.get("wet"))
	expect(nave_wet > city_wet + 0.15,"the nave rings more than the open city (%.2f against %.2f)" % [nave_wet,city_wet])
	# Variation: the same blow does not sound the same twice.
	var pitches := {}
	for i in range(12):
		s.play_sfx("hit")
		pitches[snappedf(s.effects["hit"].pitch_scale,0.001)] = true
	expect(pitches.size() >= 6,"a sword blow varies in pitch from one hit to the next")
	var fixed := {}
	for i in range(6):
		s.play_sfx("bell")
		fixed[s.effects["bell"].pitch_scale] = true
	expect(fixed.size() == 1,"the bell and the narrative sounds are always the same")
	# Positional sound.
	var children_before: int = game.get_child_count()
	s.played.clear()
	s.last_time.clear()
	s.play_sfx_at("devorador_rugido",game.player.global_position + Vector2(400,0))
	expect(game.get_child_count() == children_before + 1,"a sound in the world is a voice placed in the world")
	var found = null
	for child in game.get_children():
		if child is AudioStreamPlayer2D: found = child
	expect(found != null and found.global_position.x > game.player.global_position.x + 300.0,"it sits to the right of the penitent")
	s.play_sfx_at("devorador_rugido",game.player.global_position)
	expect(game.get_child_count() == children_before + 1,"the same sound cannot be stacked within 70 ms")
	# Hooks: events that used to be silent now announce themselves, and are inert until a file exists.
	s.played.clear()
	game.player.has_weapon = true
	for e in get_nodes_in_group("enemies"): e.queue_free()
	await frames(2)
	var devotee = game.EnemyScript.new()
	devotee.setup(0,game.player.global_position + Vector2(80,0),0,game.player)
	game.add_child(devotee)
	devotee.set_physics_process(false)
	devotee.take_hit(1000.0,game.player.global_position.x)
	expect(s.played.get("dor",0) > 0 and s.played.get("morte",0) > 0,"an enemy hurt and an enemy death announce themselves")
	game.player.prev_vy = 600.0
	game.player.global_position.y += 0.0
	s.played.clear()
	game.player._start_parry()
	game.player.take_hit(16.0,game.player.global_position.x + 50.0,devotee,true)
	expect(s.played.get("aparo",0) > 0,"a parry announces itself")
	for name in s.HOOK_NAMES:
		if not ResourceLoader.exists("res://assets/audio/%s.wav" % name): expect(not s.effects.has(name),"hook %s is inert until its file exists" % name)
		break
	game.soundscape.ambience.stop()
	game.soundscape.incoming.stop()
	game.soundscape.guilt_layer.stop()
	game._delete_save()
	game.queue_free()
	game = null
	await frames(5)
	print("AUDIO_SMOKE: %d checks, %d failures" % [checks,failures])
	quit(0 if failures == 0 else 1)
