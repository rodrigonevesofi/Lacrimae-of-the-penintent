extends CharacterBody2D
## Inimigos: 0 = Devoto Corrompido, 1 = Chorão (voador), 2 = A Mãe das Lágrimas (chefe)

const Util = preload("res://scripts/util.gd")
const Tear = preload("res://scripts/tear.gd")
const Spike = preload("res://scripts/spike.gd")

signal killed(enemy)

## Bestiary. Kinds 0-2 are the original devotee, weeper and boss; 3-7 are the Goya-inspired additions.
## `family` decides body and movement; `actor` names the animation entry in clips.json (art slot).
const TYPES := {
	0: {"name":"Devoto Corrompido","family":"walker","actor":"devotee","scale":0.36,"tint":Color.WHITE,"hp":45.0,"reward":30,"body":Vector2(34,56),"col":0},
	1: {"name":"Chorão","family":"flyer","actor":"mourner","scale":0.36,"tint":Color.WHITE,"hp":30.0,"reward":40,"body":Vector2(36,48),"col":1},
	2: {"name":"A Mãe das Lágrimas","family":"boss","actor":"guardian","scale":0.92,"tint":Color.WHITE,"hp":450.0,"reward":1500,"body":Vector2(110,190),"col":-1},
	3: {"name":"O Devorador","family":"walker","actor":"devorador","scale":0.62,"tint":Color.WHITE,"hp":130.0,"reward":120,"body":Vector2(58,112),"col":0},
	4: {"name":"Flagelante","family":"walker","actor":"flagelante","scale":0.35,"tint":Color.WHITE,"hp":70.0,"reward":45,"body":Vector2(34,56),"col":0},
	5: {"name":"Bruxa do Aquelarre","family":"flyer","actor":"bruxa","scale":0.36,"tint":Color.WHITE,"hp":40.0,"reward":55,"body":Vector2(36,48),"col":1},
	6: {"name":"Asmodeia","family":"flyer","actor":"asmodeia","scale":0.42,"tint":Color.WHITE,"hp":60.0,"reward":60,"body":Vector2(44,56),"col":1},
	7: {"name":"Duelista","family":"walker","actor":"duelista","scale":0.36,"tint":Color.WHITE,"hp":70.0,"reward":40,"body":Vector2(34,56),"col":0},
}
const BESTIARY := {
	3: "O DEVORADOR — O que ele não consegue perdoar, ele engole. Esquive o bote e golpeie na recuperação.",
	4: "FLAGELANTE — Pune o corpo para calar o que a alma sabe. Faça-o errar a investida.",
	5: "AQUELARRE — Três vozes, um voto. Enquanto não estão sós, o voto as protege: elas só caem uma de cada vez.",
	6: "ASMODEIA — Paira sobre o povo e deixa cair a sentença. Não fique sob ela.",
	7: "OS DUELISTAS — Lutam até os joelhos no mesmo chão. Ignoram quem não os atrapalha.",
}

var room_id := "city"
var executing := false
var execution_progress := 0.0
var stagger_used := false
var fed_by_guilt := false
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
var group := -1
var partner = null
var duel_t := 0.0
var rage_t := 0.0
var charge_hit := false
var windup_len := 0.55
var tint := Color.WHITE
var announced := false
var family := "walker"


func setup(k: int, pos: Vector2, rng: float, p) -> void:
	kind = k
	home = pos
	position = pos
	patrol_range = rng
	player = p
	var t: Dictionary = TYPES[kind]
	display_name = t.name
	max_hp = t.hp
	reward = t.reward
	body_size = t.body
	family = t.family
	tint = t.tint
	match kind:
		2: state = "idle"
		7: state = "duel"
	hp = max_hp


func humanoid() -> bool:
	return family == "walker"


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	var t: Dictionary = TYPES[kind]
	if kind == 2:
		var guardian := AtlasTexture.new()
		guardian.atlas = load("res://assets/guardian.png")
		guardian.region = Rect2(320, 0, 850, 1024)
		appearance = guardian
	else:
		var atlas := AtlasTexture.new()
		atlas.atlas = load("res://assets/characters.png")
		atlas.region = Rect2((int(t.col) + 1) * 384, 0, 384, 1000)
		atlas.filter_clip = true
		appearance = atlas
	animator = preload("res://scripts/actor_animation.gd").new()
	animator.configure(t.actor, t.scale)
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
	if family == "walker":
		ledge = RayCast2D.new()
		ledge.collision_mask = 1
		ledge.enabled = true
		add_child(ledge)
	if family == "flyer":
		var glow := Color(0.6, 0.78, 1.0)
		if kind == 5: glow = Color(0.55, 0.9, 0.6)
		if kind == 6: glow = Color(0.78, 0.65, 1.0)
		light = Util.make_light(glow, 0.6, 1.4)
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


func coven_others() -> Array:
	var others: Array = []
	for e in get_tree().get_nodes_in_group("enemies"):
		if e != self and is_instance_valid(e) and e.kind == 5 and not e.dead and e.group == group and e.room_id == room_id:
			others.append(e)
	return others


func take_hit(dmg: float, from_x: float) -> void:
	if dead or executing:
		return
	var was_open := state in ["recover", "cast"]
	if kind == 5:
		# The coven's shared vow: every sister still standing absorbs part of the blow.
		var sisters := coven_others().size()
		if sisters > 0:
			dmg *= pow(0.7, sisters)
			get_tree().call_group("game", "spawn_fx", global_position + Vector2(0, -body_size.y * 0.8), Color(0.9, 0.8, 0.45))
	hp -= dmg
	flash = 0.12
	get_tree().call_group("game", "spawn_fx", global_position + Vector2(0, -body_size.y * 0.55), Color(1.0, 0.4, 0.3))
	var kb := signf(global_position.x - from_x)
	if kb == 0.0:
		kb = 1.0
	if kind == 7 and state == "duel":
		_aggro_duel()
	# The Devourer and a charging flagellant shrug off blows mid-attack; their opening comes from recovery.
	var armored: bool = (kind == 3 and state in ["windup", "strike"]) or (kind == 4 and state in ["windup", "charge"])
	if family == "walker":
		if not armored:
			velocity.x = kb * (90.0 if kind == 3 else 220.0)
			state = "hurt"
			state_t = 0.3
	elif family == "flyer":
		velocity = Vector2(kb * 200.0, -80.0)
		state = "hurt"
		state_t = 0.3
	elif not awake:
		awaken()
	if hp <= 0.0:
		_die()
	elif kind != 2 and not stagger_used and (was_open or hp <= max_hp * 0.35):
		stagger_used = true
		state = "stagger"
		state_t = 2.0
		velocity = Vector2.ZERO


func _aggro_duel() -> void:
	if state == "duel":
		state = "chase"
		cd = 0.4
	if partner != null and is_instance_valid(partner) and partner.state == "duel":
		partner.state = "chase"
		partner.cd = 0.5
	duel_t = 0.0


func _die() -> void:
	if dead: return
	dead = true
	collision_layer = 0
	if player != null and is_instance_valid(player):
		player.lagrimas += reward
		player.add_culpa(8)
	if kind == 5:
		for sister in coven_others():
			sister.rage_t = 8.0
			sister.cd = minf(sister.cd, 0.4)
			sister.flash = 0.2
	if kind == 7 and partner != null and is_instance_valid(partner) and partner.state == "duel":
		partner._aggro_duel()
	get_tree().call_group("game", "shake_cam", 8.0 if kind == 2 else 3.0)
	killed.emit(self)


func _physics_process(delta: float) -> void:
	var game = get_tree().get_first_node_in_group("game")
	if game != null and (game.state != "play" or game.message_text != "" or game.narrative.mode != "" or game.penitence_menu or (game.exploration != null and (game.exploration.map_open or game.exploration.is_transitioning() or game.exploration.room != room_id))):
		return
	if not announced and kind >= 3 and game != null and (state in ["chase", "windup"] or (kind == 7 and state == "duel" and player != null and absf(player.global_position.x - global_position.x) < 420.0)):
		announced = true
		game.announce_enemy(kind)
	fed_by_guilt = kind != 2 and game != null and game.stain_active and global_position.distance_to(game.stain_pos) < 330
	if executing: return
	if state == "stagger" and not dead:
		state_t -= delta
		velocity = Vector2.ZERO
		if state_t <= 0:
			state = "chase" if family == "walker" else "patrol"
			cd = 0.8
		return
	if hit_pause > 0:
		hit_pause -= delta
		return
	if spawn_opacity < 1:
		return
	anim_t += delta
	flash = maxf(flash - delta, 0.0)
	state_t -= delta
	cd -= delta * (1.35 if fed_by_guilt else 1.0)
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
	rage_t = maxf(rage_t - delta, 0.0)
	match kind:
		0, 7:
			if state == "duel": _duel(delta)
			else: _walker(delta)
		1, 5:
			_flyer(delta)
		2:
			_boss(delta)
		3:
			_brute(delta)
		4:
			_charger(delta)
		6:
			_bomber(delta)
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
	var seen: bool = alive and dist < (460.0 if fed_by_guilt else 360.0) and dy < 140.0
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
				velocity.x = facing * (150.0 if fed_by_guilt else 115.0)
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


# ---------- Duelistas ("Duelo a cacetadas"): dois homens presos a um combate entre si ----------
func _find_partner() -> void:
	for e in get_tree().get_nodes_in_group("enemies"):
		if e != self and is_instance_valid(e) and e.kind == 7 and not e.dead and e.group == group and e.room_id == room_id and e.partner == null:
			partner = e
			e.partner = self
			# Their blows alternate: one strikes while the other recovers.
			if e.get_instance_id() < get_instance_id(): duel_t = 1.0
			return


func _duel(delta: float) -> void:
	velocity.y = minf(velocity.y + 1800.0 * delta, 900.0)
	velocity.x = 0.0
	if partner == null or not is_instance_valid(partner) or partner.dead:
		partner = null
		_find_partner()
	if partner == null:
		state = "chase"
		return
	facing = 1 if partner.global_position.x > global_position.x else -1
	var to_p: float = player.global_position.x - global_position.x
	var dy: float = absf(player.global_position.y - global_position.y)
	if player.state != "dead" and absf(to_p) < 340.0 and dy < 140.0:
		_aggro_duel()
		return
	duel_t += delta
	if duel_t >= 2.0:
		duel_t = 0.0
		# Blows hurt, but never finish the rival: the player must be the one to end it.
		partner.hp = maxf(partner.hp - 5.0, partner.max_hp * 0.4)
		partner.flash = 0.12
		get_tree().call_group("game", "spawn_fx", partner.global_position + Vector2(0, -partner.body_size.y * 0.6), Color(0.95, 0.75, 0.4))
	move_and_slide()


# ---------- O Devorador ("Saturno"): lento, blindado no ataque, agarra e se cura ----------
func _brute(delta: float) -> void:
	velocity.y = minf(velocity.y + 1800.0 * delta, 900.0)
	var to_p: float = player.global_position.x - global_position.x
	var dist: float = absf(to_p)
	var dy: float = absf(player.global_position.y - global_position.y)
	var alive: bool = player.state != "dead"
	var seen: bool = alive and dist < (460.0 if fed_by_guilt else 380.0) and dy < 150.0
	match state:
		"patrol":
			velocity.x = facing * 38.0
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
			if dist > 90.0 and _ledge_ok():
				velocity.x = facing * (92.0 if fed_by_guilt else 72.0)
			else:
				velocity.x = 0.0
			if dist < 170.0 and dy < 100.0 and cd <= 0.0 and alive:
				state = "windup"
				state_t = 1.0
				windup_len = 1.0
				velocity.x = 0.0
			elif not seen and dist > 460.0:
				state = "patrol"
		"windup":
			velocity.x = 0.0
			if state_t <= 0.0:
				state = "strike"
				state_t = 0.32
				struck = false
		"strike":
			velocity.x = facing * (330.0 if _ledge_ok() else 0.0)
			if not struck:
				var r := Rect2(global_position + Vector2(0.0 if facing > 0 else -100.0, -84.0), Vector2(100.0, 84.0))
				if r.intersects(player.body_rect()) and player.invuln <= 0.0:
					player.take_hit(30.0, global_position.x)
					player.add_culpa(10)
					hp = minf(hp + 18.0, max_hp)
					get_tree().call_group("game", "spawn_fx", player.global_position + Vector2(0, -40), Color(0.7, 0.1, 0.12))
					get_tree().call_group("game", "shake_cam", 6.0)
					struck = true
			if state_t <= 0.0:
				state = "recover"
				state_t = 1.5
				cd = 2.0
		"recover":
			velocity.x = 0.0
			if state_t <= 0.0:
				state = "chase"
		"hurt":
			velocity.x = move_toward(velocity.x, 0.0, 900.0 * delta)
			if state_t <= 0.0:
				state = "chase"
	move_and_slide()


# ---------- Flagelante ("Procissão de flagelantes"): investida reta; errar a investida o abre ----------
func _charger(delta: float) -> void:
	velocity.y = minf(velocity.y + 1800.0 * delta, 900.0)
	var to_p: float = player.global_position.x - global_position.x
	var dist: float = absf(to_p)
	var dy: float = absf(player.global_position.y - global_position.y)
	var alive: bool = player.state != "dead"
	var seen: bool = alive and dist < (500.0 if fed_by_guilt else 420.0) and dy < 140.0
	match state:
		"patrol":
			velocity.x = facing * 60.0
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
			# He keeps his distance to gather speed, and charges from there.
			if dist > 240.0 and _ledge_ok():
				velocity.x = facing * 100.0
			else:
				velocity.x = 0.0
			if dist < 360.0 and dy < 90.0 and cd <= 0.0 and alive:
				state = "windup"
				state_t = 0.5
				windup_len = 0.5
				velocity.x = 0.0
			elif not seen and dist > 460.0:
				state = "patrol"
		"windup":
			velocity.x = 0.0
			if state_t <= 0.0:
				# Up close he lashes out instead; from afar he charges.
				if dist < 130.0:
					state = "strike"
					state_t = 0.18
					struck = false
				else:
					state = "charge"
					state_t = 0.9
					charge_hit = false
		"strike":
			velocity.x = 0.0
			if not struck:
				var lash := Rect2(global_position + Vector2(0.0 if facing > 0 else -84.0, -60.0), Vector2(84.0, 60.0))
				if lash.intersects(player.body_rect()) and player.invuln <= 0.0:
					player.take_hit(12.0, global_position.x)
					struck = true
			if state_t <= 0.0:
				state = "recover"
				state_t = 0.8
				cd = 1.4
		"charge":
			velocity.x = facing * 430.0
			if not charge_hit:
				var r := Rect2(global_position + Vector2(0.0 if facing > 0 else -64.0, -60.0), Vector2(64.0, 60.0))
				if r.intersects(player.body_rect()) and player.invuln <= 0.0:
					player.take_hit(18.0, global_position.x)
					charge_hit = true
			if is_on_wall() or not _ledge_ok():
				# A missed charge ends against stone: the penitent drops, and the opening is the player's.
				state = "stagger"
				stagger_used = true
				state_t = 1.8
				velocity = Vector2.ZERO
				cd = 1.5
				get_tree().call_group("game", "shake_cam", 4.0)
				get_tree().call_group("game", "spawn_fx", global_position + Vector2(facing * 26.0, -40.0), Color(0.9, 0.7, 0.4))
			elif state_t <= 0.0:
				state = "recover"
				state_t = 0.8
				cd = 1.6
		"recover":
			velocity.x = 0.0
			if state_t <= 0.0:
				state = "chase"
		"hurt":
			velocity.x = move_toward(velocity.x, 0.0, 900.0 * delta)
			if state_t <= 0.0:
				state = "chase"
	move_and_slide()


# ---------- Asmodeia: paira acima e solta uma linha de estilhaços sobre o jogador ----------
func _bomber(delta: float) -> void:
	var to_p: Vector2 = player.global_position - global_position
	var alive: bool = player.state != "dead"
	var target := Vector2(home.x + sin(anim_t * 0.5) * patrol_range, home.y + sin(anim_t * 1.3) * 18.0)
	match state:
		"patrol":
			velocity = velocity.lerp((target - global_position) * 1.2, 4.0 * delta)
			velocity = velocity.limit_length(130.0)
			if alive and absf(to_p.x) < (620.0 if fed_by_guilt else 520.0) and to_p.y > 30.0 and cd <= 0.0:
				facing = 1 if to_p.x > 0.0 else -1
				cast_emitted = false
				state = "windup"
				state_t = 0.9
				windup_len = 0.9
		"windup":
			velocity = velocity.lerp(Vector2.ZERO, 6.0 * delta)
			if not cast_emitted and state_t <= 0.4:
				_drop_line()
				cast_emitted = true
			if state_t <= 0.0:
				state = "cast"
				state_t = 0.25
				cd = 3.4
		"cast":
			velocity = Vector2.ZERO
			if state_t <= 0.0:
				state = "patrol"
		"hurt":
			velocity = velocity.lerp(Vector2.ZERO, 5.0 * delta)
			if state_t <= 0.0:
				state = "patrol"
	move_and_slide()


func _drop_line() -> void:
	var game = get_tree().get_first_node_in_group("game")
	var floor_y := 598.0
	if game != null and game.exploration != null: floor_y = float(game.exploration.rooms[room_id].floor) + 24.0
	for offset in [-120.0, 0.0, 120.0]:
		var t = Tear.new()
		t.player = player
		t.vel = Vector2(0.0, 70.0)
		t.grav = 760.0
		t.dmg = 12.0
		t.life = 4.5
		t.radius = 11.0
		t.ground_y = floor_y
		get_parent().add_child(t)
		t.global_position = Vector2(player.global_position.x + offset, global_position.y + 12.0)


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
			if alive and dist < (630.0 if fed_by_guilt else 520.0):
				facing = 1 if to_p.x > 0.0 else -1
				if cd <= 0.0:
					cast_emitted = false
					state = "windup"
					state_t = 0.75
		"windup":
			velocity = velocity.lerp(Vector2.ZERO, 6.0 * delta)
			facing = 1 if to_p.x > 0.0 else -1
			if not cast_emitted and state_t <= 0.375:
				if kind == 5: _shoot_fan(to_p.normalized())
				else: _shoot(to_p.normalized())
				cast_emitted = true
			if state_t <= 0.0:
				state = "cast"
				state_t = 0.18
				cd = 2.3 if kind == 1 else (2.2 if rage_t > 0.0 else 4.2)
		"cast":
			velocity = Vector2.ZERO
			if state_t <= 0:
				state = "patrol"
		"hurt":
			velocity = velocity.lerp(Vector2.ZERO, 5.0 * delta)
			if state_t <= 0.0:
				state = "patrol"
	move_and_slide()


func _shoot_fan(d: Vector2) -> void:
	for spread in [-0.32, 0.0, 0.32]:
		var t = Tear.new()
		t.player = player
		t.vel = d.rotated(spread) * 240.0
		t.dmg = 7.0
		t.life = 4.0
		get_parent().add_child(t)
		t.global_position = global_position + Vector2(0, -26)


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


const WINDUPS := {0:0.55,1:0.75,3:1.0,4:0.5,5:0.75,6:0.9,7:0.55}
const STRIKES := {0:0.18,3:0.32,7:0.18}
const RECOVERS := {0:0.7,3:1.5,4:0.8,7:0.7}


func _process(delta: float) -> void:
	if animator == null:
		return
	var game = get_tree().get_first_node_in_group("game")
	if dead and not executing and game != null and game.narrative.mode != "":
		fade = maxf(fade - delta * (1.25 if kind == 2 else 1.4), 0)
		if light:
			light.energy = fade * 0.5
		if fade <= 0:
			queue_free()
	spawn_opacity = minf(spawn_opacity + delta / 0.45, 1.0)
	animator.modulate = _col(Color(1, 0.87, 0.80) if kind == 2 and phase == 2 else tint)
	animator.modulate.a *= spawn_opacity
	animator.speed_scale = 1.0
	if executing:
		animator.select("executed", facing, execution_progress)
	elif state == "stagger" and not dead:
		animator.pose("hurt", facing, 2)
	elif dead:
		animator.select("death", facing, 1 - fade)
	elif state == "hurt":
		animator.select("hurt", facing, 1 - state_t / 0.3)
	elif family == "walker":
		var wind: float = WINDUPS[kind]
		match state:
			"duel":
				# Rivals trade blows to the beat of their cycle: rest, wind up, strike.
				if duel_t < 1.3: animator.select("idle", facing)
				elif duel_t < 1.85: animator.select("attack", facing, (duel_t - 1.3) / 0.55 * 4.0 / 6)
				else: animator.select("attack", facing, (4 + clampf((duel_t - 1.85) / 0.15, 0, 1) * 2) / 6)
			"windup": animator.select("attack", facing, clampf(1 - state_t / wind, 0, 1) * 4.0 / 6)
			"strike": animator.select("attack", facing, (4 + clampf(1 - state_t / float(STRIKES.get(kind, 0.18)), 0, 1) * 2) / 6)
			"charge":
				animator.speed_scale = 1.9
				animator.select("walk", facing)
			"recover": animator.pose("attack", facing, clampi(5 - int((1 - state_t / float(RECOVERS.get(kind, 0.7))) * 6), 0, 5))
			_: animator.select("walk" if absf(velocity.x) > 10 else "idle", facing)
	elif family == "flyer":
		if state == "windup":
			animator.select("attack", facing, 1 - state_t / float(WINDUPS[kind]))
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
	if fed_by_guilt and not dead:
		draw_arc(Vector2(0, -body_size.y * 0.5), body_size.y * 0.6, 0, TAU, 32, Color(0.65, 0.08, 0.1, 0.45), 2)
	if state == "stagger" and not dead and not executing:
		draw_arc(Vector2(0, -body_size.y - 22), 8, -PI/2, -PI/2 + TAU * clampf(state_t/2.0, 0, 1), 24, Color("e7c17b"), 2)
	if kind != 2 and hp < max_hp and not dead:
		var w := maxf(36.0, body_size.x)
		draw_rect(Rect2(-w / 2.0, -body_size.y - 14, w, 4), Color(0, 0, 0, 0.6))
		draw_rect(Rect2(-w / 2.0, -body_size.y - 14, w * hp / max_hp, 4), Color(0.8, 0.15, 0.15))
	if kind == 2 and state in ["slam_wind", "spike_cast", "rain"]:
		draw_arc(Vector2(0, -110), 80, 0, TAU, 40, Color(0.8, 0.3, 0.08, 0.35), 2)
	if dead or executing:
		return
	# Telegraphs: every new attack announces itself in a colour of its own before it lands.
	match kind:
		3:
			if state == "windup":
				var k := clampf(1.0 - state_t / 1.0, 0.0, 1.0)
				draw_arc(Vector2(facing * 40.0, -42.0), 34.0 + 18.0 * k, 0, TAU, 28, Color(0.75, 0.06, 0.08, 0.25 + 0.5 * k), 3)
			elif state == "strike":
				draw_rect(Rect2(0.0 if facing > 0 else -100.0, -84.0, 100.0, 84.0), Color(0.7, 0.05, 0.08, 0.12))
			elif not dead:
				draw_circle(Vector2(0, -body_size.y * 0.5), body_size.y * 0.62, Color(0.1, 0.0, 0.02, 0.10))
		4:
			if state == "windup":
				draw_line(Vector2(0, -30), Vector2(facing * 150.0, -30), Color(0.9, 0.7, 0.45, 0.5), 2)
			elif state == "charge":
				for i in range(5):
					draw_circle(Vector2(-facing * (14.0 + i * 16.0), -18.0 - fmod(i * 7.0, 20.0)), 2.2, Color(0.65, 0.05, 0.08, 0.55 - i * 0.1))
		5:
			for sister in coven_others():
				if get_instance_id() < sister.get_instance_id():
					var a := Vector2(0, -body_size.y * 0.5)
					var b: Vector2 = sister.global_position - global_position + Vector2(0, -sister.body_size.y * 0.5)
					draw_line(a, b, Color(0.75, 0.15, 0.15, 0.4 if rage_t <= 0.0 else 0.8), 1.5)
			if rage_t > 0.0:
				draw_arc(Vector2(0, -body_size.y * 0.5), body_size.y * 0.7, 0, TAU, 24, Color(0.85, 0.25, 0.2, 0.55), 2)
		6:
			if state == "windup":
				var base: Vector2 = player.global_position - global_position
				for offset in [-120.0, 0.0, 120.0]:
					draw_line(Vector2(base.x + offset, 0), Vector2(base.x + offset, base.y), Color(0.8, 0.7, 1.0, 0.18), 1)
