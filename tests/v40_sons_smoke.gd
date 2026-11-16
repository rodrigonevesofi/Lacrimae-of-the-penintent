extends SceneTree
## Sons do Argon (v40): os nove efeitos do Vale tocam, a revelação tem música própria e a luta mantém a do chefe.
var checks := 0
var failures := 0
func _initialize() -> void: call_deferred("run")
func expect(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		print("FALHA: ", label)
func run() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	var sound = game.soundscape
	# ---- os nove efeitos do Vale: carregados, no formato do jogo e disparados pelo evento
	var duracoes := {"chefe_transforma": 1.2, "reflexo_devolve": 0.45, "gota_culpa": 0.5, "gota_recolhe": 0.5, "chefe_reza": 2.0, "placa_cai": 0.9, "chefe_ajoelha": 1.4, "capacete_sai": 1.6, "beatriz_chega": 1.2}
	for nome in sound.VALE_HOOKS:
		expect(sound.effects.has(nome), nome + ": carregado")
		if not sound.effects.has(nome): continue
		var voz: AudioStreamPlayer = sound.effects[nome]
		var onda: AudioStreamWAV = voz.stream
		expect(onda.mix_rate == 44100 and not onda.stereo, nome + ": 44,1 kHz, mono")
		expect(absf(onda.get_length() - float(duracoes[nome])) < 0.01, nome + ": duração pedida")
		sound.play_sfx(nome)
		expect(voz.playing and sound.played.get(nome, 0) > 0, nome + ": o evento toca")
	# ---- música (v41): a trilha do Lyria substituiu a sintetizada; ver tests/v41_trilha_smoke.gd
	expect(sound.music_streams.has("revelacao") and sound.music_streams.has("vale"), "revelação e Vale têm música própria")
	# ---- ambiências: dez salas e o Vale, em laço
	for sala in ["city", "ossuary", "cistern", "cloister", "belfry", "archive", "refuge", "nave", "terrace", "court", "vale"]:
		expect(ResourceLoader.exists("res://assets/audio/amb_%s.wav" % sala), "ambiência " + sala)
	# ---- famílias: toda variação sorteada existe
	for familia in ["swing", "dor", "jump", "hit_carne", "hit_metal", "step_pedra", "step_agua", "step_osso", "step_madeira", "lanca_estocada"]:
		for nome in sound.FAMILIES[familia]: expect(sound.effects.has(nome), familia + ": variação " + nome)
	print("V40_SONS: %d checks, %d failures" % [checks, failures])
	game.queue_free()
	await process_frame
	quit(1 if failures > 0 else 0)
