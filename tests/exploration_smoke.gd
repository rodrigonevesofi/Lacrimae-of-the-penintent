extends SceneTree
var game
var checks := 0
var failures := 0
var elapsed_frames := 0
func _initialize() -> void: call_deferred("run")
func expect(ok: bool,label: String) -> void:
	checks += 1
	print("PASS: " if ok else "FAIL: ",label)
	if not ok: failures += 1
func frames(n: int) -> void:
	for i in range(n):
		await physics_frame
		await process_frame
		elapsed_frames += 1
func interact() -> void:
	await frames(2)
	Input.action_press("interact")
	await frames(3)
	Input.action_release("interact")
	for step in range(40):
		if not game.exploration.is_transitioning(): break
		await frames(1)
func close_message() -> void:
	game.message_t = 0
	game.advance_message()
	await frames(2)
func quiet_enemies() -> void:
	for e in get_nodes_in_group("enemies"): e.set_physics_process(false)
func go(x: float,y: float,limit: int = 260) -> bool:
	var p = game.player
	Input.action_release("jump")
	await frames(2)
	var jumping := false
	var age := 0
	var start_y: float = p.position.y
	var stuck := 0
	var last_x: float = p.position.x
	for i in range(limit):
		var dx: float = x-p.position.x
		if absf(dx)<12 and absf(p.position.y-y)<8 and p.is_on_floor():
			Input.action_release("left")
			Input.action_release("right")
			Input.action_release("jump")
			Input.action_release("down")
			return true
		if dx>8:
			Input.action_press("right")
			Input.action_release("left")
		elif dx < -8:
			Input.action_press("left")
			Input.action_release("right")
		else:
			Input.action_release("left")
			Input.action_release("right")
		if p.is_on_floor() and absf(p.position.x-last_x)<0.5 and absf(dx)>20: stuck += 1
		else: stuck = 0
		last_x = p.position.x
		if stuck > 6 and p.is_on_floor() and not jumping:
			# Masonry mounds shape the floor: hop over them like a player would.
			Input.action_press("jump")
			jumping = true
			age = 0
			start_y = p.position.y
			stuck = 0
		if p.is_on_floor() and not jumping:
			if p.position.y > y+20 and absf(dx)<(290 if p.position.y-y>125 and p.has_double_jump else 160):
				Input.action_press("jump")
				jumping = true
				age = 0
				start_y = p.position.y
			elif p.position.y < y-30 and p.can_drop():
				Input.action_press("down")
				Input.action_press("jump")
				await frames(1)
				Input.action_release("jump")
				Input.action_release("down")
		if jumping:
			age += 1
			if age == 16 and start_y-y>125 and p.has_double_jump: Input.action_release("jump")
			if age == 18 and start_y-y>125 and p.has_double_jump: Input.action_press("jump")
			if age > 6 and p.is_on_floor():
				Input.action_release("jump")
				jumping = false
		await frames(1)
		if game.message_text != "": await close_message()
	Input.action_release("left")
	Input.action_release("right")
	Input.action_release("jump")
	print("ROUTE_BLOCKED target=",Vector2(x,y)," actual=",p.position)
	return false
func ledge_index(x: float,y: float) -> int:
	for i in range(game.exploration.ledges.size()):
		var r: Rect2 = game.exploration.ledges[i]
		if is_equal_approx(r.position.x,x) and is_equal_approx(r.position.y,y): return i
	return -1
func climb(indices: Array) -> bool:
	for index in indices:
		var rect: Rect2 = game.exploration.ledges[index]
		if not await go(rect.position.x+minf(60,rect.size.x/2),rect.position.y): return false
	return true
func run() -> void:
	game=load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	expect(game.art!=null and game.exploration!=null,"world and exploration initialize")
	game._start_game(false,false)
	for i in range(3): await close_message()
	quiet_enemies()
	game.player.has_weapon=true
	expect(game.exploration.rooms.size()==10,"ten distinct connected places")
	expect(game.exploration.passages.size()==15,"fifteen passages include secrets and four unlockable shortcuts")
	expect(game.altars.size()==9,"nine themed checkpoints across the act")
	expect(game.exploration.gate!=null,"boss access physically sealed before exploration")
	# Start at the actual tomb; all following route movement uses controls or doorway interactions.
	expect(await go(1160,600),"walk from tomb to burial passage")
	await interact()
	expect(game.exploration.room=="ossuary","enter ossuary through door")
	expect(await climb([0,1,2,3,4,5]),"climb the ossuary gallery without double jump")
	expect(await go(6450,200),"reach optional upper passage")
	await interact()
	expect(game.exploration.room=="refuge","upper branch leads to refuge")
	# Refuge stair indices: final five ledges in the layout.
	var refuge_steps: Array = []
	for i in range(4): refuge_steps.append(ledge_index(19300+i*140,520-i*80))
	refuge_steps.append(ledge_index(19720,280))
	expect(not refuge_steps.has(-1),"refuge stair ledges found by position")
	expect(await climb(refuge_steps),"climb refuge shrine")
	expect(await go(20030,280),"find doll beyond the refuge branch")
	await interact()
	expect(game.doll_found,"optional doll is discovered off the main path")
	await close_message()
	expect(await go(20600,600),"descend from shrine and reach healing vessel")
	await interact()
	expect(game.player.max_flasks==4,"optional exploration grants extra healing vessel")
	await close_message()
	expect(await go(20830,600),"reach refuge exit")
	await interact()
	expect(game.exploration.room=="cistern","refuge rejoins cistern through alternate entrance")
	# Cistern starts after ten ossuary ledges, followed by seven ascending ledges.
	expect(await climb([12,13,14,15,16,17]),"climb cistern mechanism with normal jumps")
	expect(await go(9650,40),"reach upper water-chain mechanism")
	await interact()
	expect(game.exploration.bells.has("water"),"release first chain through physical branch traversal")
	expect(await go(10400,600),"descend to courtyard sluice")
	await interact()
	expect(game.exploration.room=="city" and game.exploration.opened.has("water_return"),"open shortcut onto far side of broken bridge")
	expect(await go(3080,600),"find cloister entrance in courtyard")
	await interact()
	expect(game.exploration.room=="cloister","enter cloister branch")
	# Ossuary10 + cistern13 =23; cloister ascent23..29 and gallery30.
	expect(await climb([23,24,25,26,27,28,29,30]),"climb cloister upper route")
	expect(await go(12800,40),"reach hidden archive entrance")
	await interact()
	expect(game.exploration.room=="archive","upper cloister branches to archive")
	var archive_steps: Array = []
	for i in range(4): archive_steps.append(ledge_index(16880+i*140,520-i*80))
	archive_steps.append(ledge_index(17300,280))
	expect(not archive_steps.has(-1),"archive shelf ledges found by position")
	expect(await climb(archive_steps),"climb document shelves")
	expect(await go(17800,280),"reach concealed confession register")
	await interact()
	expect(game.exploration.collected.has("register"),"archive rewards investigation with narrative record")
	await close_message()
	expect(await go(18430,600),"find archive passage")
	await interact()
	expect(game.exploration.room=="belfry" and game.exploration.opened.has("archive_return"),"archive shortcut rejoins middle of tower")
	expect(await go(14580,1100),"descend tower to the relic alcove")
	expect(game.player.has_double_jump and game.relic_taken,"relic acquired in tower through exploration")
	if game.message_text!="": await close_message()
	# Cloister ends35; tower lower flight36..42, landing43, upper44..50, high51, double-jump52.
	expect(await climb([36,37,38,39,40,41,42,43]),"ascend lower tower switchback")
	expect(await climb([44,45,46,47,48,49,50,51]),"ascend upper tower switchback")
	expect(await go(14730,-100),"approach final elevated gap")
	expect(await climb([52]),"double jump reaches upper bell gallery")
	expect(await go(15120,-260),"reach second bell mechanism")
	await interact()
	expect(game.exploration.bells.size()==2 and game.exploration.gate==null,"both explored mechanisms open boss access")
	expect(await go(16040,1100),"descend tower to courtyard return")
	await interact()
	expect(game.exploration.room=="city" and game.exploration.opened.has("tower_return"),"tower return forms a second courtyard loop")
	expect(await go(3960,600),"walk through unlocked boss passage")
	expect(game.boss.awake and game.boss_wall!=null,"boss arena starts only after exploration requirements")
	expect(game.exploration.visited.size()==7,"the seven main places are reached through the real route")
	print("PHYSICAL_ROUTE_FRAMES: ",elapsed_frames," SIMULATED_SECONDS: ",elapsed_frames/60.0," PLAY_TIME: ",game.play_time," WALKED_UNITS: ",game.exploration.journey_distance)
	game._save()
	var saved=game.exploration.serialize()
	game.exploration.reset()
	game._load()
	expect(game.exploration.bells.size()==2 and game.exploration.visited.size()==7,"save restores discoveries and chains")
	expect(game.exploration.opened.size()==3,"save restores all three shortcut latches")
	expect(game.player.max_flasks==4,"save restores optional vessel reward")
	game.exploration.map_open=true
	var before: Vector2=game.player.position
	Input.action_press("left")
	await frames(8)
	Input.action_release("left")
	expect(game.player.position==before,"cartography suspends movement")
	game.exploration.map_open=false
	game.soundscape.set_process(false)
	game.soundscape.ambience.stop()
	game.soundscape.incoming.stop()
	game.soundscape.guilt_layer.stop()
	for voice in game.soundscape.effects.values(): voice.stop()
	game._delete_save()
	game.player.set_physics_process(false)
	quiet_enemies()
	await create_timer(0.2,true,false,true).timeout
	game.queue_free()
	game=null
	await frames(5)
	print("EXPLORATION_SMOKE: %d checks, %d failures" % [checks,failures])
	quit(0 if failures==0 else 1)
