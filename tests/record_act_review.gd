extends SceneTree
var game
func _initialize() -> void: call_deferred("run")
func frames(n: int) -> void:
	for i in range(n): await process_frame
func screenshot(name: String) -> void:
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("/tmp/v8-"+name+".png")
func run() -> void:
	game=load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	game._start_game(false,false)
	for i in range(3):
		game.message_t=0
		game.advance_message()
	game.player.has_weapon=true
	game.player.lagrimas=138
	game.player.culpa=62
	game.player.apply_penitence("nails")
	game.player.position=Vector2(540,600)
	game.player.camera.reset_smoothing()
	await frames(95)
	await screenshot("altar-hud")
	Input.action_press("right")
	await frames(80)
	Input.action_release("right")
	game.exploration.travel("ossuary",Vector2(5480,600))
	await frames(80)
	await screenshot("ossuary")
	game.exploration.travel("cistern",Vector2(9280,280))
	await frames(80)
	await screenshot("cistern")
	game.exploration.travel("refuge",Vector2(20000,280))
	await frames(80)
	await screenshot("refuge")
	game.exploration.travel("cloister",Vector2(12500,40))
	await frames(80)
	await screenshot("cloister")
	game.exploration.travel("archive",Vector2(17800,280))
	await frames(80)
	await screenshot("archive")
	game.exploration.travel("belfry",Vector2(15000,380))
	await frames(80)
	await screenshot("belfry")
	game.exploration.map_open=true
	await frames(100)
	await screenshot("map")
	game.exploration.map_open=false
	game.exploration.bells=["water","vigil"]
	game.exploration.update_gate()
	game.exploration.travel("city",Vector2(4260,600))
	game.player.invuln=20
	await frames(100)
	await screenshot("boss-hud")
	game.soundscape.set_process(false)
	game.player.set_physics_process(false)
	for e in get_nodes_in_group("enemies"):e.set_physics_process(false)
	game.soundscape.ambience.stop()
	game.soundscape.incoming.stop()
	game.soundscape.guilt_layer.stop()
	for voice in game.soundscape.effects.values():voice.stop()
	await frames(20)
	game._delete_save()
	game.queue_free()
	await frames(5)
	quit()
