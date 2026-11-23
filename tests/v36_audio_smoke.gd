extends SceneTree
## Verifica os WAVs entregues e sua reprodução pelos eventos reais, sem alterar volumes.
var checks := 0
var failures := 0
func _initialize() -> void: call_deferred("run")
func expect(ok: bool, label: String) -> void:
	checks += 1
	print("PASS: " if ok else "FAIL: ",label)
	if not ok: failures += 1
func run() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	var sound = game.soundscape
	# v43: durações da tabela de docs/prompts-efeitos-sonoros-v43.md (efeitos gerados de novo).
	var durations := {"sangue_jato":0.5,"carne_rasga":0.4,"osso_quebra":0.3,"respingo_chao":0.25,"lamina_sai":0.5,"corpo_cai_carne":0.6,"corpo_cai_armadura":0.6,"esquiva_perfeita":0.5,"aviso_aparavel":0.4,"aviso_perigo":0.5,"execucao_impacto":0.9}
	for event in durations:
		var names: Array = sound.FAMILIES[event] if sound.FAMILIES.has(event) else [event]
		for name in names:
			expect(sound.effects.has(name), name + ": carregado pelo soundscape")
			if not sound.effects.has(name): continue
			var voice: AudioStreamPlayer = sound.effects[name]
			var stream: AudioStreamWAV = voice.stream
			expect(stream.mix_rate == 44100 and not stream.stereo and stream.format == AudioStreamWAV.FORMAT_16_BITS and absf(stream.get_length()-float(durations[event]))<0.015,name + ": PCM16 mono 44,1 kHz e duração correta")
			sound.play_sfx(name)
			expect(voice.playing and sound.played.get(name,0)>0,name + ": evento inicia reprodução")
		if sound.FAMILIES.has(event):
			var seen := {}
			var valid := true
			for i in range(128):
				var selected: String = sound.resolve(event)
				valid = valid and selected in names and sound.effects.has(selected)
				seen[selected] = true
			expect(valid,event + ": resolução usa somente variações entregues")
			expect(seen.size() == names.size(),event + ": todas as variações podem tocar")
	sound.toggle_mute()
	sound.play_sfx("aviso_perigo")
	expect(not sound.effects.aviso_perigo.playing,"silenciar interrompe e impede o novo aviso")
	sound.toggle_mute()
	sound.play_sfx("esquiva_perfeita")
	expect(sound.effects.esquiva_perfeita.playing,"reativar som permite a esquiva perfeita")
	game.queue_free()
	await process_frame
	await process_frame
	print("V36_AUDIO: %d checks, %d failures" % [checks,failures])
	quit(0 if failures == 0 else 1)
