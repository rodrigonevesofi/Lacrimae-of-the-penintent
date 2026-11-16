extends SceneTree
## Capturas dirigidas dos cenários vivos, com o renderizador real. Não substituem uma partida humana.
## Para cada sala grava uma sequência de quadros (para montar um GIF e medir o que se move).
## Uso: LACRIMAE_REVIEW_DIR=<pasta> godot --rendering-driver opengl3 --script tests/v39_cenario_review.gd
## LACRIMAE_REVIEW_SALAS=cistern,terrace limita as salas; LACRIMAE_REVIEW_QUADROS muda o número de quadros.
var game
var directory: String

func _initialize() -> void: call_deferred("run")

func frames(n: int) -> void:
	for i in range(n):
		await physics_frame
		await process_frame

func capture(name: String) -> void:
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(directory.path_join(name + ".png"))

func run() -> void:
	directory = OS.get_environment("LACRIMAE_REVIEW_DIR")
	if directory.is_empty():
		quit(3)
		return
	var quadros := int(OS.get_environment("LACRIMAE_REVIEW_QUADROS")) if OS.has_environment("LACRIMAE_REVIEW_QUADROS") else 12
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	game._start_game(false, false)
	await frames(20)
	game.player.dev_god = true
	# Com LACRIMAE_REVIEW_DUPLA, Beatriz entra (os testes por --script rodam sem ela por padrão).
	var dupla := OS.has_environment("LACRIMAE_REVIEW_DUPLA")
	var andar := OS.has_environment("LACRIMAE_REVIEW_ANDAR")
	if dupla:
		game.enable_duo(true)
		await frames(3)
		game.partner.dev_god = true
	var salas: Array = ["city", "ossuary", "cistern", "cloister", "belfry", "archive", "refuge", "nave", "terrace", "court"]
	if OS.has_environment("LACRIMAE_REVIEW_SALAS"): salas = Array(OS.get_environment("LACRIMAE_REVIEW_SALAS").split(","))
	var fracao := float(OS.get_environment("LACRIMAE_REVIEW_X")) if OS.has_environment("LACRIMAE_REVIEW_X") else 0.42
	for id in salas:
		var data: Dictionary = game.exploration.rooms[id]
		var x: float = data.bounds.position.x + data.bounds.size.x * fracao
		if id == "city": x = 3300.0
		# Chão livre: sem alvenaria nem galeria baixa por perto.
		for tentativa in range(40):
			var livre := true
			for r in game.exploration.blocks + game.exploration.ledges:
				if x > r.position.x - 170.0 and x < r.end.x + 170.0 and r.position.y > data.floor - 260.0: livre = false
			if livre: break
			x += 60.0
		game.exploration.travel(id, Vector2(x, data.floor), 1)
		await frames(40)
		game.player.global_position = Vector2(x, data.floor)
		if dupla:
			game.partner.global_position = Vector2(x - 80.0, data.floor)
			game.partner.velocity = Vector2.ZERO
		game.player.velocity = Vector2.ZERO
		game.player.camera.reset_smoothing()
		game.message_t = 0.0
		game.message_text = ""
		game.player.controllable = true
		game.toast_t = 0.0
		game.area_t = 0.0
		await frames(30)
		# LACRIMAE_REVIEW_PASSO: quadros de jogo entre capturas (2 = vídeo a 30 por segundo).
		var passo := int(OS.get_environment("LACRIMAE_REVIEW_PASSO")) if OS.has_environment("LACRIMAE_REVIEW_PASSO") else 5
		if game.pintura.tem_chuva(): game.pintura.proximo_raio = 0.6
		if andar: Input.action_press("right")
		for i in range(quadros):
			await capture("%s-%03d" % [id, i])
			await frames(passo)
		if andar: Input.action_release("right")
		for peca in game.primeiro_plano.pecas: print("  frente: x na tela = ", int(peca.get_global_transform_with_canvas().origin.x), " y = ", int(peca.get_global_transform_with_canvas().origin.y))
		print("CAPTURE: ", id, " pintura=", game.pintura.ativa(id), " corvos=", game.bichos.corvos.size(), " morcegos=", game.bichos.morcegos.size(), " ratos=", game.bichos.ratos.size(), " frente=", game.primeiro_plano.pecas.size())
	game._delete_save()
	game.queue_free()
	game = null
	await frames(5)
	quit()
