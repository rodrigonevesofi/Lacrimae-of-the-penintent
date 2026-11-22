extends Node2D
## O Vale dos Flagelados — "onde a culpa permanece".
## Cenário vivo em camadas pintadas separadas: cada peça se move a cada quadro. O céu de crepúsculo, o sol,
## as nuvens, os desfiladeiros em camadas (paralaxe), a névoa, os enforcados e as gaiolas que balançam ao vento
## e reagem à luta, as árvores mortas, os corvos e as cinzas que caem. O vale também muda com o combate:
## a cada parte da armadura que o chefe perde, o céu escurece e o vento aumenta (ver set_mood).
##
## Há dois nós com este script: o fundo (front = false), atrás dos personagens, e o primeiro plano
## (front = true), à frente deles.

const X0 := 30200.0
const X1 := 33600.0
const FLOOR := 600.0
const CAM_Y := 380.0

var paints := {}
var game
## Camada da frente (z 9 na main.tscn): partículas e silhuetas que passam à frente da cena.
@export var front := false
var t := 0.0
## 0 = crepúsculo calmo; 1 = o vale inteiro em sangue.
var mood := 0.0
var mood_target := 0.0
var hanged: Array = []
var trees: Array = []
var ridges: Array = []
var crows: Array = []
var stones: Array = []
var ash: CPUParticles2D
var embers: CPUParticles2D

func _ready() -> void:
	for name in ["ceu","desfiladeiro_longe","desfiladeiro_meio","desfiladeiro_perto","forcas","enforcados","arvores_mortas","chao"]:
		paints[name]=load("res://assets/vale/"+name+".png")
	paints["corvo"]=load("res://assets/animation/corvo.png")
	var rng := RandomNumberGenerator.new()
	rng.seed = 1746
	if front:
		_build_particles()
		# Silhuetas de primeiro plano: postes e galhos que passam à frente da cena.
		for i in range(4):
			hanged.append({"x": X0 + 380.0 + i * 900.0 + rng.randf_range(-90, 90), "layer": 1.4, "kind": "pole", "len": rng.randf_range(160, 260), "h": rng.randf_range(520, 700), "ang": 0.0, "vel": 0.0, "phase": rng.randf() * TAU, "side": 1 if i % 2 == 0 else -1})
		return
	# Enforcados e gaiolas em três profundidades. Os de camada 1.0 estão no plano do jogo.
	var kinds := ["body", "cage", "body", "body", "cage"]
	for i in range(9):
		hanged.append({"x": X0 + 420.0 + i * 360.0 + rng.randf_range(-70, 70), "layer": 1.0, "kind": kinds[i % kinds.size()], "len": rng.randf_range(90, 190), "h": rng.randf_range(430, 560), "ang": 0.0, "vel": 0.0, "phase": rng.randf() * TAU, "side": 1 if rng.randf() < 0.5 else -1})
	for i in range(11):
		hanged.append({"x": X0 + 200.0 + i * 330.0 + rng.randf_range(-90, 90), "layer": 0.72, "kind": kinds[(i + 2) % kinds.size()], "len": rng.randf_range(70, 150), "h": rng.randf_range(360, 520), "ang": 0.0, "vel": 0.0, "phase": rng.randf() * TAU, "side": 1 if rng.randf() < 0.5 else -1})
	for i in range(14):
		hanged.append({"x": X0 + 100.0 + i * 270.0 + rng.randf_range(-80, 80), "layer": 0.5, "kind": "body", "len": rng.randf_range(50, 110), "h": rng.randf_range(300, 430), "ang": 0.0, "vel": 0.0, "phase": rng.randf() * TAU, "side": 1 if rng.randf() < 0.5 else -1})
	# Árvores mortas: galhos gerados uma vez, depois apenas balançados pelo vento.
	for i in range(10):
		var layer := 1.0 if i % 2 == 0 else 0.72
		var segments: Array = []
		_grow(segments, Vector2.ZERO, -PI / 2 + rng.randf_range(-0.25, 0.25), rng.randf_range(90, 150), 5, rng)
		trees.append({"x": X0 + 300.0 + i * 330.0 + rng.randf_range(-100, 100), "layer": layer, "seg": segments, "phase": rng.randf() * TAU})
	# Desfiladeiros: três cristas de rocha, da mais distante à mais próxima.
	for k in range(3):
		var pts := PackedVector2Array()
		var base: float = [250.0, 330.0, 420.0][k]
		var amp: float = [150.0, 190.0, 150.0][k]
		var x := X0 - 1200.0
		while x <= X1 + 1200.0:
			var n := sin(x * 0.0021 + k * 1.7) * 0.5 + sin(x * 0.0057 + k * 4.1) * 0.3 + sin(x * 0.013 + k) * 0.2
			# Agulhas de pedra: picos estreitos e altos, como no vale da referência do autor.
			var spire := pow(maxf(sin(x * 0.0038 + k * 2.3), 0.0), 6.0) * 260.0
			pts.append(Vector2(x, base - n * amp - spire))
			x += 40.0
		ridges.append({"pts": pts, "layer": [0.22, 0.4, 0.62][k]})
	for i in range(6):
		crows.append({"cx": X0 + 500.0 + i * 520.0, "cy": rng.randf_range(-40, 140), "r": rng.randf_range(90, 220), "w": rng.randf_range(0.25, 0.5) * (1 if i % 2 == 0 else -1), "phase": rng.randf() * TAU})
	for i in range(70):
		stones.append({"x": rng.randf_range(X0, X1), "w": rng.randf_range(10, 46), "h": rng.randf_range(4, 18), "kind": rng.randi_range(0, 3)})

func _grow(out: Array, from: Vector2, angle: float, length: float, depth: int, rng: RandomNumberGenerator) -> void:
	var to := from + Vector2(cos(angle), sin(angle)) * length
	out.append([from, to, float(depth)])
	if depth <= 1: return
	var branches := 2 if depth > 2 else rng.randi_range(1, 2)
	for b in range(branches):
		_grow(out, to, angle + rng.randf_range(-0.75, 0.75), length * rng.randf_range(0.55, 0.75), depth - 1, rng)

func _build_particles() -> void:
	# Cinzas que caem sobre o vale inteiro, levadas pelo vento.
	ash = CPUParticles2D.new()
	ash.amount = 90
	ash.lifetime = 7.0
	ash.preprocess = 7.0
	ash.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	ash.emission_rect_extents = Vector2(900, 10)
	ash.direction = Vector2(-0.35, 1.0)
	ash.spread = 18.0
	ash.gravity = Vector2(-10, 14)
	ash.initial_velocity_min = 30.0
	ash.initial_velocity_max = 80.0
	ash.scale_amount_min = 1.2
	ash.scale_amount_max = 3.0
	ash.color = Color(0.78, 0.7, 0.66, 0.55)
	add_child(ash)
	# Brasas que sobem do chão.
	embers = CPUParticles2D.new()
	embers.amount = 26
	embers.lifetime = 5.0
	embers.preprocess = 5.0
	embers.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	embers.emission_rect_extents = Vector2(800, 6)
	embers.direction = Vector2(0.2, -1.0)
	embers.spread = 25.0
	embers.gravity = Vector2(0, -22)
	embers.initial_velocity_min = 20.0
	embers.initial_velocity_max = 70.0
	embers.scale_amount_min = 1.0
	embers.scale_amount_max = 2.2
	embers.color = Color(1.0, 0.45, 0.2, 0.8)
	add_child(embers)

## O vale reage à luta: 0 no começo, 1 quando o chefe perde a última parte da armadura.
func set_mood(value: float) -> void:
	mood_target = clampf(value, 0.0, 1.0)

## Um golpe forte no chão faz balançar tudo o que está pendurado por perto.
func impulse(at_x: float, strength: float) -> void:
	for h in hanged:
		var d: float = absf(h.x - at_x)
		if d < 700.0:
			h.vel += strength * (1.0 - d / 700.0) * (1.0 if h.x >= at_x else -1.0) * (1.0 if h.layer >= 1.0 else 0.4)

func _active() -> bool:
	return game != null and game.exploration != null and game.exploration.room == "vale"

func _process(delta: float) -> void:
	visible = _active()
	if not visible:
		if ash: ash.emitting = false
		if embers: embers.emitting = false
		return
	t += delta
	mood = move_toward(mood, mood_target, delta * 0.25)
	var wind := 0.10 + 0.22 * mood
	var player_x: float = game.player.global_position.x
	var player_v: float = game.player.velocity.x
	for h in hanged:
		# Pêndulo amortecido, empurrado por um vento que vem em rajadas.
		var push: float = wind * (sin(t * 0.6 + h.phase) + 0.5 * sin(t * 1.7 + h.phase * 2.0))
		if h.layer >= 1.0 and absf(h.x - player_x) < 46.0 and absf(player_v) > 160.0:
			# Passar correndo sob um enforcado o faz balançar.
			h.vel += signf(player_v) * 0.9 * delta * 6.0
		var acc: float = -5.5 * h.ang - 0.9 * h.vel + push * 2.2
		h.vel += acc * delta
		h.ang += h.vel * delta
	if ash:
		var cam: Vector2 = game.player.camera.get_screen_center_position()
		ash.emitting = true
		ash.position = cam + Vector2(120, -420)
		ash.gravity = Vector2(-10.0 - 60.0 * mood, 14.0)
		ash.amount = 90
		embers.emitting = true
		embers.position = Vector2(cam.x, FLOOR - 4.0)
	queue_redraw()

func _px(wx: float, layer: float, cam: Vector2) -> float:
	return cam.x * (1.0 - layer) + wx * layer

func _py(wy: float, layer: float, cam: Vector2) -> float:
	return wy + (cam.y - CAM_Y) * (1.0 - layer) * 0.7

func _draw() -> void:
	if not _active(): return
	var cam: Vector2 = game.player.camera.get_screen_center_position()
	if not paints.is_empty():
		_draw_painted(cam)
		return
	if front:
		_draw_front(cam)
		return
	var view := Rect2(cam - Vector2(760, 470), Vector2(1520, 940))
	# ---- céu: do roxo escuro no alto ao laranja no horizonte; em sangue quando a luta avança
	var top := Color(0.13, 0.07, 0.11).lerp(Color(0.10, 0.01, 0.02), mood)
	var mid := Color(0.56, 0.24, 0.22).lerp(Color(0.42, 0.04, 0.05), mood)
	var low := Color(0.93, 0.56, 0.40).lerp(Color(0.72, 0.12, 0.08), mood)
	var horizon: float = _py(330.0, 0.1, cam)
	draw_polygon(PackedVector2Array([view.position, Vector2(view.end.x, view.position.y), Vector2(view.end.x, horizon - 190.0), Vector2(view.position.x, horizon - 190.0)]), PackedColorArray([top, top, mid, mid]))
	draw_polygon(PackedVector2Array([Vector2(view.position.x, horizon - 190.0), Vector2(view.end.x, horizon - 190.0), Vector2(view.end.x, view.end.y), Vector2(view.position.x, view.end.y)]), PackedColorArray([mid, mid, low, low]))
	# ---- sol pálido, com halo que pulsa devagar
	var sun := Vector2(_px(X0 + 2300.0, 0.06, cam) + 160.0, _py(170.0, 0.06, cam))
	var pulse := 1.0 + 0.04 * sin(t * 0.8)
	for i in range(5):
		draw_circle(sun, (150.0 - i * 22.0) * pulse, Color(1.0, 0.72, 0.5, 0.05 + i * 0.03).lerp(Color(0.9, 0.15, 0.1, 0.06 + i * 0.03), mood))
	draw_circle(sun, 46.0, Color(1.0, 0.9, 0.78).lerp(Color(0.95, 0.3, 0.2), mood))
	# ---- nuvens em faixas, arrastadas pelo vento
	for i in range(7):
		var cx: float = fposmod(X0 + i * 620.0 - t * (9.0 + i * 2.0) - X0 + 800.0, X1 - X0 + 1600.0) + X0 - 800.0
		var cp := Vector2(_px(cx, 0.12, cam), _py(40.0 + (i % 3) * 70.0, 0.12, cam))
		_cloud(cp, 260.0 + (i % 4) * 70.0, 20.0 + (i % 3) * 8.0, Color(0.35, 0.12, 0.14, 0.42).lerp(Color(0.2, 0.0, 0.02, 0.6), mood))
	# ---- desfiladeiros em três camadas, com névoa entre elas
	var ridge_colors := [Color(0.66, 0.33, 0.29), Color(0.42, 0.18, 0.18), Color(0.20, 0.09, 0.11)]
	for k in range(3):
		var layer: float = ridges[k].layer
		var poly := PackedVector2Array()
		for v in ridges[k].pts:
			var sx: float = _px(v.x, layer, cam)
			if sx < view.position.x - 80.0 or sx > view.end.x + 80.0: continue
			poly.append(Vector2(sx, _py(v.y, layer, cam)))
		if poly.size() >= 2:
			poly.append(Vector2(poly[poly.size() - 1].x, view.end.y))
			poly.append(Vector2(poly[0].x, view.end.y))
			draw_colored_polygon(poly, ridge_colors[k].lerp(Color(0.12, 0.01, 0.02), mood * 0.7))
		_mist(cam, view, _py(360.0 + k * 60.0, layer, cam), 70.0 + k * 20.0, 14.0 + k * 9.0, k)
		# enforcados distantes, pequenos, entre as cristas
		for h in hanged:
			if (k == 1 and is_equal_approx(h.layer, 0.5)) or (k == 2 and is_equal_approx(h.layer, 0.72)):
				_draw_gallows(h, cam, view)
		if k == 2:
			for tree in trees:
				if not is_equal_approx(tree.layer, 1.0): _draw_tree(tree, cam, view)
	# ---- corvos em círculos
	for c in crows:
		var a: float = t * c.w + c.phase
		var cp := Vector2(_px(c.cx + cos(a) * c.r, 0.5, cam), _py(c.cy + sin(a) * c.r * 0.35, 0.5, cam))
		if not view.has_point(cp): continue
		var flap := sin(t * 9.0 + c.phase) * 5.0
		draw_polyline(PackedVector2Array([cp + Vector2(-8, -flap), cp, cp + Vector2(8, -flap)]), Color(0.05, 0.02, 0.03), 2.0)
	# ---- paredões que fecham o vale
	draw_colored_polygon(PackedVector2Array([Vector2(X0 - 900, -900), Vector2(X0 + 40, -900), Vector2(X0 + 150, -200), Vector2(X0 + 60, 200), Vector2(X0 + 200, FLOOR), Vector2(X0 - 900, FLOOR)]), Color(0.07, 0.04, 0.05))
	draw_colored_polygon(PackedVector2Array([Vector2(X1 + 900, -900), Vector2(X1 - 60, -900), Vector2(X1 - 170, -150), Vector2(X1 - 70, 240), Vector2(X1 - 220, FLOOR), Vector2(X1 + 900, FLOOR)]), Color(0.07, 0.04, 0.05))
	# ---- plano do jogo: árvores, forcas, gaiolas
	for tree in trees:
		if is_equal_approx(tree.layer, 1.0): _draw_tree(tree, cam, view)
	for h in hanged:
		if is_equal_approx(h.layer, 1.0): _draw_gallows(h, cam, view)
	# ---- chão: terra escura, pedras, ossos e estacas; uma linha de luz vermelha na borda
	draw_rect(Rect2(X0 - 900, FLOOR, X1 - X0 + 1800, 600), Color(0.06, 0.035, 0.04))
	for s in stones:
		if s.x < view.position.x - 60.0 or s.x > view.end.x + 60.0: continue
		match s.kind:
			0, 1:
				draw_colored_polygon(PackedVector2Array([Vector2(s.x - s.w * 0.5, FLOOR + 1), Vector2(s.x - s.w * 0.3, FLOOR - s.h), Vector2(s.x + s.w * 0.25, FLOOR - s.h * 0.8), Vector2(s.x + s.w * 0.5, FLOOR + 1)]), Color(0.11, 0.06, 0.07))
			2:
				draw_line(Vector2(s.x, FLOOR), Vector2(s.x + s.w * 0.2, FLOOR - s.h * 2.4), Color(0.1, 0.05, 0.06), 3.0)
			3:
				draw_line(Vector2(s.x - s.w * 0.4, FLOOR - 2), Vector2(s.x + s.w * 0.4, FLOOR - 3), Color(0.55, 0.47, 0.4, 0.8), 2.0)
				draw_circle(Vector2(s.x - s.w * 0.4, FLOOR - 2), 2.5, Color(0.55, 0.47, 0.4, 0.8))
	draw_line(Vector2(X0 - 900, FLOOR), Vector2(X1 + 900, FLOOR), Color(0.75, 0.3, 0.22, 0.55).lerp(Color(0.8, 0.08, 0.06, 0.8), mood), 2.0)
	_mist(cam, view, FLOOR - 26.0, 60.0, 30.0, 5)

func _draw_front(cam: Vector2) -> void:
	var view := Rect2(cam - Vector2(760, 470), Vector2(1520, 940))
	# Névoa rasteira à frente dos personagens e postes em silhueta no primeiro plano.
	_mist(cam, view, FLOOR + 6.0, 80.0, 44.0, 9)
	for h in hanged:
		var sx: float = _px(h.x, h.layer, cam)
		if sx < view.position.x - 200.0 or sx > view.end.x + 200.0: continue
		var base := Vector2(sx, FLOOR + 130.0)
		var top := base + Vector2(0, -h.h)
		draw_line(base, top, Color(0.02, 0.01, 0.015, 0.78), 11.0)
		draw_line(top, top + Vector2(h.side * 130.0, 0), Color(0.02, 0.01, 0.015, 0.78), 8.0)
		var rope_top: Vector2 = top + Vector2(h.side * 110.0, 0)
		var end: Vector2 = rope_top + Vector2(sin(h.ang), cos(h.ang)) * h.len
		draw_line(rope_top, end, Color(0.02, 0.01, 0.015, 0.78), 3.0)
		draw_set_transform(end, -h.ang * 1.1, Vector2(1.5, 1.5))
		_body(Color(0.02, 0.01, 0.015, 0.78), h.phase)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	# Bordas escuras: o vale fecha sobre quem luta.
	var shade := Color(0.03, 0.0, 0.01, 0.35 + 0.25 * mood)
	var clear := Color(0.03, 0.0, 0.01, 0.0)
	draw_polygon(PackedVector2Array([view.position, Vector2(view.position.x + 260, view.position.y), Vector2(view.position.x + 260, view.end.y), Vector2(view.position.x, view.end.y)]), PackedColorArray([shade, clear, clear, shade]))
	draw_polygon(PackedVector2Array([Vector2(view.end.x - 260, view.position.y), Vector2(view.end.x, view.position.y), view.end, Vector2(view.end.x - 260, view.end.y)]), PackedColorArray([clear, shade, shade, clear]))

func _cloud(center: Vector2, width: float, height: float, color: Color) -> void:
	var pts := PackedVector2Array()
	for i in range(14):
		var a := TAU * i / 14.0
		pts.append(center + Vector2(cos(a) * width, sin(a) * height * (0.7 + 0.3 * sin(a * 3.0 + center.x * 0.01))))
	draw_colored_polygon(pts, color)

## Uma faixa de névoa que desliza de lado, mais densa embaixo.
func _mist(cam: Vector2, view: Rect2, y: float, height: float, speed: float, seed_k: int) -> void:
	var col := Color(0.62, 0.34, 0.30, 0.20).lerp(Color(0.45, 0.05, 0.05, 0.30), mood)
	var clear := Color(col.r, col.g, col.b, 0.0)
	var span := 520.0
	var offset: float = fposmod(t * speed + seed_k * 137.0, span)
	var x: float = view.position.x - span + offset - fposmod(view.position.x, span)
	while x < view.end.x + span:
		var wob := sin(x * 0.004 + t * 0.5 + seed_k) * 14.0
		draw_polygon(PackedVector2Array([Vector2(x, y - height + wob), Vector2(x + span * 0.5, y - height * 0.6 + wob), Vector2(x + span, y - height + wob), Vector2(x + span, y + 34.0), Vector2(x, y + 34.0)]), PackedColorArray([clear, clear, clear, col, col]))
		x += span

func _draw_tree(tree: Dictionary, cam: Vector2, view: Rect2) -> void:
	var sx: float = _px(tree.x, tree.layer, cam)
	if sx < view.position.x - 260.0 or sx > view.end.x + 260.0: return
	var base := Vector2(sx, _py(FLOOR, tree.layer, cam))
	var s: float = tree.layer
	var col := Color(0.07, 0.035, 0.045) if tree.layer >= 1.0 else Color(0.14, 0.07, 0.085)
	for seg in tree.seg:
		# Os galhos mais finos oscilam mais com o vento.
		var sway: float = sin(t * 0.9 + tree.phase + seg[0].y * 0.02) * (6.0 - seg[2]) * (0.6 + 1.4 * mood)
		var a: Vector2 = base + seg[0] * s * 1.6 + Vector2(sway * (5.0 - seg[2]) * 0.2, 0)
		var b: Vector2 = base + seg[1] * s * 1.6 + Vector2(sway * (6.0 - seg[2]) * 0.2, 0)
		draw_line(a, b, col, maxf(1.5, seg[2] * 2.4 * s))

func _draw_gallows(h: Dictionary, cam: Vector2, view: Rect2) -> void:
	var sx: float = _px(h.x, h.layer, cam)
	if sx < view.position.x - 240.0 or sx > view.end.x + 240.0: return
	var s: float = h.layer
	var col := Color(0.06, 0.03, 0.04) if h.layer >= 1.0 else (Color(0.13, 0.065, 0.08) if h.layer > 0.6 else Color(0.24, 0.11, 0.12))
	var base := Vector2(sx, _py(FLOOR, h.layer, cam))
	var top := base + Vector2(0, -h.h * s)
	var arm: Vector2 = top + Vector2(h.side * 96.0 * s, 0)
	draw_line(base, top, col, 9.0 * s)
	draw_line(top, arm, col, 7.0 * s)
	draw_line(top + Vector2(0, 46.0 * s), top + Vector2(h.side * 50.0 * s, 0), col, 4.0 * s)
	var rope_top: Vector2 = top + Vector2(h.side * 82.0 * s, 0)
	var end: Vector2 = rope_top + Vector2(sin(h.ang), cos(h.ang)) * h.len * s
	draw_line(rope_top, end, col, maxf(1.0, 2.0 * s))
	draw_set_transform(end, -h.ang * 1.15, Vector2(s, s))
	if h.kind == "cage": _cage(col, h.phase)
	else: _body(col, h.phase)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

## Um enforcado em silhueta: cabeça tombada, mãos atadas, pés que giram devagar.
func _body(col: Color, phase: float) -> void:
	var turn := sin(t * 0.5 + phase)
	draw_circle(Vector2(2.0 * turn, 8), 7.0, col)
	draw_colored_polygon(PackedVector2Array([Vector2(-9, 14), Vector2(9, 14), Vector2(7 + turn, 52), Vector2(-7 + turn, 52)]), col)
	draw_line(Vector2(-4 + turn, 50), Vector2(-6 + turn * 3.0, 86), col, 5.0)
	draw_line(Vector2(4 + turn, 50), Vector2(5 + turn * 3.0, 88), col, 5.0)
	draw_line(Vector2(-9, 18), Vector2(-3, 44), col, 4.0)
	draw_line(Vector2(9, 18), Vector2(3, 44), col, 4.0)

## Uma gaiola de ferro pendurada, com alguém encolhido dentro.
func _cage(col: Color, phase: float) -> void:
	draw_arc(Vector2(0, 16), 22.0, PI, TAU, 12, col, 3.0)
	for i in range(5):
		var x := -22.0 + i * 11.0
		draw_line(Vector2(x, 16), Vector2(x, 86), col, 2.5)
	draw_line(Vector2(-23, 86), Vector2(23, 86), col, 4.0)
	draw_line(Vector2(-23, 50), Vector2(23, 50), col, 2.0)
	var breath := sin(t * 1.3 + phase) * 1.2
	draw_circle(Vector2(-2, 52 + breath), 6.0, col)
	draw_colored_polygon(PackedVector2Array([Vector2(-10, 58 + breath), Vector2(8, 58 + breath), Vector2(12, 84), Vector2(-12, 84)]), col)

## As pinturas são peças separadas: a física dos pêndulos, partículas e paralaxe permanece ativa.
func _draw_painted(cam:Vector2) -> void:
	var view:=Rect2(cam-Vector2(760,470),Vector2(1520,940))
	if front:
		_mist(cam,view,FLOOR+6,80,44,9)
		for h in hanged:
			var x:=_px(h.x,h.layer,cam)
			if x>view.position.x-250 and x<view.end.x+250:
				draw_texture_rect_region(paints.forcas,Rect2(x-100,FLOOR-h.h,200,h.h),Rect2(0,0,256,512),Color(0.22,0.18,0.20,0.9))
		return
	var sky_tint:=Color.WHITE.lerp(Color(0.45,0.20,0.24),mood)
	draw_texture_rect(paints.ceu,Rect2(cam-Vector2(1024,470),Vector2(2048,940)),false,sky_tint)
	for i in range(3):
		var layer:float=[0.22,0.4,0.62][i]
		var origin:=_px(X0,layer,cam)
		var first:=int(floorf((view.position.x-origin)/4096.0))
		var start:=first*4096.0+origin
		var name:String=["desfiladeiro_longe","desfiladeiro_meio","desfiladeiro_perto"][i]
		for tile in range(2):
			# A repetição espelhada encontra exatamente a mesma borda, sem emenda vertical.
			var mirrored:=posmod(first+tile,2)==1
			draw_set_transform(Vector2(start+tile*4096+(4096 if mirrored else 0),FLOOR-720),0,Vector2(-1 if mirrored else 1,1))
			draw_texture_rect(paints[name],Rect2(0,0,4096,720),false,Color.WHITE.lerp(Color(0.42,0.18,0.22),mood*0.7))
			draw_set_transform(Vector2.ZERO)
		_mist(cam,view,360+i*60,70+i*20,14+i*9,i)
		for h in hanged:
			if (i==1 and is_equal_approx(h.layer,0.5)) or (i==2 and is_equal_approx(h.layer,0.72)):_paint_gallows(h,cam,view)
	for tree in trees:
		var x:=_px(tree.x,tree.layer,cam)
		if x<view.position.x-250 or x>view.end.x+250:continue
		var size:=Vector2(230,460)*float(tree.layer)
		var sway:=sin(t*0.9+tree.phase)*(0.005+0.009*mood)
		draw_set_transform(Vector2(x,FLOOR),sway)
		draw_texture_rect_region(paints.arvores_mortas,Rect2(-size.x/2,-size.y,size.x,size.y),Rect2((int(tree.x)%4)*256,0,256,512))
		draw_set_transform(Vector2.ZERO)
	for h in hanged:
		if is_equal_approx(h.layer,1.0):_paint_gallows(h,cam,view)
	for c in crows:
		var a:float=t*c.w+c.phase
		var at:=Vector2(_px(c.cx+cos(a)*c.r,0.5,cam),_py(c.cy+sin(a)*c.r*0.35,0.5,cam))
		if view.has_point(at):draw_texture_rect_region(paints.corvo,Rect2(at-Vector2(16,16),Vector2(32,32)),Rect2((int(t*10+c.phase)%6)*128,0,128,128))
	draw_rect(Rect2(X0-900,FLOOR,X1-X0+1800,600),Color("110b0f"))
	var tile_start:=floorf(view.position.x/1024)*1024
	for i in range(3):
		var mirrored:=posmod(int(tile_start/1024)+i,2)==1
		draw_set_transform(Vector2(tile_start+i*1024+(1024 if mirrored else 0),FLOOR),0,Vector2(-1 if mirrored else 1,1))
		draw_texture_rect(paints.chao,Rect2(0,0,1024,128),false)
		draw_set_transform(Vector2.ZERO)
	_mist(cam,view,FLOOR-26,60,30,5)

func _paint_gallows(h:Dictionary,cam:Vector2,view:Rect2) -> void:
	var x:=_px(h.x,h.layer,cam)
	if x<view.position.x-240 or x>view.end.x+240:return
	var s:float=h.layer
	var base:=Vector2(x,_py(FLOOR,s,cam))
	var tall:float=h.h*s
	var wide:=tall*0.5
	var variation:=int(h.x)%6
	draw_set_transform(base,0,Vector2(h.side,1))
	draw_texture_rect_region(paints.forcas,Rect2(-wide/2,-tall,wide,tall),Rect2(variation*256,0,256,512),Color(0.8,0.7,0.72,1))
	draw_set_transform(Vector2.ZERO)
	var pivot:=base+Vector2(h.side*wide*0.32,-tall*0.91)
	var index:=4+int(h.x)%4 if h.kind=="cage" else int(h.x)%4
	draw_set_transform(pivot,-h.ang*1.15,Vector2(s*0.65,s*0.65))
	draw_texture_rect_region(paints.enforcados,Rect2(-64,0,128,256),Rect2(index*128,0,128,256))
	draw_set_transform(Vector2.ZERO)
