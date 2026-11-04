extends SceneTree
var game
func _initialize() -> void: call_deferred("run")
func frames(count: int) -> void:
	for i in range(count): await process_frame
func place(pos: Vector2) -> void:
	game.player.revive(pos)
	game.player.has_weapon = true
	game.player.camera.reset_smoothing()
	game.message_text = ""
	game.toast_t = 0
func run() -> void:
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await frames(60)
	game._start_game(false,false)
	for i in range(3):
		game.message_t = 0
		game.advance_message()
	game.relic_taken = true
	place(Vector2(1800,360))
	await frames(150)
	place(Vector2(2600,600))
	await frames(150)
	game.doll_found = true
	place(Vector2(2860,600))
	await frames(4)
	Input.action_press("interact")
	await frames(1)
	Input.action_release("interact")
	await frames(150)
	game.message_t = 0
	game.advance_message()
	place(Vector2(4200,600))
	await frames(100)
	game.boss.take_hit(10000,game.player.position.x)
	await frames(820)
	game.soundscape.ambience.stop()
	game.soundscape.incoming.stop()
	game.soundscape.guilt_layer.stop()
	for voice in game.soundscape.effects.values(): voice.stop()
	game.queue_free()
	game = null
	await frames(8)
	quit()
