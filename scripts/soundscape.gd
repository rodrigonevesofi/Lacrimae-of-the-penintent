extends Node
## Original composed stereo score and separate polyphonic action effects.
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
const EFFECT_NAMES := ["step", "swing", "hit", "hurt", "roll", "jump", "heal", "altar", "death", "bell", "breath"]

func _ready() -> void:
	ambience = AudioStreamPlayer.new()
	for context in ["menu", "exploration", "temple", "combat", "boss", "story", "ending"]:
		var track: AudioStreamWAV = load("res://assets/audio/ost_%s.wav" % context)
		track.loop_mode = AudioStreamWAV.LOOP_FORWARD
		track.loop_end = track.data.size() / 4
		music_streams[context] = track
	var music: AudioStreamWAV = music_streams["menu"]
	music.loop_mode = AudioStreamWAV.LOOP_FORWARD
	music.loop_begin = 0
	music.loop_end = music.data.size() / 4
	ambience.stream = music
	ambience.volume_db = -3
	add_child(ambience)
	ambience.play()
	incoming = AudioStreamPlayer.new()
	add_child(incoming)
	guilt_layer = AudioStreamPlayer.new()
	var guilt: AudioStreamWAV = load("res://assets/audio/guilt.wav")
	guilt.loop_mode = AudioStreamWAV.LOOP_FORWARD
	guilt.loop_end = guilt.data.size() / 2
	guilt_layer.stream = guilt
	guilt_layer.volume_db = -80
	add_child(guilt_layer)
	guilt_layer.play()
	for name in EFFECT_NAMES:
		var voice := AudioStreamPlayer.new()
		voice.stream = load("res://assets/audio/%s.wav" % name)
		voice.max_polyphony = 6
		voice.volume_db = -7 if name == "step" else -2
		add_child(voice)
		effects[name] = voice

func play_sfx(name: String) -> void:
	if muted or not effects.has(name):
		return
	var voice: AudioStreamPlayer = effects[name]
	voice.pitch_scale = randf_range(0.94, 1.06) if name in ["step", "swing", "hit"] else 1.0
	voice.play()

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

func desired_context() -> String:
	var game = get_parent()
	if game.state == "title": return "menu"
	if game.narrative != null and game.narrative.mode != "":
		return "temple" if game.narrative.mode == "prayer" else "story"
	if game.state == "ending": return "ending"
	if game.state == "dead" or game.message_text != "": return "story"
	if game.boss != null and is_instance_valid(game.boss) and game.boss.awake and not game.boss.dead and (game.exploration == null or game.exploration.room == "city"):
		return "boss"
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if not enemy.dead and (game.exploration == null or enemy.room_id == game.exploration.room) and enemy.global_position.distance_to(game.player.global_position) < 230 and enemy.state in ["chase", "windup", "strike", "cast"]:
			return "combat"
	return "temple" if game.player.position.x < 1250 or game.exploration.room in ["ossuary","refuge"] else "exploration"

func change_context(context: String) -> void:
	if context == music_context or switching or not music_streams.has(context): return
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
	context_timer -= delta
	if context_timer <= 0 and not switching:
		context_timer = 0.25
		change_context(desired_context())
	var base := -9.0 if game.narrative != null and game.narrative.mode in ["prayer", "memory"] else -3.0
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
