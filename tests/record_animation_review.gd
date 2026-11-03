extends SceneTree
## Controlled gameplay rehearsal, recorded with Godot Movie Maker at fixed 60 Hz.
## This demonstrates poses/transitions; it is not an unassisted playthrough or FPS benchmark.
var game
var frame_number := 0
var stages: Array = []
func _initialize() -> void:
	call_deferred("run")
func frames(count: int) -> void:
	for i in range(count):
		await process_frame
		frame_number += 1
func stage(label: String) -> void:
	stages.append({"frame":frame_number,"label":label})
	print("REVIEW: ",frame_number," ",label)
func prepare(x: float) -> void:
	game.player.revive(Vector2(x, 600))
	game.player.has_weapon = true
	game.player.invuln = 0
	game.player.camera.reset_smoothing()
	game.message_text = ""
	game.prologue_page = -1
	game.relic_taken = true
	game.player.has_double_jump = true
	game.toast_t = 0
func tap(action: String) -> void:
	Input.action_press(action)
	await frames(1)
	Input.action_release(action)
func run() -> void:
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	game._start_game(false, false)
	for enemy in get_nodes_in_group("enemies"):
		enemy.set_physics_process(false)
	prepare(180)
	stage("idle")
	await frames(30)
	stage("run")
	Input.action_press("right")
	await frames(50)
	Input.action_release("right")
	stage("jump")
	await tap("jump")
	await frames(45)
	prepare(600)
	stage("two sword attacks")
	await tap("attack")
	await frames(14)
	await tap("attack")
	await frames(45)
	stage("dodge")
	await tap("roll")
	await frames(26)
	stage("hurt and heal")
	game.player.invuln = 0
	game.player.take_hit(20, game.player.position.x + 30)
	await frames(20)
	await tap("heal")
	await frames(40)
	stage("penitence")
	game.player.culpa = 60
	await tap("penance")
	await frames(65)
	prepare(1080)
	var devotee
	for enemy in get_nodes_in_group("enemies"):
		if enemy.kind == 0 and not enemy.dead:
			devotee = enemy
			break
	devotee.position = Vector2(1140, 600)
	devotee.home = devotee.position
	devotee.state = "windup"
	devotee.state_t = 0.55
	devotee.facing = -1
	devotee.set_physics_process(true)
	stage("devotee strike and recovery")
	await frames(90)
	if is_instance_valid(devotee):
		devotee.set_physics_process(false)
	prepare(1450)
	var mourner
	for enemy in get_nodes_in_group("enemies"):
		if enemy.kind == 1:
			mourner = enemy
			break
	mourner.position = Vector2(1620, 530)
	mourner.home = mourner.position
	mourner.state = "windup"
	mourner.state_t = 0.75
	mourner.cast_emitted = false
	mourner.set_physics_process(true)
	stage("mourner cast and projectile")
	await frames(80)
	mourner.set_physics_process(false)
	prepare(4160)
	game.boss.position = Vector2(4350, 600)
	game.boss.awake = true
	game.boss.state = "slam_wind"
	game.boss.state_t = 0.8
	game.boss.facing = -1
	game.boss.set_physics_process(true)
	stage("guardian slam")
	await frames(90)
	game.boss.state = "rain"
	game.boss.state_t = 2.4
	game.boss.rain_t = 0.8
	stage("guardian ritual")
	await frames(150)
	game.boss.set_physics_process(false)
	prepare(990)
	stage("Iria gestures")
	await tap("interact")
	await frames(50)
	var data := FileAccess.open("res://artifacts/animation-review-stages.json", FileAccess.WRITE)
	data.store_string(JSON.stringify(stages,"  "))
	data.close()
	game.queue_free()
	game = null
	devotee = null
	mourner = null
	await frames(5)
	quit()
