extends Node
## Trilha estéreo original composta e efeitos de ação polifônicos separados.
var incoming: AudioStreamPlayer
var music_context := "menu"
var transition_context := ""
var fade_elapsed := 0.0
var switching := false
var context_timer := 0.0
var music_streams: Dictionary = {}
var guilt_layer: AudioStreamPlayer
var ambience: AudioStreamPlayer
var effects: Dictionary = {}
var muted := false
var knock_count := 0
## Ajustes de mixagem em dB, somados ao nível base de cada grupo. Começam em zero de propósito: a auditoria dos
## volumes (docs/auditoria-volume.md) propôs ajustes, mas eles foram medidos nos arquivos, sem ouvir durante o jogo.
## Após a escuta, reajustar a mixagem exige apenas alterar estes quatro números.
## v43: medido numa luta de 14 s (tools/medir_mixagem.gd), os efeitos estavam em -8,4 LUFS e a música em -23,2:
## a trilha sumia. Agora a música sobe 8 dB, os efeitos descem 6 e o limitador não soma mais 3 dB a tudo.
## Alvo: música perto de -18 LUFS e efeitos de luta logo acima dela.
const MIX_TRIM_DB := {"tracks": 9.0, "action": -10.0, "scene": -3.0, "creature": -8.0, "ambience": -1.0}
## Sons que se repetem muito numa luta (respingos, jatos) descem mais, para não virar uma parede de ruído.
const TRIM_NOME := {"respingo_chao": -6.0, "sangue_jato": -3.0, "carne_rasga": -3.0, "step": -2.0, "osso_quebra": -2.0}

func trim_nome(name: String) -> float:
	for chave in TRIM_NOME:
		if name.begins_with(chave): return float(TRIM_NOME[chave])
	return 0.0
const SCENE_SFX := ["altar", "bell", "breath", "knock", "murmurio_01", "murmurio_02", "murmurio_03", "corrente_cede", "sino_surdo"]

func trim_for(name: String) -> float:
	if CREATURE_SFX.has(name): return MIX_TRIM_DB.creature
	if SCENE_SFX.has(name): return MIX_TRIM_DB.scene
	return MIX_TRIM_DB.action

const CREATURE_SFX := ["devorador_rugido", "devorador_bote", "flagelante_chicote", "flagelante_investida", "bruxa_sussurro", "bruxa_leque", "asmodeia_aviso", "asmodeia_estilhaco", "duelista_cacete"]
## Sons de eventos antes silenciosos. Cada um só é carregado se o arquivo existir, deixando os pontos de integração
## prontos antes dos sons: assim que um arquivo com esse nome chega a assets/audio/, ele toca.
## Pontos de áudio do combate e da dupla; os arquivos fornecidos na v32 ativam esses eventos.
## Mantidos separados de HOOK_NAMES por compatibilidade com pacotes anteriores.
const PENDING_HOOKS := ["golpe_carregado_carga", "golpe_carregado_solta", "mergulho_impacto", "arremate", "empalar", "sangue_compartilhado", "caido", "levanta"]
## O Argon entrega estes WAV separadamente; a ausência deles preserva os sons atuais.
const GORE_HOOKS := ["lamina_sai", "corpo_cai_carne", "corpo_cai_armadura", "esquiva_perfeita", "aviso_aparavel", "aviso_perigo", "execucao_impacto"]
## A luta final e a revelação no Vale dos Flagelados. Mudos até os arquivos chegarem (ver prompts-sons-vale-argon.md).
const VALE_HOOKS := ["chefe_transforma", "reflexo_devolve", "gota_culpa", "gota_recolhe", "chefe_reza", "placa_cai", "chefe_ajoelha", "capacete_sai", "beatriz_chega"]
## Músicas opcionais: a luta no Vale e a revelação. Sem os arquivos, tocam a do chefe e a de história.
const OPTIONAL_MUSIC := ["vale", "revelacao"]
## v43: golpes e mortes novos. Enquanto o arquivo não chega, toca o som parecido mais próximo (SUBSTITUTOS).
const V43_HOOKS := ["investida", "corte_ascendente", "lamina_sangue", "bloqueio", "decapitacao", "corpo_partido", "coracao_arrancado", "cranio_esmagado", "lagrima_coleta", "oferenda"]
const SUBSTITUTOS := {"investida": "esquiva_perfeita", "corte_ascendente": "swing", "lamina_sangue": "golpe_carregado_solta", "bloqueio": "hit_metal", "decapitacao": "osso_quebra", "corpo_partido": "carne_rasga", "coracao_arrancado": "carne_rasga", "cranio_esmagado": "osso_quebra", "lagrima_coleta": "coleta", "oferenda": "altar"}
const HOOK_NAMES := ["morte", "morte_grande", "chefe_morte", "chefe_pancada", "dor", "aterrissagem", "coleta", "porta", "projetil", "projetil_impacto", "espinho", "aparo", "execucao", "portao_fecha", "portao_abre", "ui_mover", "ui_confirmar"]
## Os sons narrativos são sempre reproduzidos da mesma forma; os demais variam um pouco em altura e volume.
const FIXED_SFX := ["altar", "bell", "breath", "knock", "murmurio_01", "murmurio_02", "murmurio_03", "corrente_cede", "sino_surdo"]
## Famílias de variações: uma solicitação por nome escolhe aleatoriamente uma de suas gravações.
const FAMILIES := {
	"jump": ["jump_01", "jump_02", "jump_03"],
	"lanca_estocada": ["lanca_estocada_01", "lanca_estocada_02", "lanca_estocada_03"],
	"hit_carne": ["hit_carne_01", "hit_carne_02", "hit_carne_03"],
	"hit_metal": ["hit_metal_01", "hit_metal_02", "hit_metal_03"],
	"dor": ["dor", "dor_01", "dor_02", "dor_03"],
	"morte": ["morte", "morte_01", "morte_02", "morte_03"],
	"swing": ["swing", "swing_01", "swing_02", "swing_03"],
	"sangue_jato": ["sangue_jato_01", "sangue_jato_02", "sangue_jato_03"],
	"carne_rasga": ["carne_rasga_01", "carne_rasga_02", "carne_rasga_03"],
	"osso_quebra": ["osso_quebra_01", "osso_quebra_02", "osso_quebra_03"],
	"respingo_chao": ["respingo_chao_01", "respingo_chao_02", "respingo_chao_03", "respingo_chao_04"],
	"step_pedra": ["step_pedra_01", "step_pedra_02", "step_pedra_03", "step_pedra_04"],
	"step_madeira": ["step_madeira_01", "step_madeira_02", "step_madeira_03"],
	"step_agua": ["step_agua_01", "step_agua_02", "step_agua_03"],
	"step_osso": ["step_osso_01", "step_osso_02", "step_osso_03"],
}
## O som de cada sala vem da cena dela (scenes/salas/<id>.tscn, grupo Som do Inspetor), lido em _ler_salas():
## reverberação (quanto da cauda acústica da sala os efeitos carregam), superfície dos passos, música fora de
## combate e laço de ambiente.
const Layout = preload("res://scripts/act_one_layout.gd")
## Músicas de sala com faixa própria: valem mesmo no começo da Cidade, antes do canto do templo.
const TRILHAS_PROPRIAS := ["nave", "terraco", "patio"]
var room_space := {}
var room_surface := {}
var room_music := {}
var room_ambience := {}
## Até onde (x do mundo) toca o canto do templo: a borda direita da zona musica_do_templo da Cidade.
var temple_until := 0.0
var beds: Array = []
var bed_streams := {}
var bed_room := "-"
var bed_mix := 1.0
var played := {}
var last_time := {}
var base_db := {}
var reverb: AudioEffect

func _build_buses() -> void:
	for bus_name in ["Music", "Ambience", "SFX"]:
		if AudioServer.get_bus_index(bus_name) == -1:
			AudioServer.add_bus()
			var index := AudioServer.bus_count - 1
			AudioServer.set_bus_name(index, bus_name)
			AudioServer.set_bus_send(index, "Master")
	# Um limitador na saída principal impede que momentos intensos (combates acumulam sons) ultrapassem o nível máximo.
	var master := AudioServer.get_bus_index("Master")
	if AudioServer.get_bus_effect_count(master) == 0:
		var limiter: AudioEffect = ClassDB.instantiate("AudioEffectHardLimiter") if ClassDB.class_exists("AudioEffectHardLimiter") else AudioEffectLimiter.new()
		limiter.set("ceiling_db", -1.0)
		limiter.set("pre_gain_db", 0.0)
		AudioServer.add_bus_effect(master, limiter)
	var sfx := AudioServer.get_bus_index("SFX")
	if AudioServer.get_bus_effect_count(sfx) == 0:
		var room_reverb := AudioEffectReverb.new()
		room_reverb.room_size = 0.6
		room_reverb.damping = 0.55
		room_reverb.dry = 1.0
		room_reverb.wet = 0.1
		AudioServer.add_bus_effect(sfx, room_reverb)
		reverb = room_reverb
	else:
		reverb = AudioServer.get_bus_effect(sfx, 0)

const EFFECT_NAMES := ["step", "swing", "hit", "hurt", "roll", "jump", "heal", "altar", "death", "bell", "breath", "knock", "murmurio_01", "murmurio_02", "murmurio_03", "corrente_cede", "sino_surdo", "devorador_rugido", "devorador_bote", "flagelante_chicote", "flagelante_investida", "bruxa_sussurro", "bruxa_leque", "asmodeia_aviso", "asmodeia_estilhaco", "duelista_cacete"]

func _ler_salas() -> void:
	var salas := Layout.rooms()
	for id in salas:
		var som: Dictionary = salas[id].sound
		room_space[id] = som.reverb
		room_surface[id] = som.steps
		room_music[id] = som.music
		if not str(som.ambience).is_empty(): room_ambience[id] = som.ambience
	temple_until = Layout.zona("musica_do_templo").end.x

func _ready() -> void:
	_ler_salas()
	_build_buses()
	ambience = AudioStreamPlayer.new()
	ambience.bus = "Music"
	for context in ["menu", "exploration", "temple", "combat", "boss", "story", "ending", "nave", "terraco", "patio"]:
		music_streams[context] = _carregar_musica(context)
	for context in OPTIONAL_MUSIC:
		var extra := _carregar_musica(context)
		if extra != null: music_streams[context] = extra
	# Com a trilha nova, as três salas que tinham tema próprio passam a usar a mesma família de música:
	# a Nave do Silêncio fica com o canto do templo; o Terraço e o Pátio, com a exploração.
	if music_streams["exploration"] is AudioStreamOggVorbis:
		music_streams["terraco"] = music_streams["exploration"]
		music_streams["patio"] = music_streams["exploration"]
	if music_streams["temple"] is AudioStreamOggVorbis:
		music_streams["nave"] = music_streams["temple"]
	var music: AudioStream = music_streams["menu"]
	ambience.stream = music
	ambience.volume_db = -3
	add_child(ambience)
	ambience.play()
	incoming = AudioStreamPlayer.new()
	incoming.bus = "Music"
	add_child(incoming)
	guilt_layer = AudioStreamPlayer.new()
	guilt_layer.bus = "Music"
	var guilt: AudioStreamWAV = load("res://assets/audio/guilt.wav")
	guilt.loop_mode = AudioStreamWAV.LOOP_FORWARD
	guilt.loop_end = guilt.data.size() / 2
	guilt_layer.stream = guilt
	guilt_layer.volume_db = -80
	add_child(guilt_layer)
	guilt_layer.play()
	# A textura sonora de cada lugar, um ciclo longo sob a música.
	for room in room_ambience:
		var path := "res://assets/audio/%s.wav" % room_ambience[room]
		if ResourceLoader.exists(path):
			var bed: AudioStreamWAV = load(path)
			bed.loop_mode = AudioStreamWAV.LOOP_FORWARD
			bed.loop_begin = 0
			bed.loop_end = bed.data.size() / 4
			bed_streams[room] = bed
	for i in range(2):
		var layer := AudioStreamPlayer.new()
		layer.bus = "Ambience"
		layer.volume_db = -80
		add_child(layer)
		beds.append(layer)
	var every_effect: Array = EFFECT_NAMES.duplicate()
	for hook in HOOK_NAMES + PENDING_HOOKS + GORE_HOOKS + VALE_HOOKS + V43_HOOKS:
		if ResourceLoader.exists("res://assets/audio/%s.wav" % hook): every_effect.append(hook)
	for family in FAMILIES.values():
		for variant in family:
			if not every_effect.has(variant) and ResourceLoader.exists("res://assets/audio/%s.wav" % variant): every_effect.append(variant)
	for name in every_effect:
		var voice := AudioStreamPlayer.new()
		voice.bus = "SFX"
		voice.stream = load("res://assets/audio/%s.wav" % name)
		voice.max_polyphony = 6
		voice.volume_db = (-7 if name.begins_with("step") else (-8 if name.begins_with("murmurio") else (-4 if CREATURE_SFX.has(name) else -2))) + trim_for(name) + trim_nome(name)
		base_db[name] = voice.volume_db
		add_child(voice)
		effects[name] = voice

## Gravação que atende à solicitação: uma variação da família ou, para passos, a superfície sob os pés.
func resolve(name: String) -> String:
	var family := name
	var game = get_parent()
	if name == "step" and game != null and game.exploration != null: family = room_surface.get(game.exploration.room, "step")
	if FAMILIES.has(family):
		var options: Array = []
		for variant in FAMILIES[family]:
			if effects.has(variant): options.append(variant)
		if not options.is_empty(): return options[randi() % options.size()]
	if not effects.has(name) and SUBSTITUTOS.has(name) and not FAMILIES.has(name): return resolve(SUBSTITUTOS[name])
	if not effects.has(name) and name.begins_with("hit_"): return "hit"
	if not effects.has(name) and name == "lanca_estocada": return "swing"
	return name

func play_sfx(request: String) -> void:
	if request == "knock": knock_count += 1
	played[request] = int(played.get(request, 0)) + 1
	var name := resolve(request)
	if muted or not effects.has(name):
		return
	var voice: AudioStreamPlayer = effects[name]
	var varied: bool = not FIXED_SFX.has(name)
	voice.pitch_scale = randf_range(0.94, 1.06) if varied else 1.0
	voice.volume_db = float(base_db.get(name, -2.0)) + (randf_range(-1.2, 1.2) if varied else 0.0)
	voice.play()

## Som localizado no mundo: vem da esquerda ou direita do penitente e diminui com a distância.
func _update_beds(game, delta: float) -> void:
	if beds.size() < 2:
		return
	var room: String = game.exploration.room if game.exploration != null and game.state != "title" else ""
	if room != bed_room:
		bed_room = room
		var fresh: AudioStreamPlayer = beds[1]
		beds[1] = beds[0]
		beds[0] = fresh
		if bed_streams.has(room):
			fresh.stream = bed_streams[room]
			fresh.play(randf() * 20.0)
		else:
			fresh.stop()
		bed_mix = 0.0
	bed_mix = minf(bed_mix + delta / 1.6, 1.0)
	var level: float = -9.0 + float(MIX_TRIM_DB.ambience)
	if game.narrative != null and game.narrative.mode != "": level -= 14.0
	beds[0].volume_db = -80.0 if muted or not beds[0].playing else level + linear_to_db(maxf(bed_mix, 0.001))
	beds[1].volume_db = -80.0 if muted or not beds[1].playing else level + linear_to_db(maxf(1.0 - bed_mix, 0.001))
	if bed_mix >= 1.0 and beds[1].playing: beds[1].stop()

func play_sfx_at(request: String, pos: Vector2) -> void:
	played[request] = int(played.get(request, 0)) + 1
	var name := resolve(request)
	if muted or not effects.has(name):
		return
	var now := Time.get_ticks_msec()
	if now - int(last_time.get(name, 0)) < 70:
		return
	last_time[name] = now
	var base: AudioStreamPlayer = effects[name]
	var voice := AudioStreamPlayer2D.new()
	voice.stream = base.stream
	voice.bus = "SFX"
	voice.volume_db = float(base_db.get(name, -2.0)) + randf_range(-1.2, 1.2)
	voice.pitch_scale = randf_range(0.94, 1.06)
	voice.max_distance = 1100.0
	voice.attenuation = 1.3
	get_parent().add_child(voice)
	voice.global_position = pos
	voice.finished.connect(voice.queue_free)
	voice.play()

## Três batidas do outro lado da pedra. Param antes que alguém possa dizer de onde vieram.
func play_knocks(delay: float = 0.9) -> void:
	await get_tree().create_timer(delay).timeout
	for i in range(3):
		if i > 0: await get_tree().create_timer(0.62).timeout
		play_sfx("knock")
		if not get_parent().reduced_pulses: get_tree().call_group("game", "shake_cam", 2.5)

func chime() -> void:
	play_sfx("altar")

func toggle_mute() -> void:
	muted = not muted
	ambience.volume_db = -80 if muted else -3
	incoming.volume_db = -80
	if muted:
		guilt_layer.volume_db = -80
		for voice in effects.values():
			voice.stop()

## Carrega a música de um contexto. A trilha nova (v41) vem em OGG, em laço; se não houver, vale o WAV antigo.
func _carregar_musica(context: String) -> AudioStream:
	var ogg := "res://assets/audio/ost_%s.ogg" % context
	if ResourceLoader.exists(ogg):
		var faixa: AudioStreamOggVorbis = load(ogg)
		faixa.loop = true
		return faixa
	var wav := "res://assets/audio/ost_%s.wav" % context
	if not ResourceLoader.exists(wav): return null
	var track: AudioStreamWAV = load(wav)
	track.loop_mode = AudioStreamWAV.LOOP_FORWARD
	track.loop_begin = 0
	track.loop_end = track.data.size() / 4
	return track

func desired_context() -> String:
	var game = get_parent()
	if game.state == "title": return "menu"
	if game.narrative != null and game.narrative.mode != "":
		return "temple" if game.narrative.mode == "prayer" else "story"
	if game.state == "ending": return "ending"
	if game.exploration != null and game.exploration.room == "vale":
		# No Vale: a revelação e a luta final têm músicas próprias, quando existem.
		if game.get("finale") != null and is_instance_valid(game.finale):
			return "revelacao" if music_streams.has("revelacao") else "story"
		var fb = game.get("final_boss")
		if fb != null and is_instance_valid(fb) and fb.awake and not fb.fallen:
			return "vale" if music_streams.has("vale") else "boss"
	if game.state == "dead" or game.message_text != "": return "story"
	if game.boss != null and is_instance_valid(game.boss) and game.boss.awake and not game.boss.dead and (game.exploration == null or game.exploration.room == "city"):
		return "boss"
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if not enemy.dead and (game.exploration == null or enemy.room_id == game.exploration.room) and enemy.global_position.distance_to(game.player.global_position) < 230 and enemy.state in ["chase", "windup", "strike", "cast"]:
			return "combat"
	var musica: String = room_music.get(game.exploration.room, "exploration") if game.exploration != null else "exploration"
	if musica in TRILHAS_PROPRIAS: return musica
	return "temple" if game.player.position.x < temple_until or musica == "temple" else "exploration"

func change_context(context: String) -> void:
	if context == music_context or switching or not music_streams.has(context): return
	# Dois contextos com a mesma faixa (por exemplo exploração e Terraço): a música segue sem recomeçar.
	if music_streams.has(music_context) and music_streams[context] == music_streams[music_context]:
		music_context = context
		return
	transition_context = context
	incoming.stream = music_streams[context]
	incoming.volume_db = -80
	incoming.play()
	fade_elapsed = 0
	switching = true

func _process(delta: float) -> void:
	var game = get_parent()
	if game.player == null:
		return
	if reverb != null and game.exploration != null:
		reverb.set("wet", move_toward(float(reverb.get("wet")), float(room_space.get(game.exploration.room, 0.12)), delta * 0.3))
	_update_beds(game, delta)
	context_timer -= delta
	if context_timer <= 0 and not switching:
		context_timer = 0.25
		change_context(desired_context())
	var base := -3.0 + MIX_TRIM_DB.tracks
	if game.narrative != null:
		if game.narrative.mode == "prayer": base = -9.0 + MIX_TRIM_DB.tracks
		elif game.narrative.mode in ["memory", "echo", "memorial"]: base = game.narrative.music_target() + MIX_TRIM_DB.tracks
	var quiet_memory: bool = game.narrative != null and game.narrative.mode == "memory" and game.narrative.elapsed >= 6.6 and game.narrative.elapsed < 7.1
	if quiet_memory:
		base = -38
	if switching:
		fade_elapsed += delta
		var progress := minf(fade_elapsed / 1.2, 1)
		ambience.volume_db = -80 if muted else base + linear_to_db(maxf(1 - progress, 0.001))
		incoming.volume_db = -80 if muted else base + linear_to_db(maxf(progress, 0.001))
		if progress >= 1:
			var old := ambience
			ambience = incoming
			incoming = old
			incoming.stop()
			music_context = transition_context
			switching = false
	else:
		ambience.volume_db = -80 if muted else base
	var target := -80.0 if muted or quiet_memory or game.state == "title" else lerpf(-42, -5, game.player.culpa / 100.0)
	guilt_layer.volume_db = move_toward(guilt_layer.volume_db, target, delta * 20)

func _exit_tree() -> void:
	if is_instance_valid(incoming):
		incoming.stop()
		incoming.stream = null
	if is_instance_valid(guilt_layer):
		guilt_layer.stop()
		guilt_layer.stream = null
	if is_instance_valid(ambience):
		ambience.stop()
		ambience.stream = null
	for voice in effects.values():
		voice.stop()
		voice.stream = null
	for layer in beds:
		if is_instance_valid(layer):
			layer.stop()
			layer.stream = null
	music_streams.clear()
	bed_streams.clear()
	effects.clear()
	beds.clear()
