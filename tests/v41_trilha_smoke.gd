extends SceneTree
## Trilha do Lyria (v41): nove faixas em OGG, em laço, uma por contexto; a música certa em cada momento.
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
	var sound = game.soundscape
	var registro: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://docs/trilha-v41.json"))
	var contextos := ["menu", "exploration", "combat", "boss", "story", "temple", "ending", "vale", "revelacao"]
	var vistos := {}
	for contexto in contextos:
		expect(sound.music_streams.has(contexto), contexto + ": carregada")
		var faixa = sound.music_streams.get(contexto)
		expect(faixa is AudioStreamOggVorbis, contexto + ": é a faixa nova em OGG")
		if not (faixa is AudioStreamOggVorbis): continue
		expect(faixa.loop, contexto + ": em laço")
		var dados: Dictionary = registro.faixas["ost_" + contexto]
		expect(absf(faixa.get_length() - float(dados.segundos_em_laco)) < 0.2, contexto + ": duração registrada")
		expect(faixa.get_length() > 80.0, contexto + ": faixa longa (mais de 80 s), não um trecho curto repetido")
		expect(float(dados.pico_final_db) <= -1.0 + 0.05, contexto + ": pico até -1 dB")
		vistos[faixa.get_instance_id()] = true
	expect(vistos.size() == 9, "nove faixas diferentes")
	# hierarquia de volume: luta mais alta que exploração e menu
	var f: Dictionary = registro.faixas
	expect(float(f.ost_boss.volume_final_db) > float(f.ost_exploration.volume_final_db) + 3.0 and float(f.ost_combat.volume_final_db) > float(f.ost_menu.volume_final_db) + 2.0, "a música de luta é mais alta que a de exploração e a de menu")
	# as salas que tinham tema sintetizado usam a trilha nova
	expect(sound.music_streams["nave"] == sound.music_streams["temple"], "Nave do Silêncio usa o canto do templo")
	expect(sound.music_streams["terraco"] == sound.music_streams["exploration"] and sound.music_streams["patio"] == sound.music_streams["exploration"], "Terraço e Pátio usam a exploração")
	# trocar entre dois contextos com a mesma faixa não recomeça a música
	game._start_game(false, false)
	await frames(10)
	sound.music_context = "exploration"
	sound.switching = false
	sound.change_context("terraco")
	expect(sound.music_context == "terraco" and not sound.switching, "exploração -> Terraço: a música segue sem recomeçar")
	sound.change_context("boss")
	expect(sound.switching and sound.incoming.stream == sound.music_streams["boss"], "exploração -> chefe: troca de faixa")
	# no Vale: luta com a música do Vale, revelação com a dela
	expect(sound.music_streams.has("vale") and sound.music_streams.has("revelacao"), "Vale e revelação têm música própria")
	print("V41_TRILHA: %d checks, %d failures" % [checks, failures])
	game._delete_save()
	game.queue_free()
	await frames(3)
	quit(1 if failures > 0 else 0)
