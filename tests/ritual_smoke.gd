extends SceneTree
var game
var checks := 0
var failures := 0
func _initialize() -> void:
	call_deferred("run")
func expect(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(label)
	else:
		print("PASS: ", label)
func frames(count: int) -> void:
	for i in range(count):
		await physics_frame
		await process_frame
func run() -> void:
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	game._start_game(false, false)
	for i in range(3):
		game.message_t = 0
		game.advance_message()
	await frames(3)
	game.player.position = game.altars[1]
	game.player.hp = 30
	game.player.flasks = 1
	game.player.state = "idle"
	var old_enemies := get_nodes_in_group("enemies")
	var zoom: Vector2 = game.player.camera.zoom
	var limits := [game.player.camera.limit_left, game.player.camera.limit_right, game.player.camera.limit_top, game.player.camera.limit_bottom]
	game._pray(1)
	expect(game.narrative.mode == "prayer", "altar starts a timed ritual")
	expect(not game.player.controllable and game.player.cinematic_focus, "ritual focuses camera and blocks combat input")
	expect(game.player.hp == 30 and game.player.flasks == 1 and game.respawn_index == 0, "no heal or checkpoint commit before completion")
	game.narrative._process(1.4)
	game.player._update_animation()
	expect(game.player.animator.animation == "pray" and game.player.animator.frame in [3,4], "prayer holds kneeling pose")
	expect(game.player.camera.zoom.x > zoom.x, "camera approaches during prayer")
	Input.action_press("interact")
	game.narrative._process(0)
	Input.action_release("interact")
	await frames(2)
	expect(game.narrative.mode == "prayer", "interact cannot cut prayer short")
	expect(get_nodes_in_group("enemies")[0] == old_enemies[0], "enemies are not recreated during prayer")
	game.narrative.elapsed = game.narrative.PRAYER_DURATION - 0.01
	game.narrative._process(0)
	expect(game.player.hp == 30, "healing waits through final prayer frames")
	game.narrative._process(0.02)
	await frames(3)
	expect(game.player.hp == game.player.max_hp and game.player.flasks == game.player.max_flasks, "completed prayer restores health and cures")
	expect(game.respawn_index == 1 and game.pending_altar == -1, "completed prayer commits checkpoint once")
	expect(game.player.camera.zoom == zoom and not game.player.cinematic_focus, "prayer restores camera")
	expect(get_nodes_in_group("enemies").size() == game.enemy_defs.size() + game.exploration.Layout.enemies().size() + 1, "common foes respawn once without duplicating boss")
	game.memory_seen = false
	game.narrative.begin("memory")
	expect(not game.memory_seen, "memory is not marked seen before scene finishes")
	game.narrative._process(1.6)
	game.player._update_animation()
	expect(game.player.animator.animation == "cry_hold", "boss scene cries with the in-world animated actor")
	expect(game.player.camera.zoom.x > 2 and game.player.animator.get_parent() == game.player, "close-up shows gameplay actor rather than a portrait")
	game.narrative._process(2.0)
	game.player._update_animation()
	expect(game.player.animator.animation == "cry_wipe", "crying flows into wiping the face")
	game.narrative._process(1.2)
	game.player._update_animation()
	expect(game.player.animator.animation == "cry_end", "wiping flows into lowering hand and recovering")
	game.narrative._process(2.1)
	expect(game.player.camera.zoom == zoom and not game.player.cinematic_focus, "close-up returns smoothly before memory flash")
	game.narrative.elapsed = game.narrative.MEMORY_DURATION
	game.narrative._process(0)
	expect(game.memory_seen and game.player.controllable and game.player.state == "idle", "memory completes and returns control")
	expect([game.player.camera.limit_left,game.player.camera.limit_right,game.player.camera.limit_top,game.player.camera.limit_bottom] == limits, "camera boundaries are restored exactly")
	game._delete_save()
	game.soundscape.set_process(false)
	game.soundscape.incoming.stop()
	game.soundscape.ambience.stop()
	game.soundscape.guilt_layer.stop()
	for voice in game.soundscape.effects.values():
		voice.stop()
	await create_timer(0.15).timeout
	old_enemies.clear()
	game.queue_free()
	game = null
	await frames(4)
	print("RITUAL_SMOKE: %d checks, %d failures" % [checks, failures])
	quit(0 if failures == 0 else 1)
