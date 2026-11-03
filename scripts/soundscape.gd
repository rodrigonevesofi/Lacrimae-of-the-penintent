extends Node
## Original composed stereo score and separate polyphonic action effects.
var guilt_layer: AudioStreamPlayer
var ambience: AudioStreamPlayer
var effects: Dictionary = {}
var muted := false
const EFFECT_NAMES := ["step", "swing", "hit", "hurt", "roll", "jump", "heal", "altar", "death", "bell", "breath"]

func _ready() -> void:
	ambience = AudioStreamPlayer.new()
	var music: AudioStreamWAV = load("res://assets/audio/vespera_lament.wav")
	music.loop_mode = AudioStreamWAV.LOOP_FORWARD
	music.loop_begin = 0
	music.loop_end = music.data.size() / 4
	ambience.stream = music
	ambience.volume_db = -3
	add_child(ambience)
	ambience.play()
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
	if muted:
		guilt_layer.volume_db = -80
		for voice in effects.values():
			voice.stop()

func _process(delta: float) -> void:
	var game = get_parent()
	if game.player == null:
		return
	var target := -80.0 if muted or game.state == "title" else lerpf(-42, -5, game.player.culpa / 100.0)
	guilt_layer.volume_db = move_toward(guilt_layer.volume_db, target, delta * 20)

func _exit_tree() -> void:
	if is_instance_valid(guilt_layer):
		guilt_layer.stop()
		guilt_layer.stream = null
	if is_instance_valid(ambience):
		ambience.stop()
		ambience.stream = null
	for voice in effects.values():
		voice.stop()
		voice.stream = null
