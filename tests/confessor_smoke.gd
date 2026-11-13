extends SceneTree
# Confessionário sem rede: contexto, formato da requisição ao Gemini, leitura da resposta,
# modo offline, pausa ao abrir/fechar no altar e telemetria local.
# godot --headless --path . --script res://tests/confessor_smoke.gd
var game
var failures: Array[String] = []

func _initialize(): call_deferred("run")

func check(ok: bool, label: String) -> void:
	print(("OK    " if ok else "FALHA ") + label)
	if not ok: failures.append(label)

func frames(n: int) -> void:
	for i in range(n):
		await physics_frame
		await process_frame

func run() -> void:
	create_timer(20.0).timeout.connect(func(): print("CONFESSOR_TIMEOUT"); quit(4))
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await frames(2)
	game.telemetry.path = "user://telemetria_teste.json"
	game._start_game(false, false)
	game.message_text = ""
	game.prologue_page = -1
	game.player.has_weapon = true
	var c = game.confessor
	c.api_key = ""   # força o modo offline, mesmo com GEMINI_API_KEY definida

	# Contexto e requisição
	var ctx: String = c.state_context()
	check(ctx.contains("Cidade Da Penitência") or ctx.contains("Cidade da Penitência"), "contexto cita o lugar atual")
	check(ctx.contains(game.exploration.objective()), "contexto cita o objetivo da tela")
	check(ctx.contains("faltam: Cisterna dos Nomes, Campanário da Vigília"), "contexto lista as correntes que faltam")
	check(c.system_prompt().contains("NUNCA REVELE"), "instrução de sistema protege o segredo")
	var req: Dictionary = c.build_request("Como passo do abismo?")
	check(req.contents.back().role == "user" and req.contents.back().parts[0].text == "Como passo do abismo?", "pergunta vai como último turno do usuário")
	check(req.generationConfig.has("thinkingConfig"), "pede raciocínio mínimo")
	check(not c.build_request("x", false).generationConfig.has("thinkingConfig"), "segunda tentativa sem thinkingConfig")
	check(req.systemInstruction.parts[0].text.contains("ESTADO DO PEREGRINO"), "estado vai na instrução de sistema")

	# Leitura da resposta
	var sample := '{"candidates":[{"content":{"role":"model","parts":[{"text":"pensando","thought":true},{"text":"O Espinho repousa no Campanário."}]}}]}'
	check(c.parse_response(sample) == "O Espinho repousa no Campanário.", "lê o texto e ignora o raciocínio")
	check(c.parse_response("<html>erro</html>") == "", "resposta inválida vira texto vazio")
	check(c.parse_response('{"candidates":[]}') == "", "sem candidatos vira texto vazio")
	check(c.clean_text("**Ouça**, peregrino.") == "Ouça, peregrino.", "remove Markdown")

	# Classificação de dúvidas
	check(c.classify("Onde fica a RELÍQUIA?") == "reliquia", "classifica relíquia com acento e maiúsculas")
	check(c.classify("quem é o guardião?") == "guardiao", "classifica guardião")
	check(c.classify("quais são os controles") == "controles", "classifica controles")
	check(c.classify("bom dia") == "outro", "pergunta solta vira outro")

	# Abrir no altar pausa o jogo; pergunta offline responde
	game.player.global_position = game.altars[0]
	game.open_confession(0)
	check(paused and game.confession_open and game.confession_panel.visible, "abrir o Confessionário pausa o jogo")
	game.toggle_pause()
	check(not game.paused, "ESC não abre a pausa por cima do Confessionário")
	var answers: Array = []
	c.answered.connect(func(text, source): answers.append([text, source]))
	game.confession_panel._on_submitted("Para onde eu vou agora?")
	check(c.busy, "pergunta em andamento bloqueia outra")
	check(not c.ask("outra"), "segunda pergunta é recusada enquanto espera")
	await frames(2)
	check(answers.size() == 1 and answers[0][1] == "offline", "responde offline sem chave")
	check(answers.size() == 1 and str(answers[0][0]).to_lower().contains("espinho"), "resposta offline usa o objetivo atual")
	check(c.history.size() == 2, "histórico guarda pergunta e resposta")
	check(game.confession_panel.entries.size() == 3, "painel mostra saudação, pergunta e resposta")
	check(c.voice_label().contains("sem chave"), "painel avisa que está sem chave")
	game.confession_panel.close()
	check(not paused and not game.confession_open, "fechar devolve o jogo")

	# Telemetria
	var before: int = int(game.telemetry.data.questions)
	game._on_player_died()
	game.telemetry.load_data()
	check(int(game.telemetry.data.deaths_by_room.get("city", 0)) >= 1, "morte registrada por lugar")
	check(int(game.telemetry.data.questions) == before, "telemetria salva e recarrega")
	check(game.telemetry.top_deaths(1)[0][0] == "city", "lugar com mais mortes")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(game.telemetry.path))

	print("CONFESSOR_RESULT ", "PASS" if failures.is_empty() else "FAIL " + ", ".join(failures))
	game._delete_save()
	quit(0 if failures.is_empty() else 1)
