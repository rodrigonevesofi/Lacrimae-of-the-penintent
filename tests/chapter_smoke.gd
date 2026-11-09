extends SceneTree
## Run with a disposable XDG_DATA_HOME. This suite creates and removes its save.
var failures := 0
var checks := 0
var capture := false
var game

func _initialize() -> void:
	capture = "--capture" in OS.get_cmdline_user_args()
	call_deferred("run")

func expect(condition: bool, description: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error("FAIL: " + description)
	else:
		print("PASS: " + description)

func frames(count: int) -> void:
	for i in range(count):
		await physics_frame
		await process_frame

func screenshot(name: String) -> void:
	if not capture:
		return
	await process_frame
	await RenderingServer.frame_post_draw
	var path := "res://artifacts/" + name + ".png"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://artifacts"))
	var result := root.get_texture().get_image().save_png(path)
	expect(result == OK, "screenshot " + name)

func interact() -> void:
	Input.action_press("interact")
	game._play_update(0.016)
	Input.action_release("interact")
	await frames(2)

func close_dialogue() -> void:
	game.message_t = 0
	game.advance_message()
	await frames(2)

func run() -> void:
	# Refuse to delete progress from a previous or player-owned save.
	if FileAccess.file_exists("user://lacrimae_save.json"):
		push_error("Use a fresh disposable XDG_DATA_HOME; a save already exists.")
		quit(2)
		return
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await frames(3)
	expect(game.state == "title" and not game.player.controllable, "title locks player input")
	expect(game.player.appearance != null and game.player.appearance.atlas != null, "player uses illustrated character atlas")
	expect(game.soundscape.ambience.playing and game.soundscape.ambience.stream.stereo, "stereo score starts automatically")
	expect(game.soundscape.effects.size() == 26, "twenty-six action, cinematic and creature effects are loaded")
	game.player.culpa = 100
	game.state = "play"
	game.soundscape._process(4)
	expect(game.soundscape.guilt_layer.volume_db >= -5, "high guilt raises dissonant music layer")
	game.player.culpa = 0
	game.state = "title"
	game.soundscape.toggle_mute()
	expect(game.soundscape.muted and game.soundscape.ambience.volume_db == -80, "mute silences music")
	game.soundscape.toggle_mute()
	expect(not game.soundscape.muted and game.soundscape.ambience.volume_db == -3, "unmute restores music volume")
	await screenshot("01-title")
	game._start_game(false)
	expect(game.narrative.mode == "opening" and not game.player.controllable, "new game starts cinematic before control")
	game.narrative.finish()
	expect(game.prologue_page == 1, "cinematic continues into tomb inscription")
	game._start_game(false, false)
	await frames(3)
	expect(game.prologue_page == 0 and not game.player.controllable, "new game opens canonical prologue")
	expect(not game.player.has_weapon and game.player.position.x < game.SWORD_POS.x, "start unarmed at tomb")
	game.player._start_attack()
	expect(game.player.state != "attack", "cannot attack before picking up sword")
	await screenshot("02-prologue")
	await close_dialogue()
	expect(game.message_title == "A INSCRIÇÃO", "burial inscription is second prologue page")
	await close_dialogue()
	await close_dialogue()
	expect(game.message_text == "" and game.player.controllable, "closing prologue enables exploration")
	expect(get_nodes_in_group("enemies").size() == game.enemy_defs.size() + game.exploration.Layout.enemies().size() + 1, "all room encounters and one boss exist")
	game.player.invuln = 0
	await screenshot("03-crypt")
	var initial_x: float = game.player.position.x
	Input.action_press("right")
	await frames(24)
	Input.action_release("right")
	expect(game.player.position.x > initial_x + 50, "movement uses physics input")
	game.player.position = game.SWORD_POS
	await frames(3)
	await interact()
	expect(game.player.has_weapon and game.message_title == "A ESPADA DIANTE DO TÚMULO", "interaction acquires sword")
	expect(FileAccess.file_exists("user://lacrimae_save.json"), "sword acquisition saves progression")
	await close_dialogue()
	game.player._start_attack()
	expect(game.player.state == "attack", "sword enables combat")
	expect(game.soundscape.effects["swing"].playing, "attack triggers sword sound")
	await frames(24)
	var enemy = get_nodes_in_group("enemies")[0]
	enemy.position = game.player.position + Vector2(50, 0)
	var enemy_hp: float = enemy.hp
	game.player.facing = 1
	game.player.hit_list.clear()
	game.player._attack_hits()
	expect(enemy.hp < enemy_hp, "sword hit damages an enemy")
	# Enemies are tougher now: leave this one at the edge of death so the penance is what finishes it.
	enemy.hp = minf(enemy.hp, 30.0)
	game.player.culpa = 60
	game.player._do_penance()
	expect(game.player.culpa == 8 and game.player.penance_fx > 0 and enemy.dead, "penance spends guilt; defeating enemy adds 8 new guilt")
	game.player.position = game.altars[0]
	game.player.hp = 30
	game.player.flasks = 1
	game.player.state = "idle"
	game._pray(0)
	await frames(3)
	expect(game.player.hp == 30 and game.narrative.mode == "prayer", "altar waits for prayer completion before healing")
	game.narrative.elapsed = game.narrative.PRAYER_DURATION
	game.narrative._process(0)
	await frames(3)
	expect(game.player.hp == game.player.max_hp and game.player.flasks == 3, "altar restores health and healing charges")
	game.player.lagrimas = 150
	game.player.state = "idle"
	Input.action_press("offer")
	game._play_update(0.016)
	Input.action_release("offer")
	expect(game.player.upgrades == 1 and game.player.max_hp == 115 and game.player.lagrimas == 50, "altar offering spends tears and increases max health")
	game._take_relic()
	expect(game.player.has_double_jump and game.relic_taken, "relic grants double jump")
	await close_dialogue()
	game.player.position = Vector2(990, 600)
	await frames(2)
	await interact()
	expect(game.iria_met and game.message_title == "IRIA — A TESTEMUNHA", "Iria can be encountered")
	await close_dialogue()
	game.exploration.travel("refuge",Vector2(20030,280))
	for e in get_nodes_in_group("enemies"): e.set_physics_process(false)
	await frames(2)
	await interact()
	expect(game.doll_found and game.player.blood_tears > 0, "optional doll triggers narrative blood tears")
	await close_dialogue()
	game.player.lagrimas = 123
	game._save()
	game._start_game(true)
	await frames(4)
	expect(game.player.has_weapon and game.player.has_double_jump and game.player.lagrimas == 123 and game.player.max_hp == 115, "continue restores equipment and progression")
	expect(game.iria_met and game.doll_found, "save preserves NPC encounter and optional story item")
	game.player.revive(Vector2(1975, 600))
	game.player.invuln = 10
	await frames(3)
	Input.action_press("right")
	Input.action_press("jump")
	await frames(19)
	Input.action_release("jump")
	await frames(2)
	Input.action_press("jump")
	await frames(48)
	Input.action_release("jump")
	Input.action_release("right")
	print("ABYSS landing: ", game.player.position, " air jumps: ", game.player.air_jumps)
	expect(game.player.position.x > 2270 and game.player.position.y < 650, "double jump crosses monastery abyss using physics input")
	game.player.position = Vector2(1670, 360)
	game.player.camera.reset_smoothing()
	await frames(4)
	game.toast_t = 0
	game.player.invuln = 0
	await screenshot("04-monastery")
	var before_pause: Vector2 = game.player.position
	game.toggle_pause()
	await create_timer(0.08, true).timeout
	expect(game.player.position == before_pause and paused, "pause freezes gameplay")
	await screenshot("05-pause")
	game.toggle_pause()
	game.player.position = Vector2(310, 600)
	game.player.lagrimas = 75
	game.player.invuln = 0
	game.player.take_hit(1000, 200)
	expect(game.state == "dead", "lethal damage enters death state")
	game._respawn()
	await frames(3)
	expect(game.player.lagrimas == 0 and game.stain_amount == 75, "death drops carried tears")
	game.player.position = game.stain_pos
	game._play_update(0.016)
	expect(game.player.lagrimas == 75 and game.stain_amount == 0, "returning recovers dropped tears")
	expect(game.narrative.mode == "echo", "the first recovery plays a short guilt scene")
	game.narrative.finish()
	game.exploration.bells = ["water","vigil"]
	game.exploration.update_gate()
	game.player.position = Vector2(3950, 600)
	await frames(4)
	expect(game.boss.awake and game.boss_wall != null, "entering arena awakens boss and closes gate")
	expect(game.narrative.mode == "boss_intro", "the Guardian arrives in a short scene, rope first")
	game.narrative.finish()
	await screenshot("06-basilica")
	game.boss.take_hit(10000, game.player.position.x)
	await frames(4)
	expect(game.boss_defeated and game.ending_countdown > 0, "boss defeat starts chapter completion")
	expect(game.narrative.mode == "boss_end", "the Guardian falls in silence first")
	game.narrative.elapsed = game.narrative.BOSS_END_DURATION
	game.narrative._process(0.0)
	expect(not game.memory_seen and game.narrative.mode == "memory", "guardian defeat reveals a memory")
	game.narrative.finish()
	game.ending_countdown = 0.01
	game._play_update(0.02)
	expect(game.state == "play", "boss victory leaves side routes available for exploration")
	game.player.position = Vector2(4700,600)
	await interact()
	expect(game.state == "ending", "player explicitly chooses to close chapter at the gates")
	game.ending_t = 17
	await screenshot("07-chapter-end")
	game._start_game(true)
	await frames(3)
	expect(game.state == "play" and game.boss_defeated, "completed chapter resumes exploration from saved progress")
	game._delete_save()
	game.soundscape.set_process(false)
	game.soundscape.incoming.stop()
	game.soundscape.ambience.stop()
	game.soundscape.guilt_layer.stop()
	for voice in game.soundscape.effects.values():
		voice.stop()
	await create_timer(0.15).timeout
	game.queue_free()
	game = null
	enemy = null
	await frames(4)
	print("CHAPTER_SMOKE: %d checks, %d failures" % [checks, failures])
	quit(0 if failures == 0 else 1)
