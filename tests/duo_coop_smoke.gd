extends SceneTree
## The Penitent and Beatriz together on screen: the game drives her until a second player takes her.
var game
var p
var b
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
func run() -> void:
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	game._start_game(false,false)
	for i in range(3):
		game.message_t = 0
		game.advance_message()
	await frames(3)
	game.exploration.arenas_enabled = false
	game.enable_duo(true)
	await frames(5)
	p = game.player
	b = game.partner
	p.has_weapon = true
	for e in get_nodes_in_group("enemies"): e.queue_free()
	await frames(2)
	expect(b != null and b.character == "beatriz" and b.ai and p.character == "penitente","Beatriz walks beside the Penitent, driven by the game")
	expect(b.camera.enabled == false and p.camera.enabled,"one camera for the two")
	expect(not InputMap.action_has_event("left", _key(KEY_LEFT)) and InputMap.action_has_event("p2_left", _key(KEY_LEFT)),"the arrows belong to Beatriz; A and D to the Penitent")
	# She follows
	p.revive(Vector2(1400,600))
	b.global_position = Vector2(1000,600)
	await frames(90)
	expect(absf(b.global_position.x - p.global_position.x) < 260.0,"she follows the Penitent (%.0f px apart)" % absf(b.global_position.x - p.global_position.x))
	expect(absf(p.camera_focus_x) > 5.0, "a câmera mantém o enquadramento compartilhado entre quadros")
	# Enemies take the nearest
	var e = game.EnemyScript.new()
	e.setup(0,Vector2(b.global_position.x - 80.0,600),0,p)
	e.room_id = "city"
	game.add_child(e)
	e.spawn_opacity = 1.0
	await frames(25)
	expect(e.player == b,"a creature turns on the nearest penitent")
	e.queue_free()
	await frames(2)
	# Falling and raising
	b.global_position = p.global_position + Vector2(-50,0)
	p.invuln = 0
	p.take_hit(999.0, p.global_position.x + 30.0)
	expect(p.state == "fallen" and game.state == "play","the one who falls is not dead while the other stands")
	var raised := false
	for i in range(160):
		await frames(1)
		if p.state == "idle":
			raised = true
			break
	expect(raised and p.hp > 0.0 and b.hp < b.max_hp,"Beatriz comes and bleeds to raise him")
	# Both fall
	b.invuln = 0
	b.take_hit(999.0, b.global_position.x + 30.0)
	expect(b.state == "fallen","now she falls")
	p.invuln = 0
	p.take_hit(999.0, p.global_position.x + 30.0)
	await frames(2)
	expect(game.state == "dead","when both fall, the penance ends for the two")
	game.death_t = 0.0
	await frames(4)
	expect(p.standing() and b.standing(),"both rise again at the altar")
	# Drop-in
	Input.action_press("p2_attack")
	await frames(2)
	Input.action_release("p2_attack")
	expect(not b.ai,"pressing one of her controls gives Beatriz to the second player")
	# Isola o ensaio de comandos do fragmento deixado pela morte anterior.
	game.stain_active = false
	for enemy in get_nodes_in_group("enemies"): enemy.queue_free()
	if game.narrative.mode != "": game.narrative.finish()
	game.message_text = ""
	p.cinematic_focus = false
	b.cinematic_focus = false
	p.revive(Vector2(1400,600))
	b.revive(Vector2(1460,600))
	await frames(4)
	b._start_attack()
	b.state_t = b.attack_len * 0.25
	b.hit_pause = 0.065
	Input.action_press("p2_roll")
	await frames(1)
	Input.action_release("p2_roll")
	await frames(8)
	expect(b.state == "roll", "o jogador 2 preserva a esquiva durante o impacto")
	expect(p.state == "idle", "comandos do jogador 2 não acionam o Penitente")
	b.ai = true
	# Left behind
	b.global_position = Vector2(30000, 600)
	await frames(3)
	expect(b.global_position.distance_to(p.global_position) < 200.0,"left behind, she reappears beside him")
	# Scenes freeze her
	game.narrative.begin("echo")
	var before: Vector2 = b.global_position
	b.ai_axis = 1.0
	await frames(10)
	expect(b.global_position.distance_to(before) < 2.0,"she holds still during a scene")
	game.narrative.finish()
	game._delete_save()
	game.queue_free()
	game = null
	await frames(5)
	print("DUO_COOP: %d checks, %d failures" % [checks,failures])
	quit(0 if failures == 0 else 1)
func _key(code: int) -> InputEventKey:
	var ev := InputEventKey.new()
	ev.physical_keycode = code
	return ev
