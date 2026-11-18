extends SceneTree
## Mede a mixagem numa luta de 14 s no claustro, com o Penitente conduzido por comandos simulados.
## Uso: godot --path . --write-movie saida.avi --fixed-fps 60 --script res://tools/medir_mixagem.gd -- tudo|musica|efeitos
## Depois: ffmpeg -i saida.avi -vn -af ebur128 -f null -   (veja docs/v43-entrega.md)
const Inimigo = preload("res://scripts/enemy.gd")
var p
var game
func _initialize() -> void: call_deferred("run")
func fr(n):
	for i in range(n):
		await physics_frame
		await process_frame
func run() -> void:
	var modo: String = OS.get_cmdline_user_args()[0] if OS.get_cmdline_user_args().size() > 0 else "tudo"
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await fr(5)
	game._start_game(false, false)
	await fr(5)
	p = game.player
	p.has_weapon = true
	p.dev_god = true
	game.exploration.travel("cloister", Vector2(11500, 600))
	await fr(60)
	game.message_text = ""
	p.controllable = true
	if modo == "musica":
		AudioServer.set_bus_mute(AudioServer.get_bus_index("SFX"), true)
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Ambience"), true)
	elif modo == "efeitos":
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Music"), true)
	for par in [[0, 300], [4, 420], [7, 520], [3, 650]]:
		var e = Inimigo.new()
		e.setup(par[0], Vector2(11500 + par[1], 600), 120.0, p)
		e.room_id = "cloister"
		game.add_child(e)
		e.awaken()
	# 14 s de luta: avança, golpeia em sequência, apara de vez em quando
	for i in range(14 * 60):
		var alvo = null
		for e in get_nodes_in_group("enemies"):
			if not e.dead and (alvo == null or absf(e.global_position.x - p.global_position.x) < absf(alvo.global_position.x - p.global_position.x)): alvo = e
		Input.action_release("right"); Input.action_release("left")
		if alvo != null:
			var dx: float = alvo.global_position.x - p.global_position.x
			if absf(dx) > 90: Input.action_press("right" if dx > 0 else "left")
			elif i % 8 == 0: Input.action_press("attack")
			elif i % 8 == 2: Input.action_release("attack")
			if alvo.state == "stagger" and absf(dx) < 70 and i % 10 == 0: Input.action_press("interact")
			elif i % 10 == 2: Input.action_release("interact")
		await fr(1)
	quit()
