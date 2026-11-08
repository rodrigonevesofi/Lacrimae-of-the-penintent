extends SceneTree
var game
func _initialize():call_deferred("run")
func frames(n: int):
	for i in range(n):await physics_frame;await process_frame
func run():
	game=load("res://scenes/main.tscn").instantiate();root.add_child(game)
	game._start_game(false,false)
	for i in range(5):
		if game.message_text=="":break
		game.message_t=0;game.advance_message()
	game.soundscape.muted=true;game.soundscape.set_process(false)
	game.soundscape.ambience.stop();game.soundscape.incoming.stop();game.soundscape.guilt_layer.stop()
	for voice in game.soundscape.effects.values():voice.stop()
	for e in get_nodes_in_group("enemies"):e.set_physics_process(false)
	game.player.has_weapon=true
	game.narrative.begin("memory")
	for shot in [[8.7,"maos"],[12.5,"mao-pequena"],[17.2,"figura"],[22.0,"portao"]]:
		game.narrative.elapsed=shot[0];game.narrative.update_focus()
		await frames(3);await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://docs/imagens/v12-memoria-"+shot[1]+".png")
	game.narrative.finish();game._delete_save();game.queue_free();game=null
	await frames(8);await create_timer(.2).timeout
	print("V12_VISUAL: memory frames captured from actual scene")
	quit()
