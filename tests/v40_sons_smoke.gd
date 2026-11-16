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
	# ---- música: a revelação tem a sua; a luta no Vale continua com a do chefe (a música do Vale não foi integrada)
	expect(sound.music_streams.has("revelacao"), "música da revelação carregada")
	expect(not sound.music_streams.has("vale"), "sem música própria do Vale: a luta usa a do chefe")
	var rev: AudioStreamWAV = sound.music_streams["revelacao"]
	expect(rev.stereo and rev.loop_mode == AudioStreamWAV.LOOP_FORWARD and absf(rev.get_length() - 60.0) < 0.01, "revelação: estéreo, em laço, 60 s")
	# ---- as músicas antigas, com notas, continuam sendo sete e diferentes entre si
	var tamanhos := {}
	for contexto in ["menu", "exploration", "combat", "boss", "story", "temple", "ending"]:
		expect(sound.music_streams.has(contexto), "música " + contexto)
		tamanhos[sound.music_streams[contexto].data.hex_encode().substr(0, 4000)] = true
	expect(tamanhos.size() == 7, "sete músicas diferentes entre si")
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
