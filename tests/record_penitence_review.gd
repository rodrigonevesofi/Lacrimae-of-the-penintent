extends SceneTree
var game
func _initialize() -> void: call_deferred("run")
func frames(n: int) -> void:
	for i in range(n): await process_frame
func place(pos: Vector2) -> void:
	game.player.revive(pos)
	game.player.has_weapon = true
	game.player.has_double_jump = true
	game.player.invuln = 999
	game.player.camera.reset_smoothing()
	game.message_text = ""
	game.toast_t = 0
func run() -> void:
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	game._start_game(false,false)
	for i in range(3):
		game.message_t = 0
		game.advance_message()
	game.relic_taken = true
	place(Vector2(540,600))
	await frames(6)
	game.penitence_menu = true
	await frames(120)
	Input.action_press("penitence_nails")
	await frames(1)
	Input.action_release("penitence_nails")
	await frames(40)
	place(Vector2(150,600))
	Input.action_press("right")
	var jumped := false
	var double_jumped := false
	var jump_at := 0
	for frame_index in range(1010):
		game.player.invuln = 999
		if game.player.position.x > 1945 and not jumped:
			jumped = true
			jump_at = frame_index
			Input.action_press("jump")
		if jumped and frame_index == jump_at + 36 and not double_jumped:
			double_jumped = true
			Input.action_press("jump")
		if (jumped and frame_index == jump_at + 30) or (double_jumped and frame_index == jump_at + 66): Input.action_release("jump")
		await frames(1)
	Input.action_release("right")
	print("ROUTE_END: ",game.player.position)
	await frames(30)
	for enemy in get_nodes_in_group("enemies"): enemy.set_physics_process(false)
	for kind in [0,1]:
		var pos := Vector2(3070,600) if kind == 0 else Vector2(4030,515)
		place(pos)
		var victim = game.EnemyScript.new()
		victim.setup(kind,pos + Vector2(55,0),0,game.player)
		game.add_child(victim)
		victim.set_physics_process(false)
		victim.state = "recover" if kind == 0 else "cast"
		await frames(32)
		game.player.combo = 0
		game.player._start_attack()
		await frames(36)
		Input.action_press("interact")
		await frames(3)
		Input.action_release("interact")
		print("EXECUTION_STARTED: ",kind," ",game.player.state)
		if game.player.state != "execution": push_error("Review failed to activate execution")
		await frames(90)
	place(Vector2(3060,600))
	game.player.lagrimas = 65
	game.player.invuln = 0
	game.player.die()
	await frames(185)
	# Mantém uma única demonstração de fragmento e mostra o inimigo fortalecido próximo.
	place(Vector2(2930,600))
	await frames(80)
	Input.action_press("right")
	await frames(45)
	Input.action_release("right")
	await frames(65)
	game.soundscape.set_process(false)
	game.soundscape.ambience.stop()
	game.soundscape.incoming.stop()
	game.soundscape.guilt_layer.stop()
	for voice in game.soundscape.effects.values(): voice.stop()
	await frames(15)
	game._delete_save()
	game.queue_free()
	game = null
	await frames(8)
	quit()
