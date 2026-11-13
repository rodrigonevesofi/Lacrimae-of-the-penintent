extends SceneTree
## The sword stays in the fist of the drawing that is on screen, every displayed frame, standing and running.
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
func grip_error(p) -> float:
	var grips: Array = p.RUN_GRIPS if p.animator.animation == "run" else p.IDLE_GRIPS
	var wrist: Vector2 = grips[p.animator.frame]
	var hand: Vector2 = (wrist - Vector2(128,250)) * 0.44
	return p.sword.position.distance_to(Vector2(hand.x * p.facing, hand.y))
func run() -> void:
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	game._start_game(false,false)
	for i in range(3):
		game.message_t = 0
		game.advance_message()
	await frames(3)
	var p = game.player
	p.has_weapon = true
	for e in get_nodes_in_group("enemies"): e.queue_free()
	p.revive(Vector2(700,600))
	await frames(5)
	expect(p.sword.z_index > p.animator.z_index,"the sword is drawn in front of the body, over the fingers")
	var worst_idle := 0.0
	var seen_idle := {}
	for i in range(90):
		await process_frame
		if p.sword.visible and p.animator.animation == "idle":
			worst_idle = maxf(worst_idle, grip_error(p))
			seen_idle[p.animator.frame] = true
	expect(seen_idle.size() >= 4 and worst_idle < 0.5,"standing, the grip is in the fist on every drawing (%d drawings, worst %.2f px)" % [seen_idle.size(), worst_idle])
	Input.action_press("right")
	var worst_run := 0.0
	var seen_run := {}
	for i in range(120):
		await process_frame
		if p.sword.visible and p.animator.animation == "run":
			worst_run = maxf(worst_run, grip_error(p))
			seen_run[p.animator.frame] = true
	Input.action_release("right")
	expect(seen_run.size() == 6 and worst_run < 0.5,"running, the grip is in the fist on every drawing (%d drawings, worst %.2f px)" % [seen_run.size(), worst_run])
	game._delete_save()
	game.queue_free()
	game = null
	await frames(5)
	print("SWORD_SYNC: %d checks, %d failures" % [checks,failures])
	quit(0 if failures == 0 else 1)
