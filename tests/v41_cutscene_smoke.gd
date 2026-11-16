extends SceneTree
## Cutscene em vídeo da revelação (v41): com clipes, a cena vira filme; sem clipes, nada muda.
const ValeFinale = preload("res://scripts/vale_finale.gd")
var checks := 0
var failures := 0
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
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	game._start_game(false, false)
	await frames(10)
	# Ao abrir direto no Vale, a pintura ainda pode estar visível antes da primeira montagem.
	var sala_anterior: String = game.pintura.sala
	var pintura_visivel: bool = game.pintura.pintura.visible
	game.pintura.sala = ""
	game.pintura.pintura.visible = true
	expect(not game.pintura.tem_chuva(), "sem sala de pintura montada, não consulta chuva nem gera erro")
	game.pintura.sala = sala_anterior
	game.pintura.pintura.visible = pintura_visivel
	# ---- com um clipe (o de teste): modo filme
	var f = ValeFinale.new()
	f.game = game
	f.pasta_clipes = "res://tests/dados/"
	game.finale = f
	game.add_child(f)
	await frames(2)
	expect(f.filme and f.videos.has(0) and f.videos.size() == 1, "um clipe na pasta liga o modo filme")
	expect(is_equal_approx(f.duracao(), 52.0), "o filme dura 52 s")
	expect(f.CLIPES.size() == 6 and f.LINES_FILME.size() == f.LINES.size(), "seis clipes e as mesmas sete falas")
	for i in range(f.CLIPES.size()):
		expect(is_equal_approx(float(f.CLIPES[i][0]), 3.0 + i * 8.0), "clipe %d começa a cada 8 s" % (i + 1))
	for i in range(f.LINES.size()): expect(f.LINES_FILME[i][2] == f.LINES[i][2], "fala %d é a mesma da cena parada" % (i + 1))
	# cada fala cai dentro do trecho do seu clipe
	for i in range(1, f.LINES_FILME.size()):
		expect(f.trecho(float(f.LINES_FILME[i][0])) == i - 1 and f.trecho(float(f.LINES_FILME[i][1]) - 0.01) == i - 1, "fala %d fica sobre o clipe %d" % [i + 1, i])
	expect(f.trecho(1.0) == -1 and f.trecho(3.0) == 0 and f.trecho(50.0) == 5, "trechos do filme")
	f.t = 3.2
	await frames(3)
	expect(f.clipe_atual == 0 and f.tela.visible and f.tela.stream == f.videos[0], "no primeiro trecho toca o clipe")
	expect(f.tela.volume_db < -60.0, "o clipe toca sem som: o som é o do jogo")
	f.t = 11.5
	await frames(3)
	expect(f.clipe_atual == 1 and not f.tela.visible, "trecho sem clipe: mostra o close parado")
	f.t = 12.6
	await frames(2)
	expect(f.marks.has("helmet"), "o som do capacete toca quando as mãos o erguem")
	f.t = 19.2
	await frames(2)
	expect(f.marks.has("face"), "o sino toca quando o rosto aparece")
	expect(f.can_skip(), "pode pular depois de 3 s")
	f.t = 51.95
	await frames(8)
	expect(game.final_defeated and game.state == "ending", "depois do filme, a vigília termina")
	expect(not game.player.cinematic_focus, "a câmera é devolvida")
	# ---- sem clipes: a cena de sempre
	var g = ValeFinale.new()
	g.game = game
	g.pasta_clipes = "res://tests/dados/pasta_que_nao_existe/"
	game.add_child(g)
	await frames(2)
	expect(not g.filme and g.tela == null and is_equal_approx(g.duracao(), 44.0), "sem clipes: 44 s, closes parados")
	g.queue_free()
	# ---- a pasta do jogo: só clipes válidos
	var dir := DirAccess.open("res://assets/cutscene")
	expect(dir != null, "pasta assets/cutscene existe")
	if dir != null:
		for arquivo in dir.get_files():
			if not arquivo.ends_with(".ogv"): continue
			var numero := int(arquivo.substr(11, 1))
			expect(arquivo.begins_with("revelacao_0") and numero >= 1 and numero <= 6, "clipe com nome esperado: " + arquivo)
	print("V41_CUTSCENE: %d checks, %d failures" % [checks, failures])
	game._delete_save()
	game.queue_free()
	await frames(3)
	quit(1 if failures > 0 else 0)
