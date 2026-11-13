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
const ATTACK_TIME := 0.36
const COMBO_DURATIONS := [0.32, 0.36, 0.46]
const INPUT_BUFFER := 0.22
const AIR_ATTACK_TIME := 0.48
const AIR_RECOVERY_TIME := 0.16
const MAX_FALL := 950.0

var animator
var sword: Sprite2D
const SWORD_GRIP := Vector2(410, 360)
const SWORD_SCALE := 0.035
## Posição do punho em cada desenho de hero_motion.png (coordenadas da célula de 256 x 256), medida quadro a quadro.
## A empunhadura ocupa esse ponto para a mão fechar no cabo, em vez de ficar solta ao lado.
const IDLE_GRIPS := [Vector2(177,159),Vector2(184,157),Vector2(183,154),Vector2(185,147),Vector2(180,156),Vector2(181,158)]
const RUN_GRIPS := [Vector2(210,116),Vector2(202,133),Vector2(209,122),Vector2(222,98),Vector2(196,143),Vector2(200,141)]
var penitence := "none"
var execution_target = null
var execution_contact := false
var execution_zoom_start := Vector2.ONE
const EXECUTION_TIME := 1.15
var execution_length := EXECUTION_TIME
var execution_wound_at := 0.42
var execution_kill_at := 0.66
var cinematic_focus := false
var ritual_clip := "pray"
var ritual_progress := 0.0
var hit_pause := 0.0
var parry_cd := 0.0
var prev_vy := 0.0
var parry_hit := false
var counter_t := 0.0
var counter_attack := false
var execution_wound := false
## Combate: sequência de três golpes com arremate no terceiro, golpe pesado carregado e ataque descendente.
const HEAVY_STRIKE_TIME := 0.32
const HEAVY_FULL := 0.9
var combo_step := 0
var combo_window := 0.0
var finisher := false
var heavy_t := 0.0
var heavy_done := false
var heavy_len := HEAVY_STRIKE_TIME
var parry_buffer := 0.0
var heavy_buffer := 0.0
var swing_effect := false
var input_release_gate := false
var roll_direction := 0.0
var parry_direction := 0.0
var camera_focus_x := 0.0
var plunge_landed := false
## Modo de desenvolvimento (F3): atravessa paredes e evita dano para apresentar as salas.
## Dois penitentes carregam o mesmo fardo: o Penitente e Beatriz. No modo solo, T troca quem está em cena;
## cada um tem sua vida e, perto da morte, o outro pode sangrar para salvá-lo (H).
const CHARACTERS := {
	"penitente": {"name": "PENITENTE", "speed": 1.0, "reach": 1.0, "damage": 1.0, "attack_time": 1.0, "tint": Color(1, 1, 1)},
	"beatriz": {"name": "BEATRIZ", "speed": 0.92, "reach": 1.6, "damage": 1.2, "attack_time": 1.15, "tint": Color(0.86, 0.74, 0.96)},
}
var character := "penitente"
var partner_hp := 100.0
## A lança de Beatriz pesa mais a cada pecado purgado (contrapasso): fica lenta e forte, até ela orar.
var lance_weight := 0.0
var swap_cd := 0.0
var share_cd := 0.0
var attack_len := ATTACK_TIME
var lance: Node2D
## Os dois penitentes caminham juntos. O jogo controla Beatriz até o segundo jogador usar um
## dos comandos dela (prefixo "p2_"). Quem cai ainda pode receber sangue do parceiro para se levantar.
var is_partner := false
var prefix := ""
var ai := false
var ai_held := {}
var ai_tap := {}
var ai_axis := 0.0
var ai_attack_cd := 0.0
var revive_t := 0.0
signal fell
var dev_fly := false
var dev_god := false
const BLOOD_DECALS_MAX := 14
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
	# Lança provisória de Beatriz quando a arte própria está ausente: haste de ferro batido e ponta cinzenta.
	lance = Node2D.new()
	lance.z_index = 1
	var shaft := Polygon2D.new()
	shaft.polygon = PackedVector2Array([Vector2(-30, -2), Vector2(70, -2), Vector2(70, 2), Vector2(-30, 2)])
	shaft.color = Color(0.22, 0.18, 0.16)
	lance.add_child(shaft)
	var point := Polygon2D.new()
	point.polygon = PackedVector2Array([Vector2(70, -5), Vector2(92, 0), Vector2(70, 5)])
	point.color = Color(0.62, 0.62, 0.64)
	lance.add_child(point)
	lance.visible = false
	add_child(lance)
	# À frente do corpo: o cabo cobre os dedos para a mão parecer fechada na empunhadura.
	sword.z_index = 1
	# Acompanha o desenho assim que muda: o punho se desloca até 30 pixels entre quadros de corrida.
	animator.frame_changed.connect(_update_sword)
	animator.animation_changed.connect(_update_sword)
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
	# A câmera do Penitente enquadra o mundo; a câmera da parceira fica desligada.
	if is_partner: camera.enabled = false
	add_to_group("players")
	safe_pos = global_position


# ---------- entrada ----------
func pressed(a: String) -> bool:
	if not controllable: return false
	if ai: return bool(ai_tap.get(a, false))
	return InputMap.has_action(prefix + a) and Input.is_action_just_pressed(prefix + a)

func held(a: String) -> bool:
	if ai: return bool(ai_held.get(a, false))
	return InputMap.has_action(prefix + a) and Input.is_action_pressed(prefix + a)


func released(a: String) -> bool:
	if ai: return false
	return controllable and InputMap.has_action(prefix + a) and Input.is_action_just_released(prefix + a)


func axis() -> float:
	if not controllable:
		return 0.0
	if ai: return ai_axis
	return Input.get_axis(prefix + "left", prefix + "right")


func body_rect() -> Rect2:
	return Rect2(global_position + Vector2(-11, -56), Vector2(22, 56))


# ---------- física / estados ----------
func _physics_process(delta: float) -> void:
	if is_partner:
		var director = get_tree().get_first_node_in_group("game")
		if director != null and (director.state != "play" or director.narrative.mode != "" or director.exploration.is_transitioning() or director.message_text != ""):
			_clear_combat_input()
			input_release_gate = true
			velocity = Vector2.ZERO
			animator.select("idle", facing)
			return
	if ai:
		_ai_think(delta)
	if state == "fallen":
		_clear_combat_input()
		velocity.x = move_toward(velocity.x, 0.0, 900.0 * delta)
		velocity.y = minf(velocity.y + 1800.0 * delta, 900.0)
		move_and_slide()
		animator.select("death", facing, 0.999)
		return
	if standing() and held("share_blood"):
		var other = partner()
		if other != null and other.state == "fallen" and global_position.distance_to(other.global_position) < 110.0:
			revive_t += delta
			if revive_t >= 1.0:
				revive_t = 0.0
				_raise(other)
		else:
			revive_t = 0.0
	else:
		revive_t = 0.0
	var game = get_tree().get_first_node_in_group("game")
	var blocked: bool = not controllable or cinematic_focus or (game != null and (game.state != "play" or game.message_text != "" or game.narrative.mode != "" or game.penitence_menu or (game.exploration != null and (game.exploration.map_open or game.exploration.is_transitioning()))))
	if blocked or state in ["dead", "execution", "pray"]:
		_clear_combat_input()
		input_release_gate = true
	else:
		_capture_combat_input()
	if dev_fly:
		var fly := Vector2(axis(), (1.0 if held("down") else 0.0) - (1.0 if held("jump") else 0.0))
		global_position += fly * 900.0 * delta
		velocity = Vector2.ZERO
		if dev_god: hp = max_hp
		return
	# Lê os comandos de acionamento antes da pausa de impacto; a entrada armazenada persiste durante a pausa.
	if hit_pause > 0:
		# A pausa congela a ação, mas preserva o comando que acabou de chegar.
		hit_pause = maxf(hit_pause - delta, 0.0)
		return
	anim_t += delta
	blood_tears = maxf(blood_tears - delta, 0.0)
	invuln = maxf(invuln - delta, 0.0)
	state_t -= delta
	penance_fx = maxf(penance_fx - delta, 0.0)
	shake = maxf(shake - delta * 30.0, 0.0)
	roll_cd = maxf(roll_cd - delta, 0.0)
	if camera and not cinematic_focus:
		var amplitude := 0.0 if game != null and game.reduced_pulses else shake
		camera.offset = Vector2(camera_focus_x, -110) + Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * amplitude

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
		var progress := 1.0 - state_t / execution_length
		camera.zoom = execution_zoom_start.lerp(execution_zoom_start * 1.5, sin(clampf(progress, 0, 1) * PI))
		if is_instance_valid(execution_target):
			execution_target.execution_progress = clampf(progress, 0, 1)
			if progress >= execution_wound_at and not execution_wound:
				# Primeiro ferimento: a lâmina penetra o corpo.
				execution_wound = true
				# Quando ferimento e golpe mortal coincidem, usa apenas o jato final.
				if execution_wound_at < execution_kill_at:
					get_tree().call_group("game", "play_sfx", "hit_carne")
					_blood_burst(_execution_torso(), 0.4, 18)
			if progress >= execution_kill_at and not execution_contact:
				execution_contact = true
				var torso := _execution_torso()
				var ground := Vector2(execution_target.global_position.x, execution_target.global_position.y)
				execution_target._die()
				hp = minf(hp + 8, max_hp)
				add_culpa(12)
				shake = 5
				hit_pause = 0.1
				get_tree().call_group("game", "play_sfx", "hit_carne")
				get_tree().call_group("game", "play_sfx", "execucao")
				# Golpe mortal: sangue em leque, gotas que caem e uma poça que permanece na pedra.
				_blood_burst(torso, 0.6, 46)
				get_tree().call_group("game", "spawn_effect", _impact_kind(execution_target), torso, facing, 0.3, "impactos")
				_blood_decal(ground)
				_slow_motion(0.3, 0.2)
				add_weight(12.0)
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
	if not input_release_gate and pressed("jump") and held("down") and is_on_floor() and can_drop():
		position.y += 28
		velocity.y = 120
		jump_buffer = 0

	velocity.y = minf(velocity.y + GRAVITY * delta, MAX_FALL)
	attack_buffer = maxf(attack_buffer - delta, 0.0)
	roll_buffer = maxf(roll_buffer - delta, 0.0)
	parry_buffer = maxf(parry_buffer - delta, 0.0)
	heavy_buffer = maxf(heavy_buffer - delta, 0.0)
	parry_cd = maxf(parry_cd - delta, 0.0)
	counter_t = maxf(counter_t - delta, 0.0)
	combo_window = maxf(combo_window - delta, 0.0)
	swap_cd = maxf(swap_cd - delta, 0.0)
	share_cd = maxf(share_cd - delta, 0.0)
	damage_flash = maxf(damage_flash - delta, 0.0)
	var dir := axis()

	match state:
		"idle":
			velocity.x = move_toward(velocity.x, dir * speed(), 2600.0 * delta)
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
			if _buffered_defense(on_floor):
				pass
			elif heavy_buffer > 0.0 and has_weapon and on_floor:
				_start_charge()
			elif attack_buffer > 0.0 and has_weapon:
				_start_attack()
			elif pressed("swap") and partner() == null:
				swap_character()
			elif pressed("share_blood"):
				share_blood()
			elif pressed("heal"):
				_start_heal()
			elif pressed("penance"):
				_do_penance()
		"attack":
			if not on_floor:
				velocity.x = move_toward(velocity.x, dir * speed() * 0.7, 1800.0 * delta)
			else:
				velocity.x = move_toward(velocity.x, facing * 60.0, 2400.0 * delta)
			var p := 1.0 - state_t / attack_len
			var contact_frame := clampi(int(p * 6), 0, 5)
			if contact_frame in [2, 3]:
				_swing_trail()
				_attack_hits()
			# Há compromisso até o contato; a recuperação permite defesa antes do próximo golpe.
			if p >= 0.60 and _buffered_defense(on_floor):
				pass
			elif p >= 0.70 and _jump_from_recovery(on_floor):
				pass
			elif p >= 0.76 and heavy_buffer > 0.0 and on_floor:
				_start_charge()
			elif attack_buffer > 0.0 and has_weapon and p >= 0.76:
				_start_attack()
			elif state_t <= 0.0:
				state = "idle"
		"charge":
			velocity.x = move_toward(velocity.x, dir * speed() * 0.22, 1800.0 * delta)
			if heavy_t < 0.25 and dir != 0.0: facing = 1 if dir > 0.0 else -1
			var was_full := heavy_t >= HEAVY_FULL
			heavy_t += delta
			if heavy_t >= HEAVY_FULL and not was_full:
				# Carga completa: confirmação sonora e barra preenchida.
				# A barra cheia e o som confirmam a carga sem repetir o sinal visual de aparo.
				get_tree().call_group("game", "play_sfx", "ui_confirmar")
			if _buffered_defense(on_floor):
				pass
			elif _jump_from_recovery(on_floor):
				pass
			elif not held("heavy") or heavy_t > 2.5:
				_start_heavy()
		"heavy":
			velocity.x = move_toward(velocity.x, facing * 40.0, 2400.0 * delta)
			if not heavy_done and state_t <= heavy_len * 0.7:
				heavy_done = true
				_heavy_hits()
			if state_t <= heavy_len * 0.32 and _buffered_defense(on_floor):
				pass
			elif state_t <= 0.0:
				state = "idle"
		"plunge":
			velocity.x = 0.0
			velocity.y = 950.0
			if on_floor and not plunge_landed:
				plunge_landed = true
				_plunge_impact()
				state = "air_recover"
				state_t = AIR_RECOVERY_TIME
		"air_attack":
			velocity.x = move_toward(velocity.x, dir * speed() * 0.85, 1200.0 * delta)
			var progress := 1.0 - state_t / AIR_ATTACK_TIME
			if on_floor:
				state = "air_recover"
				state_t = AIR_RECOVERY_TIME
			elif clampi(int(progress * 12),0,11) in [5,6,7]:
				_swing_trail()
				_attack_hits(true)
			if state == "air_attack" and state_t <= 0:
				state = "idle"
		"air_recover":
			velocity.x = move_toward(velocity.x,0,2100.0*delta)
			if _buffered_defense(on_floor):
				pass
			elif attack_buffer > 0.0 and has_weapon and state_t <= AIR_RECOVERY_TIME * 0.5:
				_start_attack()
			elif state_t <= 0:
				state = "idle"
				aerial_after_cut = false
		"parry":
			velocity.x = move_toward(velocity.x, 0.0, 3200.0 * delta)
			if parry_hit and attack_buffer > 0.0:
				_start_attack()
			elif state_t <= 0.0:
				state = "idle"
				parry_cd = 0.25
		"roll":
			velocity.x = facing * ROLL_SPEED
			if state_t <= 0.0:
				state = "idle"
				velocity.x = facing * speed() * 0.6
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
	var tint: Color = CHARACTERS[character].tint if animator.actor == "hero" else Color.WHITE
	if invuln > 0 and not cinematic_focus and state not in ["roll", "dead", "execution"]:
		tint.a = 0.6 if int(anim_t * 18) % 2 else 1.0
	animator.modulate = tint
	if cinematic_focus:
		animator.select(ritual_clip, facing, ritual_progress)
		return
	if state == "fallen":
		animator.select("death", facing, 0.999)
		return
	if revive_t > 0.0 and state == "idle" and animator.actor == "beatriz":
		animator.select("raise", facing, minf(revive_t, 0.999))
		return
	match state:
		"execution": animator.select(_execution_clip(), facing, 1 - state_t / execution_length)
		"air_attack": animator.select("air_attack",facing,1-state_t/AIR_ATTACK_TIME)
		"air_recover": animator.select("air_land",facing,1-state_t/AIR_RECOVERY_TIME)
		"attack": animator.select("strong_counter" if counter_attack or finisher else ("attack_a" if combo == 1 else "attack_b"), facing, 1 - state_t / attack_len)
		"charge": animator.select("charged_heavy", facing, minf(heavy_t / HEAVY_FULL, 1.0) * 3.99 / 6.0)
		"heavy": animator.select("charged_heavy", facing, (4.0 + clampf(1.0 - state_t / heavy_len, 0.0, 1.0) * 1.99) / 6.0)
		"plunge": animator.select("air_attack", facing, 0.55)
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
			elif animator.actor == "beatriz" and absf(velocity.x) <= 30.0:
				# Três faixas de peso: 0–33, 34–66 e 67–100.
				var weight_pose := 0 if lance_weight < 34.0 else (1 if lance_weight < 67.0 else 2)
				animator.pose("idle_weight", facing, weight_pose)
			else:
				animator.select("run" if absf(velocity.x) > 30 else "idle", facing)


# ---------- ações ----------
func _start_attack() -> void:
	if not has_weapon:
		return
	if not is_on_floor() and held("down"):
		_start_plunge()
		return
	if not is_on_floor() or velocity.y < -100.0:
		_start_air_attack()
		return
	var d := axis()
	if d != 0.0:
		facing = 1 if d > 0.0 else -1
	get_tree().call_group("game", "play_sfx", "lanca_estocada" if character == "beatriz" else "swing")
	attack_buffer = 0.0
	# Sequência de três: o terceiro golpe dentro do intervalo é o arremate.
	combo_step = (combo_step + 1) % 3 if combo_window > 0.0 else 0
	finisher = combo_step == 2
	combo_window = float(COMBO_DURATIONS[combo_step]) * attack_scale() + 0.30
	velocity.x = facing * (210.0 if finisher else 125.0)
	state = "attack"
	counter_attack = counter_t > 0.0
	counter_t = 0.0
	attack_len = float(COMBO_DURATIONS[combo_step]) * attack_scale()
	state_t = attack_len
	combo = 1 if combo_step == 0 else 0
	swing_effect = false
	hit_list.clear()


func _attack_hits(aerial: bool = false) -> void:
	var width := 86.0 * float(CHARACTERS[character].reach)
	var r := Rect2(global_position + Vector2(6.0 if facing > 0 else -(6.0 + width), -66.0), Vector2(width, 66.0))
	if aerial:
		var air_width := 92.0 * float(CHARACTERS[character].reach)
		r = Rect2(global_position + Vector2(8.0 if facing > 0 else -(8.0 + air_width),-108.0),Vector2(air_width,82.0))
	for e in get_tree().get_nodes_in_group("enemies"):
		if e.dead or hit_list.has(e):
			continue
		if r.intersects(e.hurt_rect()) and _clear_strike(e):
			# Guarda o material antes de o golpe quebrar a proteção.
			var impact_kind := _impact_kind(e)
			# Bronze e armadura ressoam; a carne cede.
			get_tree().call_group("game", "play_sfx", "hit_carne" if impact_kind == "sangue" else "hit_metal")
			hit_list.append(e)
			var dmg := (22.0 if aerial else (38.0 if counter_attack else (34.0 if finisher else (20.0 if combo == 1 else 26.0)))) * sword_multiplier()
			e.last_hitter = self
			e.take_hit(dmg, global_position.x)
			if finisher and not aerial:
				get_tree().call_group("game", "play_sfx", "arremate")
				_launch(e, 360.0, -220.0)
				if e.dead: _slow_motion(0.3, 0.16)
			# Cada golpe tem peso: pausa no impacto, pausa maior ao matar, faíscas e sangue.
			var stop := 0.085 if e.dead else (0.065 if finisher or counter_attack else 0.045)
			hit_pause = maxf(hit_pause, stop)
			e.hit_pause = maxf(e.hit_pause, stop)
			add_culpa(3)
			shake = maxf(shake, 6.0 if e.dead else 4.0)
			var spot: Vector2 = e.global_position + Vector2(-float(facing) * 14.0, -e.body_size.y * 0.55)
			# Grandes efeitos pintados: arco da lâmina, estrela no contato, sangue e poça ao matar.
			get_tree().call_group("game", "spawn_effect", "star", spot, facing, 0.5, "golpe")
			# Cada material reage de um jeito: faíscas na armadura, lascas na pedra e sangue na carne.
			get_tree().call_group("game", "spawn_effect", impact_kind, spot + Vector2(float(facing) * 8.0, 4.0), facing, 0.42 if e.dead else 0.34, "impactos")
			if e.dead and e.family != "flyer":
				get_tree().call_group("game", "spawn_effect", "pool", Vector2(e.global_position.x, e.global_position.y - 52.0), facing, 0.6, "golpe")


func _start_roll() -> void:
	var d := axis()
	if d == 0.0 and roll_buffer > 0.0: d = roll_direction
	if d != 0.0:
		facing = 1 if d > 0.0 else -1
	get_tree().call_group("game", "play_sfx", "roll")
	_clear_combat_input()
	combo_window = 0.0
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
	var direction := axis()
	if direction == 0.0 and parry_buffer > 0.0: direction = parry_direction
	_clear_combat_input()
	combo_window = 0.0
	if direction != 0.0: facing = 1 if direction > 0.0 else -1
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
	if dev_god:
		return
	if state == "parry" and parryable and state_t > PARRY_TIME - PARRY_WINDOW and (from_x - global_position.x) * float(facing) >= -10.0:
		_parry_success(attacker, from_x)
		return
	if state == "dead" or invuln > 0.0 or cinematic_focus or state == "execution":
		return
	get_tree().call_group("game", "play_sfx", "hurt")
	_clear_combat_input()
	combo_window = 0.0
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


func partner() -> Node:
	for other in get_tree().get_nodes_in_group("players"):
		if other != self and is_instance_valid(other): return other
	return null

func standing() -> bool:
	return state != "dead" and state != "fallen"

func die() -> void:
	if state == "dead" or state == "fallen":
		return
	var other = partner()
	if other != null and other.standing():
		# Ainda não morreu: permanece no chão até receber sangue do parceiro.
		get_tree().call_group("game", "play_sfx", "hurt")
		get_tree().call_group("game", "play_sfx", "caido")
		state = "fallen"
		hp = 0.0
		velocity = Vector2(-facing * 80.0, -160.0)
		invuln = 1.0
		fell.emit()
		get_tree().call_group("game", "toast", "%s caiu. Chegue perto e segure H para dar sangue." % str(CHARACTERS[character].name).capitalize())
		return
	if other != null and other.state == "fallen":
		# Os dois caíram: a penitência termina para ambos.
		other.state = "dead"
		other.hp = 0.0
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
	execution_wound = false
	_clear_combat_input()
	input_release_gate = false
	combo_step = 0
	combo_window = 0.0
	finisher = false
	counter_attack = false
	counter_t = 0.0
	parry_cd = 0.0
	roll_cd = 0.0
	swing_effect = false
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
	if state == "execution" and animator.actor == "hero" and _execution_clip() == "execute_devotee" and is_instance_valid(execution_target) and execution_target.humanoid():
		var progress := 1 - state_t / execution_length
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
	if state == "charge":
		var amount := clampf(heavy_t / HEAVY_FULL, 0.0, 1.0)
		draw_rect(Rect2(-20, -118, 40, 4), Color(0.08, 0.06, 0.06, 0.9))
		draw_rect(Rect2(-20, -118, 40 * amount, 4), Color("e7c17b") if amount >= 1.0 else Color("ae8059"))

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
	var m := 1.4 if penitence == "nails" else 1.0
	m *= float(CHARACTERS[character].damage)
	if character == "beatriz":
		m *= 1.0 + lance_weight * 0.006
	return m

func speed() -> float:
	return SPEED * float(CHARACTERS[character].speed)

func attack_scale() -> float:
	var s := float(CHARACTERS[character].attack_time)
	if character == "beatriz":
		s *= 1.0 + lance_weight * 0.004
	return s

func add_weight(amount: float) -> void:
	if character == "beatriz":
		lance_weight = clampf(lance_weight + amount, 0.0, 100.0)

## T: o outro penitente assume o fardo; cada um mantém sua própria vida.
func swap_character() -> bool:
	if swap_cd > 0.0 or state != "idle" or not is_on_floor() or cinematic_focus or partner_hp <= 0.0:
		return false
	var keep := hp
	hp = minf(partner_hp, max_hp)
	partner_hp = keep
	character = "beatriz" if character == "penitente" else "penitente"
	apply_character()
	swap_cd = 0.8
	get_tree().call_group("game", "spawn_effect", "dust", global_position + Vector2(0.0, -30.0), facing, 0.9)
	get_tree().call_group("game", "play_sfx", "ui_confirmar")
	get_tree().call_group("game", "toast", ("Beatriz ergue a lança." if character == "beatriz" else "O Penitente retoma a espada."))
	return true

## H: perto da morte, o outro doa parte da vida para salvar quem está em cena; a penitência é compartilhada.
func share_blood() -> bool:
	if share_cd > 0.0 or hp > max_hp * 0.25 or partner_hp <= max_hp * 0.30 or state == "dead":
		return false
	var given := minf(max_hp * 0.35, partner_hp - 1.0)
	partner_hp -= given
	hp = minf(max_hp, hp + given)
	share_cd = 6.0
	get_tree().call_group("game", "spawn_effect", "blood", global_position + Vector2(0.0, -60.0), facing, 0.8)
	get_tree().call_group("game", "play_sfx", "heal")
	get_tree().call_group("game", "toast", "Sangue compartilhado: %s sangra para salvar quem caminha." % ("o Penitente" if character == "beatriz" else "Beatriz"))
	return true

func apply_character() -> void:
	# Usa os desenhos próprios de Beatriz quando as folhas estão disponíveis.
	var own_art: bool = ResourceLoader.exists("res://assets/animation/beatriz_movimento.png") and ResourceLoader.exists("res://assets/animation/beatriz_combate.png")
	if character == "beatriz" and own_art:
		animator.configure("beatriz", 0.44)
		animator.modulate = Color.WHITE
	else:
		if animator.actor != "hero": animator.configure("hero", 0.44)
		animator.modulate = CHARACTERS[character].tint
	if lance != null:
		lance.visible = false
	_update_sword()

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
	execution_wound = false
	state = "execution"
	get_tree().call_group("game", "play_sfx", "execucao")
	var clip_data: Dictionary = animator.definitions.get(_execution_clip(), {})
	execution_length = float(clip_data.get("duration", EXECUTION_TIME))
	var frames_count := maxf(float(clip_data.get("count", 12)), 1.0)
	execution_wound_at = float(clip_data.wound_frame) / frames_count if clip_data.has("wound_frame") else 0.42
	execution_kill_at = float(clip_data.kill_frame) / frames_count if clip_data.has("kill_frame") else 0.66
	state_t = execution_length
	facing = 1 if target.position.x >= position.x else -1
	target.executing = true
	# Um voador atordoado desce ao nível do penitente para alinhar a animação conjunta com o chão.
	if target.family == "flyer": target.position.y = position.y
	target.execution_progress = 0
	target.velocity = Vector2.ZERO
	target.facing = -facing
	velocity = Vector2.ZERO
	invuln = execution_length + 0.1
	attack_buffer = 0
	roll_buffer = 0
	return true

func _start_charge() -> void:
	_clear_combat_input()
	combo_window = 0.0
	get_tree().call_group("game", "play_sfx", "golpe_carregado_carga")
	state = "charge"
	heavy_t = 0.0
	velocity.x = 0.0

func _start_heavy() -> void:
	state = "heavy"
	heavy_len = HEAVY_STRIKE_TIME * attack_scale()
	state_t = heavy_len
	heavy_done = false
	hit_list.clear()
	velocity.x = facing * 220.0
	get_tree().call_group("game", "play_sfx", "swing")
	get_tree().call_group("game", "play_sfx", "golpe_carregado_solta")

func _start_plunge() -> void:
	state = "plunge"
	plunge_landed = false
	hit_list.clear()
	attack_buffer = 0.0
	velocity = Vector2(0.0, 950.0)
	get_tree().call_group("game", "play_sfx", "swing")

## Armadura solta faíscas, o caixão solta pedra e os demais corpos sangram.
func _impact_kind(e) -> String:
	if e.kind == 2 or e.kind == 3:
		return "faiscas"
	if e.kind == 8 and not e.exposed:
		return "pedra"
	return "sangue"

func _room_is(id: String) -> bool:
	var director = get_tree().get_first_node_in_group("game")
	return director != null and director.exploration.room == id

## Arremessa a criatura para trás e, se caminha, para cima.
func _launch(e, push: float, lift: float) -> void:
	if not is_instance_valid(e) or e.dead or e.kind == 2:
		return
	if e.state == "stagger":
		# Não apaga a abertura de execução que o próprio golpe acabou de criar.
		e.velocity = Vector2.ZERO
		return
	if character == "beatriz" and not (e.kind == 8 and not e.exposed):
		# A lança empala e mantém a criatura no lugar.
		get_tree().call_group("game", "play_sfx", "empalar")
		e.state = "stagger"
		e.state_t = 1.2
		e.velocity = Vector2.ZERO
		return
	if e.kind == 8 and not e.exposed:
		return
	e.state = "hurt"
	e.state_t = 0.45
	e.poise = e.POISE.get(e.kind, 40.0)
	e.velocity = Vector2(float(facing) * push, lift if e.family == "walker" else lift * 0.5)

## Breve câmera lenta nos golpes mais fortes para dar peso ao impacto.
func _slow_motion(scale: float, seconds: float) -> void:
	var game = get_tree().get_first_node_in_group("game")
	if (game != null and game.reduced_pulses) or Engine.time_scale < 0.99:
		return
	Engine.time_scale = scale
	get_tree().create_timer(seconds, true, false, true).timeout.connect(func(): Engine.time_scale = 1.0)

func _heavy_hits() -> void:
	var full := heavy_t >= HEAVY_FULL
	if full:
		get_tree().call_group("game", "spawn_effect", "anel", global_position + Vector2(facing * 65.0, 0), facing, 0.65, "onda_golpe")
	var long := 134.0 * float(CHARACTERS[character].reach)
	var reach := Rect2(global_position + Vector2(0.0 if facing > 0 else -long, -94.0), Vector2(long, 94.0))
	get_tree().call_group("game", "spawn_effect", "arc", global_position + Vector2(facing * 70.0, -56.0), facing, 0.95, "golpe")
	var landed := false
	for e in get_tree().get_nodes_in_group("enemies"):
		if e.dead or hit_list.has(e) or not reach.intersects(e.hurt_rect()) or not _clear_strike(e):
			continue
		hit_list.append(e)
		landed = true
		var impact_kind := _impact_kind(e)
		var dmg := lerpf(28.0, 62.4, clampf(heavy_t / HEAVY_FULL, 0.0, 1.0)) * sword_multiplier()
		e.last_hitter = self
		e.take_hit(dmg, global_position.x)
		if full and e.kind == 8 and not e.exposed: e._break_coffin()
		_launch(e, 440.0 if full else 230.0, -300.0 if full else -130.0)
		e.hit_pause = maxf(e.hit_pause, 0.085)
		var spot: Vector2 = e.global_position + Vector2(0.0, -e.body_size.y * 0.55)
		get_tree().call_group("game", "spawn_effect", "star", spot, facing, 0.75, "golpe")
		get_tree().call_group("game", "spawn_effect", impact_kind, spot, facing, 0.5, "impactos")
		if e.dead and e.family != "flyer":
			get_tree().call_group("game", "spawn_effect", "pool", Vector2(e.global_position.x, e.global_position.y - 52.0), facing, 0.6, "golpe")
	if landed:
		get_tree().call_group("game", "play_sfx", "hit_carne")
		get_tree().call_group("game", "play_sfx", "chefe_pancada")
		shake = maxf(shake, 10.0)
		hit_pause = 0.085
		add_culpa(5)
		_slow_motion(0.5, 0.09)

func _plunge_impact() -> void:
	shake = maxf(shake, 8.0)
	get_tree().call_group("game", "spawn_effect", "poeira", global_position, facing, 0.85, "onda_golpe")
	var floor_kind := "osso" if _room_is("ossuary") else "pedra"
	get_tree().call_group("game", "spawn_effect", floor_kind, global_position + Vector2(0.0, -20.0), facing, 0.45, "impactos")
	get_tree().call_group("game", "play_sfx", "mergulho_impacto")
	get_tree().call_group("game", "play_sfx", "chefe_pancada")
	for e in get_tree().get_nodes_in_group("enemies"):
		if e.dead: continue
		var d: Vector2 = e.global_position - global_position
		if absf(d.x) < 130.0 and absf(d.y) < 70.0 and _clear_strike(e):
			e.take_hit(30.0 * sword_multiplier(), global_position.x)
			var away := 1 if d.x >= 0.0 else -1
			var keep := facing
			facing = away
			_launch(e, 280.0, -260.0)
			facing = keep

## Sangue compartilhado: doa parte da própria vida para levantar quem caiu.
func _raise(other) -> void:
	var given := minf(max_hp * 0.35, hp - 1.0)
	if given < 5.0:
		get_tree().call_group("game", "toast", "Não há sangue bastante para dar.")
		return
	hp -= given
	other.hp = given
	other.state = "idle"
	other.state_t = 0.0
	other.invuln = 1.5
	get_tree().call_group("game", "spawn_effect", "blood", other.global_position + Vector2(0.0, -40.0), facing, 0.8)
	get_tree().call_group("game", "play_sfx", "heal")
	get_tree().call_group("game", "play_sfx", "sangue_compartilhado")
	get_tree().call_group("game", "play_sfx", "levanta")
	get_tree().call_group("game", "toast", "Sangue compartilhado: %s se levanta." % str(other.CHARACTERS[other.character].name).capitalize())

## O jogo controla Beatriz até o segundo jogador assumir: ela segue, luta, apara e levanta o Penitente.
func _ai_think(delta: float) -> void:
	ai_tap.clear()
	ai_held.clear()
	ai_axis = 0.0
	ai_attack_cd = maxf(ai_attack_cd - delta, 0.0)
	var lead = partner()
	if lead == null or not standing():
		return
	if lead.state == "fallen":
		var gap: float = lead.global_position.x - global_position.x
		if absf(gap) > 60.0: ai_axis = signf(gap)
		else: ai_held["share_blood"] = true
		return
	var foe = null
	var best := 99999.0
	for e in get_tree().get_nodes_in_group("enemies"):
		if e.dead or e.spawn_opacity < 1.0: continue
		var d: float = e.global_position.distance_to(lead.global_position)
		if d < 560.0 and absf(e.global_position.y - global_position.y) < 170.0 and d < best:
			best = d
			foe = e
	if foe != null:
		var dx: float = foe.global_position.x - global_position.x
		var reach := 96.0 * float(CHARACTERS[character].reach)
		if absf(dx) > reach * 0.85:
			ai_axis = signf(dx)
		else:
			facing = 1 if dx > 0.0 else -1
			if foe.state == "windup" and foe.state_t < 0.22 and parry_cd <= 0.0 and randf() < 0.5:
				ai_tap["parry"] = true
			elif foe.state == "stagger" and is_on_floor():
				ai_tap["interact"] = true
				ai_tap["attack"] = true
			elif ai_attack_cd <= 0.0:
				ai_tap["attack"] = true
				ai_attack_cd = 0.5
	else:
		var gap: float = lead.global_position.x - global_position.x
		if absf(gap) > 150.0: ai_axis = signf(gap)
		if lead.global_position.y < global_position.y - 90.0 and absf(gap) < 280.0 and is_on_floor():
			ai_tap["jump"] = true
		if hp < max_hp * 0.3 and flasks > 0:
			ai_tap["heal"] = true
	if is_on_wall() and absf(ai_axis) > 0.0 and is_on_floor():
		ai_tap["jump"] = true

## Cada criatura usa sua execução própria quando a animação correspondente existe ("execute_<actor>");
## enquanto isso, usa a execução compartilhada de humanoides ou do Chorão.
func _execution_clip() -> String:
	if is_instance_valid(execution_target):
		var own := "execute_" + str(execution_target.TYPES[execution_target.kind].actor)
		if animator.sprite_frames != null and animator.sprite_frames.has_animation(own):
			return own
		return "execute_devotee" if execution_target.humanoid() else "execute_mourner"
	return "execute_devotee"

func _execution_torso() -> Vector2:
	if is_instance_valid(execution_target):
		return execution_target.global_position + Vector2(0.0, -execution_target.body_size.y * 0.55)
	return global_position + Vector2(facing * 45, -42)

func _blood_burst(at: Vector2, size: float, drops: int) -> void:
	var game = get_tree().get_first_node_in_group("game")
	if game == null: return
	game.spawn_effect("blood", at, facing, size)
	game.spawn_effect("blood", at + Vector2(float(facing) * 18.0, -8.0), facing, size * 0.75)
	var spray := CPUParticles2D.new()
	spray.one_shot = true
	spray.emitting = false
	spray.amount = drops
	spray.lifetime = 1.0
	spray.explosiveness = 0.95
	spray.direction = Vector2(float(facing), -0.7)
	spray.spread = 38.0
	spray.initial_velocity_min = 240.0
	spray.initial_velocity_max = 560.0
	spray.gravity = Vector2(0, 1500)
	# Gotas arredondadas de 2–5 pixels, em vez de quadrados grandes.
	var drop_gradient := Gradient.new()
	drop_gradient.colors = PackedColorArray([Color.WHITE, Color(1, 1, 1, 0)])
	var drop_texture := GradientTexture2D.new()
	drop_texture.gradient = drop_gradient
	drop_texture.width = 8
	drop_texture.height = 8
	drop_texture.fill = GradientTexture2D.FILL_RADIAL
	drop_texture.fill_from = Vector2(0.5, 0.5)
	drop_texture.fill_to = Vector2(1.0, 0.5)
	spray.texture = drop_texture
	spray.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	spray.scale_amount_min = 0.3
	spray.scale_amount_max = 0.625
	spray.color = Color(0.55, 0.02, 0.04)
	spray.z_index = 7
	spray.position = at
	spray.add_to_group("blood_spray")
	game.add_child(spray)
	spray.emitting = true
	get_tree().create_timer(1.6).timeout.connect(spray.queue_free)

func _blood_decal(ground: Vector2) -> void:
	var game = get_tree().get_first_node_in_group("game")
	if game == null or not ResourceLoader.exists("res://assets/animation/efeitos_golpe.png"): return
	var old := get_tree().get_nodes_in_group("blood_decals")
	while old.size() >= BLOOD_DECALS_MAX:
		# Retira da contagem imediatamente; o nó é removido no fim do quadro.
		var oldest = old.pop_front()
		oldest.remove_from_group("blood_decals")
		oldest.queue_free()
	var pool := Sprite2D.new()
	var art := AtlasTexture.new()
	art.atlas = load("res://assets/animation/efeitos_golpe.png")
	art.region = Rect2(5 * 256, 3 * 256, 256, 256)
	pool.texture = art
	pool.scale = Vector2(0.62, 0.62)
	pool.modulate = Color(0.78, 0.74, 0.74)
	pool.flip_h = facing < 0
	pool.z_index = 5
	pool.position = ground - Vector2(0.0, (215.0 - 128.0) * 0.62)
	pool.add_to_group("blood_decals")
	game.add_child(pool)
	var fade := pool.create_tween()
	fade.tween_interval(25.0)
	fade.tween_property(pool, "modulate:a", 0.0, 4.0)
	fade.tween_callback(pool.queue_free)

func can_drop() -> bool:
	for i in range(get_slide_collision_count()):
		var collider = get_slide_collision(i).get_collider()
		if collider != null and collider.get_meta("one_way",false): return true
	return false


func _update_sword() -> void:
	if sword == null: return
	if lance != null: lance.visible = false
	if animator.actor == "beatriz":
		# Os desenhos próprios já incluem a lança.
		sword.visible = false
		return
	# Os desenhos de ataque e ritual já incluem a lâmina; nunca acrescenta uma segunda.
	sword.visible = has_weapon and state == "idle" and not cinematic_focus and animator.animation in ["idle","run"]
	if not sword.visible: return
	var grips: Array = RUN_GRIPS if animator.animation == "run" else IDLE_GRIPS
	var wrist: Vector2 = grips[clampi(animator.frame, 0, grips.size() - 1)]
	# Os desenhos já respiram e se movem; a espada acompanha o punho sem movimento adicional.
	var hand := (wrist-Vector2(128,250))*0.44
	var angle := 0.75
	# Mantém a ponta acima do piso de colisão durante o movimento baixo da espada na corrida.
	var blade_length := (2050-SWORD_GRIP.x)*SWORD_SCALE
	angle = minf(angle,asin(clampf((-3-hand.y)/blade_length,-1,1)))
	sword.position = Vector2(hand.x*facing,hand.y)
	sword.scale = Vector2(SWORD_SCALE*facing,SWORD_SCALE)
	sword.rotation = angle*facing
	sword.modulate = animator.modulate
	if character != "penitente" and lance != null:
		# Beatriz segura a lança no mesmo punho, com a ponta para a frente e para baixo.
		lance.visible = true
		lance.position = sword.position
		lance.rotation = sword.rotation
		lance.scale = Vector2(float(facing), 1.0)
		sword.visible = false


func _start_air_attack() -> void:
	if not has_weapon or air_attack_used: return
	var direction := axis()
	if direction != 0: facing = 1 if direction > 0 else -1
	state = "air_attack"
	state_t = AIR_ATTACK_TIME
	air_attack_used = true
	swing_effect = false
	aerial_after_cut = true
	attack_buffer = 0
	hit_list.clear()
	get_tree().call_group("game","play_sfx","swing")


func _capture_combat_input() -> void:
	if input_release_gate:
		for action in ["attack", "heavy", "parry", "roll", "jump"]:
			if held(action): return
		input_release_gate = false
	if pressed("attack") and has_weapon:
		attack_buffer = minf(INPUT_BUFFER * attack_scale(), 0.36)
	if pressed("heavy") and has_weapon:
		heavy_buffer = INPUT_BUFFER
	if pressed("parry") and has_weapon:
		parry_buffer = 0.18
		parry_direction = axis()
	if pressed("roll"):
		roll_buffer = 0.18
		roll_direction = axis()
	if pressed("jump"):
		jump_buffer = 0.12

func _clear_combat_input() -> void:
	attack_buffer = 0.0
	roll_buffer = 0.0
	parry_buffer = 0.0
	heavy_buffer = 0.0
	jump_buffer = 0.0
	roll_direction = 0.0
	parry_direction = 0.0

func _buffered_defense(on_floor: bool) -> bool:
	if not on_floor: return false
	if roll_buffer > 0.0 and roll_cd <= 0.0:
		_start_roll()
		return true
	if parry_buffer > 0.0 and has_weapon and parry_cd <= 0.0:
		_start_parry()
		return true
	return false

func _jump_from_recovery(on_floor: bool) -> bool:
	if not on_floor or jump_buffer <= 0.0: return false
	jump_buffer = 0.0
	coyote = 0.0
	jump_elapsed = 0.0
	state = "idle"
	velocity.y = JUMP_V
	get_tree().call_group("game", "play_sfx", "jump")
	return true

func _exit_tree() -> void:
	# Uma troca de cena não deve herdar a câmera lenta de um impacto anterior.
	Engine.time_scale = 1.0

func _clear_strike(target) -> bool:
	# A lâmina alcança o corpo, mas não atravessa paredes ou pisos sólidos.
	var origin := global_position + Vector2(0, -40)
	var end: Vector2 = target.global_position + Vector2(0, -target.body_size.y * 0.55)
	var ray := PhysicsRayQueryParameters2D.create(origin, end, 1)
	ray.exclude = [get_rid()]
	return get_world_2d().direct_space_state.intersect_ray(ray).is_empty()

func _swing_trail() -> void:
	if swing_effect: return
	swing_effect = true
	get_tree().call_group("game", "spawn_effect", "arc", global_position + Vector2(float(facing) * 58.0, -52.0), facing, 0.62, "golpe")
