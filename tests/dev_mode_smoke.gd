extends SceneTree
## Development mode, for showing the game: every room can be reached, the Penitent can fly and take no damage.
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
func key(code: int) -> void:
	var ev := InputEventKey.new()
	ev.keycode = code
	ev.pressed = true
	game.hud._unhandled_input(ev)
func run() -> void:
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	game._start_game(false,false)
	for i in range(3):
		game.message_t = 0
		game.advance_message()
	await frames(3)
	game.exploration.arenas_enabled = false
	key(KEY_F3)
	expect(game.dev_mode,"F3 turns development mode on")
	var reached := 0
	var rooms: Array = game.dev_rooms()
	for k in range(rooms.size()):
		game.dev_index = k
		key(KEY_ENTER)
		for i in range(80):
			await frames(1)
			if not game.exploration.is_transitioning() and game.exploration.room == rooms[k]: break
		if game.exploration.room == rooms[k]: reached += 1
		else: print("  did not reach ", rooms[k])
	expect(reached == rooms.size(),"every room can be reached from the menu (%d of %d)" % [reached, rooms.size()])
	key(KEY_G)
	var hp0: float = game.player.hp
	game.player.invuln = 0
	game.player.take_hit(30.0, game.player.global_position.x + 20.0)
	expect(game.player.dev_god and game.player.hp == hp0,"G: no damage is taken")
	key(KEY_N)
	var y0: float = game.player.global_position.y
	Input.action_press("jump")
	await frames(20)
	Input.action_release("jump")
	expect(game.player.dev_fly and game.player.global_position.y < y0 - 100.0,"N: the Penitent flies through the room")
	key(KEY_F3)
	expect(not game.dev_mode and not game.player.dev_fly and not game.player.dev_god,"F3 again turns everything off")
	game._delete_save()
	game.queue_free()
	game = null
	await frames(5)
	print("DEV_MODE: %d checks, %d failures" % [checks,failures])
	quit(0 if failures == 0 else 1)
