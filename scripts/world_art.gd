extends Node2D
## Original procedural scenery; geometry matches main.gd's collision layout.

var game
var redraw_clock := 0.0
var sky: Sprite2D
var sky_next: Sprite2D
var zone_textures: Array[Texture2D] = []
var zone := 0
var zone_pending := 0
var sky_mix := 0.0
var sky_changing := false
var iria_animation
var npc_art: AtlasTexture
var interior: Texture2D
var background_layer: CanvasLayer
const GROUND_Y := 600.0
const INK := Color("17191e")
const STONE := Color("34383d")
const EDGE := Color("68665f")
const GOLD := Color("a58a59")

func _ready() -> void:
	var surface := CanvasItemMaterial.new()
	surface.light_mode = CanvasItemMaterial.LIGHT_MODE_UNSHADED
	material = surface
	npc_art = AtlasTexture.new()
	npc_art.atlas = load("res://assets/characters.png")
	npc_art.region = Rect2(768, 0, 384, 1000)
	interior = load("res://assets/basilica.png")
	iria_animation = preload("res://scripts/actor_animation.gd").new()
	iria_animation.configure("iria", 0.38)
	var iria_anchor := Node2D.new()
	iria_anchor.position = Vector2(990, 600)
	add_child(iria_anchor)
	iria_anchor.add_child(iria_animation)
	background_layer = CanvasLayer.new()
	background_layer.layer = -10
	add_child(background_layer)
	var fill := ColorRect.new()
	fill.color = Color("303e49")
	fill.size = Vector2(1280, 720)
	background_layer.add_child(fill)
	for name in ["court", "gallery", "gates"]:
		zone_textures.append(load("res://assets/" + name + ".png"))
	if ResourceLoader.exists("res://assets/city.png"):
		sky = Sprite2D.new()
		sky.texture = zone_textures[0]
		sky.centered = false
		sky.scale = Vector2(1920, 1080) / sky.texture.get_size()
		background_layer.add_child(sky)
		sky_next = Sprite2D.new()
		sky_next.centered = false
		sky_next.modulate.a = 0
		background_layer.add_child(sky_next)

func _process(delta: float) -> void:
	if iria_animation:
		iria_animation.select("talk" if game.message_title == "IRIA — A TESTEMUNHA" and game.message_text != "" else "idle", -1)
	if sky and game.player:
		var desired := 0 if game.player.position.x < 2270 else (1 if game.player.position.x < 3300 else 2)
		if desired != zone and not sky_changing:
			zone_pending = desired
			sky_next.texture = zone_textures[desired]
			sky_next.scale = Vector2(1920, 1080) / sky_next.texture.get_size()
			sky_mix = 0
			sky_changing = true
		sky.position = Vector2(-fmod(game.player.position.x * 0.06, 350), -170)
		sky_next.position = sky.position
		if sky_changing:
			sky_mix = minf(sky_mix + delta, 1)
			sky_next.modulate.a = sky_mix
			if sky_mix >= 1:
				zone = zone_pending
				sky.texture = zone_textures[zone]
				sky_next.modulate.a = 0
				sky_changing = false
	redraw_clock += delta
	if redraw_clock >= 1.0 / 24.0:
		redraw_clock = 0.0
		queue_redraw()

func polygon(points: Array, color: Color) -> void:
	draw_colored_polygon(PackedVector2Array(points), color)

func arch(x: float, y: float, width: float, height: float, color: Color, thickness: float) -> void:
	var points := PackedVector2Array()
	points.append(Vector2(x, y))
	points.append(Vector2(x, y - height * 0.62))
	for i in range(17):
		var f := float(i) / 16.0
		points.append(Vector2(x + width * f, y - height * (0.62 + 0.38 * sin(f * PI))))
	points.append(Vector2(x + width, y))
	draw_polyline(points, color, thickness, true)

func candle(pos: Vector2, height: float, phase: float) -> void:
	draw_rect(Rect2(pos.x - 2, pos.y - height, 4, height), Color("b9a682"))
	draw_line(pos + Vector2(-2, -height + 3), pos + Vector2(-2, -height + 8), Color("e5cfa4"), 1)
	var tip := pos + Vector2(sin(game.t * 4 + phase), -height - 3)
	draw_circle(tip, 8, Color(1, 0.55, 0.16, 0.035))
	draw_circle(tip, 4, Color(1, 0.65, 0.22, 0.13))
	polygon([tip + Vector2(-2, 2), tip + Vector2(0, -5), tip + Vector2(2, 2)], Color("ffd58a"))
	draw_circle(tip, 1, Color("fff1c5"))

func _draw() -> void:
	if game == null:
		return
	# Interior backdrops line up with the actual ground (y=600).
	# The statues are environmental art; their identity remains undisclosed.
	for bounds in [Vector2(0, 1240)]:
		draw_rect(Rect2(bounds.x, -600, bounds.y - bounds.x, 1250), Color("171b22"))
		draw_texture_rect(interior, Rect2(bounds.x, -210, bounds.y - bounds.x, 930), false)
		draw_rect(Rect2(bounds.x, -210, bounds.y - bounds.x, 930), Color(0.01, 0.02, 0.03, 0.18))
	# Foreground must match collision platforms exactly.
	_draw_ground(0, 2000)
	_draw_ground(2270, 4800)
	for p in game.platforms:
		draw_rect(p, Color("303137"))
		draw_rect(Rect2(p.position, Vector2(p.size.x, 4)), EDGE)
		for x in range(int(p.position.x) + 6, int(p.end.x) - 4, 22):
			draw_line(Vector2(x, p.position.y + 5), Vector2(x, p.end.y), INK, 2)
	# Iria remains separate from combatants; the cane identifies her silhouette.
	if not game.doll_found:
		draw_circle(Vector2(2760, 499), 5, Color("a18b78"))
		draw_line(Vector2(2760, 504), Vector2(2760, 516), Color("624d49"), 6)
		draw_line(Vector2(2751, 507), Vector2(2769, 507), Color("846d58"), 2)
		for dx in [-3, 3]:
			draw_line(Vector2(2760 + dx, 514), Vector2(2760 + dx, 520), Color("846d58"), 2)
	# Suspended empty cages: background silhouettes, never hidden collision.
	for x in range(1430, 3200, 360):
		var sway := sin(game.t * 0.65 + x) * 5
		var pos := Vector2(x + sway, 190)
		draw_line(Vector2(x, -100), pos, Color("252228"), 2)
		draw_arc(pos + Vector2(0, 22), 22, PI, TAU, 16, Color("6d5a43"), 2)
		draw_rect(Rect2(pos.x - 22, pos.y + 22, 44, 60), Color("3a3433"), false, 2)
		for dx in [-14, -5, 5, 14]:
			draw_line(pos + Vector2(dx, 22), pos + Vector2(dx, 82), Color("6d5a43"), 2)
	# A memorial is part of the collision-free scenery; its object changes with the story.
	draw_rect(Rect2(2823, 531, 74, 69), Color("383538"))
	for row in range(6):
		draw_line(Vector2(2832, 542 + row * 7), Vector2(2887, 542 + row * 7), Color("72685d"), 1)
		draw_line(Vector2(2844, 539 + row * 7), Vector2(2870, 548 + row * 7), Color("252428"), 2)
	if game.memorial_honored:
		draw_circle(Vector2(2860, 579), 5, Color("a18b78"))
		draw_line(Vector2(2860, 584), Vector2(2860, 597), Color("624d49"), 6)
		for i in range(5):
			candle(Vector2(2830 + i * 15, 600), 12 + i * 2, i)
	# Tomb, broken lid, burial inscription; purely visual, no hidden collision.
	draw_rect(Rect2(78, 568, 150, 30), Color("393a3c"))
	draw_rect(Rect2(82, 563, 142, 7), EDGE)
	draw_rect(Rect2(91, 573, 124, 18), INK)
	draw_line(Vector2(148, 575), Vector2(148, 587), GOLD, 1)
	draw_line(Vector2(141, 579), Vector2(155, 579), GOLD, 1)
	polygon([Vector2(51, 600), Vector2(66, 511), Vector2(83, 515), Vector2(73, 600)], Color("4a4948"))
	# Crown left beside the tomb.
	draw_arc(Vector2(245, 593), 12, PI, TAU, 10, GOLD, 2)
	for i in range(5):
		draw_line(Vector2(234 + i * 5, 590), Vector2(232 + i * 5, 584), GOLD, 1)
	if not game.player.has_weapon:
		var x: float = game.SWORD_POS.x
		draw_line(Vector2(x, 597), Vector2(x, 527), Color("c1bfad"), 4)
		draw_line(Vector2(x - 13, 543), Vector2(x + 13, 543), GOLD, 3)
		draw_line(Vector2(x, 543), Vector2(x, 523), Color("5d342b"), 5)
		draw_circle(Vector2(x, 521), 4, GOLD)
		for i in range(5):
			draw_line(Vector2(x, 553 + i * 7), Vector2(x + 5, 550 + i * 7), GOLD, 1)
		draw_circle(Vector2(x, 553), 25 + sin(game.t * 2) * 3, Color(0.8, 0.63, 0.3, 0.04))
	for altar in game.altars:
		for step in range(3):
			draw_rect(Rect2(altar.x - 48 + step * 8, 595 - step * 9, 96 - step * 16, 9), Color(0.28 + step * 0.025, 0.27 + step * 0.025, 0.27))
		draw_rect(Rect2(altar.x - 27, 554, 54, 18), Color("56504a"))
		draw_line(Vector2(altar.x, 539), Vector2(altar.x, 564), GOLD, 2)
		draw_line(Vector2(altar.x - 8, 547), Vector2(altar.x + 8, 547), GOLD, 2)
	var rng := RandomNumberGenerator.new()
	rng.seed = 7413
	for cx in game.candle_xs:
		for i in range(7):
			candle(Vector2(cx + rng.randf_range(-28, 28), 599), rng.randf_range(9, 30), float(i))
	for altar in game.altars:
		for i in range(18):
			candle(Vector2(altar.x - 100 + i * 11, 599), rng.randf_range(12, 42), float(i))
	for entry in game.lore:
		var x: float = entry["x"]
		polygon([Vector2(x - 19, 600), Vector2(x - 19, 553), Vector2(x, 535), Vector2(x + 19, 553), Vector2(x + 19, 600)], Color("49484a"))
		for i in range(4):
			draw_line(Vector2(x - 10, 563 + i * 5), Vector2(x + 10, 563 + i * 5), Color("777164"), 1)
	# Ground rubble, small bones and roots. Deterministic across frames.
	for i in range(120):
		var x := rng.randf_range(10, 4790)
		if x > 2000 and x < 2270:
			continue
		polygon([Vector2(x - 4, 600), Vector2(x - 2, 594), Vector2(x + 5, 596), Vector2(x + 7, 600)], Color("4b4945"))
	# Slow dust and mist give motion without obscuring the collision plane.
	for i in range(50):
		var x := fmod(i * 107.5 + game.t * (2 + i % 3), 4800)
		var y := 90 + fmod(i * 77.3 + game.t * 4, 480)
		draw_circle(Vector2(x, y), 1, Color(0.88, 0.80, 0.64, 0.17))


func _draw_ground(x0: float, x1: float) -> void:
	draw_rect(Rect2(x0, GROUND_Y, x1 - x0, 200), Color("29282a"))
	draw_rect(Rect2(x0, GROUND_Y, x1 - x0, 5), Color("716351"))
	var row := 0
	while row < 6:
		var y := GROUND_Y + 5.0 + float(row) * 30.0
		draw_line(Vector2(x0, y), Vector2(x1, y), Color(0.07, 0.06, 0.07), 2.0)
		var off := 0.0 if row % 2 == 0 else 32.0
		var bx := x0 + off
		while bx < x1:
			draw_line(Vector2(bx, y), Vector2(bx, y + 30.0), Color(0.07, 0.06, 0.07), 2.0)
			bx += 64.0
		row += 1
