extends CanvasLayer
## Timed visual sequences; no recorded narration is bundled.
var game
var elapsed := 0.0
var mode := ""
const PRAYER_DURATION := 4.8
const GRIEF_DURATION := 6.6
const MEMORY_DURATION := 13.0
var saved_zoom := Vector2.ONE
var saved_offset := Vector2.ZERO
var saved_limits: Array = []
var saved_music_db := -3.0
var font: Font
var title_font: Font
var panel: Control
var opening := [
	"Dizem que os homens nasceram do pecado\ne que somente através da dor poderiam encontrar a salvação.",
	"Mas quando as lágrimas deixaram de ser suficientes,\nfizeram do sofrimento uma religião.",
	"E quando até os céus permaneceram em silêncio,\ncondenaram uns aos outros em nome do perdão.",
	"Erga-se, Penitente.\nSua morte ainda não foi concedida.",
]

func _ready() -> void:
	layer = 30
	font = ThemeDB.fallback_font
	title_font = load("res://assets/title_font.ttf")
	panel = Control.new()
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.draw.connect(paint)
	add_child(panel)

func has_focus() -> bool:
	return mode == "prayer" or (mode == "memory" and elapsed < GRIEF_DURATION)

func begin(sequence: String) -> void:
	if mode != "":
		return
	mode = sequence
	elapsed = 0
	game.player.controllable = false
	game.player.attack_buffer = 0
	game.player.roll_buffer = 0
	game.player.hit_pause = 0
	game.player.shake = 0
	game.soundscape.play_sfx("bell")
	if sequence in ["prayer", "memory"]:
		var camera: Camera2D = game.player.camera
		saved_zoom = camera.zoom
		saved_offset = camera.offset
		saved_limits = [camera.limit_left, camera.limit_right, camera.limit_top, camera.limit_bottom]
		camera.limit_left = -10000
		camera.limit_right = 10000
		camera.limit_top = -10000
		camera.limit_bottom = 10000
		game.player.cinematic_focus = true
		saved_music_db = -3.0 if game.soundscape.muted else game.soundscape.ambience.volume_db
		if not game.soundscape.muted:
			game.soundscape.ambience.volume_db = -9
		if sequence == "memory":
			game.player.state = "cry"
			game.player.blood_tears = GRIEF_DURATION
		else:
			game.player.pray(false, PRAYER_DURATION)
	else:
		game.soundscape.play_sfx("breath")

func restore_camera() -> void:
	if saved_limits.is_empty():
		return
	var camera: Camera2D = game.player.camera
	camera.zoom = saved_zoom
	camera.offset = saved_offset
	camera.limit_left = saved_limits[0]
	camera.limit_right = saved_limits[1]
	camera.limit_top = saved_limits[2]
	camera.limit_bottom = saved_limits[3]
	saved_limits.clear()
	game.player.cinematic_focus = false

func finish() -> void:
	var previous := mode
	restore_camera()
	mode = ""
	game.player.controllable = true
	game.player.state = "idle"
	game.player.state_t = 0
	game.player.blood_tears = 0
	game.player.velocity = Vector2.ZERO
	if previous in ["prayer", "memory"] and not game.soundscape.muted:
		game.soundscape.ambience.volume_db = saved_music_db
	if previous == "opening":
		game.prologue_page = 1
		game.show_message(game.PROLOGUE[1]["title"], game.PROLOGUE[1]["text"])
	elif previous == "prayer":
		game.complete_prayer()
	elif previous == "memory":
		game.memory_seen = true
		game._save()

func update_focus() -> void:
	if not has_focus():
		if game.player.cinematic_focus:
			restore_camera()
		return
	var duration := PRAYER_DURATION if mode == "prayer" else GRIEF_DURATION
	var zoom_factor := 1.6 if mode == "prayer" else 2.7
	var fade_in := smoothstep(0.0, 1.1, elapsed)
	var fade_out := 1 - smoothstep(duration - 1.1, duration, elapsed)
	var strength := minf(fade_in, fade_out)
	game.player.camera.zoom = saved_zoom.lerp(saved_zoom * zoom_factor, strength)
	game.player.camera.offset = saved_offset.lerp(Vector2(0, -55), strength)
	if mode == "prayer":
		game.player.ritual_clip = "pray"
		if elapsed < 1.0:
			game.player.ritual_progress = elapsed * 0.56
		elif elapsed < 3.6:
			game.player.ritual_progress = 0.62 + sin(elapsed * 3) * 0.06
		else:
			game.player.ritual_progress = lerpf(0.72, 0.999, clampf((elapsed - 3.6) / 1.2, 0, 1))
	else:
		if elapsed < 1.0:
			game.player.ritual_clip = "cry_start"
			game.player.ritual_progress = elapsed
		elif elapsed < 3.4:
			game.player.ritual_clip = "cry_hold"
			game.player.ritual_progress = fmod((elapsed - 1.0) * 1.333, 1.0)
		elif elapsed < 4.2:
			game.player.ritual_clip = "cry_wipe"
			game.player.ritual_progress = (elapsed - 3.4) / 0.8
		else:
			game.player.ritual_clip = "cry_end"
			game.player.ritual_progress = minf((elapsed - 4.2) / 1.4, 0.999)

func _process(delta: float) -> void:
	if mode != "":
		elapsed += delta
		update_focus()
		var duration := 22.0 if mode == "opening" else (PRAYER_DURATION if mode == "prayer" else MEMORY_DURATION)
		var can_skip := (mode == "opening" and elapsed > 0.6) or (mode == "memory" and elapsed > GRIEF_DURATION + 0.2)
		if elapsed >= duration or (can_skip and Input.is_action_just_pressed("interact")):
			finish()
	panel.queue_redraw()

func text_at(pos: Vector2, text: String, size: int, color: Color, width: float) -> void:
	panel.draw_multiline_string(font, pos, text, HORIZONTAL_ALIGNMENT_CENTER, width, size, -1, color)

func paint() -> void:
	if mode == "":
		return
	var vs := panel.get_viewport_rect().size
	if has_focus():
		panel.draw_rect(Rect2(0, 0, vs.x, 50), Color.BLACK)
		panel.draw_rect(Rect2(0, vs.y - 90, vs.x, 90), Color(0, 0, 0, 0.88))
		if mode == "prayer":
			var feet: Vector2 = game.player.get_global_transform_with_canvas().origin
			var zoom: float = game.player.camera.zoom.x
			panel.draw_set_transform(feet, 0, Vector2(1, 0.22))
			panel.draw_arc(Vector2.ZERO, (35 + sin(elapsed * 2) * 4) * zoom, 0, TAU, 50, Color(0.82, 0.66, 0.36, 0.4), 2)
			panel.draw_set_transform(Vector2.ZERO, 0, Vector2.ONE)
			text_at(Vector2(0, vs.y - 58), "ORAÇÃO DE PENITÊNCIA", 21, Color("d2bb89"), vs.x)
			text_at(Vector2(50, vs.y - 25), "Ao concluir: vida e curas restauradas; inimigos comuns retornam.", 15, Color("b6ac9b"), vs.x - 100)
			var progress := clampf(elapsed / PRAYER_DURATION, 0, 1)
			panel.draw_line(Vector2(vs.x / 2 - 130, vs.y - 77), Vector2(vs.x / 2 - 130 + progress * 260, vs.y - 77), Color("c2a66f"), 2)
		else:
			text_at(Vector2(0, vs.y - 45), "O peso de cada lágrima.", 21, Color("c4a99d"), vs.x)
		return
	panel.draw_rect(Rect2(Vector2.ZERO, vs), Color(0.01, 0.015, 0.02, 0.87))
	panel.draw_texture_rect((load("res://assets/basilica.png") if mode == "opening" else game.art.gate_memory), Rect2(-elapsed * 2, -50, vs.x + 70, vs.y + 60), false, Color(0.35, 0.34, 0.35))
	if mode == "opening":
		# Silhouettes of the kneeling dead; the altar towers above them.
		for i in range(11):
			var x := 150.0 + i * 92
			panel.draw_circle(Vector2(x, 470), 10, Color("101116"))
			panel.draw_colored_polygon(PackedVector2Array([Vector2(x - 12, 475), Vector2(x + 9, 477), Vector2(x + 19, 527), Vector2(x - 24, 527)]), Color("101116"))
		var index := mini(int(elapsed / 5), 3)
		panel.draw_rect(Rect2(0, vs.y - 175, vs.x, 175), Color(0, 0, 0, 0.85))
		text_at(Vector2(100, vs.y - 120), opening[index], 22, Color("e1d7c6"), vs.x - 200)
		text_at(Vector2(0, 58), "O PESO DE MIL LÁGRIMAS", 18, Color("b59c71"), vs.x)
	else:
		text_at(Vector2(0, 110), "MEMÓRIAS DA CULPA  ·  I", 25, Color("d3b67f"), vs.x)
		panel.draw_rect(Rect2(0, 515, vs.x, 145), Color(0, 0, 0, 0.8))
		text_at(Vector2(100, 555), "Você lembra o peso do ferro. E as vozes.\nAbra. Ainda estamos aqui." if elapsed < 10 else "Suas mãos fecham os portões.\nO silêncio não devolve quem ficou do outro lado.", 24, Color("ded4c3"), vs.x - 200)
		if game.doll_found:
			text_at(Vector2(100, 632), "A boneca entre as mãos pequenas. Você a deixou junto aos nomes." if game.memorial_honored else "Entre as mãos pequenas, uma boneca. A mesma que você carrega.", 17, Color("c19481"), vs.x - 200)
	panel.draw_rect(Rect2(0, 0, vs.x, 28), Color.BLACK)
	text_at(Vector2(0, vs.y - 25), "[E] Prosseguir", 14, Color("b6ac9b"), vs.x)
