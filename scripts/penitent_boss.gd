extends "res://scripts/enemy.gd"
## O Flagelado — o chefe final, no Vale dos Flagelados. (Só a revelação diz quem ele é: o próprio Penitente.)
## Ele é o reflexo do protagonista: a culpa que o Penitente recusou lembrar, vestida com a forma dele.
##
## Duas formas:
##  - REFLEXO ("mirror"): tem a aparência do jogador. Não perde vida: todo golpe contra ele volta para quem
##    bateu (REFLECT do dano) e deixa cair no chão uma gota de culpa.
##  - VERDADEIRA ("true"): a aparência original. Frágil: recebe dano normalmente por VULNERABLE_TIME segundos,
##    e chama flagelantes para protegê-lo. Depois volta a ser reflexo.
## Duas maneiras de arrancar a forma verdadeira:
##  1. aparar um golpe dele (os de anel dourado) no momento certo;
##  2. esperar que ele recolha as gotas de culpa e se ajoelhe para rezar: ao rezar para se perdoar, ele
##     volta a ser quem é.
## A cada quarto da vida ele perde uma parte da armadura (STAGES). Na segunda, Beatriz chega. Na última, ele
## cai de joelhos, e resta o capacete — que só Beatriz tira.

## O nome que o jogador vê. Não pode entregar o final: quem ele é só se descobre quando Beatriz tira o capacete.
const NOME := "O FLAGELADO"
const VULNERABLE_TIME := 30.0
const REFLECT := 0.35
const STAGES := 4
const DROPS_TO_PRAY := 3
const DROPS_MAX := 6
const MINIONS_MAX := 4

var form := "mirror"
var form_t := 0.0
## Partes da armadura já perdidas (0 a 4).
var stage := 0
var gathered := 0
var fallen := false
var swings := 0
var target_drop = null
var plunge_from := Vector2.ZERO
var plunge_to := Vector2.ZERO
var hit_done := false
var minions: Array = []
## Quantas vezes cada caminho revelou a forma verdadeira (para o registro e os testes).
var reveals_by_parry := 0
var reveals_by_prayer := 0
## A culpa do Penitente pinga sozinha enquanto o reflexo o encara: a luta nunca fica sem saída.
var drip_t := 6.0
## Ao acordar ele ainda tem a própria forma; em instantes veste a do jogador. Nesse intervalo nada o fere.
var intro := false

func _ready() -> void:
	super._ready()
	arena_left = 30560.0
	arena_right = 33240.0
	state = "sleep"
	facing = -1
	# Ele espera entre as forcas com a própria aparência. Só copia o jogador depois de vê-lo.
	_wear("true")

## Veste a forma do jogador (reflexo) ou a própria.
func _wear(which: String) -> void:
	if form != which and is_node_ready() and has_node("CombatVisuals"): get_node("CombatVisuals").transform_out()
	form = which
	if which == "mirror":
		animator.configure("hero", 0.44)
		tint = Color(0.42, 0.34, 0.40)
		body_size = Vector2(34, 60)
	else:
		animator.configure("flagelado_%d" % clampi(stage,0,4), 0.62)
		tint = Color(1.0, 1.0 - 0.07 * stage, 1.0 - 0.09 * stage)
		body_size = Vector2(56, 110)

func hurt_rect() -> Rect2:
	return Rect2(global_position + Vector2(-body_size.x / 2.0, -body_size.y), body_size)

func awaken() -> void:
	if awake: return
	awake = true
	state = "idle"
	state_t = 1.2
	intro = true
	form_t = 2.2

func _game():
	return get_tree().get_first_node_in_group("game")

# ---------------------------------------------------------------- dano

func take_hit(dmg: float, from_x: float) -> void:
	if fallen or dead or state == "sleep" or intro:
		return
	if not awake:
		awaken()
	flash = 0.12
	if form == "mirror":
		# O reflexo não sangra: o golpe volta para quem bateu, e a culpa cai no chão como uma gota.
		_sfx("hit_metal")
		_sfx("reflexo_devolve")
		var hitter = last_hitter if last_hitter != null and is_instance_valid(last_hitter) else player
		if hitter != null and is_instance_valid(hitter) and hitter.standing():
			var back := dmg * REFLECT
			# O reflexo fere, mas não mata sozinho: quem mata é o golpe dele.
			hitter.hp = maxf(hitter.hp - back, 1.0)
			hitter.damage_flash = 0.3
			hitter.add_culpa(back * 0.5)
			get_tree().call_group("game", "spawn_effect", "sangue", hitter.global_position + Vector2(0, -40), -hitter.facing, 0.3, "impactos")
			get_tree().call_group("game", "blood_splats", hitter.global_position, -hitter.facing, 2, 0.5)
			_drop_guilt(hitter.global_position)
		get_tree().call_group("game", "boss_reflected")
		return
	hp -= dmg
	_sfx("dor")
	var new_stage := clampi(int(floor((1.0 - hp / max_hp) * STAGES + 0.0001)), 0, STAGES)
	if hp <= 0.0:
		new_stage = STAGES
	if new_stage > stage:
		_break_armor(new_stage)
	elif state in ["idle", "walk"]:
		velocity.x = signf(global_position.x - from_x) * 120.0

## Aparar um golpe dele arranca o reflexo.
func parried() -> void:
	if fallen or dead: return
	flash = 0.2
	if form == "mirror":
		reveals_by_parry += 1
		_reveal(false)
	state = "exposed"
	state_t = 1.6
	velocity = Vector2.ZERO

func _drop_guilt(at: Vector2) -> void:
	_sfx("gota_culpa")
	if get_tree().get_nodes_in_group("guilt_drops").size() >= DROPS_MAX: return
	var game = _game()
	if game == null: return
	var drop := Node2D.new()
	drop.position = Vector2(clampf(at.x + randf_range(-30, 30), arena_left + 20.0, arena_right - 20.0), 596.0)
	drop.z_index = 6
	drop.add_to_group("guilt_drops")
	var paint = load("res://scripts/actor_animation.gd").new()
	paint.configure("gota_culpa",0.22)
	paint.select("fall",1)
	drop.add_child(paint)
	paint.animation_finished.connect(func():
		if is_instance_valid(drop) and not drop.has_meta("collecting"): paint.select("idle",1)
	)
	game.add_child(drop)
	var pulse := drop.create_tween().set_loops()
	pulse.tween_property(drop, "scale", Vector2(1.25, 1.25), 0.6)
	pulse.tween_property(drop, "scale", Vector2.ONE, 0.6)

# ---------------------------------------------------------------- formas

## Volta a ser quem é: frágil por VULNERABLE_TIME, protegido pelos flagelantes.
func _reveal(by_prayer: bool) -> void:
	_sfx("chefe_transforma")
	_wear("true")
	form_t = VULNERABLE_TIME
	gathered = 0
	swings = 0
	_sfx("corrente_cede")
	get_tree().call_group("game", "spawn_effect", "silhueta", global_position + Vector2(0, -50), facing, 0.9, "golpe")
	get_tree().call_group("game", "shake_cam", 5.0)
	get_tree().call_group("game", "boss_revealed", by_prayer)
	_summon(2 + mini(stage, 2))

## Veste de novo a forma do jogador.
func _mirror_again() -> void:
	intro = false
	_sfx("chefe_transforma")
	_wear("mirror")
	form_t = 0.0
	state = "idle"
	state_t = 1.0
	_sfx("sino_surdo")
	get_tree().call_group("game", "spawn_effect", "silhueta", global_position + Vector2(0, -40), facing, 0.9, "golpe")
	get_tree().call_group("game", "boss_mirrored")

## Penitentes do vale: flagelantes de capirote que vêm protegê-lo enquanto ele está frágil.
func _summon(count: int) -> void:
	var game = _game()
	if game == null: return
	var alive: Array = []
	for m in minions:
		if is_instance_valid(m) and not m.dead: alive.append(m)
	minions = alive
	for i in range(count):
		if minions.size() >= MINIONS_MAX: break
		var side := -1.0 if i % 2 == 0 else 1.0
		var x := clampf(global_position.x + side * (150.0 + 70.0 * i), arena_left + 60.0, arena_right - 60.0)
		var m = game.EnemyScript.new()
		m.setup(4 if i % 3 != 2 else 0, Vector2(x, 600.0), 80.0, player)
		m.room_id = "vale"
		m.tint = Color(1.0, 0.92, 0.9)
		m.reward = 0
		m.killed.connect(game._on_enemy_killed)
		game.add_child(m)
		minions.append(m)
		get_tree().call_group("game", "spawn_effect", "dust", Vector2(x, 596.0), 1, 0.8)

func _break_armor(new_stage: int) -> void:
	_sfx("placa_cai")
	stage = new_stage
	_wear("true")
	_sfx("hit_metal")
	_sfx("chefe_pancada")
	get_tree().call_group("game", "shake_cam", 9.0)
	get_tree().call_group("game", "spawn_effect", "faiscas", global_position + Vector2(0, -60), facing, 0.7, "impactos")
	_shed_plates()
	if stage >= STAGES:
		_fall()
		return
	state = "armor_break"
	state_t = 1.2
	velocity = Vector2(-facing * 160.0, 0)
	get_tree().call_group("game", "boss_armor_broke", stage)

## Placas de bronze que se soltam e caem no chão.
func _shed_plates() -> void:
	var game = _game()
	if game == null: return
	var plates := CPUParticles2D.new()
	plates.one_shot = true
	plates.amount = 7
	plates.lifetime = 1.6
	plates.explosiveness = 1.0
	plates.direction = Vector2(-facing, -1.0)
	plates.spread = 60.0
	plates.initial_velocity_min = 180.0
	plates.initial_velocity_max = 420.0
	plates.gravity = Vector2(0, 1500)
	plates.angular_velocity_min = -500.0
	plates.angular_velocity_max = 500.0
	plates.texture = load("res://assets/efeitos/placas_flagelado.png")
	var pieces := CanvasItemMaterial.new()
	pieces.particles_animation = true
	pieces.particles_anim_h_frames = 4
	pieces.particles_anim_v_frames = 1
	pieces.particles_anim_loop = false
	plates.material = pieces
	plates.anim_offset_min = 0.0
	plates.anim_offset_max = 0.999
	plates.scale_amount_min = 0.25
	plates.scale_amount_max = 0.45
	plates.color = Color.WHITE
	plates.z_index = 7
	plates.position = global_position + Vector2(0, -60)
	game.add_child(plates)
	plates.emitting = true
	get_tree().create_timer(2.2).timeout.connect(plates.queue_free)
	# Uma peça de cada queda permanece no chão, marcando a armadura já abandonada.
	var fallen_plate:=Sprite2D.new()
	var tile:=AtlasTexture.new()
	tile.atlas=plates.texture
	tile.region=Rect2(clampi(stage-1,0,3)*128,0,128,128)
	fallen_plate.texture=tile
	fallen_plate.scale=Vector2.ONE*0.4
	fallen_plate.position=global_position+Vector2(0,-65)
	fallen_plate.z_index=-1
	game.add_child(fallen_plate)
	var landing:=Vector2(clampf(global_position.x-facing*randf_range(45,100),arena_left,arena_right),592)
	var fall:=fallen_plate.create_tween()
	fall.tween_property(fallen_plate,"position",fallen_plate.position+Vector2(-facing*30,-35),0.18).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	fall.tween_property(fallen_plate,"position",landing,0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	fall.tween_interval(24)
	fall.tween_property(fallen_plate,"modulate:a",0,1)
	fall.tween_callback(fallen_plate.queue_free)

## Sem armadura, ele cai de joelhos. Não morre: resta o capacete.
func _fall() -> void:
	_sfx("chefe_ajoelha")
	hp = 0.0
	fallen = true
	state = "kneel"
	state_t = 0.0
	velocity = Vector2.ZERO
	collision_layer = 0
	_wear("true")
	for m in minions:
		if is_instance_valid(m) and not m.dead: m._die()
	for drop in get_tree().get_nodes_in_group("guilt_drops"): drop.queue_free()
	get_tree().call_group("game", "final_boss_fallen", self)

func _die() -> void:
	# Este chefe não morre por golpe: cai de joelhos (_fall) e espera.
	pass

# ---------------------------------------------------------------- comportamento

func _strike(reach: float, height: float, dmg: float, parryable: bool) -> void:
	var box := Rect2(global_position + Vector2(0.0 if facing > 0 else -reach, -height), Vector2(reach, height))
	for who in get_tree().get_nodes_in_group("players"):
		if is_instance_valid(who) and who.standing() and box.intersects(who.body_rect()):
			var before: float = who.hp
			who.take_hit(dmg, global_position.x, self, parryable)
			if who.hp < before and form == "mirror": _drop_guilt(who.global_position)

func _physics_process(delta: float) -> void:
	var game = _game()
	if game == null or game.state != "play" or game.message_text != "" or game.narrative.mode != "" or game.exploration.room != room_id or game.exploration.is_transitioning():
		return
	# Persegue o penitente de pé mais próximo.
	var best = null
	var best_d := 99999.0
	for who in get_tree().get_nodes_in_group("players"):
		if not is_instance_valid(who) or not who.standing(): continue
		var d: float = absf(who.global_position.x - global_position.x)
		if d < best_d:
			best_d = d
			best = who
	if best != null: player = best
	if hit_pause > 0.0:
		hit_pause -= delta
		return
	anim_t += delta
	flash = maxf(flash - delta, 0.0)
	state_t -= delta
	cd -= delta
	velocity.y = minf(velocity.y + 1800.0 * delta, 900.0)
	if fallen or state == "sleep" or player == null or not is_instance_valid(player):
		velocity.x = 0.0
		move_and_slide()
		return
	var to_p: float = player.global_position.x - global_position.x
	var dist := absf(to_p)
	if form == "true" and state not in ["pray", "armor_break", "exposed"]:
		form_t -= delta
		if form_t <= 0.0:
			_mirror_again()
	if form == "mirror":
		drip_t -= delta
		if drip_t <= 0.0:
			drip_t = 6.0
			_drop_guilt(player.global_position)
	var speed := 150.0 if form == "mirror" else 105.0
	match state:
		"idle":
			velocity.x = move_toward(velocity.x, 0.0, 900.0 * delta)
			facing = 1 if to_p > 0.0 else -1
			if state_t <= 0.0: _decide(dist)
		"walk":
			facing = 1 if to_p > 0.0 else -1
			velocity.x = facing * speed
			if dist < 110.0 or state_t <= 0.0: _decide(dist)
		"gather":
			# Recolhe as gotas de culpa que o jogador deixou cair.
			if target_drop == null or not is_instance_valid(target_drop):
				state = "idle"
				state_t = 0.2
			else:
				var dx: float = target_drop.global_position.x - global_position.x
				facing = 1 if dx > 0.0 else -1
				velocity.x = facing * 190.0
				if absf(dx) < 26.0:
					_collect_drop(target_drop)
					target_drop = null
					gathered += 1
					flash = 0.1
					_sfx("coleta")
					_sfx("gota_recolhe")
					if gathered >= DROPS_TO_PRAY:
						# Reza para se perdoar, e ao rezar volta a ser quem é.
						reveals_by_prayer += 1
						_reveal(true)
						state = "pray"
						_sfx("chefe_reza")
						state_t = 3.0
						velocity.x = 0.0
					else:
						state = "idle"
						state_t = 0.25
		"pray":
			velocity.x = 0.0
			if state_t <= 0.0:
				state = "idle"
				state_t = 0.5
		"swing_wind":
			velocity.x = move_toward(velocity.x, 0.0, 1400.0 * delta)
			if state_t <= 0.0:
				state = "swing"
				state_t = 0.2
				hit_done = false
				velocity.x = facing * 140.0
				_sfx("swing")
		"swing":
			if not hit_done:
				hit_done = true
				_strike(104.0 if form == "mirror" else 128.0, 80.0, 14.0 if form == "mirror" else 18.0, true)
			velocity.x = move_toward(velocity.x, 0.0, 1200.0 * delta)
			if state_t <= 0.0 and state == "swing":
				swings += 1
				if swings < 3 and dist < 170.0 and form == "mirror":
					facing = 1 if to_p > 0.0 else -1
					state = "swing_wind"
					state_t = 0.3
				else:
					swings = 0
					state = "idle"
					state_t = 0.9 if form == "mirror" else 1.3
		"thrust_wind":
			velocity.x = 0.0
			facing = 1 if to_p > 0.0 else -1
			if state_t <= 0.0:
				state = "thrust"
				state_t = 0.34
				hit_done = false
				velocity.x = facing * 620.0
				_sfx("swing")
		"thrust":
			if not hit_done:
				var box := Rect2(global_position + Vector2(0.0 if facing > 0 else -96.0, -70.0), Vector2(96.0, 70.0))
				for who in get_tree().get_nodes_in_group("players"):
					if is_instance_valid(who) and who.standing() and box.intersects(who.body_rect()):
						hit_done = true
						who.take_hit(16.0, global_position.x, self, true)
			if state_t <= 0.0 and state == "thrust":
				velocity.x = 0.0
				state = "idle"
				state_t = 1.0
		"plunge_wind":
			velocity.x = 0.0
			if state_t <= 0.0:
				state = "plunge_air"
				state_t = 0.7
				plunge_from = global_position
				plunge_to = Vector2(clampf(player.global_position.x, arena_left + 40.0, arena_right - 40.0), 600.0)
		"plunge_air":
			# Salta e cai sobre o penitente: não se apara, esquive.
			var k := clampf(1.0 - state_t / 0.7, 0.0, 1.0)
			global_position = Vector2(lerpf(plunge_from.x, plunge_to.x, k), 600.0 - sin(k * PI) * 240.0)
			velocity = Vector2.ZERO
			if k >= 1.0:
				global_position = plunge_to
				state = "plunge_land"
				state_t = 0.55
				_sfx("mergulho_impacto")
				get_tree().call_group("game", "shake_cam", 8.0)
				get_tree().call_group("game", "spawn_effect", "poeira", global_position, facing, 0.9, "onda_golpe")
				get_tree().call_group("game", "vale_impulse", global_position.x, 2.2)
				for who in get_tree().get_nodes_in_group("players"):
					if is_instance_valid(who) and who.standing() and absf(who.global_position.x - global_position.x) < 110.0 and absf(who.global_position.y - global_position.y) < 80.0:
						who.take_hit(20.0, global_position.x, self, false)
			return
		"plunge_land":
			velocity.x = 0.0
			if state_t <= 0.0:
				state = "idle"
				state_t = 0.8
		"slam_wind":
			velocity.x = 0.0
			facing = 1 if to_p > 0.0 else -1
			if state_t <= 0.0:
				state = "slam"
				state_t = 0.4
				hit_done = false
				_sfx("chefe_pancada")
		"slam":
			if not hit_done:
				hit_done = true
				_strike(150.0, 110.0, 22.0, false)
				get_tree().call_group("game", "shake_cam", 7.0)
				get_tree().call_group("game", "vale_impulse", global_position.x, 1.6)
				get_tree().call_group("game", "spawn_effect", "pedra", global_position + Vector2(facing * 90.0, -14.0), facing, 0.5, "impactos")
			velocity.x = 0.0
			if state_t <= 0.0 and state == "slam":
				state = "idle"
				state_t = 1.4
		"exposed":
			velocity.x = 0.0
			if state_t <= 0.0:
				state = "idle"
				state_t = 0.4
		"armor_break":
			velocity.x = move_toward(velocity.x, 0.0, 500.0 * delta)
			if state_t <= 0.0:
				# Ferido, ele se esconde de novo atrás da forma do jogador.
				_mirror_again()
	move_and_slide()
	global_position.x = clampf(global_position.x, arena_left, arena_right)

func _decide(dist: float) -> void:
	facing = 1 if player.global_position.x > global_position.x else -1
	if form == "mirror":
		var drops := get_tree().get_nodes_in_group("guilt_drops")
		if drops.size() > 0 and (drops.size() >= 2 or randf() < 0.45):
			var nearest = null
			var nd := 99999.0
			for d in drops:
				var dd: float = absf(d.global_position.x - global_position.x)
				if dd < nd:
					nd = dd
					nearest = d
			target_drop = nearest
			state = "gather"
			return
		if dist > 300.0:
			if randf() < 0.55:
				state = "thrust_wind"
				state_t = 0.5
				_sfx("aviso_aparavel")
			else:
				state = "plunge_wind"
				state_t = 0.45
				_sfx("aviso_perigo")
		elif dist > 120.0:
			state = "walk"
			state_t = 1.2
		else:
			state = "swing_wind"
			state_t = 0.42
			_sfx("aviso_aparavel")
	else:
		# Na forma verdadeira ele é mais lento e pesado: golpes largos, alguns sem defesa.
		if dist > 190.0:
			state = "walk"
			state_t = 1.4
		elif randf() < 0.5:
			state = "slam_wind"
			state_t = 0.75
			_sfx("aviso_perigo")
		else:
			state = "swing_wind"
			state_t = 0.55

# ---------------------------------------------------------------- imagem

func _process(delta: float) -> void:
	if animator == null: return
	spawn_opacity = minf(spawn_opacity + delta / 0.6, 1.0)
	var col := tint
	if flash > 0.0: col = col.lerp(Color(1.6, 1.4, 1.4), 0.7)
	animator.modulate = col
	animator.modulate.a *= spawn_opacity
	animator.speed_scale = 1.0
	if form == "mirror":
		match state:
			"sleep", "idle": animator.select("idle", facing)
			"walk", "gather": animator.select("run", facing)
			"swing_wind": animator.select("attack_a" if swings % 2 == 0 else "attack_b", facing, clampf(1.0 - state_t / 0.42, 0.0, 1.0) * 0.3)
			"swing": animator.select("attack_a" if swings % 2 == 0 else "attack_b", facing, 0.3 + clampf(1.0 - state_t / 0.2, 0.0, 1.0) * 0.69)
			"thrust_wind": animator.select("attack_b", facing, clampf(1.0 - state_t / 0.5, 0.0, 1.0) * 0.3)
			"thrust": animator.select("attack_b", facing, 0.45)
			"plunge_wind": animator.select("jump", facing, 0.1)
			"plunge_air": animator.select("air_attack", facing, 0.5)
			"plunge_land": animator.select("air_attack", facing, 0.95)
			_: animator.select("idle", facing)
	else:
		match state:
			"sleep", "idle": animator.select("idle", facing)
			"walk": animator.select("walk", facing)
			"pray":
				if state_t>2.3:animator.select("kneel_down",facing,clampf((3.0-state_t)/0.7,0,0.999))
				else:animator.select("pray",facing)
			"swing_wind": animator.select("attack_a", facing, clampf(1.0 - state_t / 0.55, 0.0, 1.0) * 0.3)
			"swing": animator.select("attack_a", facing, 0.3 + clampf(1.0 - state_t / 0.2, 0.0, 1.0) * 0.69)
			"slam_wind": animator.select("slam", facing, clampf(1.0 - state_t / 0.75, 0.0, 1.0) * 0.3)
			"slam": animator.select("slam", facing, 0.34 + clampf(1.0 - state_t / 0.4, 0.0, 1.0) * 0.6)
			"exposed": animator.select("hurt", facing, clampf(1.0-state_t/1.6,0.0,0.999))
			"armor_break": animator.select("armor_break", facing, clampf(1.0-state_t/1.2,0.0,0.999))
			"kneel": animator.select("kneel", facing, 0.99)
			_: animator.select("idle", facing)
	queue_redraw()

func _draw() -> void:
	if fallen: return
	var mid := Vector2(0, -body_size.y * 0.5)
	if form == "mirror" and state != "sleep":
		# O reflexo: um contorno vermelho que respira, avisando que bater nele é bater em si.
		var breathe := 0.5 + 0.5 * sin(anim_t * 3.0)
		draw_arc(mid, body_size.y * 0.62, 0, TAU, 36, Color(0.85, 0.08, 0.1, 0.25 + 0.35 * breathe), 2.0)
		draw_arc(mid, body_size.y * 0.74 + breathe * 4.0, 0, TAU, 36, Color(0.85, 0.08, 0.1, 0.12), 1.5)
	if form == "true" and state != "kneel":
		# Tempo que resta de fragilidade.
		draw_arc(Vector2(0, -body_size.y - 20), 9, -PI / 2, -PI / 2 + TAU * clampf(form_t / VULNERABLE_TIME, 0, 1), 28, Color("e7c17b"), 2.5)
	if state == "pray":
		draw_circle(mid, body_size.y * 0.8, Color(1.0, 0.85, 0.55, 0.10))
	# Avisos: dourado pode ser aparado; vermelho não, esquive.
	if state in ["swing_wind", "thrust_wind"] and state_t < 0.24:
		draw_arc(Vector2(facing * 40.0, -46.0), 26.0, 0, TAU, 24, Color(1.0, 0.84, 0.32, 0.95), 3.0)
	if state in ["plunge_wind", "slam_wind"]:
		draw_arc(mid, 44.0, 0, TAU, 28, Color(0.92, 0.12, 0.1, 0.9), 3.0)

## Retira da coleta imediatamente; a gota termina sua animação antes de sair da cena.
func _collect_drop(drop: Node2D) -> void:
	drop.remove_from_group("guilt_drops")
	drop.set_meta("collecting",true)
	if drop.get_child_count()>0:
		var paint = drop.get_child(0)
		paint.select("collect",1)
		paint.animation_finished.connect(drop.queue_free,CONNECT_ONE_SHOT)
	else: drop.queue_free()
