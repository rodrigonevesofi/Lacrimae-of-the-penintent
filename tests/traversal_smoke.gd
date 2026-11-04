extends SceneTree
var game
func _initialize() -> void: call_deferred("run")
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
	for e in get_nodes_in_group("enemies"): e.set_physics_process(false)
	var p = game.player
	p.revive(Vector2(1800,600))
	p.has_double_jump = true
	p.has_weapon = true
	game.relic_taken = true
	await frames(4)
	Input.action_press("right")
	var jumped := false
	var double_jumped := false
	var jump_at := -100
	for i in range(170):
		if p.position.x > 1945 and not jumped:
			jumped = true
			jump_at = i
			Input.action_press("jump")
		if jumped and i == jump_at + 36:
			double_jumped = true
			Input.action_press("jump")
		if (jumped and i == jump_at + 30) or (double_jumped and i == jump_at + 66): Input.action_release("jump")
		await frames(1)
	Input.action_release("right")
	var ok: bool = p.position.x > 2450 and p.hp == p.max_hp and game.state == "play"
	print("TRAVERSAL_SMOKE: ", "PASS" if ok else "FAIL", " — x=",p.position.x," hp=",p.hp," state=",p.state)
	game.soundscape.set_process(false)
	game.soundscape.ambience.stop()
	game.soundscape.incoming.stop()
	game.soundscape.guilt_layer.stop()
	for voice in game.soundscape.effects.values(): voice.stop()
	await create_timer(0.15).timeout
	game._delete_save()
	game.queue_free()
	await frames(4)
	quit(0 if ok else 1)
