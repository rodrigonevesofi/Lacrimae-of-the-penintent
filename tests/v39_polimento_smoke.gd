extends SceneTree
## Polimento (v39): pés no piso pintado, portas altas com soleira, espada na mão, folhas limpas e dupla jogável.
const Layout = preload("res://scripts/act_one_layout.gd")
var game
var checks := 0
var failures := 0

func _initialize() -> void: call_deferred("run")

func check(ok: bool, what: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		print("FALHA: ", what)

func frames(n: int) -> void:
	for i in range(n):
		await physics_frame
		await process_frame

func run() -> void:
	# ---- 1. o chão de colisão cai dentro do piso pintado de cada sala (faixas medidas nas pinturas)
	var pisos := {"ossuary": [0.86, 0.90], "cistern": [0.825, 0.865], "cloister": [0.925, 0.95], "belfry": [0.945, 0.97], "archive": [0.66, 0.757],
		"refuge": [0.72, 0.84], "nave": [0.835, 0.862], "terrace": [0.805, 0.86], "court": [0.835, 0.87]}
	var salas := Layout.rooms()
	for id in pisos:
		var g: float = float(salas[id].get("ground", 0.86))
		check(g > pisos[id][0] + 0.004 and g < pisos[id][1] - 0.004, "%s: o chão (%.3f) fica dentro do piso pintado, longe das beiras" % [id, g])
	# ---- 2. toda porta no alto tem piso em toda a largura
	var galerias := Layout.platforms()
	for link in Layout.passages():
		for de_a in [true, false]:
			var face: Dictionary = Layout.passage_face(link, de_a)
			var piso: float = salas[face.room].floor
			if is_equal_approx(face.foot.y, piso): continue
			var x0: float = face.foot.x - face.width * 0.5
			var coberto := 0
			for k in range(20):
				var x: float = x0 + (k + 0.5) * float(face.width) / 20.0
				for g in galerias:
					if absf(g.position.y - face.foot.y) < 1.0 and x >= g.position.x and x <= g.end.x:
						coberto += 1
						break
			check(coberto >= 19, "porta alta %s em %s tem soleira em toda a largura (%d/20)" % [link.id, face.room, coberto])
	# ---- 3. quadros reencaixados: clips.json coerente e o deslocamento aplicado ao desenhar
	var manifesto: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://assets/animation/clips.json"))
	var com := 0
	for ator in manifesto:
		for clipe in manifesto[ator]:
			var dados: Dictionary = manifesto[ator][clipe]
			if not dados.has("deslocamentos"): continue
			com += 1
			var n: int = dados.frames.size() if dados.has("frames") and not dados.frames.is_empty() else int(dados.count)
			check(dados.deslocamentos.size() == n, "%s/%s: um deslocamento por quadro" % [ator, clipe])
	check(com >= 3, "há clipes reencaixados")
	var anim = load("res://scripts/actor_animation.gd").new()
	root.add_child(anim)
	anim.configure("hero", 0.44)
	var golpe: Array = manifesto.hero.attack_a.deslocamentos
	anim.pose("attack_a", 1, 0)
	var x_sem: float = anim.position.x
	anim.pose("attack_a", 1, 4)
	check(is_equal_approx(anim.position.x - x_sem, float(golpe[4]) * 0.44) and float(golpe[4]) > 0.0, "o quadro reencaixado volta ao lugar ao ser desenhado")
	anim.pose("attack_a", -1, 4)
	check(is_equal_approx(anim.position.x + x_sem, -float(golpe[4]) * 0.44), "virado para a esquerda, o deslocamento espelha")
	anim.queue_free()
	# ---- 4. a espada: atrás da mão, empunhada junto à guarda
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	game._start_game(false, false)
	await frames(10)
	var p = game.player
	p.has_weapon = true
	p.state = "idle"
	p._update_animation()
	p._update_sword()
	# v44: parado, a espada vem desenhada no próprio quadro (espada_integrada); a solta fica escondida.
	check(p.sword.visible or p.animator.definitions.get(p.animator.animation, {}).get("espada_integrada", false), "espada visível parado")
	check(p.sword.get_index() < p.animator.get_index() and p.sword.z_index == 0, "a espada é desenhada atrás do corpo: o punho fica por cima do cabo")
	check(p.SWORD_GRIP.x > 480.0 and p.SWORD_GRIP.x < 600.0, "a mão segura o cabo junto à guarda")
	var guarda: Vector2 = p.sword.transform * (Vector2(640, 360) - p.SWORD_GRIP)
	check(guarda.distance_to(p.sword.position) < 6.0, "a guarda fica a menos de 6 pontos do punho")
	# ---- 5. sombra de contato e pés no chão
	await frames(30)
	check(p.is_on_floor(), "o Penitente está apoiado no chão")
	# ---- 6. Beatriz joga junto: entra como segunda personagem e aceita teclas sem teclado numérico
	game.enable_duo(true)
	await frames(5)
	check(game.partner != null and is_instance_valid(game.partner) and game.partner.character == "beatriz", "Beatriz entra ao lado do Penitente")
	check(game.partner.ai, "até alguém assumir, o jogo controla Beatriz")
	for acao in ["p2_attack", "p2_roll", "p2_parry", "p2_heavy", "p2_heal", "p2_interact", "p2_share_blood"]:
		var fora_do_numerico := false
		for ev in InputMap.action_get_events(acao):
			if ev is InputEventKey and ev.physical_keycode < KEY_KP_0 or ev is InputEventKey and ev.physical_keycode > KEY_KP_9 and ev.physical_keycode != KEY_KP_ENTER: fora_do_numerico = true
		check(fora_do_numerico, acao + " tem tecla fora do teclado numérico")
	game.message_text = ""
	p.controllable = true
	Input.action_press("p2_attack")
	await frames(3)
	Input.action_release("p2_attack")
	check(not game.partner.ai, "o primeiro comando da jogadora 2 assume Beatriz")
	# ---- 7. pedra na cor da sala
	check(game.art.pedra(0, "cloister") != game.art.pedra(0, "archive"), "galerias tomam a cor do piso de cada sala")
	check(game.art.PEDRA.size() == 10, "dez salas com cor de pedra")
	print("POLIMENTO: %d checks, %d failures" % [checks, failures])
	game._delete_save()
	game.queue_free()
	game = null
	await frames(5)
	quit(1 if failures > 0 else 0)
