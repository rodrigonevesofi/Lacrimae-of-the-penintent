extends SceneTree
var game
var failures := 0
var checks := 0
func _initialize() -> void:
	call_deferred("run")
func expect(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)
	else:
		print("PASS: ", message)
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
	var player = game.player
	player.has_weapon = true
	player.invuln = 100
	var actors: Array = [player.animator, game.art.iria_animation]
	for enemy in get_nodes_in_group("enemies"):
		enemy.set_physics_process(false)
		actors.append(enemy.animator)
	for actor in actors:
		for clip in actor.sprite_frames.get_animation_names():
			expect(actor.sprite_frames.get_frame_count(clip) >= 2, actor.actor + "/" + clip + " has multiple frames")
	player.velocity = Vector2(280, 0)
	var seen := {}
	Input.action_press("right")
	for i in range(24):
		await frames(1)
		seen[player.animator.frame] = true
	Input.action_release("right")
	expect(seen.size() >= 4, "run advances through distinct frames under actual input")
	player.state = "attack"
	for combo in [1, 0]:
		player.combo = combo
		for index in range(6):
			player.state_t = player.ATTACK_TIME * (1 - float(index) / 6 - 0.001)
			player._update_animation()
			expect(player.animator.frame == index, "sword animation matches combat timeline frame %d" % index)
	var target = get_nodes_in_group("enemies")[0]
	target.position = player.position + Vector2(50, 0)
	target.hp = 200
	target.dead = false
	player.facing = 1
	player.hit_list.clear()
	player.hit_pause = 0
	player.state = "attack"
	player.state_t = player.ATTACK_TIME * 0.92
	var hp_before: float = target.hp
	player._physics_process(0.001)
	expect(target.hp == hp_before, "windup frames do not deal damage")
	player.state_t = player.ATTACK_TIME * 0.59
	player._physics_process(0.001)
	expect(target.hp < hp_before, "contact frame deals damage")
	expect(is_equal_approx(player.hit_pause, 0.045), "a successful contact starts 45 ms impact pause")
	var hp_after: float = target.hp
	player.hit_pause = 0
	player._physics_process(0.001)
	expect(target.hp == hp_after, "a swing cannot hit same enemy twice")
	game.soundscape.incoming.stop()
	game.soundscape.ambience.stop()
	game.soundscape.guilt_layer.stop()
	for voice in game.soundscape.effects.values():
		voice.stop()
	await create_timer(0.15).timeout
	game.queue_free()
	game = null
	player = null
	target = null
	actors.clear()
	await frames(4)
	print("ANIMATION_SMOKE: %d checks, %d failures" % [checks, failures])
	quit(0 if failures == 0 else 1)
