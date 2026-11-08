extends SceneTree
## Independent review: reverse discovery order and interrupted conversation saves.
## Run with a dedicated XDG_DATA_HOME; this test creates/deletes its own save.
var game
var checks := 0
var failures := 0

func _initialize() -> void: call_deferred("run")

func expect(ok: bool, label: String) -> void:
	checks += 1
	print("PASS: " if ok else "FAIL: ", label)
	if not ok: failures += 1

func settle() -> void:
	await physics_frame
	await process_frame

func freeze_combat() -> void:
	game.set_process(false)
	game.player.set_physics_process(false)
	for enemy in get_nodes_in_group("enemies"): enemy.set_physics_process(false)

func close_page() -> void:
	game.message_t = 0
	game.advance_message()

func interact_at(pos: Vector2) -> void:
	game.player.position = pos
	await settle()
	Input.action_press("interact")
	game._play_update(0.016)
	Input.action_release("interact")
	await settle()
	if game.narrative.mode == "memorial":
		game.narrative.elapsed = game.narrative.MEMORIAL_DURATION
		await settle()

func run() -> void:
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	game._start_game(false, false)
	freeze_combat()
	for i in range(3): close_page()
	game.player.has_weapon = true
	game.exploration.collected.append("register")
	expect(not game.knows_alba(), "register alone does not identify the child in the gate memory")
	await interact_at(Vector2(990, 600))
	expect(game.message_title == "IRIA — OS NOMES", "register first opens the names conversation")
	close_page()
	expect(game.message_title == "OS QUE ESPERARAM", "interruption occurs during the actual names page")
	game._save()
	game._start_game(true, false)
	freeze_combat()
	expect(not game.story_flags.has("names_read"), "interrupted reading is not saved as completed")
	expect(game.dialogue_pages.is_empty() and game.dialogue_complete_flag.is_empty(), "continue clears transient conversation pages and completion credit")
	await interact_at(Vector2(990, 600))
	expect(game.message_title == "IRIA — OS NOMES", "interrupted reading can restart after continue")
	for i in range(3): close_page()
	expect(game.story_flags.has("names_read") and game.message_text.is_empty(), "restarted conversation completes and releases control")
	game.doll_found = true
	game.exploration.collected.append("doll")
	expect(game.knows_alba(), "finding the doll second completes the physical identification")
	await interact_at(Vector2(2800, 600))
	expect(game.memorial_honored and game.story_flags.has("memorial_named"), "register first names memorial in the initial deposit")
	close_page()
	game._save()
	game._start_game(true, false)
	freeze_combat()
	expect(game.knows_alba() and game.story_flags.has("names_read") and game.story_flags.has("memorial_named"), "continue retains reverse-order investigation")
	await interact_at(Vector2(2800, 600))
	expect(game.message_text.is_empty(), "completed memorial does not offer duplicate deposit")
	await interact_at(Vector2(990, 600))
	expect(game.message_text.contains("Alba") and game.message_text.contains("não confunda"), "loaded result recognizes Alba without granting forgiveness")
	close_page()
	var lines := ""
	for register in [false, true]:
		for read_names in [false, true]:
			for honored in [false, true]:
				for named in [false, true]:
					for memory in [false, true]:
						for page in game.Story.iria_pages(register, read_names, honored, named, memory):
							lines += str(page.text) + "\n"
	expect(not lines.contains("minha família") and not lines.contains("implorou para esquecer") and not lines.contains("criou o ritual"), "Iria variants do not expose later canonical revelations")
	game.soundscape.set_process(false)
	game.soundscape.ambience.stop()
	game.soundscape.incoming.stop()
	game.soundscape.guilt_layer.stop()
	for voice in game.soundscape.effects.values(): voice.stop()
	await create_timer(0.2).timeout
	game._delete_save()
	game.queue_free()
	for i in range(4): await settle()
	print("STORY_REVIEW_SMOKE: %d checks, %d failures" % [checks, failures])
	quit(0 if failures == 0 else 1)
