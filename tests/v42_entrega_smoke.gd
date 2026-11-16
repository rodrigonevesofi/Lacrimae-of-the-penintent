extends SceneTree
## Versão 42: o Confessor conhece o Vale e se cala dentro dele; os seis clipes da cutscene existem.
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
	game.message_title = ""
	game.message_text = ""
	game.player.has_weapon = true
	var c = game.confessor
	# o que o Confessor sabe
	var prompt: String = c.system_prompt()
	expect(prompt.contains("VALE DOS FLAGELADOS") and prompt.contains("Disciplinantes") and prompt.contains("Viúva da Lâmina"), "o Confessor conhece o Vale e as criaturas novas")
	expect(prompt.contains("Nunca diga quem é o Flagelado"), "regra de spoiler do Flagelado")
	expect(not prompt.contains("Edran"), "o Confessor não cita quem deu a ordem")
	expect(c.classify("o que tem no vale?") == "vale" and c.classify("como venço o flagelado") == "vale", "perguntas sobre o Vale caem no assunto vale")
	expect(c.classify("como mato o flagelante?") == "inimigos", "flagelante continua sendo inimigo comum")
	expect(c.classify("como ganho mais força?") != "vale", "força não é forca")
	expect(c.offline_answer("vale").contains("Guardião"), "antes do Guardião, o Vale ainda está guardado")
	game.boss_defeated = true
	game.memory_seen = true
	game.relic_taken = true
	game.exploration.bells.append("water")
	game.exploration.bells.append("vigil")
	expect(c.offline_answer("vale").contains("apare") and not c.offline_answer("vale").to_lower().contains("penitente"), "depois do Guardião, a dica do Vale não entrega o segredo")
	expect(c.suggestions().has("O que me espera no Vale?"), "pergunta pronta sobre o Vale")
	expect(c.state_context().contains("Vale dos Flagelados"), "o estado informa o Vale")
	# no Vale o Confessor se cala
	game.dev_teleport("vale")
	await frames(30)
	game.message_title = ""
	game.message_text = ""
	game.calm_t = 9.0
	expect(game.combat_reason().contains("Vale"), "no Vale há motivo para não confessar")
	expect(not game.try_open_confession() and not game.confession_open, "o Confessionário não abre no Vale")
	game.final_defeated = true
	expect(not game.combat_reason().contains("Vale"), "depois do fim, o Vale deixa de bloquear")
	expect(c.offline_answer("vale").contains("já lhe mostrou"), "depois do fim, o Confessor não repete o segredo")
	game.final_defeated = false
	# os seis clipes
	var f = ValeFinale.new()
	f.game = game
	game.finale = f
	game.add_child(f)
	await frames(2)
	expect(f.filme and f.videos.size() == 6, "os seis clipes da revelação estão no projeto")
	expect(game.combat_reason().contains("grade"), "durante a revelação o Confessionário não abre")
	print("V42_RESULT ", "PASS" if failures == 0 else "FAIL", " checks=", checks, " failures=", failures)
	quit(1 if failures > 0 else 0)
