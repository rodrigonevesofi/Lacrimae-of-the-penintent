extends SceneTree
# Verificação manual da chave do Gemini: faz UMA pergunta real e mostra a resposta.
# Use antes de apresentar, para conferir chave, modelo e internet.
# godot --headless --path . --script res://tests/confessor_live_check.gd
var confessor

func _initialize(): call_deferred("run")

func run() -> void:
	confessor = load("res://scripts/confessor.gd").new()
	root.add_child(confessor)
	if not confessor.online():
		print("SEM CHAVE: abra ia_local.cfg na pasta do projeto e troque COLE_SUA_CHAVE_AQUI pela sua chave (ou defina GEMINI_API_KEY).")
		quit(2)
		return
	if not confessor.api_key.begins_with("AIza"):
		print("AVISO: chaves do Google costumam começar com AIza. Confira se copiou a chave inteira.")
	print("Chave: ", confessor.api_key.left(6), "… (", confessor.api_key.length(), " caracteres)")
	print("Modelo: ", confessor.model, " · perguntando...")
	var started := Time.get_ticks_msec()
	confessor.ask("Quais teclas uso para aparar e esquivar?")
	var result: Array = await confessor.answered
	print("Fonte: ", result[1], " (", Time.get_ticks_msec() - started, " ms)")
	if result[1] != "gemini": print("Motivo: ", confessor.last_error)
	print("Resposta: ", result[0])
	quit(0 if result[1] == "gemini" else 1)
