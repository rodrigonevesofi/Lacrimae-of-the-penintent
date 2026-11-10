extends SceneTree
## Regras de combate: aparo, equilíbrio, peso dos golpes e novos valores.
var game
var p
var checks := 0
var failures := 0
func _initialize() -> void: call_deferred("run")
func expect(ok: bool,label: String) -> void:
	checks += 1
	print("PASS: " if ok else "FAIL: ",label)
	if not ok: failures += 1
func frames(n: int) -> void:
	for i in range(n):
		await physics_frame
		await process_frame
func spawn(kind: int,pos: Vector2):
	var e = game.EnemyScript.new()
	e.setup(kind,pos,0,p)
	game.add_child(e)
	e.set_physics_process(false)
	return e
func reset_player(x: float = 900.0) -> void:
	p.revive(Vector2(x,600))
	p.facing = 1
	p.invuln = 0
	p.hp = 100
	p.parry_cd = 0
	p.parries = 0
	await frames(3)

func run() -> void:
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	game._start_game(false,false)
	for i in range(3):
		game.message_t = 0
		game.advance_message()
	await frames(3)
	p = game.player
	p.has_weapon = true
	for e in get_nodes_in_group("enemies"): e.queue_free()
	await frames(2)
	var Enemy = game.EnemyScript

	# --- Valores: uma criatura comum recebe de 3 a 6 golpes de espada, elites recebem mais e o Guardião exige combate longo.
	var average := 23.0
	var commons_ok := true
	for kind in [0,1,4,5,6,7]:
		var hits: float = Enemy.TYPES[kind].hp / average
		if hits < 2.5 or hits > 6.0: commons_ok = false
	expect(commons_ok,"every common creature takes between three and six sword blows")
	expect(Enemy.TYPES[3].hp / average >= 6.0,"the Devourer is an elite: at least six blows")
	expect(Enemy.TYPES[2].hp >= 1300.0,"the Guardian has the health of a long fight (1400 after the boss probe: 6 wins in 10, 48 s)")

	# --- Aparo: temporizado, frontal e apenas para golpes leves.
	await reset_player()
	var devotee = spawn(0,Vector2(960,600))
	p._start_parry()
	expect(p.state == "parry","the parry key starts a guard")
	var hp_before: float = p.hp
	p.take_hit(16.0,devotee.global_position.x,devotee,true)
	expect(p.hp == hp_before and p.parries == 1,"a blow inside the window is turned aside")
	expect(devotee.state == "stagger" and devotee.stagger_used,"the attacker is left open")
	expect(p.invuln > 0.0 and p.hit_pause >= 0.1,"a successful parry has weight: a pause and a moment of safety")
	expect(p.parry_hit and p.counter_t > 0.0,"after a parry the recoil plays and the next blow is the strong counter")
	var before_open: float = devotee.hp
	devotee.take_hit(20.0,p.global_position.x)
	expect(is_equal_approx(before_open - devotee.hp,32.0),"a staggered creature takes 60 percent more damage")

	await reset_player()
	var late = spawn(0,Vector2(960,600))
	p._start_parry()
	p.state_t = p.PARRY_TIME - p.PARRY_WINDOW - 0.05
	p.take_hit(16.0,late.global_position.x,late,true)
	expect(p.hp < 100.0 and late.state != "stagger","a parry that comes late fails")

	await reset_player()
	var grab = spawn(3,Vector2(960,600))
	p._start_parry()
	p.take_hit(30.0,grab.global_position.x,grab,false)
	expect(p.hp < 100.0 and grab.state != "stagger","heavy grabs and charges cannot be parried; they must be dodged")

	await reset_player()
	var behind = spawn(0,Vector2(840,600))
	p._start_parry()
	p.take_hit(16.0,behind.global_position.x,behind,true)
	expect(p.hp < 100.0,"a blow from behind cannot be parried")

	await reset_player()
	expect(p.parry_cd == 0.0,"the guard is available at rest")
	p._start_parry()
	p.state_t = 0.0
	await frames(3)
	expect(p.state == "idle" and p.parry_cd > 0.0,"the guard ends and has a short cooldown")

	# --- Equilíbrio: golpes leves não interrompem todos os ataques; acertos suficientes interrompem.
	await reset_player()
	var brute = spawn(0,Vector2(960,600))
	brute.state = "windup"
	brute.state_t = 0.4
	brute.take_hit(20.0,p.global_position.x)
	expect(brute.state == "windup","one light blow does not interrupt a creature in its windup")
	brute.take_hit(20.0,p.global_position.x)
	brute.take_hit(20.0,p.global_position.x)
	expect(brute.state in ["hurt","stagger"],"three blows break its poise")

	# --- Carregador de caixão: a pedra protege sua frente até quebrar.
	await reset_player()
	var carrier = spawn(8,Vector2(960,600))
	carrier.facing = -1
	var c_hp: float = carrier.hp
	carrier.take_hit(20.0,p.global_position.x)
	expect(c_hp - carrier.hp < 5.0 and carrier.coffin < 60.0,"a blow on his front lands on the stone")
	carrier.state = "patrol"
	var before_back: float = carrier.hp
	carrier.take_hit(20.0,1100.0)
	expect(before_back - carrier.hp >= 19.0,"a blow from behind reaches him")
	carrier.state = "patrol"
	for i in range(2): carrier.take_hit(20.0,p.global_position.x)
	expect(carrier.exposed and carrier.state == "break","enough blows on the stone break it, and the break plays")
	expect(not p.begin_execution(carrier),"he cannot be executed while the stone is breaking")
	carrier.state = "chase"
	carrier.cd = 0.0
	carrier.player = p
	carrier.spawn_opacity = 1.0
	carrier.set_physics_process(true)
	await frames(3)
	expect(carrier.state in ["strike_wind","strike","recoil"],"exposed, he strikes with his bound fists")
	carrier.set_physics_process(false)
	carrier.state = "stagger"
	carrier.state_t = 2.0
	p.state = "idle"
	expect(p.begin_execution(carrier),"once the stone is broken and he is open, he can be executed")
	await frames(2)
	expect(Enemy.BESTIARY.has(8) and Enemy.TYPES[8].actor == "carregador","the carrier has a name, a note and his own art")
	# --- O Guardião é colossal.
	var boss_moves := {}
	var probe_boss = spawn(2,Vector2(4300,600))
	probe_boss.awake = true
	for i in range(80):
		probe_boss.phase = 1
		probe_boss.attacks_done = 1
		probe_boss.player.global_position.x = 4300.0 + (150.0 if i % 2 == 0 else 500.0)
		probe_boss._pick_attack()
		boss_moves[probe_boss.state] = true
	p.global_position = Vector2(900,600)
	expect(boss_moves.has("sweep_wind") and boss_moves.has("leap_crouch") and boss_moves.has("scream_wind"),"the Guardian sweeps, leaps and screams as well (%s)" % ", ".join(boss_moves.keys()))
	var rings_before: int = game.get_child_count()
	probe_boss._scream()
	var rings := 0
	for child in game.get_children():
		if child.get_child_count() > 0 and child.get_child(0).get("actor") == "onda":
			rings += 1
			expect(child.modulate.g < 0.8,"the scream's rings are not gold, so they are not read as a parry signal")
			break
	expect(rings >= 1,"the scream leaves the bell as rings of sound")
	probe_boss._crack_floor()
	expect(get_nodes_in_group("boss_cracks").size() >= 1,"the floor cracks where the Guardian lands")
	probe_boss.state = "sweep_wind"
	probe_boss.parried()
	expect(probe_boss.state == "exhausted","a parried sweep leaves the Guardian on its knees")
	probe_boss.queue_free()
	expect(Enemy.TYPES[2].actor == "guardiao_colosso" and Enemy.TYPES[2].body.y / p.body_rect().size.y >= 3.0,"the Guardian stands at least three times the penitent (%.1f)" % (Enemy.TYPES[2].body.y / p.body_rect().size.y))

	# --- Peso do golpe: pausa no impacto, maior ao matar, faíscas e sangue.
	await reset_player()
	var weak = spawn(0,Vector2(960,600))
	weak.hp = 10.0
	weak.state = "patrol"
	p.facing = 1
	p.position = Vector2(900,600)
	p.hit_list.clear()
	p.combo = 1
	var effects_before: int = game.get_child_count()
	p._attack_hits()
	expect(weak.dead and p.hit_pause >= 0.15,"a killing blow holds the frame longer than a common hit")
	expect(game.get_child_count() > effects_before,"a blow throws sparks and blood from the painted atlas")
	var big := 0
	for child in game.get_children():
		if child.get_child_count() > 0 and child.get_child(0).get("actor") == "golpe": big += 1
	expect(big >= 2,"a killing blow shows the crescent, the star and the pool")
	var strong = spawn(3,Vector2(960,600))
	p.hit_list.clear()
	p.hit_pause = 0
	p._attack_hits()
	expect(p.hit_pause >= 0.08,"an ordinary hit stops the frame for a moment")

	# --- Chefe: terceira fase abaixo de um quarto da vida.
	var boss = spawn(2,Vector2(4200,600))
	boss.awake = true
	boss.hp = boss.max_hp * 0.2
	boss._boss(0.016)
	expect(boss.phase == 3,"the Guardian has a third phase at a quarter of its health")


	# --- Arenas: as saídas fecham, as levas se sucedem e o caminho abre quando a última cai.
	var ex = game.exploration
	ex.arenas_enabled = true
	ex.arenas_done = []
	ex.travel("cistern",Vector2(9700,600))
	await frames(4)
	p.revive(Vector2(9700,600))
	await frames(3)
	var tears_before: int = p.lagrimas
	ex.update_arena()
	expect(ex.arena_active == "cistern" and ex.arena_bodies.size() == 2,"entering the stretch closes both exits")
	var wave_one: Array = ex.arena_enemies.duplicate()
	expect(wave_one.size() == 2,"the first wave brings two creatures")
	for e in wave_one: e.take_hit(1000.0,p.global_position.x)
	ex.update_arena()
	expect(ex.arena_wave == 1 and ex.arena_enemies.size() == 2 and ex.arena_active == "cistern","the second wave comes when the first falls")
	for e in ex.arena_enemies: e.take_hit(1000.0,p.global_position.x)
	ex.update_arena()
	expect(ex.arena_active == "" and ex.arenas_done.has("cistern") and ex.arena_bodies.is_empty(),"the last wave opens the way")
	expect(p.lagrimas >= tears_before + 200,"the fight pays tears")
	ex.update_arena()
	expect(ex.arena_active == "","a won arena does not close again")
	var saved: Dictionary = ex.serialize()
	ex.arenas_done = []
	ex.restore(saved)
	expect(ex.arenas_done == ["cistern"],"a won arena is remembered in the save")
	ex.arenas_done = []
	p.revive(Vector2(9700,600))
	ex.update_arena()
	expect(ex.arena_active == "cistern","an unwon arena closes again")
	p.state = "dead"
	ex.update_arena()
	expect(ex.arena_active == "" and ex.arena_bodies.is_empty() and not ex.arenas_done.has("cistern"),"dying releases the arena so it can be tried again")
	p.state = "idle"
	# Cada inimigo do ato fica onde pode agir: nenhum trecho longo da rota principal fica sem ameaça.
	var rooms_data: Dictionary = preload("res://scripts/act_one_layout.gd").rooms()
	var spacing_ok := true
	var worst := 0.0
	for id in rooms_data:
		if id == "city": continue
		var xs: Array = []
		for d in preload("res://scripts/act_one_layout.gd").enemies():
			if d[0] == id: xs.append(float(d[2]))
		for a in preload("res://scripts/act_one_layout.gd").arenas():
			if a.room == id: xs.append((a.x0 + a.x1) * 0.5)
		xs.sort()
		var prev: float = rooms_data[id].bounds.position.x
		for x in xs:
			worst = maxf(worst,x - prev)
			prev = x
		worst = maxf(worst,rooms_data[id].bounds.end.x - prev)
	expect(worst <= 1500.0,"no room has more than about a screen and a quarter without a threat (worst %.0f)" % worst)

	game.soundscape.set_process(false)
	game.soundscape.ambience.stop()
	game.soundscape.incoming.stop()
	game.soundscape.guilt_layer.stop()
	for voice in game.soundscape.effects.values(): voice.stop()
	game._delete_save()
	p.set_physics_process(false)
	await create_timer(0.2,true,false,true).timeout
	game.queue_free()
	game = null
	await frames(5)
	print("COMBAT_SMOKE: %d checks, %d failures" % [checks,failures])
	quit(0 if failures == 0 else 1)
