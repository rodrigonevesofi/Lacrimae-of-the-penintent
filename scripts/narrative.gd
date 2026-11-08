extends CanvasLayer
## Timed visual sequences; no recorded narration is bundled.
## Guilt scenes: echo of a recovered fragment, the memorial offering and the memory of the gates.
const GuiltText = preload("res://scripts/guilt_text.gd")
var game
var elapsed := 0.0
var mode := ""
const PRAYER_DURATION := 4.8
const GRIEF_DURATION := 6.6
const MEMORY_DURATION := 27.0
const ECHO_DURATION := 7.0
const MEMORIAL_DURATION := 9.0
const BOSS_INTRO_DURATION := 6.5
const BOSS_END_DURATION := 9.0
## The memory ends on three knocks, then a cut: no explanation follows them.
const MEMORY_KNOCKS := [24.6, 25.25, 25.9]
const ECHO_KNOCKS := [2.2, 2.85, 3.5]
var saved_zoom := Vector2.ONE
var saved_offset := Vector2.ZERO
var saved_limits: Array = []
var saved_music_db := -3.0
var font: Font
var title_font: Font
var panel: Control
var opening_art: Texture2D
var glow_texture: GradientTexture2D
var pool_texture: GradientTexture2D
## Painted stills for the memory of the gates. If a file is missing, a drawn silhouette stands in for it.
const MEMORY_ART := {
	"hands": "res://assets/memory/memoria_01_maos_na_roda.png",
	"small_hand": "res://assets/memory/memoria_02_mao_pequena.png",
	"small_hand_plain": "res://assets/memory/memoria_02_mao_pequena_sem_sol.png",
	"figure": "res://assets/memory/memoria_03_figura_atras.png",
	"gate": "res://assets/memory/memoria_04_portao_fechado.png",
}
var memory_art: Dictionary = {}
## Painted stills for the Bell Guardian. Without the files, the scenes use light and text only.
const BOSS_ART := {
	"rope": "res://assets/boss/guardiao_01_corda.png",
	"gesture": "res://assets/boss/guardiao_02_gesto.png",
	"still": "res://assets/boss/guardiao_03_imovel.png",
}
var boss_art: Dictionary = {}
var echo_index := 0
var knocks_done := 0
var flash := 0.0
var pulse := 0.0
var memorial_known := false
var voice_played := false
var tag := ""
var tag_t := 0.0
var opening := [
	"Dizem que os homens nasceram do pecado\ne que somente através da dor poderiam encontrar a salvação.",
	"Mas quando as lágrimas deixaram de ser suficientes,\nfizeram do sofrimento uma religião.",
	"E quando até os céus permaneceram em silêncio,\ncondenaram uns aos outros em nome do perdão.",
	"Erga-se, Penitente.\nSua morte ainda não foi concedida.",
]

func _ready() -> void:
	layer = 30
	opening_art = load("res://assets/opening.png")
	font = ThemeDB.fallback_font
	var ramp := Gradient.new()
	ramp.offsets = PackedFloat32Array([0.0, 0.55, 1.0])
	ramp.colors = PackedColorArray([Color(1, 1, 1, 1), Color(1, 1, 1, 0.35), Color(1, 1, 1, 0)])
	glow_texture = GradientTexture2D.new()
	glow_texture.gradient = ramp
	glow_texture.fill = GradientTexture2D.FILL_RADIAL
	glow_texture.fill_from = Vector2(0.5, 0.5)
	glow_texture.fill_to = Vector2(1.0, 0.5)
	glow_texture.width = 256
	glow_texture.height = 256
	var shade := Gradient.new()
	shade.offsets = PackedFloat32Array([0.0, 0.14, 0.30, 1.0])
	shade.colors = PackedColorArray([Color(1, 1, 1, 0), Color(1, 1, 1, 0), Color(1, 1, 1, 0.97), Color(1, 1, 1, 0.97)])
	pool_texture = GradientTexture2D.new()
	pool_texture.gradient = shade
	pool_texture.fill = GradientTexture2D.FILL_RADIAL
	pool_texture.fill_from = Vector2(0.5, 0.5)
	pool_texture.fill_to = Vector2(1.0, 0.5)
	pool_texture.width = 256
	pool_texture.height = 256
	for key in MEMORY_ART:
		if ResourceLoader.exists(MEMORY_ART[key]): memory_art[key] = load(MEMORY_ART[key])
	for key in BOSS_ART:
		if ResourceLoader.exists(BOSS_ART[key]): boss_art[key] = load(BOSS_ART[key])
	title_font = load("res://assets/title_font.ttf")
	panel = Control.new()
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.draw.connect(paint)
	add_child(panel)

## Closed captions for sound: every sound that carries information also appears on screen for a moment.
func caption_sound(text: String, seconds: float = 2.4) -> void:
	tag = text
	tag_t = seconds

func duration_of(sequence: String) -> float:
	match sequence:
		"opening": return 22.0
		"prayer": return PRAYER_DURATION
		"echo": return ECHO_DURATION
		"memorial": return MEMORIAL_DURATION
		"boss_intro": return BOSS_INTRO_DURATION
		"boss_end": return BOSS_END_DURATION
	return MEMORY_DURATION

func has_focus() -> bool:
	return mode in ["prayer", "echo", "memorial"] or (mode == "memory" and elapsed < GRIEF_DURATION)

func begin(sequence: String, argument: int = 0) -> void:
	if mode != "":
		return
	mode = sequence
	elapsed = 0
	knocks_done = 0
	voice_played = false
	flash = 0.0
	pulse = 0.0
	echo_index = argument
	memorial_known = argument == 1
	game.player.controllable = false
	game.player.attack_buffer = 0
	game.player.roll_buffer = 0
	game.player.hit_pause = 0
	game.player.shake = 0
	if sequence == "memorial":
		game.soundscape.play_sfx("sino_surdo")
		caption_sound("[Sino grave, abafado]", 3.0)
	elif sequence != "echo":
		game.soundscape.play_sfx("bell")
		caption_sound("[Sino]", 2.2)
	if sequence in ["prayer", "memory", "echo", "memorial"]:
		var camera: Camera2D = game.player.camera
		saved_zoom = camera.zoom
		saved_offset = camera.offset
		saved_limits = [camera.limit_left, camera.limit_right, camera.limit_top, camera.limit_bottom]
		camera.limit_left = -100000
		camera.limit_right = 100000
		camera.limit_top = -100000
		camera.limit_bottom = 100000
		game.player.cinematic_focus = true
		saved_music_db = -3.0 if game.soundscape.muted else game.soundscape.ambience.volume_db
		if not game.soundscape.muted:
			game.soundscape.ambience.volume_db = -9
		if sequence == "prayer":
			game.player.pray(false, PRAYER_DURATION)
		else:
			game.player.state = "cry"
			game.player.blood_tears = GRIEF_DURATION if sequence == "memory" else duration_of(sequence)
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
	if previous in ["prayer", "memory", "echo", "memorial"] and not game.soundscape.muted:
		game.soundscape.ambience.volume_db = saved_music_db
	if previous == "opening":
		game.prologue_page = 1
		game.show_message(game.PROLOGUE[1]["title"], game.PROLOGUE[1]["text"])
	elif previous == "prayer":
		game.complete_prayer()
	elif previous == "memory":
		game.memory_seen = true
		game._save()
	elif previous == "boss_end":
		# The silence after the bell leads straight into the memory of the gates.
		begin("memory")
	elif previous == "memorial":
		# The silence comes first; the written record follows, so the text stays available to read again.
		game.show_message("ÀQUELES QUE FICARAM DO OUTRO LADO", game.Story.memorial_text(memorial_known))

func memorial_timeline(duration: float) -> void:
	# Kneel with the doll, set it down, stay with it, rise and leave it there.
	if elapsed < 1.8:
		game.player.ritual_clip = "memorial_kneel"
		game.player.ritual_progress = elapsed / 1.8
	elif elapsed < 4.5:
		game.player.ritual_clip = "memorial_place"
		game.player.ritual_progress = (elapsed - 1.8) / 2.7
	elif elapsed < duration - 2.4:
		game.player.ritual_clip = "memorial_hold"
		game.player.ritual_progress = fmod((elapsed - 4.5) * 0.9, 1.0)
	else:
		game.player.ritual_clip = "memorial_rise"
		game.player.ritual_progress = minf((elapsed - (duration - 2.4)) / 2.4, 0.999)

func cry_timeline(duration: float) -> void:
	if mode == "memorial":
		memorial_timeline(duration)
		return
	# Kneel, hold, wipe the eyes, rise. The tail keeps its length however long the hold lasts.
	if elapsed < 1.0:
		game.player.ritual_clip = "cry_start"
		game.player.ritual_progress = elapsed
	elif elapsed < duration - 3.2:
		game.player.ritual_clip = "cry_hold"
		game.player.ritual_progress = fmod((elapsed - 1.0) * 1.333, 1.0)
	elif elapsed < duration - 2.4:
		game.player.ritual_clip = "cry_wipe"
		game.player.ritual_progress = (elapsed - (duration - 3.2)) / 0.8
	else:
		game.player.ritual_clip = "cry_end"
		game.player.ritual_progress = minf((elapsed - (duration - 2.4)) / 1.4, 0.999)

func update_focus() -> void:
	if not has_focus():
		if game.player.cinematic_focus:
			restore_camera()
		return
	var duration := GRIEF_DURATION if mode == "memory" else duration_of(mode)
	var zoom_factor: float = {"prayer": 1.6, "memory": 2.7, "echo": 2.7, "memorial": 2.6}[mode]
	if mode in ["echo", "memorial"]: zoom_factor += 0.35 * clampf(elapsed / duration, 0.0, 1.0)
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
		cry_timeline(duration)

func knock_schedule() -> Array:
	if mode == "memory": return MEMORY_KNOCKS
	if mode == "echo" and echo_index == 0: return ECHO_KNOCKS
	return []

## Muffled voices heard through stone: the second and third echoes, and the opening of the memory.
func fire_voices() -> void:
	if voice_played: return
	if mode == "echo" and echo_index in [1, 2] and elapsed >= 1.2:
		voice_played = true
		game.soundscape.play_sfx("murmurio_0%d" % echo_index)
		caption_sound("[Vozes abafadas]", 3.0)
	elif mode == "memory" and elapsed >= GRIEF_DURATION + 0.4:
		voice_played = true
		game.soundscape.play_sfx("murmurio_03")
		caption_sound("[Vozes abafadas]", 3.0)

func fire_knocks() -> void:
	var times := knock_schedule()
	while knocks_done < times.size() and elapsed >= times[knocks_done]:
		knocks_done += 1
		game.soundscape.play_sfx("knock")
		caption_sound("[Batida]", 1.1)
		game.shake_cam(3.0)
		flash = 0.14
		pulse = 1.0

func music_target() -> float:
	if mode == "memory" and elapsed > MEMORY_KNOCKS[0] - 1.8: return -34.0
	if mode == "echo" and echo_index == 0 and elapsed > 1.8 and elapsed < 4.6: return -30.0
	if mode == "memorial" and elapsed > 1.0 and elapsed < 6.0: return -26.0
	return -9.0

func can_skip() -> bool:
	match mode:
		"opening": return elapsed > 0.6
		"memory": return elapsed > GRIEF_DURATION + 0.2
		"echo": return elapsed > 2.0
		"memorial": return elapsed > 2.8
		"boss_intro": return elapsed > 2.0
		"boss_end": return elapsed > 3.0
	return false

func _process(delta: float) -> void:
	if mode != "":
		elapsed += delta
		flash = maxf(flash - delta, 0.0)
		tag_t = maxf(tag_t - delta, 0.0)
		pulse = maxf(pulse - delta * 1.4, 0.0)
		update_focus()
		fire_voices()
		fire_knocks()
		if elapsed >= duration_of(mode) or (can_skip() and Input.is_action_just_pressed("interact")):
			finish()
	panel.queue_redraw()

func text_at(pos: Vector2, text: String, size: int, color: Color, width: float) -> void:
	panel.draw_multiline_string(font, pos, text, HORIZONTAL_ALIGNMENT_CENTER, width, size, -1, color)

## Smooth 0..1 envelope for something visible between a and b.
func beat(a: float, b: float, fade: float = 0.6) -> float:
	var t := elapsed - GRIEF_DURATION
	return smoothstep(a, a + fade, t) * (1.0 - smoothstep(b - fade, b, t))

func glow(center: Vector2, radius: float, color: Color, alpha: float) -> void:
	panel.draw_texture_rect(glow_texture, Rect2(center - Vector2(radius, radius), Vector2(radius, radius) * 2.0), false, Color(color, clampf(alpha, 0.0, 1.0)))

## Everything falls into shadow except a pool of light around the kneeling figure. One smooth gradient, no seams.
func light_pool(vs: Vector2, center: Vector2, radius: float, dark: float, tint: Color) -> void:
	var half := radius / 0.14
	var tex_rect := Rect2(center - Vector2(half, half), Vector2(half, half) * 2.0)
	panel.draw_texture_rect(pool_texture, tex_rect, false, Color(tint, clampf(dark, 0.0, 1.0)))
	var solid := Color(tint, clampf(dark * 0.9, 0.0, 1.0))
	# Beyond the gradient's square the shade stays solid.
	if tex_rect.position.x > 0: panel.draw_rect(Rect2(0, 0, tex_rect.position.x, vs.y), solid)
	if tex_rect.end.x < vs.x: panel.draw_rect(Rect2(tex_rect.end.x, 0, vs.x - tex_rect.end.x, vs.y), solid)
	if tex_rect.position.y > 0: panel.draw_rect(Rect2(0, 0, vs.x, tex_rect.position.y), solid)
	if tex_rect.end.y < vs.y: panel.draw_rect(Rect2(0, tex_rect.end.y, vs.x, vs.y - tex_rect.end.y), solid)

func edge_vignette(vs: Vector2, strength: float, tint: Color) -> void:
	var clear := Color(tint, 0.0)
	var solid := Color(tint, strength)
	var depth := 220.0
	panel.draw_polygon(PackedVector2Array([Vector2(0, 0), Vector2(vs.x, 0), Vector2(vs.x, depth), Vector2(0, depth)]), PackedColorArray([solid, solid, clear, clear]))
	panel.draw_polygon(PackedVector2Array([Vector2(0, vs.y - depth), Vector2(vs.x, vs.y - depth), Vector2(vs.x, vs.y), Vector2(0, vs.y)]), PackedColorArray([clear, clear, solid, solid]))
	panel.draw_polygon(PackedVector2Array([Vector2(0, 0), Vector2(depth, 0), Vector2(depth, vs.y), Vector2(0, vs.y)]), PackedColorArray([solid, clear, clear, solid]))
	panel.draw_polygon(PackedVector2Array([Vector2(vs.x - depth, 0), Vector2(vs.x, 0), Vector2(vs.x, vs.y), Vector2(vs.x - depth, vs.y)]), PackedColorArray([clear, solid, solid, clear]))

func paint() -> void:
	if mode == "":
		return
	paint_scene()
	draw_tag()

func draw_tag() -> void:
	if tag_t <= 0.0 or tag == "":
		return
	var vs := panel.get_viewport_rect().size
	var a := clampf(tag_t / 0.4, 0.0, 1.0)
	var width := 28.0 + tag.length() * 9.5
	panel.draw_rect(Rect2(vs.x - width - 26, 64, width, 30), Color(0, 0, 0, 0.62 * a))
	panel.draw_string(font, Vector2(vs.x - width - 12, 85), tag, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color(0.9, 0.86, 0.78, a))

func paint_scene() -> void:
	var vs := panel.get_viewport_rect().size
	if has_focus():
		paint_focus(vs)
		return
	if mode in ["boss_intro", "boss_end"]:
		paint_boss(vs)
		return
	panel.draw_rect(Rect2(Vector2.ZERO, vs), Color(0.01, 0.015, 0.02, 1.0 if mode == "memory" else 0.87))
	if mode == "opening":
		panel.draw_texture_rect(opening_art, Rect2(-elapsed * 2, -20, vs.x + 70, vs.y + 40), false, Color(0.72, 0.72, 0.76))
		var index := mini(int(elapsed / 5), 3)
		panel.draw_rect(Rect2(0, vs.y - 175, vs.x, 175), Color(0, 0, 0, 0.85))
		text_at(Vector2(100, vs.y - 120), opening[index], 22, Color("e1d7c6"), vs.x - 200)
		text_at(Vector2(0, 58), "O PESO DE MIL LÁGRIMAS", 18, Color("b59c71"), vs.x)
		panel.draw_rect(Rect2(0, 0, vs.x, 28), Color.BLACK)
		text_at(Vector2(0, vs.y - 25), "[E] Prosseguir", 14, Color("b6ac9b"), vs.x)
		return
	paint_memory(vs)

func paint_focus(vs: Vector2) -> void:
	var bottom := 90.0
	if mode == "memorial": bottom = 130.0
	if mode == "prayer":
		panel.draw_rect(Rect2(0, 0, vs.x, 50), Color.BLACK)
		panel.draw_rect(Rect2(0, vs.y - bottom, vs.x, bottom), Color(0, 0, 0, 0.88))
		var feet: Vector2 = game.player.get_global_transform_with_canvas().origin
		var zoom: float = game.player.camera.zoom.x
		panel.draw_set_transform(feet, 0, Vector2(1, 0.22))
		panel.draw_arc(Vector2.ZERO, (35 + sin(elapsed * 2) * 4) * zoom, 0, TAU, 50, Color(0.82, 0.66, 0.36, 0.4), 2)
		panel.draw_set_transform(Vector2.ZERO, 0, Vector2.ONE)
		text_at(Vector2(0, vs.y - 58), "ORAÇÃO DE PENITÊNCIA", 21, Color("d2bb89"), vs.x)
		text_at(Vector2(50, vs.y - 25), "Ao concluir: vida e curas restauradas; inimigos comuns retornam.", 15, Color("b6ac9b"), vs.x - 100)
		var progress := clampf(elapsed / PRAYER_DURATION, 0, 1)
		panel.draw_line(Vector2(vs.x / 2 - 130, vs.y - 77), Vector2(vs.x / 2 - 130 + progress * 260, vs.y - 77), Color("c2a66f"), 2)
		return
	# Guilt scenes isolate the figure in a pool of light. Each knock contracts it, then it slowly opens again.
	var span := GRIEF_DURATION if mode == "memory" else duration_of(mode)
	var open := smoothstep(0.0, 1.2, elapsed) * (1.0 - smoothstep(span - 1.0, span, elapsed))
	var zoom_now: float = game.player.camera.zoom.x
	var center: Vector2 = game.player.get_global_transform_with_canvas().origin + Vector2(0, -62.0 * zoom_now)
	var radius := (150.0 + 14.0 * sin(elapsed * 1.3)) * zoom_now / 2.7 * (1.0 - 0.28 * pulse)
	var tint := Color(0.03, 0.0, 0.04) if mode != "memorial" else Color(0.05, 0.02, 0.0)
	light_pool(vs, center, radius, 0.92 * open, tint)
	var ember := 0.14 + 0.06 * sin(elapsed * 2.2)
	edge_vignette(vs, ember * open, Color(0.28, 0.0, 0.02))
	panel.draw_rect(Rect2(0, 0, vs.x, 50), Color.BLACK)
	panel.draw_rect(Rect2(0, vs.y - bottom, vs.x, bottom), Color(0, 0, 0, 0.88))
	var hint_y := vs.y - 18
	if mode == "memory":
		text_at(Vector2(0, vs.y - 45), "O peso de cada lágrima.", 21, Color("c4a99d"), vs.x)
	elif mode == "echo":
		var line_alpha := smoothstep(1.0, 2.0, elapsed) * (1.0 - smoothstep(ECHO_DURATION - 1.2, ECHO_DURATION - 0.4, elapsed))
		text_at(Vector2(0, vs.y - 62), GuiltText.echo_line(echo_index), 21, Color(0.88, 0.8, 0.72, line_alpha), vs.x)
	elif mode == "memorial":
		text_at(Vector2(0, vs.y - 86), "ÀQUELES QUE FICARAM DO OUTRO LADO", 19, Color(0.82, 0.7, 0.5, smoothstep(0.8, 2.0, elapsed) * (1.0 - smoothstep(MEMORIAL_DURATION - 1.2, MEMORIAL_DURATION - 0.4, elapsed))), vs.x)
		hint_y = vs.y - 6
	if can_skip():
		text_at(Vector2(0, hint_y), "[E] Seguir", 13, Color(0.7, 0.66, 0.6, 0.7), vs.x)
	if flash > 0.0:
		panel.draw_rect(Rect2(Vector2.ZERO, vs), Color(1, 1, 1, flash * 0.35))

func small_hand(origin: Vector2, alpha: float, sun: bool) -> void:
	# A child's hand gripping an iron bar; only silhouette and one stitched sun are drawn.
	var s := 2.0
	glow(origin + Vector2(0, 30) * s, 150.0 * s, Color(0.95, 0.62, 0.28), alpha * 0.9)
	panel.draw_set_transform(origin, 0, Vector2.ONE * s)
	var pos := Vector2.ZERO
	var dark := Color(0.03, 0.02, 0.025, alpha)
	var rim := Color(1.0, 0.72, 0.42, alpha * 0.9)
	var forearm := PackedVector2Array([pos + Vector2(-6, 10), pos + Vector2(18, 8), pos + Vector2(70, 420), pos + Vector2(26, 430)])
	panel.draw_colored_polygon(forearm, dark)
	panel.draw_line(pos + Vector2(18, 8), pos + Vector2(70, 420), rim, 1.4)
	panel.draw_rect(Rect2(pos + Vector2(-17, -14), Vector2(36, 34)), dark)
	panel.draw_line(pos + Vector2(19, -14), pos + Vector2(19, 20), rim, 1.4)
	for i in range(4):
		var y := -12.0 + i * 8.5
		var reach := 24.0 - absf(float(i) - 1.5) * 3.0
		panel.draw_rect(Rect2(pos + Vector2(-10 - reach, y), Vector2(reach, 7.2)), dark)
		panel.draw_circle(pos + Vector2(-10 - reach, y + 3.6), 3.6, dark)
		panel.draw_line(pos + Vector2(-8 - reach, y), pos + Vector2(-10, y), rim, 1.0)
	panel.draw_rect(Rect2(pos + Vector2(10, -20), Vector2(22, 9)), dark)
	if sun:
		var cuff := pos + Vector2(36, 92)
		panel.draw_rect(Rect2(cuff + Vector2(-20, -16), Vector2(52, 30)), Color(0.12, 0.09, 0.08, alpha))
		panel.draw_circle(cuff + Vector2(6, 0), 6.5, Color(1.0, 0.72, 0.25, alpha))
		for i in range(8):
			var a := TAU * i / 8.0
			panel.draw_line(cuff + Vector2(6, 0) + Vector2(cos(a), sin(a)) * 9, cuff + Vector2(6, 0) + Vector2(cos(a), sin(a)) * 14, Color(1.0, 0.72, 0.25, alpha), 1.6)
	panel.draw_set_transform(Vector2.ZERO, 0, Vector2.ONE)

func blurred_figure(pos: Vector2, alpha: float) -> void:
	# A robed figure that never comes into focus: the same shape repeated and offset, against a pale light.
	glow(pos + Vector2(0, -170), 330.0, Color(0.9, 0.8, 0.62), alpha * 0.8)
	for i in range(7):
		var off := Vector2((i - 3) * 7.0, (i % 2) * 5.0)
		var c := Color(0.03, 0.022, 0.03, alpha * 0.26)
		var body := PackedVector2Array([pos + off + Vector2(-30, -270), pos + off + Vector2(30, -270), pos + off + Vector2(72, 0), pos + off + Vector2(-72, 0)])
		panel.draw_colored_polygon(body, c)
		panel.draw_circle(pos + off + Vector2(0, -300), 31, c)

func gate_wheel(center: Vector2, angle: float, alpha: float) -> void:
	var bronze := Color(0.33, 0.25, 0.15, alpha)
	panel.draw_arc(center, 168, 0, TAU, 64, bronze, 16)
	panel.draw_arc(center, 150, 0, TAU, 64, Color(0.05, 0.04, 0.04, alpha), 3)
	for i in range(8):
		var a := angle + TAU * i / 8.0
		panel.draw_line(center + Vector2(cos(a), sin(a)) * 30, center + Vector2(cos(a), sin(a)) * 160, bronze, 12)
	panel.draw_circle(center, 34, Color(0.2, 0.15, 0.1, alpha))
	panel.draw_circle(center, 12, Color(0.05, 0.04, 0.04, alpha))
	for h in range(2):
		var a := angle + PI * 0.25 + h * PI * 0.9
		var p := center + Vector2(cos(a), sin(a)) * 160
		panel.draw_circle(p, 26, Color(0.04, 0.03, 0.035, alpha))
		panel.draw_line(p, p + Vector2(cos(a), sin(a)) * 130, Color(0.04, 0.03, 0.035, alpha), 24)

func boss_still(key: String, alpha: float, vs: Vector2, push: float) -> bool:
	if alpha <= 0.0 or not boss_art.has(key): return false
	var size := vs * (1.03 + push)
	panel.draw_texture_rect(boss_art[key], Rect2(-(size - vs) * 0.5, size), false, Color(1, 1, 1, alpha))
	return true

## The Bell Guardian: the rope that is not there, the hand that keeps pulling, the bronze that stays still.
func paint_boss(vs: Vector2) -> void:
	var span := duration_of(mode)
	var open := smoothstep(0.0, 0.9, elapsed) * (1.0 - smoothstep(span - 0.9, span, elapsed))
	panel.draw_rect(Rect2(Vector2.ZERO, vs), Color(0.005, 0.006, 0.008, 1.0))
	var lines: Array = GuiltText.BOSS_INTRO if mode == "boss_intro" else GuiltText.BOSS_END
	var split := span * 0.5
	var drawn := false
	if mode == "boss_intro":
		drawn = boss_still("rope", open, vs, elapsed * 0.004)
	else:
		var first := smoothstep(0.0, 0.9, elapsed) * (1.0 - smoothstep(split - 0.7, split, elapsed))
		var second := smoothstep(split, split + 1.2, elapsed) * (1.0 - smoothstep(span - 0.9, span, elapsed))
		drawn = boss_still("gesture", first, vs, elapsed * 0.003)
		drawn = boss_still("still", second, vs, 0.0) or drawn
	if not drawn:
		# No painting yet: a slow glow of bronze and the text carry the moment.
		glow(Vector2(vs.x * 0.5, vs.y * 0.42), 360.0 + 20.0 * sin(elapsed * 1.4), Color(0.85, 0.5, 0.2), 0.32 * open)
	edge_vignette(vs, 0.6 * open, Color(0, 0, 0))
	panel.draw_rect(Rect2(0, vs.y - 160, vs.x, 160), Color(0, 0, 0, 0.72 * open))
	for i in range(lines.size()):
		var a: float
		if mode == "boss_intro":
			a = smoothstep(0.8 + i * 1.8, 1.8 + i * 1.8, elapsed) * (1.0 - smoothstep(span - 0.9, span, elapsed))
		else:
			var start := 0.6 if i == 0 else split + 0.6
			var stop := split - 0.4 if i == 0 else span - 0.5
			a = smoothstep(start, start + 1.0, elapsed) * (1.0 - smoothstep(stop - 0.6, stop, elapsed))
		text_at(Vector2(100, vs.y - 112 + i * 34), lines[i], 23, Color(0.9, 0.84, 0.74, a), vs.x - 200)
	if can_skip():
		text_at(Vector2(0, vs.y - 18), "[E] Seguir", 13, Color(0.7, 0.66, 0.6, 0.7), vs.x)

func draw_still(key: String, alpha: float, vs: Vector2, push: float, jitter: float = 0.0) -> bool:
	if alpha <= 0.0 or not memory_art.has(key): return false
	var texture: Texture2D = memory_art[key]
	var size := vs * (1.03 + push)
	var shake := Vector2(sin(elapsed * 41.0), cos(elapsed * 37.0)) * jitter
	panel.draw_texture_rect(texture, Rect2(-(size - vs) * 0.5 + shake, size), false, Color(1, 1, 1, alpha))
	return true

func paint_memory(vs: Vector2) -> void:
	var t := elapsed - GRIEF_DURATION
	var knows: bool = game.knows_alba()
	# Backdrop: the gates of the visited panorama, pushed in slowly. It darkens as the memory narrows.
	var shade := 0.62
	if t > 8.6: shade = lerpf(0.62, 0.34, clampf((t - 8.6) / 2.0, 0, 1))
	if t > 16.4: shade = lerpf(0.34, 0.0, clampf((t - 16.4) / 1.2, 0, 1))
	var size := vs * (1.0 + t * 0.012)
	panel.draw_texture_rect(game.art.gate_memory, Rect2(-(size - vs) * Vector2(0.62, 0.45), size), false, Color(shade, shade, shade * 1.04))
	# Opening shot: the hands on the mechanism, before anything is said.
	draw_still("hands", beat(0.0, 4.6, 0.9), vs, t * 0.003)
	# Voices: overheard, never located.
	var voices := beat(0.0, 4.6)
	if voices > 0.0:
		var spots := [Vector2(0.18, 0.36), Vector2(0.80, 0.48), Vector2(0.46, 0.27)]
		for i in range(spots.size()):
			var a := voices * (0.35 + 0.35 * sin(t * 1.7 + i * 2.1))
			text_at(Vector2(vs.x * spots[i].x - 150, vs.y * spots[i].y), "Abra." if i != 1 else "Ainda estamos aqui.", 26 + i * 2, Color(0.88, 0.82, 0.72, a), 300)
	# Iron bars and the small hand.
	var bars := beat(3.8, 9.8)
	var hand_key := "small_hand" if game.doll_found and memory_art.has("small_hand") else "small_hand_plain"
	if bars > 0.0 and draw_still(hand_key, bars, vs, (elapsed - GRIEF_DURATION - 3.8) * 0.004):
		pass
	elif bars > 0.0:
		for i in range(11):
			var x := vs.x * (0.05 + i * 0.09)
			panel.draw_rect(Rect2(x - 8, -10, 16, vs.y + 20), Color(0.03, 0.025, 0.03, bars * 0.92))
			panel.draw_rect(Rect2(x - 8, -10, 2, vs.y + 20), Color(0.55, 0.4, 0.26, bars * 0.35))
		panel.draw_rect(Rect2(0, vs.y * 0.14, vs.x, 18), Color(0.03, 0.025, 0.03, bars * 0.92))
		panel.draw_rect(Rect2(0, vs.y * 0.82, vs.x, 18), Color(0.03, 0.025, 0.03, bars * 0.92))
		small_hand(Vector2(vs.x * (0.05 + 7 * 0.09) - 2 + sin(t * 9.0) * 0.8, vs.y * 0.5), bars, game.doll_found)
	# Someone behind, out of focus.
	var behind := beat(9.4, 13.6)
	if behind > 0.0 and draw_still("figure", behind, vs, (elapsed - GRIEF_DURATION - 9.4) * 0.003):
		pass
	elif behind > 0.0:
		blurred_figure(Vector2(vs.x * 0.24 + sin(t * 0.6) * 10, vs.y * 0.86), behind)
	# The wheel turns. Nothing here asks the player to press anything: it only watches.
	var wheel := beat(12.8, 17.6)
	if wheel > 0.0 and draw_still("hands", wheel, vs, 0.02 + (elapsed - GRIEF_DURATION - 12.8) * 0.006, 1.6 * wheel):
		pass
	elif wheel > 0.0:
		var turn := smoothstep(0.0, 1.0, clampf((t - 13.4) / 3.8, 0, 1)) * PI * 0.9
		glow(Vector2(vs.x * 0.5, vs.y * 0.54), 330.0, Color(0.95, 0.62, 0.28), wheel * 0.7)
		gate_wheel(Vector2(vs.x * 0.5, vs.y * 0.54), turn, wheel)
	# The closed gate holds the last seconds; the knocks arrive over it.
	draw_still("gate", beat(17.0, 20.6, 0.9), vs, 0.0)
	# Captions.
	panel.draw_rect(Rect2(0, 515, vs.x, 145), Color(0, 0, 0, 0.8 * minf(1.0, shade * 4.0 + 0.2)))
	var cap := 0.0
	var line := ""
	if t < 3.8:
		line = GuiltText.MEMORY_CAPTIONS[0]
		cap = beat(0.0, 3.8)
	elif t < 9.4:
		line = GuiltText.MEMORY_CAPTIONS[1] + "\nAbra. Ainda estamos aqui."
		cap = beat(3.8, 9.4)
	elif t < 12.8:
		line = GuiltText.MEMORY_CAPTIONS[2]
		cap = beat(9.4, 12.8)
	elif t < 17.4:
		line = game.Story.memory_line(11, knows)
		cap = beat(12.8, 17.4)
	if cap > 0.0:
		text_at(Vector2(100, 555), line, 24, Color(0.87, 0.83, 0.76, cap), vs.x - 200)
	if game.doll_found and t > 4.0 and t < 17.4:
		var doll_line: String = ("Você gravou seu nome. A pequena mão continua do outro lado." if game.story_flags.has("memorial_named") else "A boneca entre as mãos pequenas. Você a deixou junto aos nomes.") if game.memorial_honored else "Um sol bordado no pulso. A mesma boneca que você carrega."
		text_at(Vector2(100, 632), doll_line, 17, Color(0.76, 0.58, 0.5, minf(beat(4.0, 17.4), 1.0)), vs.x - 200)
	edge_vignette(vs, 0.55, Color(0, 0, 0))
	text_at(Vector2(0, 110), "MEMÓRIAS DA CULPA  ·  I", 25, Color("d3b67f"), vs.x)
	text_at(Vector2(0, 140), "Você apenas assiste. O que foi feito não pode ser desfeito.", 15, Color(0.72, 0.65, 0.55, 0.85), vs.x)
	if flash > 0.0:
		panel.draw_rect(Rect2(Vector2.ZERO, vs), Color(1, 1, 1, flash * 0.55))
	panel.draw_rect(Rect2(0, 0, vs.x, 28), Color.BLACK)
	text_at(Vector2(0, vs.y - 25), "[E] Prosseguir", 14, Color("b6ac9b"), vs.x)
