extends SceneTree
## Cenários vivos (v39): a pintura animada por shader, os bichos que reagem, o primeiro plano e o temporal.
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

func ir(id: String, fracao: float = 0.5) -> void:
	var data: Dictionary = game.exploration.rooms[id]
	var x: float = data.bounds.position.x + data.bounds.size.x * fracao
	game.exploration.travel(id, Vector2(x, data.floor), 1)
	await frames(6)
	game.player.set_physics_process(false)
	game.player.global_position = Vector2(x, data.floor)
	game.message_text = ""
	await frames(4)

func run() -> void:
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	game._start_game(false, false)
	await frames(10)
	game.player.dev_god = true
	var salas := ["city", "ossuary", "cistern", "cloister", "belfry", "archive", "refuge", "nave", "terrace", "court"]
	# ---- 1. toda sala pintada tem máscaras, pintura viva ligada e peças de primeiro plano
	for id in salas:
		var arte := str(game.exploration.rooms[id].art)
		for sufixo in ["_a", "_b"]:
			check(ResourceLoader.exists("res://assets/vivo/" + arte + sufixo + ".png"), "máscara " + arte + sufixo)
		await ir(id)
		check(game.pintura.ativa(id), id + ": pintura viva ligada")
		check(game.pintura.pintura.texture == game.art.art_texture(arte), id + ": usa a pintura da sala")
		check(game.art._pintura_viva(id), id + ": world_art não desenha a pintura parada por cima")
		var mat: ShaderMaterial = game.pintura.material_vivo
		check(mat.get_shader_parameter("marcas_a") != null and mat.get_shader_parameter("marcas_b") != null, id + ": máscaras no shader")
		check(is_equal_approx(float(mat.get_shader_parameter("tempo")), game.t), id + ": o tempo do shader anda com o jogo")
		check(float(mat.get_shader_parameter("vento")) > 0.0, id + ": há vento")
		check(game.primeiro_plano.pecas.size() >= 1, id + ": primeiro plano montado")
		check(game.bichos.sala == id, id + ": bichos montados")
		check(game.bichos.corvos.size() + game.bichos.morcegos.size() + game.bichos.ratos.size() > 0, id + ": tem algum bicho")
	# O tamanho e a posição da pintura são os mesmos de antes (a arte casa com as colisões).
	await ir("cloister")
	var d: Dictionary = game.exploration.rooms["cloister"]
	var alt: float = game.exploration.art_height("cloister")
	var esperado := Rect2(d.bounds.position.x, d.floor - alt * game.exploration.ground_line("cloister"), d.bounds.size.x, alt)
	var sprite: Sprite2D = game.pintura.pintura
	check(sprite.position.is_equal_approx(esperado.position), "claustro: a pintura fica onde ficava")
	check((sprite.texture.get_size() * sprite.scale).is_equal_approx(esperado.size), "claustro: a pintura tem o tamanho de antes")
	await ir("city", 0.3)
	check((game.pintura.pintura.texture.get_size() * game.pintura.pintura.scale).is_equal_approx(Vector2(4800, 1600)), "cidade: o panorama tem o tamanho de antes")
	# ---- 2. um golpe forte sopra os panos e se apaga
	await ir("cloister")
	game.pintura.impulse(game.player.global_position.x, 1.0)
	check(game.pintura.rajada > 0.0, "golpe forte sopra os panos")
	var x_uv: float = game.pintura.rajada_x
	check(x_uv > 0.3 and x_uv < 0.7, "o sopro nasce onde o golpe aconteceu")
	await frames(120)
	check(game.pintura.rajada < 0.05, "o sopro se apaga")
	# ---- 3. relâmpago: animação do AnimationPlayer; some com reduzir pulsos
	var anim: Animation = game.pintura.relampago.get_animation("relampago")
	check(anim != null and anim.get_track_count() == 2, "relâmpago tem trilha de clarão e trilha de trovão")
	check(anim.track_get_type(0) == Animation.TYPE_VALUE and anim.track_get_type(1) == Animation.TYPE_METHOD, "tipos das trilhas do relâmpago")
	await ir("terrace")
	check(game.pintura.tem_chuva(), "terraço: chove")
	check(float(game.pintura.material_vivo.get_shader_parameter("chuva")) > 0.0, "terraço: chuva no shader")
	game.reduced_pulses = false
	game.pintura.proximo_raio = 0.0
	await frames(8)
	check(game.pintura.relampago.is_playing(), "terraço: o relâmpago toca")
	check(game.pintura.clarao > 0.0, "terraço: o clarão acende")
	check(float(game.pintura.material_vivo.get_shader_parameter("pulso")) == 1.0, "chamas tremem por padrão")
	game.reduced_pulses = true
	await frames(3)
	check(game.pintura.clarao == 0.0 and not game.pintura.relampago.is_playing(), "reduzir pulsos apaga o clarão na hora")
	check(float(game.pintura.material_vivo.get_shader_parameter("pulso")) == 0.0, "reduzir pulsos para o tremor das chamas")
	game.pintura.proximo_raio = 0.0
	await frames(8)
	check(game.pintura.clarao == 0.0 and not game.pintura.relampago.is_playing(), "reduzir pulsos: não há relâmpago novo")
	game.reduced_pulses = false
	await ir("cloister")
	check(not game.pintura.tem_chuva(), "claustro: não chove")
	for nome in ["amb_chuva", "trovao_01", "trovao_02", "trovao_03"]:
		check(ResourceLoader.exists("res://assets/audio/" + nome + ".wav"), "som " + nome)
	# ---- 4. corvos: pousados, fogem de quem chega perto e de um estalo forte
	await ir("terrace", 0.05)
	var corvos: Array = game.bichos.corvos
	check(corvos.size() == 5, "terraço: cinco corvos")
	var pousados := 0
	for c in corvos:
		if c.estado == "pousado" and c.no.animation == "pousado": pousados += 1
	check(pousados >= 3, "corvos começam pousados")
	var alvo: Dictionary = {}
	for c in corvos:
		if c.estado == "pousado": alvo = c
	var antes: int = game.bichos.voos
	var onde: Vector2 = alvo.no.position
	game.player.global_position = onde + Vector2(-120, 0)
	await frames(14)
	check(alvo.estado == "voando" and game.bichos.voos > antes, "corvo levanta voo quando o Penitente chega perto")
	check(alvo.no.animation == "voo", "corvo em voo usa a animação de voo")
	await frames(40)
	check(alvo.no.position.x > onde.x + 20.0 and alvo.no.position.y < onde.y, "corvo foge para o lado oposto, subindo")
	await ir("court", 0.02)
	antes = game.bichos.voos
	var primeiro: Dictionary = game.bichos.corvos[0]
	game.bichos.susto(primeiro.no.position + Vector2(60, 0), 420.0)
	check(game.bichos.voos > antes, "um estalo forte espanta os corvos")
	# ---- 5. morcegos: saem em revoada quando se passa por baixo
	await ir("belfry", 0.02)
	var morcegos: Array = game.bichos.morcegos
	check(morcegos.size() == 8, "campanário: oito morcegos")
	var m: Dictionary = morcegos[0]
	check(m.estado == "pendurado", "morcegos começam pendurados")
	var rev: int = game.bichos.revoadas
	game.player.global_position = m.casa + Vector2(40, 200)
	await frames(4)
	check(m.estado == "voando" and game.bichos.revoadas > rev, "morcegos saem em revoada")
	await frames(30)
	check(m.pos.distance_to(m.casa) > 40.0, "morcego em revoada se afasta do poleiro")
	# ---- 6. ratos: fogem correndo para o lado oposto
	await ir("ossuary", 0.02)
	var r: Dictionary = game.bichos.ratos[0]
	var rx: float = r.pos.x
	game.player.global_position = r.pos + Vector2(-150, 0)
	await frames(30)
	check(r.pos.x > rx + 40.0, "rato foge do Penitente")
	# ---- 7. primeiro plano: Parallax2D mais rápido que a câmera, preso à tela na vertical
	var plano: Parallax2D = game.primeiro_plano.plano
	check(is_equal_approx(plano.scroll_scale.x, 1.35) and plano.scroll_scale.y == 0.0, "primeiro plano corre 35% mais rápido")
	check(game.primeiro_plano.z_index > 9, "primeiro plano fica na frente de tudo")
	# ---- F6 desliga a pintura viva e a pintura parada volta
	await ir("cloister")
	game.pintura.desligada = true
	await frames(3)
	check(not game.art._pintura_viva("cloister") and not game.pintura.visible, "F6: pintura parada de volta")
	game.pintura.desligada = false
	await frames(3)
	check(game.art._pintura_viva("cloister") and game.pintura.visible, "F6 de novo: pintura viva de volta")
	# ---- 8. o Vale tem cenário próprio: nada disto entra lá
	game.exploration.travel("vale", Vector2(30500, 600), 1)
	await frames(8)
	check(not game.pintura.ativa("vale") and not game.pintura.visible, "vale: sem pintura viva (tem cenário próprio)")
	check(game.bichos.sala == "" and game.bichos.corvos.is_empty(), "vale: sem bichos destas salas")
	check(game.primeiro_plano.pecas.is_empty(), "vale: sem primeiro plano destas salas")
	print("CENARIO_VIVO: %d checks, %d failures" % [checks, failures])
	game._delete_save()
	game.queue_free()
	game = null
	await frames(5)
	quit(1 if failures > 0 else 0)
