extends SceneTree
var game
var checks := 0
var failures := 0
func _initialize() -> void: call_deferred("run")
func expect(ok: bool, label: String) -> void:
	checks += 1
	if ok: print("PASS: ", label)
	else:
		failures += 1
		push_error(label)
func frames(n: int) -> void:
	for i in range(n):
		await physics_frame
		await process_frame
func run() -> void:
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	expect(game.art != null, "world art initializes with gameplay scene")
	if game.art == null:
		quit(1)
		return
	game._start_game(false, false)
	for i in range(3):
		game.message_t = 0
		game.advance_message()
	await frames(3)
	var p = game.player
	p.has_weapon = true
	for e in get_nodes_in_group("enemies"): e.set_physics_process(false)
	p.position = game.altars[0]
	await frames(4)
	var ev := InputEventAction.new()
	ev.action = "penitence_menu"
	ev.pressed = true
	game._unhandled_input(ev)
	expect(game.penitence_menu, "V opens altar equipment panel")
	p.hp = 90
	Input.action_press("penitence_nails")
	game._play_update(0.016)
	Input.action_release("penitence_nails")
	expect(not game.penitence_menu and p.penitence == "nails", "choice equips nails through panel")
	expect(p.max_hp == 70 and p.hp == 70, "nails trade 30 percent max health")
	expect(is_equal_approx(p.sword_multiplier(), 1.4), "nails amplify sword damage by 40 percent")
	p.apply_penitence("none")
	expect(p.max_hp == 100 and p.hp == 70, "unequipping cannot heal")
	p.apply_penitence("chains")
	p._start_roll()
	var slow_cd: float = p.roll_cd
	p.apply_penitence("none")
	p._start_roll()
	expect(is_equal_approx(slow_cd - p.roll_cd, 0.65), "chains add exactly 650ms to dodge reuse")
	p.state = "idle"
	p.apply_penitence("nails")
	p.upgrades = 2
	p.apply_penitence("nails")
	expect(is_equal_approx(p.max_hp, 91), "nails correctly scale altar health upgrades")
	p.apply_penitence("chains")
	game._save()
	p.apply_penitence("none")
	game._load()
	expect(p.penitence == "chains" and p.max_hp == 130, "penitence and upgrades survive reload")
	p.position = Vector2(1550, 600)
	game._unhandled_input(ev)
	expect(not game.penitence_menu, "equipment changes refused outside altars")
	p.lagrimas = 0
	p.invuln = 0
	p.die()
	game._respawn()
	expect(game.stain_active and game.stain_amount == 0, "death creates fragment with zero currency")
	expect(p.culpa_capacity() == 75, "unrecovered fragment caps capacity at 75")
	p.add_culpa(200)
	expect(p.culpa == 75, "guilt gain obeys reduced capacity")
	p.culpa = 0
	p._do_penance()
	expect(p.culpa == 0 and p.penance_fx == 0, "insufficient energy cannot cast penance")
	game._save()
	game.stain_active = false
	game._load()
	expect(game.stain_active and game.stain_pos == Vector2(1550,600), "zero-currency fragment location persists")
	var e = get_nodes_in_group("enemies")[0]
	e.position = Vector2(1600,600)
	e.spawn_opacity = 1
	e._physics_process(0.016)
	expect(e.fed_by_guilt, "enemy near fragment becomes empowered")
	e.position = Vector2(2300,600)
	e._physics_process(0.016)
	expect(not e.fed_by_guilt, "distant enemy is not empowered")
	p.position = Vector2(1600,600)
	e.position = Vector2(1700,600)
	e.state = "chase"
	e.cd = -1
	e._physics_process(0.016)
	expect(absf(e.velocity.x) == 150, "empowered walker has increased pursuit speed")
	e.position = Vector2(1640,600)
	e.state = "chase"
	e.cd = -1
	e._physics_process(0.016)
	expect(e.state == "windup" and e.state_t == 0.55, "empowered attack retains readable anticipation")
	p.position = game.stain_pos
	game._play_update(0.016)
	if game.narrative.mode == "echo": game.narrative.finish()
	expect(not game.stain_active and p.culpa_capacity() == 100, "recovery restores capacity with zero currency")
	e._physics_process(0.016)
	expect(not e.fed_by_guilt, "recovery immediately removes empowerment")
	# Uma segunda morte substitui um fragmento, sem acumular penalidades permanentes.
	p.position = Vector2(1700,600)
	p.lagrimas = 45
	p.die()
	game._respawn()
	p.position = Vector2(1800,600)
	p.lagrimas = 12
	p.die()
	game._respawn()
	expect(game.stain_amount == 12 and game.stain_pos == Vector2(1800,600), "second death replaces old fragment and currency")
	expect(p.culpa_capacity() == 75, "multiple deaths never stack capacity reductions")
	p.position = game.stain_pos
	game._play_update(0.016)
	if game.narrative.mode == "echo": game.narrative.finish()
	expect(p.lagrimas == 12 and not game.stain_active, "only latest fragment currency is recovered")
	for old_enemy in get_nodes_in_group("enemies"):
		old_enemy.set_physics_process(false)
		if old_enemy.kind != 2: old_enemy.queue_free()
	await frames(2)
	# Testa o atordoamento real do inimigo, duas animações distintas e recompensas apenas no contato.
	for kind in [0,1]:
		p.revive(Vector2(650,600))
		p.hp = 40
		p.culpa = 0
		p.lagrimas = 0
		p.apply_penitence("none")
		await frames(4)
		e = game.EnemyScript.new()
		e.setup(kind, Vector2(700,600), 0, p)
		game.add_child(e)
		e.set_physics_process(false)
		e.state = "recover" if kind == 0 else "cast"
		e.take_hit(10, p.position.x)
		expect(e.state == "stagger" and not e.dead, "counter hit opens execution window kind %d" % kind)
		p.position.x = 500
		expect(not p.begin_execution(e), "execution refuses remote target kind %d" % kind)
		p.position.x = 650
		await frames(2)
		Input.action_press("interact")
		await frames(3)
		Input.action_release("interact")
		expect(p.state == "execution", "E executes grounded nearby staggered enemy kind %d" % kind)
		expect(not e.dead and p.hp == 40, "execution has anticipation before kill and reward kind %d" % kind)
		expect(not p.begin_execution(e), "cannot restart same execution kind %d" % kind)
		await frames(28)
		expect(not e.dead and p.hp == 40, "precontact frames remain nonlethal kind %d" % kind)
		expect(p.animator.animation == ("execute_devotee" if kind == 0 else "execute_mourner"), "correct hero execution clip kind %d" % kind)
		expect(e.animator.animation == "executed", "victim uses separate animated execution kind %d" % kind)
		await frames(25)
		expect(e.dead and p.hp == 48 and p.lagrimas == e.reward, "contact grants one kill and eight health kind %d" % kind)
		var coins: int = p.lagrimas
		e._die()
		expect(p.lagrimas == coins, "kill reward cannot be claimed twice kind %d" % kind)
		await frames(30)
		expect(p.state == "idle" and p.execution_target == null, "execution returns control kind %d" % kind)
		expect(p.camera.zoom.is_equal_approx(Vector2.ONE), "execution restores camera zoom kind %d" % kind)
	p.revive(Vector2(650,600))
	await frames(3)
	game.boss.state = "stagger"
	game.boss.position = Vector2(700,600)
	expect(not p.begin_execution(game.boss), "boss cannot bypass fight through common execution")
	var victim = game.EnemyScript.new()
	victim.setup(0, Vector2(700,600), 0, p)
	game.add_child(victim)
	victim.spawn_opacity = 1
	victim.state = "stagger"
	victim.state_t = 0.01
	victim._physics_process(0.02)
	expect(victim.state == "chase", "stagger expires and enemy resumes combat")
	expect(game.art.panorama.get_width() > 2000 and game.art.PANORAMA_RECT.size.x == game.exploration.rooms.city.bounds.size.x, "single detailed panorama spans full level")
	expect(not game.art.get("sky_changing"), "walking does not trigger backdrop swaps")
	var before: Transform2D = game.art.global_transform
	p.position.x = 3400
	game.art._process(0.016)
	expect(game.art.global_transform == before, "landmarks remain fixed to world coordinates")
	expect(not game.lore[1].text.contains("Mateus 5:4") and not game.lore[2].text.contains("João 8:7"), "inscriptions omit chapter and verse labels")
	# Exercita os modificadores pelos caminhos reais de dano, não apenas pelos metadados.
	victim.queue_free()
	await frames(2)
	var sword_target = game.EnemyScript.new()
	sword_target.setup(0, Vector2(700,600), 0, p)
	game.add_child(sword_target)
	sword_target.set_physics_process(false)
	p.position = Vector2(650,600)
	p.facing = 1
	p.apply_penitence("nails")
	p.combo = 1
	p.hit_list.clear()
	p._attack_hits()
	expect(is_equal_approx(sword_target.hp, sword_target.max_hp - 28.0), "nail bonus applies to actual sword contact")
	sword_target.queue_free()
	await frames(2)
	p.apply_penitence("chains")
	game.boss.position = Vector2(700,600)
	game.boss.hp = 450
	p.culpa = 50
	p._do_penance()
	expect(is_equal_approx(game.boss.hp, 450 - 61 * 1.55), "chain bonus applies to actual penance damage")
	game._delete_save()
	game.soundscape.set_process(false)
	game.soundscape.ambience.stop()
	game.soundscape.incoming.stop()
	game.soundscape.guilt_layer.stop()
	for voice in game.soundscape.effects.values(): voice.stop()
	await create_timer(0.15).timeout
	game.queue_free()
	game = null
	await frames(4)
	print("PENITENCE_SMOKE: %d checks, %d failures" % [checks,failures])
	quit(0 if failures == 0 else 1)
