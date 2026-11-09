extends SceneTree

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	var failures := 0
	for name in game.soundscape.HOOK_NAMES:
		if not game.soundscape.effects.has(name):
			push_error("Missing audio hook: " + name)
			failures += 1
		else:
			var voice: AudioStreamPlayer = game.soundscape.effects[name]
			if voice.stream == null or voice.bus != "SFX":
				push_error("Invalid audio hook: " + name)
				failures += 1
	print("AUDIO_V20: 17 hook resources, %d failures" % failures)
	game.queue_free()
	await process_frame
	quit(0 if failures == 0 else 1)
