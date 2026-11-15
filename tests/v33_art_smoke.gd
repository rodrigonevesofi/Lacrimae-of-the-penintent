extends SceneTree
## Execuções por criatura, contato no quadro 8 e faixas de peso da lança.
var game
var checks := 0
var failures := 0
func _initialize() -> void: call_deferred("run")
func expect(ok: bool, label: String) -> void:
	checks += 1
	print("PASS: " if ok else "FAIL: ", label)
	if not ok: failures += 1
func frames(n: int) -> void:
	for i in range(n):
		await physics_frame
		await process_frame
func spawn(kind: int, x: float = 960.0):
	var e = game.EnemyScript.new()
	e.setup(kind, Vector2(x, 600), 0, game.player)
	e.room_id = "city"
	game.add_child(e)
	e.set_physics_process(false)
	e.spawn_opacity = 1.0
	return e
func latest_impact() -> String:
	var result := ""
	for child in game.get_children():
		if child.get_child_count() > 0 and child.get_child(0).get("actor") == "impactos": result = child.get_child(0).animation
	return result
func run() -> void:
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	game._start_game(false, false)
	game.enable_duo(true)
	for i in range(3):
		game.message_t = 0
		game.advance_message()
	await frames(5)
	for e in get_nodes_in_group("enemies"): e.queue_free()
	await frames(2)
	var p = game.player
	var b = game.partner
	b.ai = false
	p.revive(Vector2(900, 600))
	b.revive(Vector2(1000, 600))
	p.has_weapon = true
	b.has_weapon = true
	await frames(4)
	p.set_physics_process(false)
	b.set_physics_process(false)
	p.set_process(false)
	b.set_process(false)
	game.set_process(false)
	for pair in [[0.0, 0], [33.0, 0], [34.0, 1], [66.0, 1], [67.0, 2], [100.0, 2]]:
		b.lance_weight = pair[0]
		b.state = "idle"
		b.velocity = Vector2.ZERO
		b.landing_t = 0.0
		b._update_animation()
		expect(b.animator.animation == "idle_weight" and b.animator.frame == pair[1], "peso %.0f seleciona pose %d" % pair)
	b.facing = -1
	b._update_animation()
	expect(b.animator.flip_h, "pose de peso acompanha a direção")
	b._start_attack()
	b._update_animation()
	expect(b.animator.animation != "idle_weight", "peso parado não substitui o ataque")
	game.pending_altar = 0
	game.complete_prayer()
	expect(b.lance_weight == 0.0, "oração alivia a lança da parceira")
	for e in get_nodes_in_group("enemies"): e.queue_free()
	await frames(2)
	game.message_text = ""
	game.narrative.mode = ""
	game.penitence_menu = false
	for kind in [3, 4, 5, 6, 7, 8]:
		p.revive(Vector2(900, 600))
		p.has_weapon = true
		p.state = "idle"
		p.hit_pause = 0.0
		var e = spawn(kind, 950.0)
		if kind == 8: e._break_coffin()
		e.state = "stagger"
		e.state_t = 2.0
		var expected := "execute_" + str(e.TYPES[kind].actor)
		expect(p.begin_execution(e), expected + ": execução começa")
		expect(p._execution_clip() == expected, expected + ": escolhe a animação própria")
		expect(is_equal_approx(p.execution_length, 1.0) and p.animator.sprite_frames.get_frame_count(expected) == 12, expected + ": 12 quadros em um segundo")
		p.state_t = 1.0 - (7.0 / 12.0 + 0.001)
		p._physics_process(0.0)
		p._update_animation()
		expect(not e.dead and not p.execution_wound and p.animator.frame == 7, expected + ": sem sangue ou morte antes do quadro 8")
		p.state_t = 1.0 - (8.0 / 12.0 + 0.001)
		p._physics_process(0.0)
		p._update_animation()
		expect(e.dead and p.execution_contact and p.execution_wound and p.animator.frame == 8, expected + ": sangue, morte e desenho coincidem no quadro 8")
		expect(get_nodes_in_group("blood_spray").size() > 0, expected + ": golpe mortal emite gotas")
		p.hit_pause = 0.0
		p.state_t = 0.0
		p._physics_process(0.0)
		expect(p.state == "idle" and not e.executing, expected + ": devolve o controle após a execução")
		e.queue_free()
		await frames(2)
	# O caixão solta pedra no golpe que o quebra, antes de expor a carne.
	for heavy in [false, true]:
		p.revive(Vector2(900, 600))
		p.facing = 1
		p.hit_list.clear()
		p.finisher = false
		p.counter_attack = false
		p.combo = 1
		var e = spawn(8)
		e.facing = -1
		e.coffin = 1.0
		if heavy:
			p.heavy_t = p.HEAVY_FULL
			p._heavy_hits()
		else: p._attack_hits()
		expect(e.exposed and latest_impact() == "pedra", "quebra do caixão por golpe %s usa pedra" % ("carregado" if heavy else "leve"))
		e.queue_free()
		await frames(2)
	game.exploration.room = "ossuary"
	p._plunge_impact()
	expect(latest_impact() == "osso", "golpe descendente no Ossuário solta osso")
	game.exploration.room = "city"
	p._plunge_impact()
	expect(latest_impact() == "pedra", "golpe descendente na Cidade solta pedra")
	game._delete_save()
	game.queue_free()
	game = null
	await frames(6)
	print("V33_ART: %d checks, %d failures" % [checks, failures])
	quit(0 if failures == 0 else 1)
