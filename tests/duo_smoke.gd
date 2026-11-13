extends SceneTree
## Two penitents, one burden: the swap, Beatriz's lance, its weight, the shared blood, and the save.
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
	expect(p.character == "penitente","the journey begins with the Penitent")
	p.hp = 70.0
	p.partner_hp = 90.0
	expect(p.swap_character() and p.character == "beatriz","T: Beatriz takes up the burden")
	expect(p.hp == 90.0 and p.partner_hp == 70.0,"each keeps her own life")
	await frames(3)
	expect(p.lance.visible and not p.sword.visible,"Beatriz holds the lance, not the sword")
	expect(not p.swap_character(),"there is a short pause before swapping again")
	# Reach: a creature at 130 px is touched by the lance but not by the sword.
	var far = spawn(0,Vector2(1030,600))
	p.position = Vector2(900,600)
	var hp0: float = far.hp
	p.hit_list.clear()
	p._attack_hits()
	expect(far.hp < hp0,"the lance reaches a creature the sword cannot")
	far.queue_free()
	await frames(2)
	# Weight
	p.lance_weight = 0.0
	var light_len: float = ATTACK_TIME_PROBE()
	var light_dmg: float = p.sword_multiplier()
	for i in range(5): game._on_enemy_killed(spawn(0,Vector2(2000 + i * 40,600)))
	expect(p.lance_weight >= 30.0,"each life taken makes the lance heavier (%.0f)" % p.lance_weight)
	expect(ATTACK_TIME_PROBE() > light_len and p.sword_multiplier() > light_dmg,"a heavier lance strikes slower and harder")
	game.pending_altar = 0
	game.complete_prayer()
	expect(p.lance_weight == 0.0 and p.partner_hp == p.max_hp,"prayer lightens the lance and restores both")
	# Shared blood
	p.hp = p.max_hp
	expect(not p.share_blood(),"with life to spare, no blood is shared")
	p.hp = 15.0
	p.partner_hp = 80.0
	expect(p.share_blood() and p.hp > 40.0 and p.partner_hp < 50.0,"close to death, the partner bleeds to save her")
	p.hp = 15.0
	expect(not p.share_blood(),"and cannot do it again at once")
	# Save
	p.lance_weight = 42.0
	game._save()
	p.character = "penitente"
	p.lance_weight = 0.0
	game._load()
	expect(p.character == "beatriz" and is_equal_approx(p.lance_weight,42.0),"the save remembers who walks and how heavy the lance is")
	game._delete_save()
	game.queue_free()
	game = null
	await frames(5)
	print("DUO: %d checks, %d failures" % [checks,failures])
	quit(0 if failures == 0 else 1)
func ATTACK_TIME_PROBE() -> float:
	return p.ATTACK_TIME * p.attack_scale()
