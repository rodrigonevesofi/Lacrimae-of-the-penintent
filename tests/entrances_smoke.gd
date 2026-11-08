extends SceneTree
var game
var checks := 0
var failures := 0
func _initialize() -> void: call_deferred("run")
func expect(ok: bool,label: String) -> void:
	checks += 1
	if not ok: failures += 1
	print("PASS: " if ok else "FAIL: ",label)
func frames(n: int) -> void:
	for i in range(n):
		await physics_frame
		await process_frame
func clear_dialogue() -> void:
	for i in range(16):
		if game.message_text.is_empty(): break
		game.message_t=0
		game.advance_message()
		await frames(1)
func run() -> void:
	game=load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	game._start_game(false,false)
	await clear_dialogue()
	for e in get_nodes_in_group("enemies"): e.set_physics_process(false)
	var ex=game.exploration
	var p=game.player
	p.has_weapon=true
	p.hp=61
	p.lagrimas=77
	p.culpa=50
	p.position=Vector2(1160,600)
	await frames(3)
	expect(game.art.doorway_art!=null,"embedded doorway atlas is retained")
	var atlas: Image=Image.load_from_file("res://assets/doorways.png")
	expect(atlas.get_size()==Vector2i(1536,1024),"doorway atlas has six architectural modules")
	expect(atlas.get_pixel(0,0).a<0.01,"doorway atlas exterior is transparent")
	for col in range(3):
		var open:=atlas.get_region(Rect2i(col*512,0,512,512))
		var shut:=atlas.get_region(Rect2i(col*512,512,512,512))
		expect(open.get_data()!=shut.get_data(),"open and closed grilles have different art theme %d" % col)
	for link in ex.passages:
		for from_a in [true,false]:
			var face: Dictionary=ex.Layout.passage_face(link,from_a)
			var spawn: Vector2=face.foot+Vector2(face.arrival_dir*face.spawn_offset,0)
			var bounds: Rect2=ex.rooms[face.room].bounds
			expect(spawn.x>bounds.position.x and spawn.x<bounds.end.x,"arrival stays inside room: %s/%s" % [link.id,face.room])
			var supported: bool=absf(spawn.y-float(ex.rooms[face.room].floor))<1
			for ledge in ex.ledges:
				if absf(spawn.y-ledge.position.y)<1 and spawn.x>=ledge.position.x and spawn.x<=ledge.end.x: supported=true
			expect(supported,"arrival has real floor or gallery: %s/%s" % [link.id,face.room])
	# Check actual timing: destination is not changed on E; movement pauses until arrival.
	Input.action_press("interact")
	game._play_update(0.016)
	Input.action_release("interact")
	expect(ex.is_transitioning() and ex.transition_phase=="out" and ex.room=="city","E starts exit fade while still in the source room")
	var start: Vector2=p.position
	Input.action_press("right")
	await frames(3)
	expect(p.position.distance_to(start)<1,"direction input cannot move actor during exit fade")
	expect(ex.room=="city" and ex.transition>0,"source remains visible during initial exit fade")
	Input.action_release("right")
	for i in range(30):
		if ex.room=="ossuary": break
		await frames(1)
	expect(ex.room=="ossuary" and ex.transition_phase=="in","destination changes only after fade to black")
	expect(p.facing==1 and p.position.x>5360,"arrival faces into ossuary rather than back toward door")
	for i in range(40):
		if not ex.is_transitioning(): break
		await frames(1)
	expect(not ex.is_transitioning() and p.controllable,"entry fade restores player control")
	expect(p.hp==61 and p.lagrimas==77 and p.culpa==50,"door travel preserves health, currency and guilt")
	# The reverse side is deliberately placed against the direction of the outgoing route.
	ex.request_travel("city",Vector2(1070,600),-1)
	await frames(30)
	expect(ex.room=="city" and p.facing==-1,"return arrival keeps its authored orientation")
	# Closed-from-other-side routes must refuse the journey.
	ex.travel("city",Vector2(2400,600))
	await frames(3)
	Input.action_press("interact")
	ex.update(0.016)
	Input.action_release("interact")
	expect(not ex.is_transitioning() and ex.room=="city","locked return grille cannot be traversed from city")
	expect(game.prompt.contains("fechada"),"locked grille explains why it cannot open from this side")
	ex.travel("cistern",Vector2(10400,600))
	await frames(3)
	Input.action_press("interact")
	ex.update(0.016)
	Input.action_release("interact")
	await frames(30)
	expect(ex.opened.has("water_return") and ex.room=="city","inner latch unlocks passage and persists its opened state")
	game._save()
	ex.opened.clear()
	game._load()
	expect(ex.opened.has("water_return"),"unlocked grille survives save and reload")
	game.memorial_honored=false
	game.art._process(0.016)
	expect(not game.art.memorial_doll.visible,"memorial contains no doll before the homage")
	game.memorial_honored=true
	game.art._process(0.016)
	expect(game.art.memorial_doll.visible,"homage adds its separate cloth doll to the memorial")
	expect(game.art.memorial_base.texture!=null and game.art.memorial_base.material is ShaderMaterial,"empty memorial uses a retained cutout material")
	game.soundscape.set_process(false)
	game.player.set_physics_process(false)
	for e in get_nodes_in_group("enemies"): e.set_physics_process(false)
	game.soundscape.ambience.stop()
	game.soundscape.incoming.stop()
	game.soundscape.guilt_layer.stop()
	for voice in game.soundscape.effects.values(): voice.stop()
	await create_timer(0.2).timeout
	game._delete_save()
	game.queue_free()
	game=null
	await frames(4)
	print("ENTRANCES_SMOKE: %d checks, %d failures" % [checks,failures])
	quit(0 if failures==0 else 1)
