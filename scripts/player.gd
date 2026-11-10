extends CharacterBody2D
## O Penitente das Lágrimas (jogador)

const Util = preload("res://scripts/util.gd")

signal died

const SPEED := 280.0
const GRAVITY := 1800.0
const JUMP_V := -620.0
const DJUMP_V := -560.0
const ROLL_SPEED := 540.0
const ROLL_TIME := 0.34
const ATTACK_TIME := 0.42
const AIR_ATTACK_TIME := 0.48
const AIR_RECOVERY_TIME := 0.16
const MAX_FALL := 950.0

var animator
var sword: Sprite2D
const SWORD_GRIP := Vector2(410, 360)
const SWORD_SCALE := 0.035
var penitence := "none"
var execution_target = null
var execution_contact := false
var execution_zoom_start := Vector2.ONE
const EXECUTION_TIME := 1.15
var cinematic_focus := false
var ritual_clip := "pray"
var ritual_progress := 0.0
var hit_pause := 0.0
var parry_cd := 0.0
var prev_vy := 0.0
var parry_hit := false
var counter_t := 0.0
var counter_attack := false
var parries := 0
const PARRY_TIME := 0.46
const PARRY_WINDOW := 0.22
var jump_elapsed := 0.0
var landing_t := 0.0
var was_grounded := true
var appearance: AtlasTexture
var blood_tears := 0.0
var footstep_t := 0.0
var attack_buffer := 0.0
var roll_buffer := 0.0
var damage_flash := 0.0
var has_weapon := false
var max_hp := 100.0
var hp := 100.0
var culpa := 0.0
var lagrimas := 0
var upgrades := 0
var max_flasks := 3
var flasks := 3
var has_double_jump := false
var facing := 1
var controllable := true
var state := "idle"
var state_t := 0.0
var invuln := 0.0
var coyote := 0.0
var jump_buffer := 0.0
var air_jumps := 0
var air_attack_used := false
var aerial_after_cut := false
var combo := 0
var hit_list: Array = []
var anim_t := 0.0
var pray_duration := 1.0
var penance_fx := 0.0
var safe_pos := Vector2.ZERO
var shake := 0.0
var roll_cd := 0.0
var camera: Camera2D
var light: PointLight2D


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	appearance = AtlasTexture.new()
	appearance.atlas = load("res://assets/characters.png")
	appearance.region = Rect2(0, 0, 384, 1000)
	appearance.filter_clip = true
	animator = preload("res://scripts/actor_animation.gd").new()
	animator.configure("hero", 0.44)
	add_child(animator)
	sword = Sprite2D.new()
	sword.texture = load("res://assets/penitent_sword.png")
	sword.centered = false
	sword.offset = -SWORD_GRIP
	sword.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	var sword_surface := ShaderMaterial.new()
	sword_surface.shader = load("res://shaders/penitent_readability.gdshader")
	sword_surface.set_shader_parameter("midtone_gain",1.12)
	sword_surface.set_shader_parameter("edge_strength",0.16)
	sword.material = sword_surface
	add_child(sword)
	# Na ordem de desenho do jogador, o cabo fica atrás da manopla.
	move_child(sword,0)
	add_to_group("player")
	collision_layer = 2
	collision_mask = 1
	floor_snap_length = 10.0
	var cs := CollisionShape2D.new()
	var rs := RectangleShape2D.new()
	rs.size = Vector2(22, 56)
	cs.shape = rs
	cs.position = Vector2(0, -28)
	add_child(cs)
	light = Util.make_light(Color(1.0, 0.82, 0.6), 0.32, 2.6)
	light.position = Vector2(0, -40)
	add_child(light)
	camera = Camera2D.new()
	camera.offset = Vector2(0, -110)
	camera.position_smoothing_enabled = true
	camera.position_smoothing_speed = 7.0
	camera.limit_left = 0
	camera.limit_right = 4800
	camera.limit_bottom = 800
	camera.limit_top = -300
	add_child(camera)
	safe_pos = global_position


# ---------- entrada ----------
func pressed(a: String) -> bool:
	return controllable and Input.is_action_just_pressed(a)


func released(a: String) -> bool:
	return controllable and Input.is_action_just_released(a)


func axis() -> float:
	if not controllable:
		return 0.0
	return Input.get_axis("left", "right")


func body_rect() -> Rect2:
	return Rect2(global_position + Vector2(-11, -56), Vector2(22, 56))


# ---------- física / estados ----------
func _physics_process(delta: float) -> void:
	# Lê os comandos de acionamento antes da pausa de impacto; a entrada armazenada persiste durante a pausa.
	if hit_pause > 0:
		if pressed("attack") and has_weapon: attack_buffer = 0.20
		if pressed("roll"): roll_buffer = 0.16
		hit_pause -= delta
		return
	anim_t += delta
	blood_tears = maxf(blood_tears - delta, 0.0)
	invuln = maxf(invuln - delta, 0.0)
	state_t -= delta
	penance_fx = maxf(penance_fx - delta, 0.0)
	shake = maxf(shake - delta * 30.0, 0.0)
	roll_cd = maxf(roll_cd - delta, 0.0)
	if camera and not cinematic_focus:
		camera.offset = Vector2(0, -110) + Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * shake

	var game = get_tree().get_first_node_in_group("game")
	if game != null and game.exploration != null and game.exploration.is_transitioning():
		velocity = Vector2.ZERO
		return

	if state == "dead":
		velocity.x = move_toward(velocity.x, 0.0, 1500.0 * delta)
		velocity.y = minf(velocity.y + GRAVITY * delta, MAX_FALL)
		move_and_slide()
		return

	if game != null and (game.message_text != "" or game.narrative.mode != "" or game.penitence_menu or game.exploration.map_open):
		velocity.x = 0.0
		velocity.y = minf(velocity.y + GRAVITY * delta, MAX_FALL)
		move_and_slide()
		return

	if state == "execution":
		velocity = Vector2.ZERO
		var progress := 1.0 - state_t / EXECUTION_TIME
		camera.zoom = execution_zoom_start.lerp(execution_zoom_start * 1.5, sin(clampf(progress, 0, 1) * PI))
		if is_instance_valid(execution_target):
			execution_target.execution_progress = clampf(progress, 0, 1)
			if progress >= 0.66 and not execution_contact:
				execution_contact = true
				execution_target._die()
				hp = minf(hp + 8, max_hp)
				add_culpa(12)
				shake = 5
				hit_pause = 0.06
				get_tree().call_group("game", "play_sfx", "hit")
				get_tree().call_group("game", "spawn_fx", global_position + Vector2(facing * 45, -42), Color("c69c72"))
		if state_t <= 0:
			if is_instance_valid(execution_target): execution_target.executing = false
			execution_target = null
			camera.zoom = execution_zoom_start
			state = "idle"
		return

	var on_floor := is_on_floor()
	var just_landed := on_floor and not was_grounded
	if just_landed and prev_vy > 430.0:
		get_tree().call_group("game", "play_sfx", "aterrissagem")
		get_tree().call_group("game", "spawn_effect", "dust", global_position + Vector2(0.0, -4.0), 1, 0.45)
	landing_t = maxf(landing_t - delta, 0.0)
	if not on_floor:
		jump_elapsed += delta
	elif not was_grounded:
		landing_t = 0.10
	was_grounded = on_floor
	if on_floor:
		air_attack_used = false
		if just_landed and aerial_after_cut and state == "idle":
			state = "air_recover"
			state_t = AIR_RECOVERY_TIME
		elif state not in ["air_attack","air_recover"]:
			aerial_after_cut = false
		coyote = 0.1
		air_jumps = 0
		safe_pos = global_position
	else:
		coyote -= delta
	jump_buffer -= delta
	if pressed("jump") and Input.is_action_pressed("down") and is_on_floor() and can_drop():
		position.y += 28
		velocity.y = 120
		jump_buffer = 0
	elif pressed("jump"):
		jump_buffer = 0.12

	velocity.y = minf(velocity.y + GRAVITY * delta, MAX_FALL)
	attack_buffer = maxf(attack_buffer - delta, 0.0)
	roll_buffer = maxf(roll_buffer - delta, 0.0)
	parry_cd = maxf(parry_cd - delta, 0.0)
	counter_t = maxf(counter_t - delta, 0.0)
	damage_flash = maxf(damage_flash - delta, 0.0)
	if pressed("attack") and has_weapon:
		attack_buffer = 0.20
	if pressed("roll"):
		roll_buffer = 0.16
	var dir := axis()

	match state:
		"idle":
			velocity.x = move_toward(velocity.x, dir * SPEED, 2600.0 * delta)
			if dir != 0.0:
				facing = 1 if dir > 0.0 else -1
			if jump_buffer > 0.0 and coyote > 0.0:
				get_tree().call_group("game", "play_sfx", "jump")
				jump_elapsed = 0.0
				velocity.y = JUMP_V
				jump_buffer = 0.0
				coyote = 0.0
				get_tree().call_group("game", "spawn_fx", global_position, Color(0.8, 0.8, 0.9))
			elif pressed("jump") and not on_floor and coyote <= 0.0 and has_double_jump and air_jumps < 1:
				jump_elapsed = 0.0
				velocity.y = DJUMP_V
				air_jumps += 1
				get_tree().call_group("game", "spawn_fx", global_position + Vector2(0, -6), Color(1.0, 0.85, 0.5))
			if released("jump") and not pressed("jump") and velocity.y < -250.0:
				velocity.y *= 0.55
			if attack_buffer > 0.0 and has_weapon:
				_start_attack()
			elif pressed("parry") and has_weapon and on_floor and parry_cd <= 0.0:
				_start_parry()
			elif roll_buffer > 0.0 and on_floor and roll_cd <= 0.0:
				_start_roll()
			elif pressed("heal"):
				_start_heal()
			elif pressed("penance"):
				_do_penance()
		"attack":
			if not on_floor:
				velocity.x = move_toward(velocity.x, dir * SPEED * 0.7, 1800.0 * delta)
			else:
				velocity.x = move_toward(velocity.x, facing * 60.0, 2400.0 * delta)
			var p := 1.0 - state_t / ATTACK_TIME
			var contact_frame := clampi(int(p * 6), 0, 5)
			if contact_frame in [2, 3]:
				_attack_hits()
			if roll_buffer > 0.0 and on_floor and roll_cd <= 0.0 and p >= 5.0 / 6.0:
				_start_roll()
			elif attack_buffer > 0.0 and has_weapon and p >= 5.0 / 6.0:
				_start_attack()
			elif state_t <= 0.0:
				state = "idle"
		"air_attack":
			velocity.x = move_toward(velocity.x, dir * SPEED * 0.85, 1200.0 * delta)
			var progress := 1.0 - state_t / AIR_ATTACK_TIME
			if on_floor:
				state = "air_recover"
				state_t = AIR_RECOVERY_TIME
			elif clampi(int(progress * 12),0,11) in [5,6,7]:
				_attack_hits(true)
			if state == "air_attack" and state_t <= 0:
				state = "idle"
		"air_recover":
			velocity.x = move_toward(velocity.x,0,2100.0*delta)
			if state_t <= 0:
				state = "idle"
				aerial_after_cut = false
		"parry":
			velocity.x = move_toward(velocity.x, 0.0, 3200.0 * delta)
			if state_t <= 0.0:
				state = "idle"
				parry_cd = 0.35
		"roll":
			velocity.x = facing * ROLL_SPEED
			if state_t <= 0.0:
				state = "idle"
				velocity.x = facing * SPEED * 0.6
		"hurt":
			velocity.x = move_toward(velocity.x, 0.0, 900.0 * delta)
			if state_t <= 0.0:
				state = "idle"
		"heal":
			velocity.x = move_toward(velocity.x, 0.0, 2400.0 * delta)
			if state_t <= 0.0:
				get_tree().call_group("game", "play_sfx", "heal")
				flasks -= 1
				hp = minf(hp + 45.0, max_hp)
				state = "idle"
				get_tree().call_group("game", "spawn_fx", global_position + Vector2(0, -40), Color(0.6, 0.85, 1.0))
		"pray":
			velocity.x = 0.0
			if state_t <= 0.0:
				state = "idle"

	prev_vy = velocity.y
	move_and_slide()
	footstep_t -= delta
	if is_on_floor() and absf(velocity.x) > 40 and state == "idle" and footstep_t <= 0:
		get_tree().call_group("game", "play_sfx", "step")
		footstep_t = 0.28

	var fall_limit: float = game.exploration.rooms[game.exploration.room].bounds.end.y + 50 if game != null else 880.0
	if global_position.y > fall_limit:
		_fell()


func _process(_delta: float) -> void:
	_update_animation()
	_update_sword()
	queue_redraw()

func _update_animation() -> void:
	var tint := Color.WHITE
	if invuln > 0 and not cinematic_focus and state not in ["roll", "dead", "execution"]:
		tint.a = 0.6 if int(anim_t * 18) % 2 else 1.0
	animator.modulate = tint
	if cinematic_focus:
		animator.select(ritual_clip, facing, ritual_progress)
		return
	match state:
		"execution": animator.select("execute_devotee" if not is_instance_valid(execution_target) or execution_target.humanoid() else "execute_mourner", facing, 1 - state_t / EXECUTION_TIME)
		"air_attack": animator.select("air_attack",facing,1-state_t/AIR_ATTACK_TIME)
		"air_recover": animator.select("air_land",facing,1-state_t/AIR_RECOVERY_TIME)
		"attack": animator.select("strong_counter" if counter_attack else ("attack_a" if combo == 1 else "attack_b"), facing, 1 - state_t / ATTACK_TIME)
		"roll": animator.select("roll", facing, 1 - state_t / ROLL_TIME)
		"parry": animator.select("parry_recoil" if parry_hit else "parry", facing, clampf(1.0 - state_t / (0.3 if parry_hit else PARRY_TIME), 0.0, 0.999))
		"hurt": animator.select("hurt", facing, 1 - state_t / 0.25)
		"dead": animator.select("death", facing, 1 - state_t / 0.70)
		"heal": animator.select("heal", facing, 1 - state_t / 0.55)
		"pray": animator.select("pray", facing, 1 - state_t / pray_duration)
		_:
			if not is_on_floor() and aerial_after_cut:
				animator.select("air_drift",facing)
			elif not is_on_floor():
				var index := (0 if jump_elapsed < 0.06 else 1) if velocity.y < -120 else (2 if velocity.y < 80 else 3)
				animator.pose("air_drift" if has_weapon else "jump", facing, index)
			elif landing_t > 0:
				animator.pose("air_land" if has_weapon else "jump", facing, 4 if landing_t > 0.05 else 5)
			else:
				animator.select("run" if absf(velocity.x) > 30 else "idle", facing)


# ---------- ações ----------
func _start_attack() -> void:
	if not has_weapon:
		return
	if not is_on_floor() or velocity.y < -100.0:
		_start_air_attack()
		return
	var d := axis()
	if d != 0.0:
		facing = 1 if d > 0.0 else -1
	get_tree().call_group("game", "play_sfx", "swing")
	attack_buffer = 0.0
	state = "attack"
	counter_attack = counter_t > 0.0
	counter_t = 0.0
	state_t = ATTACK_TIME
	combo = 1 - combo
	hit_list.clear()


func _attack_hits(aerial: bool = false) -> void:
	var r := Rect2(global_position + Vector2(6.0 if facing > 0 else -92.0, -66.0), Vector2(86.0, 66.0))
	if aerial:
		r = Rect2(global_position + Vector2(8.0 if facing > 0 else -100.0,-108.0),Vector2(92.0,82.0))
	for e in get_tree().get_nodes_in_group("enemies"):
		if e.dead or hit_list.has(e):
			continue
		if r.intersects(e.hurt_rect()):
			# Bronze e armadura ressoam; a carne cede.
			get_tree().call_group("game", "play_sfx", "hit_metal" if e.kind in [2, 3] else "hit_carne")
			hit_list.append(e)
			var dmg := (22.0 if aerial else (20.0 if combo == 1 else 26.0)) * sword_multiplier()
			e.take_hit(dmg, global_position.x)
			# Cada golpe tem peso: pausa no impacto, pausa maior ao matar, faíscas e sangue.
			var stop := 0.16 if e.dead else 0.085
			hit_pause = stop
			e.hit_pause = stop
			add_culpa(3)
			shake = maxf(shake, 6.0 if e.dead else 4.0)
			var spot: Vector2 = e.global_position + Vector2(-float(facing) * 14.0, -e.body_size.y * 0.55)
			# Grandes efeitos pintados: arco da lâmina, estrela no contato, sangue e poça ao matar.
			get_tree().call_group("game", "spawn_effect", "arc", global_position + Vector2(float(facing) * 58.0, -52.0), facing, 0.62, "golpe")
			get_tree().call_group("game", "spawn_effect", "star", spot, facing, 0.5, "golpe")
			get_tree().call_group("game", "spawn_effect", "blood", spot + Vector2(float(facing) * 8.0, 4.0), facing, 0.7 if e.dead else 0.5)
			if e.dead and e.family != "flyer":
				get_tree().call_group("game", "spawn_effect", "pool", Vector2(e.global_position.x, e.global_position.y - 52.0), facing, 0.6, "golpe")


func _start_roll() -> void:
	var d := axis()
	if d != 0.0:
		facing = 1 if d > 0.0 else -1
	get_tree().call_group("game", "play_sfx", "roll")
	roll_buffer = 0.0
	state = "roll"
	state_t = ROLL_TIME
	invuln = ROLL_TIME
	roll_cd = ROLL_TIME + (0.65 if penitence == "chains" else 0.0)


func _start_heal() -> void:
	if flasks > 0 and hp < max_hp and is_on_floor():
		state = "heal"
		state_t = 0.55


func _do_penance() -> void:
	if culpa < 50.0:
		get_tree().call_group("game", "toast", "A culpa ainda é leve demais (precisa de 50%).")
		return
	blood_tears = 3.5
	var used := culpa
	culpa = 0.0
	penance_fx = 0.5
	state = "pray"
	pray_duration = 0.45
	state_t = pray_duration
	invuln = 0.5
	shake = 9.0
	var dmg := (36.0 + used * 0.5) * (1.55 if penitence == "chains" else 1.0)
	for e in get_tree().get_nodes_in_group("enemies"):
		if e.dead:
			continue
		var d: float = e.global_position.distance_to(global_position)
		if d < 300.0:
			e.take_hit(dmg, global_position.x)


func pray(restore: bool = true, duration: float = 1.0) -> void:
	if restore:
		hp = max_hp
		flasks = max_flasks
	state = "pray"
	pray_duration = duration
	state_t = pray_duration
	velocity = Vector2.ZERO


## Defesa temporizada: nos primeiros instantes do aparo, um golpe leve frontal é desviado e o atacante fica exposto.
## Agarrões pesados, investidas e projéteis não podem ser aparados; é preciso esquivar.
func _start_parry() -> void:
	state = "parry"
	parry_hit = false
	state_t = PARRY_TIME
	velocity.x = 0.0
	get_tree().call_group("game", "play_sfx", "swing")

func _parry_success(attacker, from_x: float) -> void:
	parries += 1
	parry_hit = true
	# O próximo golpe dentro de um breve intervalo será o contra-ataque forte.
	counter_t = 0.9
	invuln = 0.5
	hit_pause = 0.12
	shake = maxf(shake, 5.0)
	state_t = 0.3
	get_tree().call_group("game", "play_sfx", "hit")
	get_tree().call_group("game", "play_sfx", "aparo")
	get_tree().call_group("game", "spawn_effect", "parry", global_position + Vector2(facing * 46.0, -54.0), facing, 0.7)
	if attacker != null and is_instance_valid(attacker) and attacker.has_method("parried"):
		attacker.parried()
	if parries == 1:
		get_tree().call_group("game", "toast", "Aparo! O inimigo está aberto: golpeie (dano maior) ou execute com E.")

func take_hit(dmg: float, from_x: float, attacker = null, parryable: bool = false) -> void:
	if state == "parry" and parryable and state_t > PARRY_TIME - PARRY_WINDOW and (from_x - global_position.x) * float(facing) >= -10.0:
		_parry_success(attacker, from_x)
		return
	if state == "dead" or invuln > 0.0 or cinematic_focus or state == "execution":
		return
	get_tree().call_group("game", "play_sfx", "hurt")
	damage_flash = 0.25
	hp -= dmg
	add_culpa(dmg * 0.6)
	invuln = 0.8
	var kd := signf(global_position.x - from_x)
	if kd == 0.0:
		kd = 1.0
	velocity = Vector2(kd * 260.0, -240.0)
	state = "hurt"
	state_t = 0.25
	shake = maxf(shake, 6.0)
	get_tree().call_group("game", "spawn_fx", global_position + Vector2(0, -30), Color(0.9, 0.15, 0.15))
	if hp <= 0.0:
		die()


func die() -> void:
	if state == "dead":
		return
	get_tree().call_group("game", "play_sfx", "death")
	state = "dead"
	state_t = 0.70
	hp = 0.0
	velocity = Vector2(-facing * 120.0, -300.0)
	died.emit()


func _fell() -> void:
	hp -= 25.0
	add_culpa(15)
	global_position = safe_pos + Vector2(-facing * 50.0, 0.0)
	velocity = Vector2.ZERO
	invuln = 1.2
	if hp <= 0.0:
		die()


func revive(pos: Vector2) -> void:
	if state == "execution" and camera: camera.zoom = execution_zoom_start
	execution_target = null
	execution_contact = false
	air_attack_used = false
	aerial_after_cut = false
	hit_pause = 0.0
	attack_buffer = 0.0
	roll_buffer = 0.0
	damage_flash = 0.0
	state = "idle"
	hp = max_hp
	flasks = max_flasks
	invuln = 1.0
	velocity = Vector2.ZERO
	global_position = pos
	safe_pos = pos
	controllable = true


# ---------- visual (representação provisória desenhada por código) ----------
func _draw() -> void:
	draw_ellipse_shadow()
	if state == "dead":
		return
	draw_set_transform(Vector2.ZERO, 0, Vector2(float(facing), 1))
	if state == "execution" and is_instance_valid(execution_target) and execution_target.humanoid():
		var progress := 1 - state_t / EXECUTION_TIME
		if progress > 0.18 and progress < 0.7:
			var wrist := Vector2(32, -58 + maxf(progress - 0.35, 0) * 75)
			var neck: Vector2 = (execution_target.global_position - global_position) * Vector2(facing, 1) + Vector2(0, -execution_target.body_size.y * 0.78)
			for i in range(8):
				var knot := wrist.lerp(neck, i / 7.0) + Vector2(0, sin(i / 7.0 * PI) * 5)
				draw_circle(knot, 1.1, Color("bc9762"))
	if blood_tears > 0 and not cinematic_focus:
		for i in range(2):
			var eye := Vector2(4 + i * 3, -77)
			draw_line(eye, eye + Vector2(0, 9), Color("7d1723"), 1.7)
			var fall := fmod(anim_t * 25 + i * 17, 50)
			draw_circle(eye + Vector2(1, 8 + fall), 1.8, Color(0.65, 0.025, 0.05, 1 - fall / 65))
	draw_set_transform(Vector2.ZERO, 0, Vector2.ONE)
	if penance_fx > 0:
		var progress := (0.5 - penance_fx) / 0.5
		draw_arc(Vector2(0, -30), 30 + progress * 270, 0, TAU, 48, Color(1, 0.8, 0.35, penance_fx * 2), 5)

func draw_ellipse_shadow() -> void:
	if is_on_floor() and state != "dead":
		draw_set_transform(Vector2(0, -1), 0, Vector2(1, 0.2))
		draw_circle(Vector2.ZERO, 18, Color(0, 0, 0, 0.3))
		draw_set_transform(Vector2.ZERO, 0, Vector2.ONE)


func culpa_capacity() -> float:
	var game = get_tree().get_first_node_in_group("game")
	return 75.0 if game != null and game.stain_active else 100.0

func add_culpa(amount: float) -> void:
	culpa = clampf(culpa + amount, 0, culpa_capacity())

func sword_multiplier() -> float:
	return 1.4 if penitence == "nails" else 1.0

func apply_penitence(id: String) -> void:
	penitence = id if id in ["none", "nails", "chains"] else "none"
	max_hp = (100.0 + upgrades * 15.0) * (0.7 if penitence == "nails" else 1.0)
	hp = minf(hp, max_hp)

func begin_execution(target) -> bool:
	# O carregador de caixão só pode ser executado depois que a pedra quebrar.
	if target != null and is_instance_valid(target) and target.kind == 8 and not target.exposed:
		return false
	if state != "idle" or not has_weapon or not is_on_floor() or not is_instance_valid(target): return false
	if target.dead or target.kind == 2 or target.state != "stagger" or target.executing: return false
	if absf(target.position.x - position.x) > 72 or absf(target.position.y - position.y) > (170 if target.family == "flyer" else 80): return false
	execution_zoom_start = camera.zoom
	execution_target = target
	execution_contact = false
	state = "execution"
	get_tree().call_group("game", "play_sfx", "execucao")
	state_t = EXECUTION_TIME
	facing = 1 if target.position.x >= position.x else -1
	target.executing = true
	# Um voador atordoado desce ao nível do penitente para alinhar a animação conjunta com o chão.
	if target.family == "flyer": target.position.y = position.y
	target.execution_progress = 0
	target.velocity = Vector2.ZERO
	target.facing = -facing
	velocity = Vector2.ZERO
	invuln = EXECUTION_TIME + 0.1
	attack_buffer = 0
	roll_buffer = 0
	return true

func can_drop() -> bool:
	for i in range(get_slide_collision_count()):
		var collider = get_slide_collision(i).get_collider()
		if collider != null and collider.get_meta("one_way",false): return true
	return false


func _update_sword() -> void:
	if sword == null: return
	# Os desenhos de ataque e ritual já incluem a lâmina; nunca acrescenta uma segunda.
	sword.visible = has_weapon and state == "idle" and not cinematic_focus and animator.animation in ["idle","run"]
	if not sword.visible: return
	var wrist := Vector2(174,135)
	if animator.animation == "run":
		wrist = [Vector2(202,124),Vector2(199,109),Vector2(156,134),Vector2(202,74),Vector2(164,184),Vector2(160,156)][animator.frame]
	var bob := sin(anim_t*(16 if animator.animation=="run" else 3))*1.2
	var hand := (wrist-Vector2(128,250))*0.44+Vector2(0,bob)
	var angle := 0.75
	# Mantém a ponta acima do piso de colisão durante o movimento baixo da espada na corrida.
	var blade_length := (2050-SWORD_GRIP.x)*SWORD_SCALE
	angle = minf(angle,asin(clampf((-3-hand.y)/blade_length,-1,1)))
	sword.position = Vector2(hand.x*facing,hand.y)
	sword.scale = Vector2(SWORD_SCALE*facing,SWORD_SCALE)
	sword.rotation = angle*facing
	sword.modulate = animator.modulate


func _start_air_attack() -> void:
	if not has_weapon or air_attack_used: return
	var direction := axis()
	if direction != 0: facing = 1 if direction > 0 else -1
	state = "air_attack"
	state_t = AIR_ATTACK_TIME
	air_attack_used = true
	aerial_after_cut = true
	attack_buffer = 0
	hit_list.clear()
	get_tree().call_group("game","play_sfx","swing")
