extends SceneTree
## v43: Beatriz faz o mesmo que o Penitente (golpes novos, aparo, prece, execução) e recolhe lágrimas
## para a bolsa comum. No automático, ela também varia os golpes.
const Inimigo = preload("res://scripts/enemy.gd")
var checks := 0
var failures := 0
var game
var p
var b

func _initialize() -> void: call_deferred("run")

func expect(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		print("FALHA: ", label)
	else:
		print("ok: ", label)

func frames(n: int) -> void:
	for i in range(n):
		await physics_frame
		await process_frame

func tap(a: String) -> void:
	Input.action_press(a)
	await frames(2)
	Input.action_release(a)

func inimigo(kind: int, onde: Vector2):
	var e = game.new_enemy(kind)
	e.setup(kind, onde, 120.0, b)
	e.room_id = game.exploration.room
	game.add_child(e)
	e.spawn_opacity = 1.0
	return e

func limpar() -> void:
	for e in get_nodes_in_group("enemies"): e.queue_free()
	for g in get_nodes_in_group("pedacos_gore"): g.queue_free()
	await frames(2)

func pronta() -> void:
	b.state = "idle"
	b.state_t = 0.0
	b.hit_pause = 0.0
	b._clear_combat_input()
	Engine.time_scale = 1.0
	await frames(3)
	for i in range(90):
		if b.is_on_floor(): break
		await frames(1)

func run() -> void:
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await frames(5)
	game._start_game(false, false)
	await frames(5)
	game.message_title = ""
	game.message_text = ""
	p = game.player
	p.has_weapon = true
	p.controllable = true
	p.global_position = Vector2(1500, 600)
	game.enable_duo(true)
	await frames(10)
	b = game.partner
	b.has_weapon = true
	b.controllable = true
	b.global_position = Vector2(1800, 600)
	b.ai = false
	await frames(20)
	expect(b.character == "beatriz" and b.prefix == "p2_", "Beatriz usa os comandos do jogador 2")

	# ---- corte ascendente
	var alvo = inimigo(0, b.global_position + Vector2(60, 0))
	alvo.max_hp = 999.0
	alvo.hp = 999.0
	b.facing = 1
	await frames(2)
	await tap("p2_heavy")
	await frames(2)
	expect(b.state == "ascendente", "um toque no pesado faz Beatriz dar o corte ascendente")
	await pronta()
	await limpar()

	# ---- investida
	inimigo(0, b.global_position + Vector2(170, 0)).max_hp = 999.0
	b.facing = 1
	b._start_roll()
	await frames(9)
	await tap("p2_attack")
	await frames(2)
	expect(b.state == "investida", "atacar no fim da esquiva vira investida também com Beatriz")
	await pronta()
	await limpar()

	# ---- Lâmina de Sangue
	b.culpa = 60.0
	b.facing = 1
	await tap("p2_prece")
	expect(b.culpa == 35.0, "Beatriz lança a Lâmina de Sangue gastando culpa")
	await pronta()

	# ---- aparo
	var d = inimigo(0, b.global_position + Vector2(55, 0))
	await frames(2)
	b.hp = b.max_hp
	b.facing = 1
	b._start_parry()
	b.state_t = b.PARRY_TIME - 0.25
	b.take_hit(16.0, d.global_position.x, d, true)
	expect(b.parry_hit and d.state == "stagger", "Beatriz apara com a mesma janela")
	await pronta()

	# ---- execução com o botão dela
	d.state = "stagger"
	d.state_t = 3.0
	d.global_position = b.global_position + Vector2(50, 0)
	p.global_position = b.global_position + Vector2(-260, 0)
	await frames(3)
	Input.action_press("p2_interact")
	await frames(3)
	Input.action_release("p2_interact")
	expect(b.state == "execution", "Beatriz executa a criatura atordoada")
	for i in range(160):
		if b.state != "execution": break
		await frames(1)
	expect(d.dead, "a execução de Beatriz mata")
	await pronta()
	await limpar()

	# ---- lágrimas: vão para quem estiver mais perto, e caem na bolsa comum
	game.lagrimas_ar.clear()
	p.global_position = b.global_position + Vector2(-260, 0)
	var antes: int = p.lagrimas
	var morto = inimigo(0, b.global_position + Vector2(40, 0))
	var premio: int = morto.reward
	morto._die()
	await frames(20)
	var perto_dela := true
	for l in game.lagrimas_ar:
		if l.p.distance_to(b.global_position) > l.p.distance_to(p.global_position): perto_dela = false
	expect(perto_dela, "as lágrimas voam para Beatriz quando ela está mais perto")
	await frames(220)
	expect(p.lagrimas == antes + premio, "as lágrimas que Beatriz recolhe vão para a bolsa comum")
	await limpar()

	# ---- melhorias valem para os dois
	p.lagrimas = 2000
	game.comprar_oferenda(0)
	expect(b.upgrades == p.upgrades and b.max_hp >= p.max_hp * 0.5, "a vida comprada no altar vale também para Beatriz")

	# ---- no automático, ela varia os golpes
	b.ai = true
	b.dev_god = true
	p.dev_god = true
	# Chão firme, longe do fosso do pátio.
	b.global_position = Vector2(1600, 600)
	p.global_position = Vector2(1540, 600)
	await frames(4)
	var saco = inimigo(0, Vector2(1670, 600))
	saco.max_hp = 99999.0
	saco.hp = 99999.0
	await frames(2)
	# O saco de pancadas fica parado: o teste olha só as escolhas dela.
	saco.set_physics_process(false)
	var vistos := {}
	for i in range(900):
		await frames(1)
		vistos[b.state] = true
		if saco.state in ["stagger", "launched"]:
			saco.state = "chase"
		if saco.dead: break
	expect(not vistos.has("fallen"), "Beatriz automática não cai durante a luta")
	expect(vistos.has("attack") and vistos.has("ascendente"), "Beatriz automática alterna cortes e corte ascendente (viu: %s)" % str(vistos.keys()))

	print("V43_BEATRIZ_RESULT ", "PASS" if failures == 0 else "FAIL", " checks=", checks, " failures=", failures)
	quit(1 if failures > 0 else 0)
