extends Node2D
## Lâmina de Sangue: um corte em meia-lua, feito da culpa acumulada, que voa reto e atravessa
## todas as criaturas no caminho. Para na parede, espirrando.

var dono
var lado := 1
var dano := 34.0
var vida := 0.85
var t := 0.0
var atingidos: Array = []
var gotas: CPUParticles2D
const VELOCIDADE := 820.0

func _ready() -> void:
	z_index = 8
	var cru := CanvasItemMaterial.new()
	cru.light_mode = CanvasItemMaterial.LIGHT_MODE_UNSHADED
	material = cru
	gotas = CPUParticles2D.new()
	gotas.amount = 40
	gotas.lifetime = 0.6
	gotas.direction = Vector2(-lado, 0.3)
	gotas.spread = 30.0
	gotas.initial_velocity_min = 40.0
	gotas.initial_velocity_max = 160.0
	gotas.gravity = Vector2(0, 900)
	gotas.scale_amount_min = 1.5
	gotas.scale_amount_max = 3.2
	var tons := Gradient.new()
	tons.colors = PackedColorArray([Color(0.75, 0.04, 0.06), Color(0.35, 0.0, 0.02, 0.0)])
	gotas.color_ramp = tons
	add_child(gotas)

func _physics_process(delta: float) -> void:
	t += delta
	var passo := Vector2(lado * VELOCIDADE * delta, 0.0)
	var consulta := PhysicsRayQueryParameters2D.create(global_position, global_position + passo * 2.0, 1)
	var parede := get_world_2d().direct_space_state.intersect_ray(consulta)
	if not parede.is_empty() or t >= vida:
		_desfazer(parede.get("position", global_position))
		return
	global_position += passo
	var area := Rect2(global_position + Vector2(-34, -46), Vector2(68, 92))
	for e in get_tree().get_nodes_in_group("enemies"):
		if e.dead or atingidos.has(e) or not area.intersects(e.hurt_rect()): continue
		atingidos.append(e)
		if is_instance_valid(dono): e.last_hitter = dono
		e.take_hit(dano, global_position.x - lado * 40.0)
		e.hit_pause = maxf(e.hit_pause, 0.06)
		var ponto: Vector2 = e.global_position + Vector2(0, -e.body_size.y * 0.55)
		get_tree().call_group("game", "play_sfx", "hit_carne")
		get_tree().call_group("game", "spawn_effect", "sangue", ponto, lado, 0.42, "impactos")
		get_tree().call_group("game", "blood_splats", e.global_position, lado, 4, 1.0)
		get_tree().call_group("game", "shake_cam", 3.0)
	queue_redraw()

func _desfazer(onde: Vector2) -> void:
	get_tree().call_group("game", "spawn_effect", "sangue", onde, -lado, 0.5, "impactos")
	get_tree().call_group("game", "wall_splat", onde)
	get_tree().call_group("game", "play_sfx", "respingo_chao")
	queue_free()

func _draw() -> void:
	var some := 1.0 - smoothstep(0.7, 1.0, t / vida)
	var pulso := 1.0 + 0.08 * sin(t * 40.0)
	# Meia-lua vertical, de costas para o lado em que voa.
	for camada in range(3):
		var r := (44.0 - camada * 8.0) * pulso
		var cor: Color = [Color(0.45, 0.0, 0.03, 0.55), Color(0.78, 0.05, 0.08, 0.8), Color(1.0, 0.82, 0.72, 0.95)][camada]
		cor.a *= some
		var pts := PackedVector2Array()
		for i in range(17):
			var a := lerpf(-1.25, 1.25, float(i) / 16.0)
			pts.append(Vector2(cos(a) * r * lado, sin(a) * r * 1.05))
		for i in range(16, -1, -1):
			var a := lerpf(-1.25, 1.25, float(i) / 16.0)
			pts.append(Vector2(cos(a) * (r - 9.0 + camada * 2.0) * lado - lado * 10.0, sin(a) * (r - 4.0) * 1.05))
		draw_colored_polygon(pts, cor)
	# Rastro atrás.
	draw_line(Vector2(-lado * 10.0, 0), Vector2(-lado * 90.0, 0), Color(0.6, 0.02, 0.05, 0.35 * some), 10.0)
