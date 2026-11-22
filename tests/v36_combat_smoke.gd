extends SceneTree
## Mede janelas reais de estados, previsões de esquiva e limites físicos, sem salvamentos do jogador.
var game
var p
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
func foe(kind: int, pos: Vector2):
	var e = game.new_enemy(kind)
	e.setup(kind, pos, 0, p)
	game.add_child(e)
	e.set_physics_process(false)
	e.spawn_opacity = 1.0
	return e
func reset() -> void:
	Engine.time_scale = 1.0
	for a in ["attack", "heavy", "roll", "parry", "left", "right", "jump", "down"]: Input.action_release(a)
	for e in get_nodes_in_group("enemies"): e.queue_free()
	for h in get_nodes_in_group("hazards"): h.queue_free()
	p.character = "penitente"
	p.lance_weight = 0
	p.apply_character()
	p.revive(Vector2(900, 600))
	p.has_weapon = true
	p.facing = 1
	p.set_physics_process(true)
	await frames(4)
	p.set_physics_process(false)
func run() -> void:
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	game._start_game(false, false)
	for i in range(3):
		game.message_t = 0
		game.advance_message()
	game.exploration.arenas_enabled = false
	p = game.player
	await reset()
	game.set_process(false)
	# Mede cada limiar com passos de 1 ms: sem encurtar o tempo para o teste.
	for character in ["penitente", "beatriz"]:
		for weight in ([0.0] if character == "penitente" else [0.0, 100.0]):
			p.character = character
			p.lance_weight = weight
			p.apply_character()
			for step in range(3):
				p.position = Vector2(900, 600)
				p.velocity = Vector2.ZERO
				p.move_and_slide()
				p.state = "idle"
				p.roll_cd = 0
				p.combo_step = (step + 2) % 3
				p.combo_window = 1.0
				p._start_attack()
				var expected: float = p.attack_len / 3.0
				var elapsed := 0.0
				while elapsed < 1.5 and p.state == "attack":
					p.position = Vector2(900, 600)
					p.velocity.x = 0
					p.roll_buffer = 0.18
					p._physics_process(0.001)
					elapsed += 0.001
				expect(p.state == "roll" and absf(elapsed - expected) < 0.003, "%s peso %.0f combo %d: esquiva em %.3fs (ativo %.3fs)" % [character, weight, step + 1, elapsed, expected])
			p.state = "idle"
			p.position = Vector2(900, 600)
			p.velocity = Vector2.ZERO
			p.move_and_slide()
			p.roll_cd = 0
			p._start_heavy()
			var expected: float = p.heavy_len * 0.30
			var elapsed := 0.0
			while elapsed < 1.5 and p.state == "heavy":
				p.position = Vector2(900, 600)
				p.velocity.x = 0
				p.roll_buffer = 0.18
				p._physics_process(0.001)
				elapsed += 0.001
			expect(p.state == "roll" and absf(elapsed - expected) < 0.003, "%s peso %.0f: pesado cancela no primeiro contato" % [character, weight])
			p.position = Vector2(900, 450)
			p.velocity = Vector2.ZERO
			p.move_and_slide()
			p.state = "idle"
			p.roll_cd = 0
			p.air_attack_used = false
			p._start_air_attack()
			elapsed = 0.0
			while elapsed < 1.0 and p.state == "air_attack":
				p.position = Vector2(900, 450)
				p.roll_buffer = 0.18
				p._physics_process(0.001)
				elapsed += 0.001
			expect(p.state == "roll" and absf(elapsed - 0.20) < 0.003, "%s peso %.0f: corte aéreo cancela no quadro 5" % [character, weight])
			p.state = "idle"
			p.roll_cd = 0
			p._start_plunge()
			p.roll_buffer = 0.18
			p._physics_process(0.001)
			expect(p.state == "roll", "%s peso %.0f: mergulho permite esquiva durante a descida" % [character, weight])
	await reset()
	p.character = "beatriz"
	p.lance_weight = 100
	p.state = "idle"
	p._start_attack()
	p.set_physics_process(true)
	Input.action_press("attack")
	await frames(1)
	Input.action_release("attack")
	await frames(35)
	expect(p.combo_step == 1, "toque antecipado sobrevive até o encadeamento com lança no peso máximo")
	await reset()
	var e = foe(0, Vector2(950, 600))
	e.facing = -1
	e.state = "windup"
	e.state_t = 0.151
	p._start_roll()
	expect(not p.perfect_dodge_used, "esquiva fora dos últimos 0,15s não recebe bônus")
	p.state = "idle"
	p.roll_cd = 0
	e.state_t = 0.149
	p._start_roll()
	expect(p.perfect_dodge_used and p.counter_t == 0.8 and Engine.time_scale == 0.35, "últimos 0,15s dão esquiva perfeita, câmera lenta e janela de 0,8s")
	expect(game.soundscape.effects.has("esquiva_perfeita") and game.soundscape.played.get("esquiva_perfeita",0) > 0, "esquiva perfeita carrega e solicita seu próprio som")
	var awarded: int = p.perfect_dodges
	p.take_hit(20, e.position.x, e, true)
	expect(p.perfect_dodges == awarded and p.hp == p.max_hp, "o mesmo golpe não concede bônus duas vezes nem fere durante a esquiva")
	p.state = "idle"
	p._start_attack()
	expect(p.counter_attack and p.counter_t == 0.0, "o próximo ataque consome o contra-ataque forte")
	await frames(25)
	expect(Engine.time_scale == 1.0, "câmera lenta da esquiva termina em 0,3s reais")
	await reset()
	p.counter_t = 0.8
	p._start_charge()
	expect(p.counter_attack and p.counter_t == 0.0, "começar a carga reserva e consome a janela de contra-ataque")
	Input.action_press("heavy")
	for i in range(100):
		p.position = Vector2(900,600)
		p.velocity.x = 0
		p._physics_process(0.01)
	Input.action_release("heavy")
	p._physics_process(0.01)
	expect(p.state == "heavy" and p.counter_attack and p.heavy_t >= p.HEAVY_FULL, "carga completa preserva o bônus mesmo após um segundo segurando")
	p.state = "idle"
	p._start_heavy()
	expect(not p.counter_attack, "outro golpe pesado não reutiliza o bônus já consumido")
	await reset()
	var guardian = foe(2,Vector2(950,600))
	guardian.state = "slam_wind"
	guardian.state_t = 0.14
	p._start_roll()
	expect(p.perfect_dodge_used, "pancada iminente do Guardião também permite esquiva perfeita")
	await reset()
	var spike = game.EnemyScript.Spike.new()
	spike.player = p
	spike.t = 0.76
	game.add_child(spike)
	spike.position = p.position
	p._start_roll()
	expect(p.perfect_dodge_used, "espinho prestes a brotar entra na previsão da esquiva")
	await reset()
	var incoming = game.EnemyScript.Tear.new()
	incoming.player = p
	incoming.vel = Vector2(-600,0)
	game.add_child(incoming)
	incoming.position = p.position + Vector2(100,-30)
	p._start_roll()
	expect(p.perfect_dodge_used, "lágrima a menos de 0,15s de contato entra na previsão")
	await reset()
	game.reduced_pulses = true
	e = foe(0,Vector2(950,600))
	e.facing = -1
	e.state = "windup"
	e.state_t = 0.14
	p._start_roll()
	expect(p.perfect_dodge_used and Engine.time_scale == 1.0, "reduzir pulsos preserva o bônus sem impor câmera lenta")
	game.reduced_pulses = false
	await reset()
	e = foe(0, Vector2(950, 600))
	e.hp = 1000
	e.max_hp = 1000
	p._launch(e, 0, -300)
	expect(e.state == "launched" and e.velocity.y < 0, "carregado/arremate cria trajetória aérea própria")
	p.position = Vector2(900, 560)
	e.position = Vector2(950, 540)
	p.state = "air_attack"
	for i in range(4):
		p.hit_list.clear()
		p._attack_hits(true)
	expect(e.juggle_hits == 3 and p.air_chain == 3, "suspensão aérea se limita a três acertos na mesma trajetória")
	expect(e.suspend_t == 0.10 and e.hp < 1000, "corte aéreo causa dano e segura a queda por 0,10s")
	for i in range(150): e._physics_process(1.0 / 60.0)
	expect(e.state != "launched" and e.is_on_floor(), "após o limite a criatura cai e encerra o malabarismo")
	await reset()
	p.character = "beatriz"
	e = foe(0, Vector2(950, 600))
	p._launch(e, 100, -300)
	expect(e.state == "stagger" and e.impaled_t > 0, "lança mantém a criatura empalada em vez de lançar")
	await reset()
	p.dev_god = true
	for kind in [0, 1, 3, 4, 5, 6, 7, 8]:
		e = foe(kind, Vector2(950, 450 if kind in [1, 5, 6] else 600))
		for variant in range(2):
			e.state = "patrol" if e.family == "flyer" else "chase"
			e.cd = 0
			for i in range(6):
				e._physics_process(0.0)
				if e.state in ["windup", "strike_wind", "alt_windup"]: break
			expect(e.attack_variant == variant and e.attack_sequence == variant + 1, "criatura %d inicia padrão %d por sua IA" % [kind, variant + 1])
			expect(e.attack_warning == ("gold" if e.attack_parryable else "red") and e.windup_len >= 0.4, "criatura %d padrão %d: aviso correto antes do dano" % [kind, variant + 1])
			e.state_t = 0
			e._physics_process(0.0)
			expect(e.state not in ["windup", "strike_wind", "alt_windup"], "criatura %d confirma padrão %d após antecipação" % [kind, variant + 1])
		e.queue_free()
		await frames(1)
	p.dev_god = false
	await reset()
	e = foe(4,Vector2(950,600))
	e.facing = -1
	e.attack_sequence = 1
	e.state = "windup"
	e.state_t = 0.6
	e._begin_pattern()
	e.state_t = 0
	e._secondary_update(0)
	p.invuln = 0
	p.position.y = 500
	e._secondary_update(0)
	expect(p.hp == p.max_hp, "saltar evita a chicotada baixa do segundo padrão")
	p.position.y = 600
	e._secondary_update(0)
	expect(p.hp < p.max_hp, "a mesma chicotada baixa atinge quem permanece no chão")
	await reset()
	p._start_parry()
	p.state_t = p.PARRY_TIME
	p.invuln = 0
	var tear = game.EnemyScript.Tear.new()
	tear.player = p
	tear.parryable = true
	game.add_child(tear)
	tear.position = p.position - Vector2(0,30)
	tear._process(0)
	expect(p.parry_hit and p.hp == p.max_hp, "projétil dourado do segundo padrão pode ser aparado")
	await reset()
	p._start_parry()
	p.state_t = p.PARRY_TIME
	p.invuln = 0
	tear = game.EnemyScript.Tear.new()
	tear.player = p
	game.add_child(tear)
	tear.position = p.position - Vector2(0,30)
	tear._process(0)
	expect(not p.parry_hit and p.hp < p.max_hp, "projétil vermelho não aceita aparo")
	await reset()
	e = foe(0, Vector2(950, 500))
	e.hp = 1
	e.last_hitter = p
	e.take_hit(100, p.position.x)
	for i in range(90): e._physics_process(1.0 / 60.0)
	expect(e.dead and e.corpse_landed, "morte normal espera a queda do corpo no chão")
	expect(get_nodes_in_group("blood_decals").size() > 0, "morte de carne deixa poça persistente")
	var metal = foe(7, Vector2(1100, 600))
	metal.take_hit(10000, p.position.x)
	expect(metal.death_material == "faiscas", "morte do Duelista de armadura usa faíscas")
	var flesh = foe(3, Vector2(1150, 600))
	flesh.take_hit(10000, p.position.x)
	expect(flesh.death_material == "sangue", "morte do Devorador de carne usa sangue")
	var ex = game.exploration
	var arena: Dictionary = ex.Layout.arenas()[0]
	ex.arena_active = arena.id
	ex.arena_wave = arena.waves.size() - 1
	var last = foe(0, Vector2(1200, 600))
	ex.arena_enemies = [last]
	last.take_hit(10000, p.position.x)
	expect(Engine.time_scale == 0.3, "última morte da última onda recebe câmera lenta")
	ex.arena_active = ""
	Engine.time_scale = 1.0
	game._delete_save()
	game.queue_free()
	game = null
	await frames(5)
	print("V36_COMBAT: %d checks, %d failures" % [checks, failures])
	quit(0 if failures == 0 else 1)
