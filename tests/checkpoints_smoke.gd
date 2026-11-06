extends SceneTree
var game
var checks := 0
var failures := 0
func _initialize() -> void: call_deferred("run")
func expect(ok: bool,label: String) -> void:
	checks+=1
	if not ok:failures+=1
	print("PASS: " if ok else "FAIL: ",label)
func frames(n: int) -> void:
	for i in range(n):
		await physics_frame
		await process_frame
func run() -> void:
	game=load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	game._start_game(false,false)
	for i in range(3):
		game.message_t=0
		game.advance_message()
	for e in get_nodes_in_group("enemies"):e.set_physics_process(false)
	game.player.hp=48
	game.player.lagrimas=123
	game.player.culpa=60
	game.exploration.travel("belfry",Vector2(14420,1100))
	await frames(50)
	expect(game.player.hp==48 and game.player.lagrimas==123 and game.player.culpa==60,"travel does not heal or reset resources")
	expect(absf(game.player.position.y-1100)<5,"lower tower floor remains safe below old fall threshold")
	var screen_foot: Vector2=game.player.get_global_transform_with_canvas().origin
	expect(screen_foot.y>350 and screen_foot.y<680,"camera keeps feet away from lower screen edge")
	Input.action_press("offer")
	await frames(3)
	Input.action_release("offer")
	expect(game.player.upgrades==1 and game.player.lagrimas==23,"tower altar supports the same offering as city altars")
	game._pray(5)
	game.narrative.elapsed=2
	game.narrative._process(0)
	expect(game.player.cinematic_focus and game.player.camera.limit_right>21000,"prayer camera can focus beyond original city coordinates")
	game.narrative.elapsed=game.narrative.PRAYER_DURATION
	game.narrative._process(0)
	await frames(4)
	expect(game.respawn_index==5 and game.player.hp==game.player.max_hp,"tower prayer saves local checkpoint and heals")
	expect(game.player.camera.limit_left==14200 and game.player.camera.limit_right==16200,"tower prayer restores room camera bounds")
	for e in get_nodes_in_group("enemies"):e.set_physics_process(false)
	game.player.position=Vector2(14800,1100)
	game.player.die()
	game._respawn()
	await frames(3)
	expect(game.exploration.room=="belfry" and game.player.position.distance_to(Vector2(14420,1100))<5,"death returns to tower checkpoint instead of city")
	game.exploration.collected.append("vessel")
	game.player.max_flasks=4
	game._save()
	game._start_game(true)
	await frames(3)
	expect(game.exploration.room=="belfry" and game.respawn_index==5,"continue restores checkpoint room")
	expect(game.player.max_flasks==4 and game.player.flasks==4,"optional healing reward survives restart")
	expect(game.stain_active and game.stain_pos.distance_to(Vector2(14800,1100))<5,"deep-room guilt fragment persists")
	for e in get_nodes_in_group("enemies"):e.set_physics_process(false)
	var shot=load("res://scripts/tear.gd").new()
	shot.player=game.player
	shot.position=game.player.position+Vector2(60,-30)
	shot.vel=Vector2(-200,0)
	game.add_child(shot)
	game.player.invuln=0
	game.player.state="idle"
	var tab := InputEventKey.new()
	tab.physical_keycode=KEY_TAB
	tab.keycode=KEY_TAB
	tab.pressed=true
	Input.parse_input_event(tab)
	await frames(3)
	expect(game.exploration.map_open,"physical TAB key opens cartography")
	tab.pressed=false
	Input.parse_input_event(tab)
	var at: Vector2=shot.position
	var hp: float=game.player.hp
	await frames(12)
	expect(is_instance_valid(shot) and shot.position==at and game.player.hp==hp,"map freezes incoming projectiles as well as actors")
	game.exploration.map_open=false
	game.exploration.travel("city",Vector2(1000,600))
	await frames(2)
	expect(get_nodes_in_group("hazards").is_empty(),"crossing a door clears attacks from previous room")
	expect(game.hud.ui_regions.size()==6,"reliquary HUD loads six original ornamental elements")
	for key in game.hud.ui_regions:
		var region: AtlasTexture=game.hud.ui_regions[key]
		expect(Rect2(Vector2.ZERO,region.atlas.get_size()).encloses(region.region),"HUD atlas region stays inside source: "+key)
	game.soundscape.set_process(false)
	game.player.set_physics_process(false)
	for e in get_nodes_in_group("enemies"):e.set_physics_process(false)
	game.soundscape.ambience.stop()
	game.soundscape.incoming.stop()
	game.soundscape.guilt_layer.stop()
	for voice in game.soundscape.effects.values():voice.stop()
	await create_timer(0.2).timeout
	game._delete_save()
	game.queue_free()
	await frames(4)
	print("CHECKPOINTS_SMOKE: %d checks, %d failures" % [checks,failures])
	quit(0 if failures==0 else 1)
