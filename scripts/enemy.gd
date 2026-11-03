extends CharacterBody2D
## Inimigos: 0 = Devoto Corrompido, 1 = Chorão (voador), 2 = A Mãe das Lágrimas (chefe)

const Util = preload("res://scripts/util.gd")
const Tear = preload("res://scripts/tear.gd")
const Spike = preload("res://scripts/spike.gd")

signal killed(enemy)

var kind := 0
var home := Vector2.ZERO
var patrol_range := 140.0
var player = null
var display_name := "Devoto Corrompido"
var max_hp := 45.0
var hp := 45.0
var reward := 30
var body_size := Vector2(34, 56)
var facing := -1
var state := "patrol"
var state_t := 0.0
var cd := 1.0
var dead := false
var flash := 0.0
var fade := 1.0
var anim_t := 0.0
var struck := false
var awake := false
var arena_left := 3800.0
var arena_right := 4780.0
var rain_t := 0.0
var phase := 1
var last_attack := -1
var ledge: RayCast2D
var animator
var spawn_opacity := 0.0
var hit_pause := 0.0
var cast_emitted := false
var appearance: Texture2D
var light: PointLight2D


func setup(k: int, pos: Vector2, rng: float, p) -> void:
	kind = k
	home = pos
	position = pos
	patrol_range = rng
	player = p
	match kind:
		0:
			display_name = "Devoto Corrompido"
			max_hp = 45.0
			reward = 30
			body_size = Vector2(34, 56)
		1:
			display_name = "Chorão"
			max_hp = 30.0
			reward = 40
			body_size = Vector2(36, 48)
		2:
			display_name = "A Mãe das Lágrimas"
			max_hp = 450.0
			reward = 1500
			body_size = Vector2(110, 190)
			state = "idle"
	hp = max_hp


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	if kind == 2:
		var guardian := AtlasTexture.new()
		guardian.atlas = load("res://assets/guardian.png")
		guardian.region = Rect2(320, 0, 850, 1024)
		appearance = guardian
	else:
		var atlas := AtlasTexture.new()
		atlas.atlas = load("res://assets/characters.png")
		atlas.region = Rect2((kind + 1) * 384, 0, 384, 1000)
		atlas.filter_clip = true
		appearance = atlas
	animator = preload("res://scripts/actor_animation.gd").new()
	animator.configure(["devotee", "mourner", "guardian"][kind], [0.36, 0.36, 0.92][kind])
	add_child(animator)
	add_to_group("enemies")
	collision_layer = 4
	collision_mask = 1
	var cs := CollisionShape2D.new()
	var rs := RectangleShape2D.new()
	rs.size = body_size
	cs.shape = rs
	cs.position = Vector2(0, -body_size.y / 2.0)
	add_child(cs)
	if kind == 0:
		ledge = RayCast2D.new()
		ledge.collision_mask = 1
		ledge.enabled = true
		add_child(ledge)
	if kind == 1:
		light = Util.make_light(Color(0.6, 0.78, 1.0), 0.6, 1.4)
		light.position = Vector2(0, -26)
		add_child(light)
	if kind == 2:
		light = Util.make_light(Color(0.95, 0.35, 0.3), 0.55, 3.0)
		light.position = Vector2(0, -100)
		add_child(light)


func hurt_rect() -> Rect2:
	return Rect2(global_position + Vector2(-body_size.x / 2.0, -body_size.y), body_size)


func awaken() -> void:
	awake = true
	state = "idle"
	state_t = 1.4


func take_hit(dmg: float, from_x: float) -> void:
	if dead:
		return
	hp -= dmg
	flash = 0.12
	get_tree().call_group("game", "spawn_fx", global_position + Vector2(0, -body_size.y * 0.55), Color(1.0, 0.4, 0.3))
	var kb := signf(global_position.x - from_x)
	if kb == 0.0:
		kb = 1.0
	if kind == 0:
		velocity.x = kb * 220.0
		state = "hurt"
		state_t = 0.3
	elif kind == 1:
		velocity = Vector2(kb * 200.0, -80.0)
		state = "hurt"
		state_t = 0.3
	elif not awake:
		awaken()
	if hp <= 0.0:
		_die()


func _die() -> void:
	dead = true
	collision_layer = 0
	if player != null and is_instance_valid(player):
		player.lagrimas += reward
		player.culpa = minf(player.culpa + 8.0, 100.0)
	get_tree().call_group("game", "shake_cam", 8.0 if kind == 2 else 3.0)
	killed.emit(self)


func _physics_process(delta: float) -> void:
	var game = get_tree().get_first_node_in_group("game")
	if game != null and (game.state != "play" or game.message_text != "" or game.narrative.mode != ""):
		return
	if hit_pause > 0:
		hit_pause -= delta
		return
	if spawn_opacity < 1:
		return
	anim_t += delta
	flash = maxf(flash - delta, 0.0)
	state_t -= delta
	cd -= delta
	if dead:
		fade -= delta * (0.5 if kind == 2 else 1.4)
		velocity.x = move_toward(velocity.x, 0.0, 800.0 * delta)
		velocity.y = minf(velocity.y + 1200.0 * delta, 700.0)
		move_and_slide()
		if light:
			light.energy = maxf(fade, 0.0) * 0.5
		if fade <= 0.0:
			queue_free()
		return
	if player == null or not is_instance_valid(player):
		return
	match kind:
		0:
			_walker(delta)
		1:
			_flyer(delta)
		2:
			_boss(delta)
	queue_redraw()


# ---------- Devoto Corrompido ----------
func _ledge_ok() -> bool:
	ledge.position = Vector2(facing * 24.0, -8.0)
	ledge.target_position = Vector2(0, 52)
	ledge.force_raycast_update()
	return ledge.is_colliding()


func _walker(delta: float) -> void:
	velocity.y = minf(velocity.y + 1800.0 * delta, 900.0)
	var to_p: float = player.global_position.x - global_position.x
	var dist: float = absf(to_p)
	var dy: float = absf(player.global_position.y - global_position.y)
	var alive: bool = player.state != "dead"
	var seen: bool = alive and dist < 360.0 and dy < 140.0
	match state:
		"patrol":
			velocity.x = facing * 55.0
			if global_position.x > home.x + patrol_range:
				facing = -1
			elif global_position.x < home.x - patrol_range:
				facing = 1
			if is_on_wall() or not _ledge_ok():
				facing = -facing
			if seen:
				state = "chase"
		"chase":
			facing = 1 if to_p > 0.0 else -1
			if dist > 54.0 and _ledge_ok():
				velocity.x = facing * 115.0
			else:
				velocity.x = 0.0
			if dist < 72.0 and dy < 90.0 and cd <= 0.0 and alive:
				state = "windup"
				state_t = 0.55
				velocity.x = 0.0
			elif not seen and dist > 460.0:
				state = "patrol"
		"windup":
			velocity.x = 0.0
			if state_t <= 0.0:
				state = "strike"
				state_t = 0.18
				struck = false
		"strike":
			velocity.x = facing * 40.0
			if not struck:
				var r := Rect2(global_position + Vector2(0.0 if facing > 0 else -70.0, -64.0), Vector2(70.0, 64.0))
				if r.intersects(player.body_rect()):
					player.take_hit(16.0, global_position.x)
					struck = true
			if state_t <= 0.0:
				state = "recover"
				state_t = 0.7
				cd = 1.1
		"recover":
			velocity.x = 0.0
			if state_t <= 0.0:
				state = "chase"
		"hurt":
			velocity.x = move_toward(velocity.x, 0.0, 900.0 * delta)
			if state_t <= 0.0:
				state = "chase"
	move_and_slide()


# ---------- Chorão (voador) ----------
func _flyer(delta: float) -> void:
	var to_p: Vector2 = (player.global_position + Vector2(0, -30)) - (global_position + Vector2(0, -24))
	var dist: float = to_p.length()
	var alive: bool = player.state != "dead"
	var target := Vector2(
		home.x + sin(anim_t * 0.7) * patrol_range,
		home.y + sin(anim_t * 1.8) * 14.0)
	match state:
		"patrol":
			velocity = velocity.lerp((target - global_position) * 1.4, 4.0 * delta)
			velocity = velocity.limit_length(180.0)
			if alive and dist < 520.0:
				facing = 1 if to_p.x > 0.0 else -1
				if cd <= 0.0:
					cast_emitted = false
					state = "windup"
					state_t = 0.75
		"windup":
			velocity = velocity.lerp(Vector2.ZERO, 6.0 * delta)
			facing = 1 if to_p.x > 0.0 else -1
			if not cast_emitted and state_t <= 0.375:
				_shoot(to_p.normalized())
				cast_emitted = true
			if state_t <= 0.0:
				state = "cast"
				state_t = 0.18
				cd = 2.3
		"cast":
			velocity = Vector2.ZERO
			if state_t <= 0:
				state = "patrol"
		"hurt":
			velocity = velocity.lerp(Vector2.ZERO, 5.0 * delta)
			if state_t <= 0.0:
				state = "patrol"
	move_and_slide()


func _shoot(d: Vector2) -> void:
	var t = Tear.new()
	t.player = player
	t.vel = d * 260.0
	t.dmg = 14.0
	t.life = 5.0
	get_parent().add_child(t)
	t.global_position = global_position + Vector2(0, -26)


# ---------- A Mãe das Lágrimas (chefe) ----------
func _boss(delta: float) -> void:
	velocity.y = minf(velocity.y + 1800.0 * delta, 900.0)
	if not awake:
		velocity.x = 0.0
		move_and_slide()
		return
	phase = 2 if hp < max_hp * 0.5 else 1
	var spd: float = 1.0 if phase == 1 else 1.35
	var to_p: float = player.global_position.x - global_position.x
	var dist: float = absf(to_p)
	var alive: bool = player.state != "dead"
	match state:
		"idle":
			velocity.x = 0.0
			facing = 1 if to_p > 0.0 else -1
			if state_t <= 0.0 and alive:
				_pick_attack()
		"walk":
			facing = 1 if to_p > 0.0 else -1
			velocity.x = facing * 95.0 * spd
			if dist < 140.0 or state_t <= 0.0:
				state = "slam_wind"
				state_t = 0.8 / spd
				velocity.x = 0.0
		"slam_wind":
			velocity.x = 0.0
			if state_t <= 0.0:
				_slam()
				state = "slam"
				state_t = 0.35
		"slam":
			velocity.x = 0.0
			if state_t <= 0.0:
				state = "idle"
				state_t = 1.1 / spd
		"rain":
			velocity.x = 0.0
			rain_t -= delta
			if rain_t <= 0.0:
				rain_t = 0.22 / spd
				_rain_drop()
			if state_t <= 0.0:
				state = "idle"
				state_t = 1.2 / spd
		"spike_cast":
			velocity.x = 0.0
			if not cast_emitted and state_t <= 0.8:
				cast_emitted = true
				_spikes()
			if state_t <= 0.0:
				state = "idle"
				state_t = 1.0 / spd
	global_position.x = clampf(global_position.x, arena_left + 60.0, arena_right - 60.0)
	move_and_slide()


func _pick_attack() -> void:
	var r := randi() % 3
	if r == last_attack:
		r = (r + 1) % 3
	last_attack = r
	match r:
		0:
			state = "walk"
			state_t = 2.2
		1:
			state = "rain"
			state_t = 2.4
			rain_t = 0.8
		2:
			state = "spike_cast"
			state_t = 1.6
			cast_emitted = false


func _slam() -> void:
	get_tree().call_group("game", "shake_cam", 10.0)
	if absf(player.global_position.x - global_position.x) < 170.0 and absf(player.global_position.y - global_position.y) < 70.0:
		player.take_hit(26.0, global_position.x)
	for s in [-1.0, 1.0]:
		var t = Tear.new()
		t.player = player
		t.vel = Vector2(s * (240.0 if phase == 1 else 320.0), 0.0)
		t.dmg = 16.0
		t.life = 3.2
		t.radius = 14.0
		t.wave = true
		get_parent().add_child(t)
		t.global_position = global_position + Vector2(s * 70.0, -14.0)


func _rain_drop() -> void:
	var x := randf_range(arena_left + 40.0, arena_right - 40.0)
	if randf() < 0.5:
		x = player.global_position.x + randf_range(-150.0, 150.0)
	x = clampf(x, arena_left + 30.0, arena_right - 30.0)
	var t = Tear.new()
	t.player = player
	t.vel = Vector2(0.0, 120.0)
	t.grav = 700.0
	t.dmg = 14.0
	t.life = 4.0
	t.ground_y = 598.0
	get_parent().add_child(t)
	t.global_position = Vector2(x, 110.0)


func _spikes() -> void:
	var n := 3 if phase == 1 else 5
	for i in range(n):
		var x: float = player.global_position.x + (float(i) - float(n - 1) / 2.0) * 110.0
		x = clampf(x, arena_left + 30.0, arena_right - 30.0)
		var s = Spike.new()
		s.player = player
		s.delay = 0.9 if phase == 1 else 0.7
		get_parent().add_child(s)
		s.global_position = Vector2(x, 600.0)


# ---------- visual (placeholders desenhados por código) ----------
func _col(base: Color) -> Color:
	var c := base
	if flash > 0.0:
		c = Color(1.0, 1.0, 1.0, base.a)
	c.a = c.a * fade
	return c


func _process(delta: float) -> void:
	if animator == null:
		return
	var game = get_tree().get_first_node_in_group("game")
	if dead and game != null and game.narrative.mode != "":
		fade = maxf(fade - delta * (1.25 if kind == 2 else 1.4), 0)
		if light:
			light.energy = fade * 0.5
		if fade <= 0:
			queue_free()
	spawn_opacity = minf(spawn_opacity + delta / 0.45, 1.0)
	animator.modulate = _col(Color(1, 0.87, 0.80) if kind == 2 and phase == 2 else Color.WHITE)
	animator.modulate.a *= spawn_opacity
	if dead:
		animator.select("death", facing, 1 - fade)
	elif state == "hurt":
		animator.select("hurt", facing, 1 - state_t / 0.3)
	elif kind == 0:
		match state:
			"windup": animator.select("attack", facing, clampf(1 - state_t / 0.55, 0, 1) * 4.0 / 6)
			"strike": animator.select("attack", facing, (4 + clampf(1 - state_t / 0.18, 0, 1) * 2) / 6)
			"recover": animator.pose("attack", facing, clampi(5 - int((1 - state_t / 0.7) * 6), 0, 5))
			_: animator.select("walk" if absf(velocity.x) > 10 else "idle", facing)
	elif kind == 1:
		if state == "windup":
			animator.select("attack", facing, 1 - state_t / 0.75)
		elif state == "cast":
			animator.pose("attack", facing, 5)
		else:
			animator.select("walk" if velocity.length() > 20 else "idle", facing)
	else:
		match state:
			"slam_wind": animator.select("slam", facing, clampf(1 - state_t / (0.8 if phase == 1 else 0.8 / 1.35), 0, 1) * 4.0 / 6)
			"slam": animator.select("slam", facing, (4 + clampf(1 - state_t / 0.35, 0, 1) * 2) / 6)
			"rain": animator.select("cast", facing, 1 - state_t / 2.4)
			"spike_cast": animator.select("cast", facing, 1 - state_t / 1.6)
			_: animator.select("walk" if state == "walk" else "idle", facing)
	queue_redraw()

func _draw() -> void:
	if kind != 2 and hp < max_hp and not dead:
		draw_rect(Rect2(-18, -body_size.y - 14, 36, 4), Color(0, 0, 0, 0.6))
		draw_rect(Rect2(-18, -body_size.y - 14, 36 * hp / max_hp, 4), Color(0.8, 0.15, 0.15))
	if kind == 2 and state in ["slam_wind", "spike_cast", "rain"]:
		draw_arc(Vector2(0, -110), 80, 0, TAU, 40, Color(0.8, 0.3, 0.08, 0.35), 2)
