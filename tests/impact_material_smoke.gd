extends SceneTree
## Impactos por material: faíscas na armadura, lascas no caixão e sangue na carne.
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
func spawn(kind: int):
	var e = game.EnemyScript.new()
	e.setup(kind,Vector2(960,600),0,game.player)
	e.room_id = "city"
	game.add_child(e)
	e.set_physics_process(false)
	e.spawn_opacity = 1.0
	return e
func impacts() -> Array:
	var seen := []
	for child in game.get_children():
		if child.get_child_count() > 0 and child.get_child(0).get("actor") == "impactos": seen.append(child.get_child(0).animation)
	return seen
func run() -> void:
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	game._start_game(false,false)
	for i in range(3):
		game.message_t = 0
		game.advance_message()
	await frames(3)
	var p = game.player
	expect(ResourceLoader.exists("res://assets/animation/impactos.png"),"the painted impacts are in the project")
	expect(p._impact_kind(spawn(0)) == "sangue","flesh bleeds")
	expect(p._impact_kind(spawn(3)) == "faiscas","the Devourer's plates throw sparks")
	var carrier = spawn(8)
	expect(p._impact_kind(carrier) == "pedra","the carrier's stone throws chips")
	carrier.exposed = true
	expect(p._impact_kind(carrier) == "sangue","without the stone, he bleeds")
	for e in get_nodes_in_group("enemies"): e.queue_free()
	await frames(2)
	p.has_weapon = true
	p.revive(Vector2(900,600))
	p.facing = 1
	await frames(3)
	spawn(3)
	p.hit_list.clear()
	p._attack_hits()
	await frames(1)
	expect(impacts().has("faiscas"),"a blow on armour shows the sparks (%s)" % str(impacts()))
	game._delete_save()
	game.queue_free()
	game = null
	await frames(5)
	print("IMPACT_MATERIAL: %d checks, %d failures" % [checks,failures])
	quit(0 if failures == 0 else 1)
