extends SceneTree
## Acessibilidade das cenas de culpa: sons têm equivalentes visuais, cenas podem ser puladas e clarões são raros.
## Mede o comportamento dos scripts; não avalia a experiência das pessoas.
var game
var checks := 0
var failures := 0
var report: Array = []
func _initialize() -> void: call_deferred("run")
func expect(ok: bool,label: String) -> void:
	checks += 1
	print("PASS: " if ok else "FAIL: ",label)
	if not ok: failures += 1
func frames(n: int) -> void:
	for i in range(n):
		await physics_frame
		await process_frame

## Reproduz uma cena inteira em passos de 1/60 s e retorna {flashes: [tempos], peak: intensidade máxima do clarão}.
func play(mode: String,arg: int = 0) -> Dictionary:
	var n = game.narrative
	n.begin(mode,arg)
	var flashes: Array = []
	var peak := 0.0
	var previous := 0.0
	var steps := int((n.duration_of(mode) + 0.5) * 60.0)
	for i in range(steps):
		n._process(1.0 / 60.0)
		if n.flash > previous + 0.05: flashes.append(n.elapsed)
		previous = n.flash
		peak = maxf(peak,n.flash)
		if n.mode == "": break
	if n.mode != "": n.finish()
	return {"flashes": flashes, "peak": peak}

func max_per_second(times: Array) -> int:
	var worst := 0
	for t in times:
		var count := 0
		for u in times:
			if u >= t and u < t + 1.0: count += 1
		worst = maxi(worst,count)
	return worst

func run() -> void:
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	game._start_game(false,false)
	for i in range(3):
		game.message_t = 0
		game.advance_message()
	await frames(3)
	game.player.has_weapon = true
	var n = game.narrative
	var sound = game.soundscape
	var GuiltText = preload("res://scripts/guilt_text.gd")
	var narrative_source := FileAccess.get_file_as_string("res://scripts/narrative.gd")

	# Clarões: no máximo três por segundo, nunca branco em tela cheia.
	var scenes := [["echo",0],["echo",1],["echo",2],["memorial",0],["memorial",1],["memory",0],["boss_intro",0],["boss_end",0]]
	for entry in scenes:
		var result := play(entry[0],entry[1])
		var rate := max_per_second(result.flashes)
		report.append("%s %d: %d flashes, at most %d per second, peak strength %.2f" % [entry[0],entry[1],result.flashes.size(),rate,result.peak])
		expect(rate <= 3,"%s (%d) flashes at most three times per second" % [entry[0],entry[1]])
		expect(result.peak <= 0.2,"%s (%d) never flashes harder than a soft pulse" % [entry[0],entry[1]])
		if n.mode != "": n.finish()
	var memory := play("memory")
	expect(memory.flashes.size() == 3,"the memory flashes exactly once for each of its three knocks")

	# Pulo de cena: indisponível nos primeiros instantes e sempre com tempo de sobra.
	for mode in ["echo","memorial","memory","boss_intro","boss_end"]:
		n.begin(mode,0)
		n.elapsed = 0.4
		expect(not n.can_skip(),"%s cannot be skipped in its first half second" % mode)
		var found := -1.0
		for i in range(int(n.duration_of(mode) * 10.0)):
			n.elapsed = i / 10.0
			if n.can_skip():
				found = n.elapsed
				break
		expect(found >= 0.0 and found <= n.duration_of(mode) - 2.0,"%s becomes skippable at %.1f s, at least two seconds before its end" % [mode,found])
		report.append("%s: skippable from %.1f s of %.1f s" % [mode,found,n.duration_of(mode)])
		n.finish()
		if n.mode != "": n.finish()

	# Som com equivalente visual: todo som essencial tem texto ou clarão na tela.
	expect(GuiltText.echo_line(0).to_lower().contains("bate"),"the knocks of the first echo are described in text")
	expect(GuiltText.echo_line(1).to_lower().contains("abra"),"the voice of the second echo is written out")
	expect(GuiltText.echo_line(2).to_lower().contains("aqui"),"the murmur of the third echo is written out")
	expect(narrative_source.contains('"Abra."') and narrative_source.contains('"Ainda estamos aqui."'),"the voices of the memory appear as text on screen")
	expect(game.Story.chain_line("vigil").to_lower().contains("bat"),"the knocks after the high chain are announced in the toast")
	expect(narrative_source.contains("ÀQUELES QUE FICARAM DO OUTRO LADO"),"the muffled bell of the memorial has an on-screen title")
	expect(GuiltText.BOSS_INTRO.size() >= 2 and GuiltText.BOSS_END.size() >= 2,"the Guardian's scenes are captioned")
	var visual_knocks := true
	n.begin("memory")
	for t in n.MEMORY_KNOCKS:
		n.elapsed = t - 0.01
		n.knocks_done = n.MEMORY_KNOCKS.find(t)
		n._process(0.02)
		if n.flash <= 0.0: visual_knocks = false
	n.finish()
	expect(visual_knocks,"each knock of the memory also pulses the screen")

	var out := FileAccess.open("res://docs/acessibilidade-cenas-medidas.txt",FileAccess.WRITE)
	out.store_string("\n".join(report) + "\n")
	out.close()
	sound.set_process(false)
	sound.ambience.stop()
	sound.incoming.stop()
	sound.guilt_layer.stop()
	for voice in sound.effects.values(): voice.stop()
	game._delete_save()
	game.player.set_physics_process(false)
	await create_timer(0.2,true,false,true).timeout
	game.queue_free()
	game = null
	await frames(5)
	print("ACCESSIBILITY_PULSES: %d checks, %d failures" % [checks,failures])
	quit(0 if failures == 0 else 1)
