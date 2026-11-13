extends SceneTree
## Combat is more than one blow: a chain of three with a finisher, a charged heavy blow, a plunge, slow motion.
var game
var p
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
func spawn(kind: int,pos: Vector2):
	var e = game.EnemyScript.new()
	e.setup(kind,pos,0,p)
	e.room_id = "city"
	game.add_child(e)
	e.set_physics_process(false)
	e.spawn_opacity = 1.0
	return e
func run() -> void:
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	game._start_game(false,false)
	for i in range(3):
		game.message_t = 0
		game.advance_message()
	await frames(3)
	p = game.player
	p.has_weapon = true
	for e in get_nodes_in_group("enemies"): e.queue_free()
	p.revive(Vector2(900,600))
	p.facing = 1
	await frames(4)
	# Chain of three
	p._start_attack()
	var first: bool = p.finisher
	p.state = "idle"
	p._start_attack()
	var second: bool = p.finisher
	p.state = "idle"
	p._start_attack()
	expect(not first and not second and p.finisher,"the third blow of a chain is the finisher")
	var target = spawn(0,Vector2(960,600))
	var hp0: float = target.hp
	p.position = Vector2(900,600)
	p.hit_list.clear()
	p._attack_hits()
	expect(hp0 - target.hp >= 33.0 and (target.dead or target.velocity.y < 0.0),"the finisher hits harder and throws the creature up")
	await frames(30)
	expect(is_equal_approx(Engine.time_scale,1.0),"slow motion always returns to normal speed")
	p.state = "idle"
	p.combo_window = 0.0
	p._start_attack()
	expect(not p.finisher,"after a pause the chain starts again")
	p.state = "idle"
	# Charged heavy blow
	for e in get_nodes_in_group("enemies"): e.queue_free()
	await frames(2)
	var heavy_target = spawn(4,Vector2(990,600))
	p.position = Vector2(900,600)
	p._start_charge()
	expect(p.state == "charge","holding I charges the heavy blow")
	p.heavy_t = 1.0
	p._start_heavy()
	var h0: float = heavy_target.hp
	p._heavy_hits()
	expect(h0 - heavy_target.hp >= 48.0,"the heavy blow, fully charged, deals at least 48 (%.0f)" % (h0 - heavy_target.hp))
	expect(heavy_target.dead or (heavy_target.state == "hurt" and heavy_target.velocity.y < 0.0),"and throws the creature off its feet")
	await frames(30)
	var carrier = spawn(8,Vector2(990,600))
	carrier.facing = -1
	p.state = "idle"
	p.position = Vector2(900,600)
	p.heavy_t = 1.0
	p.hit_list.clear()
	p._heavy_hits()
	expect(carrier.exposed,"a charged blow breaks the carrier's stone at once")
	await frames(30)
	# Plunge
	for e in get_nodes_in_group("enemies"): e.queue_free()
	await frames(2)
	var below = spawn(0,Vector2(960,600))
	p.position = Vector2(900,600)
	var b0: float = below.hp
	p._plunge_impact()
	expect(b0 - below.hp >= 29.0,"the plunge strikes what is around the landing")
	p.state = "idle"
	await frames(20)
	expect(is_equal_approx(Engine.time_scale,1.0),"time runs at normal speed after every strong blow")
	game._delete_save()
	game.queue_free()
	game = null
	await frames(5)
	print("COMBAT_RICH: %d checks, %d failures" % [checks,failures])
	quit(0 if failures == 0 else 1)
