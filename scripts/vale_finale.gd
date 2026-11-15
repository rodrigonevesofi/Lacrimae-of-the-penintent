extends CanvasLayer
## A revelação, no Vale dos Flagelados.
## O chefe está de joelhos, sem armadura; resta o capacete. Beatriz — que por toda a vida se recusou a olhar
## os rostos de quem feriu — caminha até ele e tira o capacete. O rosto por baixo é o do próprio Penitente.
## É a única vez, no jogo inteiro, em que o rosto dele aparece.
##
## O vale continua vivo ao fundo, com faixas de cinema, três closes e sete falas.
## Pode ser pulada depois de 3 s.

const DURATION := 44.0
const LINES := [
	[0.6, 3.0, "[Silêncio. Só as cordas rangem.]"],
	[3.2, 8.2, "Beatriz, que nunca olhou um rosto, ajoelha diante dele."],
	[8.6, 13.4, "As mãos de Beatriz erguem o ferro que nos escondia."],
	[14.6, 20.4, "Sob o ferro, um rosto que chora sangue.\nÉ o seu."],
	[20.8, 27.2, "Não havia outro no vale. Havia o que você fez e pediu para esquecer:\nas mãos na tranca, e as vozes do outro lado dos portões."],
	[27.6, 34.2, "A culpa não queria castigo. Queria ser olhada.\nSó vence a si mesmo quem para de fugir do próprio rosto."],
	[34.6, 41.4, "BEATRIZ — Eu também não quis ver. Agora vejo.\nO que é de um, carregamos os dois."],
]

var game
var boss
var t := 0.0
var panel: Control
var helmet: Texture2D
var face: Texture2D
var hands: Texture2D
var portrait: Texture2D
var gothic: Font
var plain: Font
var marks := {}
var done := false
var saved_offset := Vector2.ZERO
var saved_zoom := Vector2.ONE

func _ready() -> void:
	layer = 40
	helmet = load("res://assets/close/close_flagelado_elmo.png")
	hands = load("res://assets/close/close_revelacao_maos.png")
	portrait = load("res://assets/close/close_01.png")
	face = load("res://assets/close/close_dois_rostos.png")
	if ResourceLoader.exists("res://assets/fonts/UnifrakturMaguntia-Book.ttf"):
		gothic = load("res://assets/fonts/UnifrakturMaguntia-Book.ttf")
	plain = ThemeDB.fallback_font
	panel = Control.new()
	panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.draw.connect(_paint)
	add_child(panel)
	var cam: Camera2D = game.player.camera
	saved_offset = cam.offset
	saved_zoom = cam.zoom
	game.player.cinematic_focus = true
	game.player.controllable = false
	game.player.velocity = Vector2.ZERO
	var b = game.partner
	if b != null and is_instance_valid(b):
		b.set_physics_process(false)
		b.velocity = Vector2.ZERO
	game.soundscape.play_sfx("sino_surdo")

## Quanto de cada camada está na tela em um instante (também usado pelos testes).
func weights(e: float) -> Dictionary:
	return {
		"bars": smoothstep(0.0, 1.0, e),
		"helmet": smoothstep(3.2,4.2,e) * (1.0-smoothstep(11.0,12.0,e)),
		"hands": smoothstep(11.0,12.0,e) * (1.0-smoothstep(16.0,17.5,e)),
		"lift": smoothstep(13.4, 16.0, e),
		"face": smoothstep(16.0, 17.5, e) * (1.0 - smoothstep(34.0, 35.4, e)),
		"black": smoothstep(41.4, 43.6, e),
	}

func can_skip() -> bool:
	return t >= 3.0

func _process(delta: float) -> void:
	if done: return
	t += delta
	var cam: Camera2D = game.player.camera
	if boss != null and is_instance_valid(boss):
		# A câmera deixa o Penitente e se aproxima de quem está de joelhos.
		var want := clampf(boss.global_position.x - game.player.global_position.x, -420.0, 420.0)
		cam.offset.x = lerpf(cam.offset.x, want, minf(delta * 1.6, 1.0))
		cam.zoom = cam.zoom.lerp(saved_zoom * 1.25, minf(delta * 0.8, 1.0))
		var b = game.partner
		if b != null and is_instance_valid(b):
			# Beatriz caminha até ele e para diante dos joelhos.
			var goal: float = boss.global_position.x - 64.0 * (1.0 if b.global_position.x <= boss.global_position.x else -1.0)
			var gap: float = goal - b.global_position.x
			if t > 2.6 and absf(gap) > 6.0:
				var step := minf(absf(gap), maxf(150.0, absf(gap) / maxf(7.6 - t, 0.3)) * delta)
				b.global_position.x += signf(gap) * step
				b.global_position.y = boss.global_position.y
				b.facing = 1 if gap > 0.0 else -1
				b.animator.select("run", b.facing)
			else:
				b.facing = 1 if boss.global_position.x > b.global_position.x else -1
				b.animator.select("idle", b.facing)
	if t >= 8.6 and not marks.has("helmet"):
		marks["helmet"] = true
		game.soundscape.play_sfx("corrente_cede")
		game.soundscape.play_sfx("capacete_sai")
	if t >= 14.4 and not marks.has("face"):
		marks["face"] = true
		game.soundscape.play_sfx("bell")
	if can_skip() and (Input.is_action_just_pressed("confirm") or Input.is_action_just_pressed("interact")):
		t = maxf(t, 41.4)
	panel.queue_redraw()
	if t >= DURATION:
		_finish()

func _finish() -> void:
	if done: return
	done = true
	var cam: Camera2D = game.player.camera
	cam.offset = saved_offset
	cam.zoom = saved_zoom
	game.player.cinematic_focus = false
	var b = game.partner
	if b != null and is_instance_valid(b): b.set_physics_process(true)
	game.finish_finale()

func _paint() -> void:
	var vs := panel.size
	var w := weights(t)
	var bar: float = 86.0 * w.bars
	panel.draw_rect(Rect2(0, 0, vs.x, bar), Color.BLACK)
	panel.draw_rect(Rect2(0, vs.y - bar, vs.x, bar), Color.BLACK)
	var shade: float = maxf(maxf(w.helmet,w.hands),w.face)
	if shade > 0.0:
		panel.draw_rect(Rect2(Vector2.ZERO, vs), Color(0, 0, 0, 0.86 * shade))
	var side := vs.y * 0.70
	var box := Rect2(Vector2((vs.x - side) * 0.5, (vs.y - side) * 0.40), Vector2(side, side))
	if w.face > 0.0:
		# O rosto, um pouco maior a cada instante: a câmera não desvia.
		var grow := 1.0 + clampf(t - 14.0, 0.0, 22.0) * 0.004
		var fr := Rect2(box.get_center() - box.size * grow * 0.5, box.size * grow)
		panel.draw_texture_rect(face, fr, false, Color(1, 1, 1, w.face))
	if w.helmet > 0.0:
		# Primeiro a grade do Flagelado; o gesto de levantar o capirote vem no close seguinte.
		var up: float = 0.0
		panel.draw_texture_rect(helmet, Rect2(box.position + Vector2(0, -up), box.size), false, Color(1, 1, 1, w.helmet))
	if w.hands > 0.0:
		panel.draw_texture_rect(hands,box,false,Color(1,1,1,w.hands))
	for line in LINES:
		var a: float = smoothstep(line[0], line[0] + 0.7, t) * (1.0 - smoothstep(line[1] - 0.7, line[1], t))
		if a <= 0.0: continue
		var parts: PackedStringArray = str(line[2]).split("\n")
		for i in range(parts.size()):
			var y: float = vs.y - bar - 64.0 + i * 30.0 - (parts.size() - 1) * 15.0
			var font: Font = gothic if gothic != null and parts[i] == "É o seu." else plain
			var size := 34 if parts[i] == "É o seu." else 21
			panel.draw_string(font, Vector2(2, y + 2), parts[i], HORIZONTAL_ALIGNMENT_CENTER, vs.x, size, Color(0, 0, 0, 0.8 * a))
			panel.draw_string(font, Vector2(0, y), parts[i], HORIZONTAL_ALIGNMENT_CENTER, vs.x, size, Color(0.95, 0.88, 0.76, a))
	if can_skip() and t < 41.0:
		panel.draw_string(plain, Vector2(0, vs.y - 16), "[E] Seguir", HORIZONTAL_ALIGNMENT_CENTER, vs.x, 13, Color(0.7, 0.66, 0.6, 0.6))
	if w.black > 0.0:
		panel.draw_rect(Rect2(Vector2.ZERO, vs), Color(0, 0, 0, w.black))
