extends SceneTree
var game
var checks := 0
var failures := 0

func _initialize() -> void: call_deferred("run")

func expect(ok: bool, label: String) -> void:
	checks += 1
	print("PASS: " if ok else "FAIL: ", label)
	if not ok: failures += 1

func frames(n: int) -> void:
	for i in range(n):
		await physics_frame
		await process_frame

func quiet_enemies() -> void:
	for enemy in get_nodes_in_group("enemies"): enemy.set_physics_process(false)

func close_page() -> void:
	game.message_t = 0
	game.advance_message()
	await frames(2)

func interact_at(pos: Vector2) -> void:
	game.player.position = pos
	await frames(2)
	Input.action_press("interact")
	game._play_update(0.016)
	Input.action_release("interact")
	await frames(2)
	if game.narrative.mode == "memorial":
		game.narrative.elapsed = game.narrative.MEMORIAL_DURATION
		await frames(3)

func run() -> void:
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	expect(game.art != null and game.Story != null, "story initializes with world")
	game._start_game(false, false)
	for i in range(3): await close_page()
	quiet_enemies()
	game.player.has_weapon = true
	await interact_at(Vector2(990, 600))
	expect(game.message_text.contains("Chorai com os que choram"), "Iria retains the phrase within her own speech")
	expect(not game.message_text.contains("Romanos"), "Iria does not display biblical source labels")
	await close_page()
	var forbidden := RegEx.new()
	forbidden.compile("[0-9]+:[0-9]+|— (Mateus|João|Romanos|Dante)|Canto [IVX]+")
	var visible := ""
	for entry in game.lore: visible += str(entry.text) + "\n"
	for id in ["doll", "register", "vessel", "witness"]: visible += game.story_pickup_text(id, "") + "\n"
	for known in [false, true]:
		for honored in [false, true]:
			for page in game.Story.iria_pages(known, false, honored, false, false): visible += str(page.text) + "\n"
	expect(forbidden.search(visible) == null, "diegetic inscriptions and discoveries contain no chapter or verse labels")
	expect(game.lore[3].text.contains("Foi a justiça"), "gate inscription carries literary motif without author label")
	expect(game.story_pickup_text("doll", "").contains("sol") and game.story_pickup_text("register", "").contains("sol"), "doll and register share a physical clue")
	expect(game.story_pickup_text("register", "").contains("Alba"), "record supplies an individual identity")
	# Deixar a boneca primeiro não revela seu nome magicamente.
	game.doll_found = true
	var health: float = game.player.hp
	var guilt: float = game.player.culpa
	var money: int = game.player.lagrimas
	await interact_at(Vector2(2800, 600))
	expect(game.memorial_honored and not game.story_flags.has("memorial_named"), "doll can be left before identifying its owner")
	expect(not game.message_text.contains("Alba"), "early memorial does not reveal unknown name")
	await close_page()
	game.exploration.collected.append("register")
	await interact_at(Vector2(990, 600))
	expect(game.message_title == "IRIA — OS NOMES", "discovered register begins its own conversation")
	expect(not game.message_text.contains("não confunda"), "memorial response does not overwrite register conversation")
	expect(not game.story_flags.has("names_read"), "starting dialogue does not grant reading credit")
	await close_page()
	expect(game.message_title == "OS QUE ESPERARAM" and game.message_text.contains("Alba. Joana. Tomé."), "second page gives the names their own beat")
	expect(not game.story_flags.has("names_read"), "reading remains pending until the last page")
	await close_page()
	expect(game.message_text.contains("Escreva-o"), "earlier homage receives a new actionable follow-up")
	await close_page()
	expect(game.message_text.is_empty() and game.player.controllable, "final page returns control")
	expect(game.story_flags.has("names_read"), "completed conversation records reading once")
	var reminder = game.Story.iria_pages(true, true, false, false, false)
	expect(reminder[0].text.contains("Alba") and not reminder[0].text.contains("Condenado"), "completed reading retains recognition before the homage")
	await interact_at(Vector2(2800, 600))
	expect(game.story_flags.has("memorial_named") and game.message_text.contains("Alba"), "returning with evidence allows naming the memorial")
	expect(game.player.hp == health and game.player.culpa == guilt and game.player.lagrimas == money, "remembrance grants no healing, currency or automatic absolution")
	await close_page()
	await interact_at(Vector2(990, 600))
	expect(game.message_text.contains("Alba") and game.message_text.contains("não confunda"), "Iria recognizes the named memorial without granting forgiveness")
	await close_page()
	expect(game.knows_alba(), "two connected discoveries personalize the memory")
	expect(game.Story.memory_line(11, true).contains("Alba") and not game.Story.memory_line(11, false).contains("Alba"), "memory depends on what the player actually discovered")
	expect(not visible.contains("minha família") and not visible.contains("criou o ritual"), "Act I conversations preserve the later revelations")
	game._save()
	game.story_flags.clear()
	game._load()
	expect(game.story_flags.has("names_read") and game.story_flags.has("memorial_named"), "story decisions survive save and load")
	# Uma versão anterior não possui o campo story_flags; o restante do progresso deve persistir.
	var old_save = JSON.parse_string(FileAccess.get_file_as_string(game.SAVE_PATH))
	old_save.erase("story_flags")
	var file := FileAccess.open(game.SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(old_save))
	file.close()
	game._load()
	expect(game.story_flags.is_empty(), "older saves default narrative flags safely")
	expect(game.memorial_honored and game.doll_found and game.exploration.collected.has("register"), "older saves preserve objects and prior homage")
	var old_state: String = game.state
	game.story_chain_released("water")
	expect(game.toast_text.contains("mais dois") and game.state == old_state and game.message_text.is_empty(), "first chain adds a brief narrative beat without locking control")
	game.story_chain_released("vigil")
	expect(game.toast_text.contains("outro lado"), "second chain anticipates the gates rather than another counter")
	game.soundscape.set_process(false)
	game.player.set_physics_process(false)
	quiet_enemies()
	game.soundscape.ambience.stop()
	game.soundscape.incoming.stop()
	game.soundscape.guilt_layer.stop()
	for voice in game.soundscape.effects.values(): voice.stop()
	await create_timer(0.2).timeout
	game._delete_save()
	game.queue_free()
	await frames(4)
	print("STORY_SMOKE: %d checks, %d failures" % [checks, failures])
	quit(0 if failures == 0 else 1)
