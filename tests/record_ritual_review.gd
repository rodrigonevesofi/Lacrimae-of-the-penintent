extends SceneTree
## Ensaio de uma interação real com altar e da sequência de morte do chefe.
var game
func _initialize() -> void:
	call_deferred("run")
func frames(count: int) -> void:
	for i in range(count):
		await process_frame
func run() -> void:
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	game._start_game(false, false)
	for i in range(3):
		game.message_t = 0
		game.advance_message()
	game.player.revive(game.altars[0])
	game.player.camera.reset_smoothing()
	game.player.has_weapon = true
	game.player.hp = 30
	game.player.flasks = 1
	game.toast_t = 0
	await frames(5)
	game._pray(0)
	print("RITUAL_REVIEW: altar")
	await frames(310)
	game.player.revive(Vector2(4200, 600))
	game.player.camera.reset_smoothing()
	game.toast_t = 0
	game.boss.take_hit(10000, game.player.position.x)
	print("RITUAL_REVIEW: boss defeated, grief and memory")
	await frames(820)
	game.soundscape.set_process(false)
	game.soundscape.incoming.stop()
	game.soundscape.ambience.stop()
	game.soundscape.guilt_layer.stop()
	for voice in game.soundscape.effects.values():
		voice.stop()
	game.queue_free()
	game = null
	await frames(8)
	quit()
