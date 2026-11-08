extends SceneTree
## Goya-inspired bestiary: data, encounters and the behaviour of each new creature.
const Layout = preload("res://scripts/act_one_layout.gd")
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
func wait_state(e,s: String,limit: int) -> bool:
	for i in range(limit):
		if e.state == s: return true
		await frames(1)
	return e.state == s
func spawn(kind: int,pos: Vector2,rng: float,group: int = -1):
	var e = game.EnemyScript.new()
	e.setup(kind,pos,rng,p)
	e.group = group
	game.add_child(e)
	return e
func clear() -> void:
	for e in get_nodes_in_group("enemies"):
		if e.kind != 2: e.queue_free()
	for h in get_nodes_in_group("hazards"): h.queue_free()
	await frames(2)

func data_checks() -> void:
	var clips: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://assets/animation/clips.json"))
	var Enemy = game.EnemyScript
	var data_ok := true
	for kind in Enemy.TYPES:
		var t: Dictionary = Enemy.TYPES[kind]
		if not clips.has(t.actor): data_ok = false; continue
		if t.family != "boss":
			for clip in ["idle","walk","attack","hurt","death","executed"]:
				if not clips[t.actor].has(clip): data_ok = false
		for clip in clips[t.actor]:
			if not ResourceLoader.exists("res://assets/animation/"+clips[t.actor][clip].sheet+".png"): data_ok = false
	expect(data_ok,"every creature has a complete animation entry with existing art")
	expect(Enemy.TYPES.size() == 8,"eight creature types: devotee, weeper, boss and five new ones")
	var kinds: Dictionary = {}
	var groups: Dictionary = {}
	for d in Layout.enemies():
		kinds[d[1]] = kinds.get(d[1],0) + 1
		if d.size() > 5:
			var key := "%s:%d:%d" % [d[0],d[1],d[5]]
			groups[key] = groups.get(key,0) + 1
	var all_used := true
	for k in [0,1,3,4,5,6,7]:
		if not kinds.has(k): all_used = false
	expect(all_used,"all seven common creature types appear in the act")
	var shape_ok := true
	for key in groups:
		var parts: PackedStringArray = key.split(":")
		var want := 3 if parts[1] == "5" else 2
		if groups[key] != want: shape_ok = false
	expect(shape_ok and groups.size() == 3,"one coven of three and two duelling pairs")
	var bestiary_ok := true
	for k in [3,4,5,6,7]:
		if not Enemy.BESTIARY.has(k): bestiary_ok = false
	expect(bestiary_ok,"each new creature has a first-sight note")

	# Reach rule: the sword hits about 66 above the feet standing and about 108 from the feet in the air,
	# so a new flyer must hover within 170 of something the player can stand on beneath it.
	var reach_ok := true
	var reach_report := ""
	var rooms: Dictionary = Layout.rooms()
	for d in Layout.enemies():
		if not [5,6].has(d[1]): continue
		var supports: Array = [float(rooms[d[0]].floor)]
		for l in Layout.platforms():
			if l.end.x >= d[2] - d[4] and l.position.x <= d[2] + d[4]: supports.append(l.position.y)
		for b in Layout.blocks():
			if b.end.x >= d[2] - d[4] and b.position.x <= d[2] + d[4]: supports.append(b.position.y)
		var near := false
		for y in supports:
			if y - d[3] >= 0.0 and y - d[3] <= 170.0: near = true
		if not near:
			reach_ok = false
			reach_report += " %s kind %d at (%d,%d)" % [d[0],d[1],d[2],d[3]]
	expect(reach_ok,"new flyers hover within sword reach of a surface the player can stand on:"+reach_report)
	var rooms_with_new := {}
	for d in Layout.enemies():
		if d[1] >= 3: rooms_with_new[d[0]] = true
	expect(rooms_with_new.size() >= 8,"new creatures spread across at least eight rooms")

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
	data_checks()
	await clear()

	# O Devorador: armoured while attacking, heals on the grab, wide open in recovery.
	p.revive(Vector2(830,600))
	var d = spawn(3,Vector2(960,600),60)
	d.hp = d.max_hp - 40
	await frames(40)
	expect(await wait_state(d,"windup",240),"the Devourer winds up a slow grab")
	var before: float = d.hp
	d.take_hit(5.0,p.position.x)
	expect(d.state == "windup" and absf(d.hp - (before - 5.0)) < 0.01,"blows during the windup do not interrupt him")
	expect(await wait_state(d,"strike",120),"the windup becomes a lunge")
	expect(await wait_state(d,"recover",60),"the lunge ends in a long recovery")
	expect(p.hp < 100.0,"the grab wounds the penitent")
	expect(absf(d.hp - (before - 5.0 + 18.0)) < 0.01,"he heals by devouring")
	d.take_hit(10.0,p.position.x)
	expect(d.state == "stagger" and not d.dead,"a blow in recovery opens the execution window")
	for i in range(80):
		if p.state == "idle": break
		await frames(1)
	p.position = Vector2(d.position.x - 50.0,600.0)
	await frames(2)
	expect(p.begin_execution(d),"the Devourer can be executed")
	await frames(6)
	expect(p.animator.animation == "execute_devotee" and d.animator.animation == "executed","executing a brute uses the humanoid execution art")
	await frames(90)
	expect(d.dead,"the execution kills him")
	await clear()

	# Flagelante: a missed charge crashes at the broken bridge and leaves him open.
	p.revive(Vector2(1950,600))
	var f = spawn(4,Vector2(1750,600),0)
	await frames(40)
	expect(await wait_state(f,"windup",260),"the flagellant winds up before charging")
	f.take_hit(3.0,p.position.x)
	expect(f.state == "windup","he is armoured while winding up")
	expect(await wait_state(f,"charge",60),"he charges along the ground")
	p.revive(Vector2(1200,600))
	expect(await wait_state(f,"stagger",120),"a missed charge ends against the broken edge")
	expect(f.stagger_used and f.position.x < 2000.0,"he stops at the edge instead of falling, stunned")
	await clear()
	p.revive(Vector2(1180,600))
	var f2 = spawn(4,Vector2(1000,600),0)
	await frames(40)
	var hit := false
	for i in range(300):
		if p.hp < 100.0: hit = true; break
		await frames(1)
	expect(hit,"a charge that connects wounds the penitent")
	await clear()

	p.revive(Vector2(1080,600))
	var f3 = spawn(4,Vector2(1000,600),0)
	f3.cd = 0.0
	await frames(40)
	expect(await wait_state(f3,"strike",200),"up close the flagellant lashes out instead of standing idle")
	expect(await wait_state(f3,"recover",40) and p.hp < 100.0,"the lash wounds a penitent who stays beside him")
	await clear()

	# Aquelarre: the shared vow protects sisters until they stand alone.
	p.revive(Vector2(200,600))
	var a = spawn(5,Vector2(1000,300),0,9)
	var b = spawn(5,Vector2(1100,300),0,9)
	var c = spawn(5,Vector2(1200,300),0,9)
	await frames(4)
	a.take_hit(10.0,p.position.x)
	expect(absf(a.hp - (a.max_hp - 10.0 * 0.49)) < 0.01,"two sisters absorb most of a blow")
	b.take_hit(1000.0,p.position.x)
	expect(b.dead and a.rage_t > 0.0 and c.rage_t > 0.0,"a fallen sister enrages the others")
	var hp_a: float = a.hp
	a.take_hit(10.0,p.position.x)
	expect(absf(a.hp - (hp_a - 7.0)) < 0.01,"one remaining sister still shields part of the blow")
	c.take_hit(1000.0,p.position.x)
	var hp_last: float = a.hp
	a.take_hit(10.0,p.position.x)
	expect(absf(a.hp - (hp_last - 10.0)) < 0.01,"the last witch takes the full blow")
	await clear()
	p.revive(Vector2(1000,600))
	var w = spawn(5,Vector2(1000,300),0,10)
	var fan := false
	for i in range(240):
		if get_nodes_in_group("hazards").size() >= 3: fan = true; break
		await frames(1)
	expect(fan,"a witch fires a three-tear fan")
	await clear()

	# Asmodeia: three shards fall in a line over the penitent's position.
	p.revive(Vector2(900,600))
	var s = spawn(6,Vector2(900,240),100)
	var shards := false
	for i in range(260):
		if get_nodes_in_group("hazards").size() >= 3: shards = true; break
		await frames(1)
	expect(shards,"Asmodea drops a line of three shards")
	var xs: Array = []
	for h in get_nodes_in_group("hazards"): xs.append(snappedf(h.global_position.x - p.global_position.x,10.0))
	xs.sort()
	expect(xs.size() >= 3 and absf(xs[0] + 120.0) <= 20.0 and absf(xs[xs.size() - 1] - 120.0) <= 20.0,"the shards fall at -120, 0 and +120 from the target")
	await clear()

	# Duelistas: they trade blows until the penitent comes close, and cannot finish each other.
	p.revive(Vector2(300,600))
	var da = spawn(7,Vector2(1500,600),70,5)
	var db = spawn(7,Vector2(1580,600),70,5)
	await frames(60)
	expect(da.state == "duel" and db.state == "duel" and da.partner == db and db.partner == da,"two duelists fight each other and ignore the distant penitent")
	da.duel_t = 1.99
	db.duel_t = 0.0
	await frames(3)
	expect(db.hp < db.max_hp,"their blows hurt each other")
	db.hp = db.max_hp * 0.41
	for i in range(6):
		da.duel_t = 1.99
		await frames(3)
	expect(db.hp >= db.max_hp * 0.4 - 0.01,"a duel never kills the rival")
	p.position = Vector2(1330,600)
	await frames(6)
	expect(da.state == "chase" and db.state == "chase","both turn on the intruder who comes close")
	await clear()
	p.revive(Vector2(300,600))
	var ea = spawn(7,Vector2(2400,600),70,6)
	var eb = spawn(7,Vector2(2480,600),70,6)
	await frames(60)
	ea.take_hit(1.0,p.position.x)
	expect(eb.state == "chase","striking one duelist wakes the other")
	await clear()

	# A stunned flyer comes down to the penitent's level for its execution.
	p.revive(Vector2(1000,600))
	var flyer = spawn(6,Vector2(1030,480),0)
	await frames(30)
	flyer.state = "stagger"
	flyer.state_t = 2.0
	p.position = Vector2(1000,600)
	await frames(2)
	expect(p.begin_execution(flyer) and absf(flyer.position.y - 600.0) < 1.0,"a stunned flyer is brought down to ground level for its execution")
	await frames(90)
	await clear()
	var walker = game.EnemyScript.new()
	expect(walker.humanoid(),"walkers use the humanoid execution clip")
	walker.free()
	var weeper = game.EnemyScript.new()
	weeper.setup(6,Vector2.ZERO,0,p)
	expect(not weeper.humanoid(),"flyers use the weeper execution clip")
	weeper.free()
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
	print("BESTIARY_SMOKE: %d checks, %d failures" % [checks,failures])
	quit(0 if failures == 0 else 1)
