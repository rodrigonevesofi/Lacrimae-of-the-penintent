extends Node2D
## Vida do cenário: uma camada animada por cima da pintura de cada sala.
## As salas eram imagens paradas. Aqui, tudo é desenhado e movido por código a cada quadro: correntes com
## sinos e lamparinas que balançam, estandartes ao vento, feixes de luz que pulsam, poeira e cinzas no ar,
## névoa rasteira, gotas que caem e fazem ondas, corvos, e as chamas dos altares. O que está pendurado reage
## à luta: uma pancada forte por perto faz tudo balançar (impulse).
##
## Dois nós usam este script: o fundo (front = false), atrás dos personagens, e o primeiro plano (front = true).
## O Vale dos Flagelados tem o seu próprio cenário (vale_scene.gd).

## O que cada sala tem. hang: o que pende do alto; shafts: feixes de luz; air: o que flutua; drips: gotas.
const ROOMS := {
	"city": {"hang": "banner", "shafts": 0.5, "air": "dust", "fog": 0.5, "tint": Color(0.85, 0.75, 0.6)},
	"ossuary": {"hang": "chain", "shafts": 0.0, "air": "dust", "fog": 1.0, "tint": Color(0.8, 0.78, 0.7)},
	"cistern": {"hang": "chain", "shafts": 0.0, "air": "mist", "fog": 1.0, "drips": true, "tint": Color(0.6, 0.8, 0.85)},
	"cloister": {"hang": "banner", "shafts": 1.0, "air": "dust", "fog": 0.3, "tint": Color(0.9, 0.8, 0.6)},
	"belfry": {"hang": "bell", "shafts": 0.4, "air": "dust", "fog": 0.0, "tint": Color(0.85, 0.7, 0.5)},
	"archive": {"hang": "lamp", "shafts": 0.7, "air": "dust", "fog": 0.0, "tint": Color(0.95, 0.8, 0.55)},
	"refuge": {"hang": "lamp", "shafts": 0.0, "air": "ash", "fog": 0.8, "tint": Color(0.9, 0.6, 0.45)},
	"nave": {"hang": "lamp", "shafts": 1.0, "air": "dust", "fog": 0.4, "tint": Color(0.9, 0.85, 0.7)},
	"terrace": {"hang": "bell", "shafts": 0.0, "air": "ash", "fog": 0.3, "crows": true, "tint": Color(0.8, 0.7, 0.65)},
	"court": {"hang": "banner", "shafts": 0.0, "air": "ash", "fog": 0.8, "crows": true, "tint": Color(0.8, 0.5, 0.45)},
}

var paints := {}
var lamps: Array = []
var game
var front := false
var t := 0.0
var room := ""
var hung: Array = []
var shafts: Array = []
var drips: Array = []
var crows: Array = []
var air: CPUParticles2D

func _ready() -> void:
	paints["pendentes"]=load("res://assets/vida/pendentes.png")
	for name in ["chama_vela","fumaca_incenso","corvo"]:paints[name]=load("res://assets/animation/"+name+".png")
	for name in ["santo_base","santo_movimento","ossuario_base","ossuario_movimento","relicario_base","relicario_movimento"]:paints[name]=load("res://assets/vida/"+name+".png")
	if front: z_index = 9
	air = CPUParticles2D.new()
	air.amount = 70 if not front else 24
	air.lifetime = 8.0
	air.preprocess = 8.0
	air.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	air.emission_rect_extents = Vector2(820, 380)
	air.spread = 180.0
	air.gravity = Vector2(0, 4)
	air.initial_velocity_min = 4.0
	air.initial_velocity_max = 20.0
	air.scale_amount_min = 1.0
	air.scale_amount_max = 2.4 if not front else 3.6
	air.emitting = false
	add_child(air)

func _current_room() -> String:
	if game == null or game.exploration == null: return ""
	var id: String = game.exploration.room
	return id if ROOMS.has(id) else ""

## Monta os elementos da sala em que o Penitente acabou de entrar. A mesma sala monta sempre igual.
func _build(id: String) -> void:
	room = id
	for light in lamps: light.queue_free()
	lamps.clear()
	hung.clear()
	shafts.clear()
	drips.clear()
	crows.clear()
	if id == "": return
	var data: Dictionary = game.exploration.rooms[id]
	var b: Rect2 = data.bounds
	var floor_y: float = data.floor
	var cfg: Dictionary = ROOMS[id]
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(id) + (77 if front else 0)
	if not front:
		var x := b.position.x + 220.0
		while x < b.end.x - 160.0:
			hung.append({"x": x + rng.randf_range(-60, 60), "top": floor_y - rng.randf_range(520, 640), "len": rng.randf_range(90, 230), "ang": 0.0, "vel": 0.0, "phase": rng.randf() * TAU, "kind": cfg.hang, "w": rng.randf_range(0.8, 1.25)})
			x += rng.randf_range(300, 460)
		if float(cfg.get("shafts", 0.0)) > 0.0:
			x = b.position.x + 300.0
			while x < b.end.x - 200.0:
				shafts.append({"x": x + rng.randf_range(-80, 80), "w": rng.randf_range(70, 150), "phase": rng.randf() * TAU, "lean": rng.randf_range(120, 220)})
				x += rng.randf_range(520, 820)
		if cfg.get("drips", false):
			x = b.position.x + 180.0
			while x < b.end.x - 120.0:
				drips.append({"x": x + rng.randf_range(-70, 70), "period": rng.randf_range(1.6, 3.4), "phase": rng.randf() * 4.0})
				x += rng.randf_range(260, 420)
		if cfg.get("crows", false):
			for i in range(5):
				crows.append({"cx": b.position.x + 300.0 + i * (b.size.x - 600.0) / 4.0, "cy": floor_y - rng.randf_range(430, 600), "r": rng.randf_range(80, 190), "w": rng.randf_range(0.25, 0.5) * (1 if i % 2 == 0 else -1), "phase": rng.randf() * TAU})
	# O que flutua no ar muda de cor e de direção conforme a sala.
	match str(cfg.air):
		"ash":
			air.color = Color(0.8, 0.72, 0.68, 0.5)
			air.direction = Vector2(-0.5, 1.0)
			air.spread = 25.0
			air.initial_velocity_min = 25.0
			air.initial_velocity_max = 70.0
		"mist":
			air.color = Color(0.7, 0.85, 0.9, 0.22)
			air.direction = Vector2(1, -0.2)
			air.spread = 60.0
			air.initial_velocity_min = 6.0
			air.initial_velocity_max = 24.0
		_:
			air.color = Color(1.0, 0.93, 0.8, 0.32)
			air.direction = Vector2(0.3, -0.2)
			air.spread = 180.0
			air.initial_velocity_min = 4.0
			air.initial_velocity_max = 18.0

## Uma pancada forte por perto faz balançar o que está pendurado.
func impulse(at_x: float, strength: float) -> void:
	for h in hung:
		var d: float = absf(h.x - at_x)
		if d < 600.0:
			h.vel += strength * (1.0 - d / 600.0) * (1.0 if h.x >= at_x else -1.0)

func _process(delta: float) -> void:
	var id := _current_room()
	if id != room: _build(id)
	visible = id != ""
	air.emitting = visible
	if not visible: return
	t += delta
	var cam: Vector2 = game.player.camera.get_screen_center_position()
	air.position = cam
	var px: float = game.player.global_position.x
	var pv: float = game.player.velocity.x
	for h in hung:
		var push: float = 0.07 * (sin(t * 0.7 + h.phase) + 0.5 * sin(t * 1.9 + h.phase * 1.7))
		if absf(h.x - px) < 40.0 and absf(pv) > 200.0:
			h.vel += signf(pv) * delta * 2.0
		var acc: float = -6.0 * h.ang - 0.8 * h.vel + push * 2.0
		h.vel += acc * delta
		h.ang += h.vel * delta
	_update_lamps()
	queue_redraw()

func _update_lamps() -> void:
	if front:return
	while lamps.size()<4:
		var light:PointLight2D=load("res://scripts/util.gd").make_light(Color(1,0.72,0.4),0.25,0.6)
		add_child(light)
		lamps.append(light)
	var near:=0
	for h in hung:
		if h.kind not in ["lamp","bell"] or absf(h.x-game.player.global_position.x)>900:continue
		if near>=lamps.size():break
		lamps[near].global_position=Vector2(h.x,h.top)+Vector2(sin(h.ang),cos(h.ang))*h.len
		lamps[near].visible=h.kind=="lamp"
		near+=1
	for i in range(near,lamps.size()):lamps[i].visible=false

func _draw() -> void:
	if room == "": return
	var cam: Vector2 = game.player.camera.get_screen_center_position()
	var view := Rect2(cam - Vector2(760, 470), Vector2(1520, 940))
	var data: Dictionary = game.exploration.rooms[room]
	var floor_y: float = data.floor
	var cfg: Dictionary = ROOMS[room]
	var tint: Color = cfg.tint
	if front:
		_fog(view, floor_y + 4.0, 70.0, 26.0, float(cfg.get("fog", 0.0)) * 0.20, tint)
		return
	_draw_monument(floor_y,view)
	# ---- feixes de luz que descem inclinados e respiram
	for s in shafts:
		if s.x < view.position.x - 320.0 or s.x > view.end.x + 320.0: continue
		var a: float = (0.045 + 0.03 * sin(t * 0.6 + s.phase)) * float(cfg.shafts)
		var top_y: float = floor_y - 640.0
		draw_polygon(PackedVector2Array([Vector2(s.x, top_y), Vector2(s.x + s.w, top_y), Vector2(s.x + s.w - s.lean + 60.0, floor_y), Vector2(s.x - s.lean - 60.0, floor_y)]), PackedColorArray([Color(tint, a * 1.6), Color(tint, a * 1.6), Color(tint, 0.0), Color(tint, 0.0)]))
	# ---- o que pende do alto
	for h in hung:
		if h.x < view.position.x - 120.0 or h.x > view.end.x + 120.0: continue
		_draw_hung(h)
	# ---- gotas que caem e fazem ondas no chão
	for d in drips:
		if d.x < view.position.x - 40.0 or d.x > view.end.x + 40.0: continue
		var k: float = fposmod(t + d.phase, d.period) / d.period
		var fall := 0.55
		if k < fall:
			var y: float = lerpf(floor_y - 560.0, floor_y - 2.0, pow(k / fall, 2.0))
			draw_line(Vector2(d.x, y - 9.0), Vector2(d.x, y), Color(0.75, 0.9, 0.95, 0.7), 1.5)
		else:
			var r: float = (k - fall) / (1.0 - fall)
			draw_arc(Vector2(d.x, floor_y - 1.0), 4.0 + r * 22.0, PI, TAU, 14, Color(0.75, 0.9, 0.95, 0.5 * (1.0 - r)), 1.5)
	# ---- corvos
	for c in crows:
		var a: float = t * c.w + c.phase
		var cp := Vector2(c.cx + cos(a) * c.r, c.cy + sin(a) * c.r * 0.35)
		if not view.has_point(cp): continue
		var flap := sin(t * 9.0 + c.phase) * 5.0
		draw_polyline(PackedVector2Array([cp + Vector2(-8, -flap), cp, cp + Vector2(8, -flap)]), Color(0.05, 0.03, 0.04, 0.85), 2.0)
	# ---- as chamas dos altares tremem
	for pos in game.altars:
		if not view.has_point(pos) or game.exploration.room_at(pos) != room: continue
		for i in range(3):
			var fx: float = pos.x - 26.0 + i * 26.0
			var flick := 0.75 + 0.25 * sin(t * (11.0 + i * 2.3) + i)
			draw_circle(Vector2(fx, pos.y - 74.0), 20.0 * flick, Color(1.0, 0.72, 0.35, 0.06))
			draw_texture_rect_region(paints.chama_vela,Rect2(fx-9,pos.y-94,18,24),Rect2((int(t*10+i)%6)*128,0,128,128))
	_fog(view, floor_y - 18.0, 56.0, 16.0, float(cfg.get("fog", 0.0)) * 0.16, tint)

func _draw_hung(h: Dictionary) -> void:
	if paints.has("pendentes"):
		var index:int=4 if h.kind=="banner" else (1 if h.kind=="lamp" else (0 if h.kind=="bell" else [2,3,5,6,7][int(h.x)%5]))
		var height:float=h.len*1.5
		var width:=height/4.0
		draw_set_transform(Vector2(h.x,h.top),-h.ang*1.2)
		draw_texture_rect_region(paints.pendentes,Rect2(-width/2,0,width,height),Rect2(index*128,0,128,512))
		if index==2:
			draw_texture_rect_region(paints.fumaca_incenso,Rect2(-35,height-90,70,140),Rect2((int(t*8)%6)*128,0,128,256),Color(1,1,1,0.55))
		draw_set_transform(Vector2.ZERO)
		return
	var top := Vector2(h.x, h.top)
	var dir := Vector2(sin(h.ang), cos(h.ang))
	var end: Vector2 = top + dir * h.len
	match str(h.kind):
		"banner":
			# Um estandarte rasgado: a barra de cima fixa, o pano ondula até a ponta.
			var width: float = 46.0 * h.w
			var pts_l := PackedVector2Array()
			var pts_r := PackedVector2Array()
			for i in range(7):
				var k := i / 6.0
				var wave: float = sin(t * 1.6 + h.phase + k * 3.0) * 7.0 * k + h.ang * h.len * k
				var y: float = h.top + k * h.len * 1.15
				pts_l.append(Vector2(h.x - width * 0.5 + wave, y))
				pts_r.append(Vector2(h.x + width * 0.5 + wave, y))
			pts_r.reverse()
			var poly := pts_l + pts_r
			# a ponta em rasgos
			draw_colored_polygon(poly, Color(0.30, 0.05, 0.06, 0.88))
			draw_line(Vector2(h.x - width * 0.6, h.top), Vector2(h.x + width * 0.6, h.top), Color(0.12, 0.09, 0.08), 4.0)
			draw_line(pts_l[0], pts_l[6], Color(0.55, 0.38, 0.2, 0.5), 1.5)
		"bell":
			_chain(top, end)
			draw_set_transform(end, -h.ang * 1.2, Vector2(h.w, h.w))
			draw_colored_polygon(PackedVector2Array([Vector2(-6, 0), Vector2(6, 0), Vector2(15, 26), Vector2(18, 32), Vector2(-18, 32), Vector2(-15, 26)]), Color(0.36, 0.27, 0.14))
			draw_line(Vector2(-12, 22), Vector2(-4, 4), Color(0.75, 0.6, 0.3, 0.6), 2.0)
			draw_circle(Vector2(sin(t * 2.0 + h.phase) * 3.0, 34), 3.0, Color(0.2, 0.15, 0.08))
			draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		"lamp":
			_chain(top, end)
			var flick := 0.8 + 0.2 * sin(t * 9.0 + h.phase)
			draw_circle(end + Vector2(0, 10), 46.0 * flick, Color(1.0, 0.7, 0.35, 0.05))
			draw_circle(end + Vector2(0, 10), 24.0 * flick, Color(1.0, 0.75, 0.4, 0.08))
			draw_set_transform(end, -h.ang * 1.2, Vector2(h.w, h.w))
			draw_colored_polygon(PackedVector2Array([Vector2(-7, 0), Vector2(7, 0), Vector2(10, 18), Vector2(-10, 18)]), Color(0.14, 0.1, 0.08))
			draw_colored_polygon(PackedVector2Array([Vector2(-3, 14), Vector2(0, 14.0 - 9.0 * flick), Vector2(3, 14)]), Color(1.0, 0.8, 0.45, 0.9))
			draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		_:
			_chain(top, end)
			draw_circle(end, 4.5, Color(0.1, 0.09, 0.08))
			draw_arc(end + dir * 8.0, 6.0, 0, PI, 8, Color(0.12, 0.1, 0.09), 2.5)

func _chain(top: Vector2, end: Vector2) -> void:
	var n := int(top.distance_to(end) / 9.0)
	for i in range(n):
		var p: Vector2 = top.lerp(end, (i + 0.5) / float(n))
		draw_circle(p, 2.6 if i % 2 == 0 else 1.8, Color(0.1, 0.09, 0.085))

func _fog(view: Rect2, y: float, height: float, speed: float, alpha: float, tint: Color) -> void:
	if alpha <= 0.0: return
	var col := Color(tint.r * 0.8, tint.g * 0.8, tint.b * 0.82, alpha)
	var clear := Color(col.r, col.g, col.b, 0.0)
	var span := 480.0
	var offset: float = fposmod(t * speed, span)
	var x: float = view.position.x - span + offset - fposmod(view.position.x, span)
	while x < view.end.x + span:
		var wob := sin(x * 0.005 + t * 0.6) * 10.0
		draw_polygon(PackedVector2Array([Vector2(x, y - height + wob), Vector2(x + span * 0.5, y - height * 0.55 + wob), Vector2(x + span, y - height + wob), Vector2(x + span, y + 30.0), Vector2(x, y + 30.0)]), PackedColorArray([clear, clear, clear, col, col]))
		x += span

## Monumentos de duas peças; a base permanece fixa e somente a camada móvel se anima.
func _draw_monument(floor_y:float,view:Rect2) -> void:
	if room not in ["cistern","ossuary","cloister"]:return
	var bounds:Rect2=game.exploration.rooms[room].bounds
	var x:=bounds.position.x+bounds.size.x*0.58
	if x<view.position.x-600 or x>view.end.x+600:return
	var name:String={"cistern":"santo","ossuary":"ossuario","cloister":"relicario"}[room]
	var size:=Vector2(620,620)
	var rect:=Rect2(x-size.x/2,floor_y-size.y,size.x,size.y)
	draw_texture_rect(paints[name+"_base"],rect,false)
	if name=="santo":
		var flow:=fposmod(t*6.0,12.0)
		draw_texture_rect(paints.santo_movimento,Rect2(rect.position+Vector2(0,flow),rect.size),false,Color(1,1,1,0.75))
	else:
		var turn:=sin(t*0.16)*0.055 if name=="relicario" else clampf((game.player.global_position.x-x)/900.0,-0.08,0.08)
		# A projeção da largura simula a rotação lenta no eixo das correntes.
		var depth:=0.72+0.28*absf(cos(t*0.16)) if name=="relicario" else 1.0
		draw_set_transform(Vector2(x,floor_y-size.y/2),turn,Vector2(depth,1))
		draw_texture_rect(paints[name+"_movimento"],Rect2(-size/2,size),false)
		draw_set_transform(Vector2.ZERO)
