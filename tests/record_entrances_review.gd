extends SceneTree
var game
func _initialize() -> void: call_deferred("run")
func frames(n:int) -> void:
	for i in range(n): await process_frame
func show(id:String,pos:Vector2,name:String) -> void:
	game.exploration.travel(id,pos)
	game.player.has_weapon=true
	game.player.camera.reset_smoothing()
	await frames(35)
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("/tmp/entries-"+name+".png")
func run() -> void:
	game=load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	game._start_game(false,false)
	for i in range(12):
		if game.message_text.is_empty():break
		game.message_t=0
		game.advance_message()
	for e in get_nodes_in_group("enemies"): e.set_physics_process(false)
	await show("city",Vector2(1050,600),"burial")
	await show("city",Vector2(2180,540),"bridge-threshold")
	await show("city",Vector2(2510,600),"sluice-closed")
	game.exploration.opened.append("water_return")
	await show("city",Vector2(2510,600),"sluice-open")
	await show("city",Vector2(2970,600),"vows-gallery")
	await show("ossuary",Vector2(6350,200),"shelter-gallery")
	game.memorial_honored=false
	await show("city",Vector2(2790,600),"memorial-empty")
	game.memorial_honored=true
	await show("city",Vector2(2790,600),"memorial-honored")
	game.soundscape.set_process(false)
	game.player.set_physics_process(false)
	game.soundscape.ambience.stop()
	game.soundscape.incoming.stop()
	game.soundscape.guilt_layer.stop()
	for voice in game.soundscape.effects.values():voice.stop()
	await frames(15)
	game._delete_save()
	game.queue_free()
	await frames(5)
	quit()
