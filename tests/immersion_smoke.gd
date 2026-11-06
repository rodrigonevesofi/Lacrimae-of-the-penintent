extends SceneTree
var game
var checks := 0
var failures := 0
func _initialize() -> void: call_deferred("run")
func expect(ok: bool, label: String) -> void:
	checks += 1
	if ok: print("PASS: ",label)
	else:
		failures += 1
		push_error(label)
func frames(count: int) -> void:
	for i in range(count):
		await physics_frame
		await process_frame
func run() -> void:
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	expect(game.soundscape.music_streams.size() == 7,"seven contextual scores load")
	expect(game.soundscape.desired_context() == "menu","title selects sacred menu score")
	game._start_game(false,false)
	for i in range(3):
		game.message_t = 0
		game.advance_message()
	await frames(3)
	for enemy in get_nodes_in_group("enemies"):
		enemy.set_physics_process(false)
		enemy.state = "patrol"
	game.player.position = Vector2(1500,600)
	expect(game.soundscape.desired_context() == "exploration","courtyard selects exploration score")
	game.soundscape._process(2)
	game.soundscape._process(2)
	expect(game.soundscape.music_context == "exploration" and game.soundscape.ambience.playing,"crossfade completes with live playback")
	game.player.position.x = 300
	expect(game.soundscape.desired_context() == "temple","crypt selects temple score")
	game.boss.awake = true
	expect(game.soundscape.desired_context() == "boss","boss encounter selects dramatic score")
	game.boss.awake = false
	game.message_text = "test"
	expect(game.soundscape.desired_context() == "story","narrative selects story score")
	game.message_text = ""
	game.player.position = Vector2(2860,600)
	game.doll_found = true
	Input.action_press("interact")
	game._play_update(0.016)
	Input.action_release("interact")
	expect(game.memorial_honored,"player can leave doll at memorial")
	game.message_t = 0
	game.advance_message()
	game._save()
	game.memorial_honored = false
	game._load()
	expect(game.memorial_honored,"memorial choice survives save/load")
	await frames(2)
	game.player.position = Vector2(990,600)
	Input.action_press("interact")
	game._play_update(0.016)
	Input.action_release("interact")
	expect(game.message_text.contains("não confunda"),"Iria recognizes gesture without granting forgiveness")
	expect(game.art.panorama != null and game.art.PANORAMA_RECT.size.x == game.exploration.rooms.city.bounds.size.x,"continuous panorama spans entire level")
	game.soundscape.toggle_mute()
	game.soundscape._process(0.1)
	expect(game.soundscape.ambience.volume_db == -80 and game.soundscape.incoming.volume_db == -80,"mute silences both crossfade voices")
	game._delete_save()
	game.soundscape.set_process(false)
	game.soundscape.ambience.stop()
	game.soundscape.incoming.stop()
	game.soundscape.guilt_layer.stop()
	for voice in game.soundscape.effects.values(): voice.stop()
	await create_timer(0.15).timeout
	game.queue_free()
	game = null
	await frames(4)
	print("IMMERSION_SMOKE: %d checks, %d failures" % [checks,failures])
	quit(0 if failures == 0 else 1)
