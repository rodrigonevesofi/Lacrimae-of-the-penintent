extends SceneTree
## v43: golpes novos, aparo mais justo, execuções desmembrando, lágrimas visíveis, oferendas, relíquias,
## avisos de tecla no mundo, destaque dos personagens e mixagem.
const Inimigo = preload("res://scripts/enemy.gd")
const Gore = preload("res://scripts/gore.gd")
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

func tap(a: String) -> void:
	Input.action_press(a)
	await frames(2)
	Input.action_release(a)

func inimigo(kind: int, dx: float):
	var e = Inimigo.new()
	e.setup(kind, p.global_position + Vector2(dx, 0), 120.0, p)
	e.room_id = game.exploration.room
	game.add_child(e)
	e.spawn_opacity = 1.0
	return e

func limpar() -> void:
	for e in get_nodes_in_group("enemies"): e.queue_free()
	for g in get_nodes_in_group("pedacos_gore"): g.queue_free()
	await frames(2)

func reset() -> void:
	p.state = "idle"
	p.state_t = 0.0
	p.hit_pause = 0.0
	p.combo_window = 0.0
	p._clear_combat_input()
	Engine.time_scale = 1.0
	await frames(3)
	for i in range(90):
		if p.is_on_floor(): break
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
	p.global_position = Vector2(1700, 600)
	await frames(10)

	# ---- sequência de quatro
	print("ETAPA sequência de quatro")
	var tipos: Array = []
	for i in range(4):
		p._start_attack()
		tipos.append(p.golpe_tipo)
		p.state = "idle"
	expect(tipos == ["corte", "contracorte", "estocada", "descendente"], "a sequência tem quatro golpes diferentes")
	expect(p.finisher, "o quarto golpe é o arremate")
	await reset()

	# ---- corte ascendente: toque curto no pesado
	print("ETAPA corte ascendente: toque curto no pesado")
	var alvo = inimigo(0, 60.0)
	alvo.max_hp = 999.0
	alvo.hp = 999.0
	await frames(2)
	await tap("heavy")
	await frames(2)
	expect(p.state == "ascendente", "um toque no pesado faz o corte ascendente")
	await frames(16)
	expect(alvo.state == "launched" or alvo.velocity.y < 0.0, "o corte ascendente joga a criatura para cima")
	await reset()
	await limpar()

	# ---- investida: esquiva e logo ataque
	print("ETAPA investida: esquiva e logo ataque")
	var a1 = inimigo(0, 160.0)
	a1.max_hp = 999.0
	a1.hp = 999.0
	var hp0: float = a1.hp
	p.facing = 1
	p._start_roll()
	await frames(9)
	await tap("attack")
	await frames(2)
	expect(p.state == "investida", "atacar durante a esquiva vira investida")
	await frames(20)
	expect(a1.hp < hp0, "a investida fere quem está no caminho")
	await reset()
	await limpar()

	# ---- Lâmina de Sangue
	print("ETAPA Lâmina de Sangue")
	p.culpa = 10.0
	await tap("prece")
	expect(p.state != "prece" and p.culpa == 10.0, "sem culpa bastante a lâmina não sai")
	p.culpa = 60.0
	var alvo2 = inimigo(4, 300.0)
	var hp1: float = alvo2.hp
	await tap("prece")
	expect(p.culpa == 35.0, "a lâmina gasta um quarto da culpa")
	await frames(40)
	expect(alvo2.hp < hp1 or alvo2.dead, "a lâmina voa e fere")
	await reset()
	await limpar()

	# ---- aparo: janela maior, bloqueio e aparo tardio
	print("ETAPA aparo: janela maior, bloqueio e aparo tardio")
	expect(p.PARRY_WINDOW >= 0.34, "janela de aparo ampliada")
	var d = inimigo(0, 55.0)
	await frames(2)
	p.hp = 100.0
	p.facing = 1
	p._start_parry()
	p.state_t = p.PARRY_TIME - 0.30
	p.take_hit(16.0, d.global_position.x, d, true)
	expect(p.parry_hit and d.state == "stagger", "aparo aos 0,30 s ainda vale")
	await reset()
	d.state = "chase"
	p.hp = 100.0
	p._start_parry()
	p.state_t = 0.05
	p.take_hit(16.0, d.global_position.x, d, true)
	expect(not p.parry_hit and p.hp == 96.0 and p.state == "parry", "aparo atrasado bloqueia três quartos do dano")
	await reset()
	p.hp = 100.0
	p.invuln = 0.0
	p.take_hit(16.0, d.global_position.x, d, true)
	expect(p.state == "hurt" and p.perdao_t > 0.0, "golpe aparável recebido abre o aparo tardio")
	await tap("parry")
	expect(p.parry_hit and p.hp == 100.0, "aparo tardio devolve a vida e abre o inimigo")
	await reset()
	await limpar()

	# ---- preparações mais curtas e brilho
	print("ETAPA preparações mais curtas e brilho")
	var w = inimigo(0, 60.0)
	w.state = "windup"
	w.state_t = 0.55
	await frames(20)
	expect(w.state_t < 0.55 - 0.33 * 1.2 or w.state != "windup", "a preparação dos inimigos corre mais depressa")
	await limpar()

	# ---- execuções: cada estilo recorta o corpo
	print("ETAPA execuções: cada estilo recorta o corpo")
	var estilos := {}
	for kind in [0, 4, 3, 8, 6, 1]:
		estilos[Gore.estilo_de(kind)] = true
	expect(estilos.size() == 6, "seis jeitos diferentes de executar")
	var vitima = inimigo(0, 60.0)
	await frames(2)
	vitima.global_position = p.global_position + Vector2(60, 0)
	vitima.state = "stagger"
	vitima.state_t = 3.0
	p.state = "idle"
	expect(p.begin_execution(vitima), "a execução começa")
	# O corpo some depois de morto; a verificação acontece no quadro da morte (com o computador lento,
	# a câmera lenta, que corre em tempo real, acaba antes e o corpo some mais cedo).
	var desmembrou := false
	for i in range(240):
		await frames(1)
		if not is_instance_valid(vitima): break
		if vitima.dead:
			desmembrou = vitima.has_meta("desmembrado")
			break
	expect(desmembrou, "a execução desmembra a criatura")
	await frames(10)
	expect(get_nodes_in_group("pedacos_gore").size() >= 2, "a decapitação deixa corpo e cabeça")
	await reset()
	await limpar()

	# ---- lágrimas visíveis, mesma bolsa
	print("ETAPA lágrimas visíveis, mesma bolsa")
	game.enable_duo(true)
	await frames(4)
	game.recolher_lagrimas()
	var antes: int = p.lagrimas
	var morto = inimigo(0, 40.0)
	morto.player = game.partner
	var premio: int = morto.reward
	morto._die()
	expect(not game.lagrimas_ar.is_empty(), "as lágrimas saem do corpo e voam")
	await frames(240)
	expect(p.lagrimas == antes + premio and game.lagrimas_ar.is_empty(), "lágrimas da morte de Beatriz vão para a bolsa comum")
	await limpar()

	# ---- oferendas e relíquias
	print("ETAPA oferendas e relíquias")
	p.lagrimas = 1000
	p.upgrades = 0
	p.forca = 0
	var mult0: float = p.sword_multiplier()
	game.comprar_oferenda(1)
	expect(p.forca == 1 and p.lagrimas == 850 and p.sword_multiplier() > mult0 * 1.09, "oferenda de força aumenta o dano")
	expect(game.partner.forca == 1, "Beatriz recebe a mesma força")
	var frascos0: int = p.max_flasks
	game.comprar_oferenda(2)
	expect(p.max_flasks == frascos0 + 1, "oferenda de frasco aumenta os frascos")
	var ids: Array = []
	for item in game.exploration.pickups: ids.append(item.id)
	expect(ids.has("calice_1") and ids.has("calice_3") and ids.has("espinho_2"), "cálices e espinhos estão no mapa")
	var hp_base: float = p.max_hp
	p.calices = 1
	p.apply_penitence(p.penitence)
	expect(p.max_hp == hp_base + 12.0, "cada cálice dá 12 de vida máxima")

	# ---- avisos de tecla no mundo
	print("ETAPA avisos de tecla no mundo")
	game.exploration.travel("city", game.altars[0])
	await frames(50)
	game.message_text = ""
	p.controllable = true
	await frames(4)
	expect(game.prompt.contains("[R] Oferendas") and game.prompt_at != Vector2.INF, "o altar mostra as teclas acima dele")
	var itens: Array = game.hud._itens_aviso(game.prompt)
	expect(itens.size() == 3 and itens[0][0] == "E", "o aviso separa cada tecla do seu rótulo")

	# ---- destaque dos personagens
	print("ETAPA destaque dos personagens")
	expect(p.animator.material is ShaderMaterial and p.animator.material.shader.resource_path.ends_with("ator_legivel.gdshader"), "o Penitente tem contorno e luz de borda")
	expect(game.partner.animator.material is ShaderMaterial, "Beatriz também se destaca")
	var dest_iria: Dictionary = p.animator.destaque_de("iria")
	var dest_inim: Dictionary = p.animator.destaque_de("devotee")
	expect(float(dest_iria.get("aura", 0.0)) > 0.0 and float(dest_inim.get("aura", 0.0)) == 0.0, "só Iria tem aura clara")

	# ---- mixagem
	print("ETAPA mixagem")
	var mix: Dictionary = game.soundscape.MIX_TRIM_DB
	expect(float(mix.tracks) >= 6.0 and float(mix.action) <= -6.0, "a música sobe e os efeitos descem")
	expect(game.soundscape.resolve("investida") != "investida" or game.soundscape.effects.has("investida"), "som novo sem arquivo usa um substituto")

	# ---- o Confessor conhece os golpes e as oferendas
	print("ETAPA Confessor")
	expect(game.confessor.classify("como fico mais forte?") == "crescer" and game.confessor.classify("onde acho um cálice?") == "crescer", "o Confessor entende perguntas sobre ficar mais forte")
	expect(game.confessor.offline_answer("crescer").contains("oferendas") and game.confessor.offline_answer("controles").contains("Lâmina de Sangue"), "as respostas prontas falam das oferendas e dos golpes novos")

	print("V43_RESULT ", "PASS" if failures == 0 else "FAIL", " checks=", checks, " failures=", failures)
	quit(1 if failures > 0 else 0)
