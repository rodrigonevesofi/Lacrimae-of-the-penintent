extends SceneTree
## An execution is a killing: blood at the first wound and at the killing blow, drops that fall, a pool that stays.
var game
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
func blood_effects() -> int:
	var n := 0
	for child in game.get_children():
		if child.get_child_count() > 0 and child.get_child(0).get("actor") == "efeitos" and child.get_child(0).animation == "blood": n += 1
	return n
func execute(kind: int) -> Dictionary:
	var p = game.player
	p.revive(Vector2(900,600))
	p.facing = 1
	await frames(3)
	var e = game.EnemyScript.new()
	e.setup(kind,Vector2(950,600),0,p)
	e.room_id = "city"
	game.add_child(e)
	e.set_physics_process(false)
	e.spawn_opacity = 1.0
	e.state = "stagger"
	e.state_t = 2.0
	await frames(2)
	var started: bool = p.begin_execution(e)
	var clip: String = p._execution_clip()
	var wound_blood := 0
	var kill_blood := 0
	var drops := 0
	for i in range(200):
		await physics_frame
		if p.execution_wound and wound_blood == 0: wound_blood = blood_effects()
		if p.execution_contact and kill_blood == 0:
			kill_blood = blood_effects()
			drops = get_nodes_in_group("blood_spray").size()
		if p.state != "execution": break
	return {"started": started, "clip": clip, "wound": wound_blood, "kill": kill_blood, "drops": drops, "dead": e.dead}
func run() -> void:
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	game._start_game(false,false)
	for i in range(3):
		game.message_t = 0
		game.advance_message()
	await frames(3)
	game.player.has_weapon = true
	for e in get_nodes_in_group("enemies"): e.queue_free()
	await frames(2)
	var r: Dictionary = await execute(0)
	expect(r.started and r.dead,"a staggered devotee is executed")
	expect(r.wound >= 2,"the first wound draws blood (%d)" % r.wound)
	expect(r.kill >= 2 and r.drops >= 1,"the killing blow throws blood and drops (%d, %d)" % [r.kill, r.drops])
	await frames(10)
	expect(get_nodes_in_group("blood_decals").size() >= 1,"a pool of blood stays on the floor")
	expect(r.clip == "execute_devotee","the devotee's execution is his own")
	var r3: Dictionary = await execute(3)
	expect(r3.dead and r3.kill >= 2,"every creature bleeds when executed, the Devourer too")
	expect(r3.clip in ["execute_devorador","execute_devotee"],"the Devourer uses his own execution as soon as it is drawn (%s for now)" % r3.clip)
	for i in range(20):
		game.player._blood_decal(Vector2(900 + i * 10, 600))
	await frames(2)
	expect(get_nodes_in_group("blood_decals").size() <= game.player.BLOOD_DECALS_MAX,"the floor keeps at most %d pools" % game.player.BLOOD_DECALS_MAX)
	expect(game.soundscape.FAMILIES.has("jump") and game.soundscape.resolve("jump").begins_with("jump_0"),"the jump picks among three armoured recordings")
	game._delete_save()
	game.queue_free()
	game = null
	await frames(5)
	print("EXECUTION_GORE: %d checks, %d failures" % [checks,failures])
	quit(0 if failures == 0 else 1)
