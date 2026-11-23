extends SceneTree
## v44: espada fincada desenhada com a arte da espada, espada encostada no punho e seguindo o braço,
## passo no quadro em que o pé toca o chão, golpes atrasados e duplos das criaturas, respingos na tela.
var checks := 0
var failures := 0
var game
var p

func _initialize() -> void: call_deferred("run")

func expect(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		print("FALHA: ", label)

func frames(n: int) -> void:
	for i in range(n):
		await physics_frame
		await process_frame

func run() -> void:
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await frames(5)
	game._start_game(false, false)
	await frames(10)
	game.message_title = ""
	game.message_text = ""
	p = game.player

	# ---- espada fincada
	expect(not p.has_weapon and game.get_node("Arte").has_method("_desenhar_espada_fincada"), "a espada fincada é desenhada com a arte da espada")
	await frames(3)
	expect(game.get_node("Arte").espada_fincada != null and game.get_node("Arte").espada_fincada.get_width() > 80, "a arte da espada fincada foi preparada")

	# ---- espada na mão: a guarda encosta no punho e a lâmina acompanha o braço na corrida
	p.has_weapon = true
	p.state = "idle"
	expect(p.SWORD_GRIP.x > 500.0 and p.sword.offset == -p.SWORD_GRIP, "o cabo fica logo atrás da guarda, dentro do punho")
	var angulos := {}
	for i in range(6):
		p.animator.select("run", 1, float(i) / 6.0 + 0.01)
		p._update_sword()
		angulos[snappedf(p.sword.rotation, 0.01)] = true
	expect(angulos.size() >= 3, "na corrida a lâmina muda de ângulo com o braço")

	# ---- passo no quadro em que o pé encosta
	expect(p.PASSO_QUADROS == [1, 4] and p.has_method("_passo_no_quadro"), "o passo toca nos quadros em que o pé toca o chão")

	# ---- criaturas: ritmo variado
	var e = game.new_enemy(0)
	e.setup(0, p.global_position + Vector2(300, 0), 120.0, p)
	e.room_id = game.exploration.room
	game.add_child(e)
	await frames(2)
	expect(e.get("ataques_feitos") != null and e.get("golpe_extra") != null, "as criaturas contam os ataques para variar o ritmo")
	e.queue_free()

	# ---- respingos na tela
	game.sangue_na_tela(5)
	expect(game.gotas_tela.size() == 5 and game.gotas_tela[0].has("s") and game.hud.has_method("_respingo_tela"), "o sangue na tela tem forma própria em cada respingo")

	print("V44_RESULT ", "PASS" if failures == 0 else "FAIL", " checks=", checks, " failures=", failures)
	quit(1 if failures > 0 else 0)
