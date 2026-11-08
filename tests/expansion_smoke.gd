extends "res://tests/exploration_smoke.gd"
## Validates the expanded Act I: secret rooms, masonry terrain and the new loops.
const Layout = preload("res://scripts/act_one_layout.gd")

func supported(pos: Vector2, floor_y: float) -> bool:
	if is_equal_approx(pos.y,floor_y): return true
	for l in Layout.platforms():
		if is_equal_approx(l.position.y,pos.y) and pos.x >= l.position.x and pos.x <= l.end.x: return true
	for b in Layout.blocks():
		if is_equal_approx(b.position.y,pos.y) and pos.x >= b.position.x and pos.x <= b.end.x: return true
	return false

func inside_block(pos: Vector2) -> bool:
	for b in Layout.blocks():
		if Rect2(b.position.x-16,b.position.y+2,b.size.x+32,b.size.y).has_point(pos+Vector2(0,-4)): return true
	return false

func room_of(x: float) -> String:
	var rooms: Dictionary = Layout.rooms()
	for id in rooms:
		var b: Rect2 = rooms[id].bounds
		if x >= b.position.x and x <= b.end.x: return id
	return "city"

func static_checks() -> void:
	var rooms: Dictionary = Layout.rooms()
	var blocks: Array[Rect2] = Layout.blocks()
	# Geometry: rooms never overlap horizontally, every backdrop exists.
	var overlap := false
	var missing_art := false
	for a in rooms:
		if not ResourceLoader.exists("res://assets/"+rooms[a].art+".png"): missing_art = true
		for b in rooms:
			if a < b and rooms[a].bounds.position.x < rooms[b].bounds.end.x and rooms[b].bounds.position.x < rooms[a].bounds.end.x: overlap = true
	expect(not overlap,"no two rooms share world space")
	expect(not missing_art,"every room backdrop exists")
	var arts: Array = []
	for id in rooms:
		if id != "city": arts.append(rooms[id].art)
	var repeated := false
	for a in arts:
		if arts.count(a) > 1: repeated = true
	expect(not repeated,"every explorable room has its own backdrop")
	# Connectivity: all ten rooms are reachable from the city.
	var seen: Array = ["city"]
	var changed := true
	while changed:
		changed = false
		for link in Layout.passages():
			if seen.has(link.a) and not seen.has(link.b): seen.append(link.b); changed = true
			elif seen.has(link.b) and not seen.has(link.a): seen.append(link.a); changed = true
	expect(seen.size() == rooms.size(),"all rooms form one connected map")
	var ends_ok := true
	for link in Layout.passages():
		if room_of(link.pa.x) != link.a or room_of(link.pb.x) != link.b: ends_ok = false
		if not supported(link.pa,rooms[link.a].floor) or not supported(link.pb,rooms[link.b].floor): ends_ok = false
		if inside_block(link.pa) or inside_block(link.pb): ends_ok = false
	expect(ends_ok,"every doorway stands on stone, inside its own room, clear of masonry")
	# Terrain: every block is one jump (or one step of a stair) and sits inside a room.
	var blocks_ok := true
	for b in blocks:
		var id := room_of(b.position.x)
		var rise: float = rooms[id].floor - b.position.y
		if rise > 60:
			var stepped := false
			for other in blocks:
				if other != b and other.position.x <= b.position.x+b.size.x and b.position.x <= other.end.x and other.position.y > b.position.y and other.position.y - b.position.y <= 60: stepped = true
			if not stepped: blocks_ok = false
		if rise > 110 or b.position.x < rooms[id].bounds.position.x or b.end.x > rooms[id].bounds.end.x: blocks_ok = false
		if not is_equal_approx(b.end.y,rooms[id].floor): blocks_ok = false
	expect(blocks_ok,"masonry stays within one jump of the floor or a lower step")
	# Nothing is placed inside, or patrols into, the masonry.
	var spawn_ok := true
	for d in Layout.enemies():
		var pos := Vector2(d[2],d[3])
		if [0,3,4,7].has(d[1]):
			if not supported(pos,rooms[d[0]].floor): spawn_ok = false
			var span := Rect2(d[2]-d[4]-18,d[3]-56,d[4]*2+36,56)
			for b in blocks:
				if span.intersects(b) and is_equal_approx(d[3],rooms[d[0]].floor): spawn_ok = false
		elif inside_block(pos): spawn_ok = false
	expect(spawn_ok,"enemies stand on stone and never patrol into masonry")
	var items_ok := true
	var ex = game.exploration
	for item in ex.pickups:
		if not supported(item.pos,rooms[item.room].floor) or inside_block(item.pos) or room_of(item.pos.x) != item.room: items_ok = false
	for altar in ex.extra_altars:
		if not supported(altar,rooms[room_of(altar.x)].floor) or inside_block(altar): items_ok = false
	expect(items_ok,"pickups and altars rest on stone, clear of masonry")
	expect(ex.pickups.size() == 9,"nine discoveries across the act")

func run() -> void:
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	game._start_game(false,false)
	for i in range(3): await close_message()
	quiet_enemies()
	game.player.has_weapon = true
	game.player.has_double_jump = true
	static_checks()
	var ex = game.exploration
	# Secret hall: archive shelf -> nave -> coro and loft -> refuge shelf.
	ex.travel("archive",Vector2(17340,280))
	await frames(20)
	expect(await go(17400,280),"reach the concealed door on the archive shelf")
	await interact()
	expect(ex.room == "nave","archive shelf door opens onto the nave")
	expect(game.altars.has(Vector2(21800,600)),"the nave has its own checkpoint")
	expect(await climb([ledge_index(21950,520),ledge_index(22110,440),ledge_index(22270,360)]),"climb to the coro balcony")
	expect(await go(22480,360),"reach the turned pews")
	await interact()
	expect(ex.collected.has("pews"),"coro rewards the climb with a record")
	await close_message()
	var stairs: Array = []
	for i in range(4): stairs.append(ledge_index(22800+i*140,520-i*80))
	stairs.append(ledge_index(23220,200))
	expect(not stairs.has(-1),"loft stair is in the layout")
	expect(await climb(stairs),"climb to the loft above the dais")
	expect(await go(23600,200),"reach the faded rosary")
	await interact()
	expect(ex.collected.has("silence"),"loft hides the rosary")
	await close_message()
	expect(await go(23850,600),"cross the dais and reach the choir door")
	await interact()
	expect(ex.room == "refuge" and absf(game.player.position.y-280.0) < 40.0,"choir door lands on the refuge shelf, a new loop")
	# Bell terrace: belfry top gallery -> terrace -> walkway -> cloister, then back and onward to the court.
	ex.travel("belfry",Vector2(14380,-100))
	await frames(20)
	expect(await go(14420,-100),"reach the belfry's upper door")
	await interact()
	expect(ex.room == "terrace","upper belfry opens onto the bell terrace")
	var terrace_stairs: Array = []
	for i in range(5): terrace_stairs.append(ledge_index(25300+i*130,520-i*80))
	terrace_stairs.append(ledge_index(25820,200))
	expect(not terrace_stairs.has(-1),"terrace stair is in the layout")
	expect(await climb(terrace_stairs),"climb the terrace stair to the walkway")
	expect(await go(26100,200),"reach the cut bell rope")
	await interact()
	expect(ex.collected.has("rope"),"walkway holds the bell rope")
	await close_message()
	expect(await go(26600,600),"descend to the walkway door")
	await interact()
	expect(ex.room == "cloister" and ex.opened.has("bell_walk"),"terrace shortcut opens into the cloister gallery")
	expect(await go(12950,40),"stand at the bell walk door")
	await interact()
	expect(ex.room == "terrace","the opened shortcut works in both directions")
	expect(await go(26900,600),"walk to the sealed road")
	await interact()
	expect(ex.room == "court","terrace leads to the sealed gates")
	expect(await go(28800,600,520),"reach the sealed gates")
	await interact()
	expect(ex.collected.has("seal"),"the sealed gates can be examined")
	await close_message()
	var court_steps: Array = [ledge_index(28100,520),ledge_index(28300,440),ledge_index(28500,360)]
	expect(not court_steps.has(-1),"balustrade is in the layout")
	expect(await climb(court_steps),"climb the court balustrade")
	expect(await go(28700,360),"reach the sealed decree")
	await interact()
	expect(ex.collected.has("decree"),"balustrade rewards the climb")
	await close_message()
	expect(game.player.lagrimas == 720,"discovery rewards add up once")
	for id in ["nave","terrace","court"]: expect(ex.visited.has(id),"%s is recorded on the map" % id)
	game._save()
	ex.reset()
	game._load()
	expect(ex.collected.has("seal") and ex.collected.has("silence") and ex.visited.has("court"),"save restores the expanded discoveries")
	expect(game.altars.size() == 9,"all nine checkpoints exist after loading")
	ex.map_open = true
	await frames(6)
	ex.map_open = false
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
	game = null
	await frames(5)
	print("EXPANSION_SMOKE: %d checks, %d failures" % [checks,failures])
	quit(0 if failures == 0 else 1)
