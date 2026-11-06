extends "res://tests/exploration_smoke.gd"
## Curated visual review. Long room transitions are cut; stair traversal uses the player controls.
func shot(label: String) -> void:
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("/tmp/v8-final-"+label+".png")
func run() -> void:
	game=load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	game._start_game(false,false)
	for i in range(3): await close_message()
	quiet_enemies()
	game.player.has_weapon=true
	game.player.lagrimas=138
	game.player.culpa=62
	game.player.position=Vector2(540,600)
	game.player.camera.reset_smoothing()
	await frames(65)
	await shot("hud-altar")
	game.penitence_menu=true
	await frames(70)
	game.penitence_menu=false
	expect(await go(1160,600),"walk to ossuary entrance")
	await interact()
	await frames(35)
	expect(await climb([0,1,2,3,4,5]),"climb ossuary route")
	await frames(40)
	await shot("ossuary-gallery")
	await go(6450,200)
	await interact()
	await frames(40)
	await shot("refuge")
	# Cut to the water stair, then traverse it physically.
	game.exploration.travel("cistern",Vector2(8560,600))
	await frames(30)
	expect(await climb([10,11,12,13,14,15,16,17]),"climb cistern water gallery")
	await go(9650,40)
	await interact()
	await frames(40)
	await shot("cistern")
	game.exploration.travel("archive",Vector2(17760,280))
	await frames(45)
	await go(17800,280)
	await interact()
	await frames(90)
	await shot("archive-text")
	await close_message()
	game.exploration.travel("cloister",Vector2(12550,40))
	await frames(50)
	await shot("cloister")
	game.exploration.travel("belfry",Vector2(14580,1100))
	await frames(45)
	if game.message_text!="": await close_message()
	expect(await climb([36,37,38,39,40,41,42,43]),"climb tower lower flight")
	await frames(40)
	await shot("tower")
	game.exploration.map_open=true
	await frames(100)
	await shot("map")
	game.exploration.map_open=false
	game.exploration.bells=["water","vigil"]
	game.exploration.update_gate()
	game.exploration.travel("city",Vector2(4220,600))
	game.player.invuln=8
	game.boss.set_physics_process(true)
	await frames(100)
	await shot("boss-hud")
	game.soundscape.set_process(false)
	game.player.set_physics_process(false)
	quiet_enemies()
	game.soundscape.ambience.stop()
	game.soundscape.incoming.stop()
	game.soundscape.guilt_layer.stop()
	for voice in game.soundscape.effects.values():voice.stop()
	await frames(20)
	game._delete_save()
	game.queue_free()
	await frames(5)
	print("VISUAL_REVIEW: ",checks," checks ",failures," failures")
	quit(0 if failures==0 else 1)
