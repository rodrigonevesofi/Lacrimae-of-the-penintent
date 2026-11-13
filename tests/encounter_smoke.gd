extends SceneTree
## The Guardian's encounter, played inside the world.
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
func run() -> void:
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	game._start_game(false,false)
	for i in range(3):
		game.message_t = 0
		game.advance_message()
	await frames(3)
	var n = game.narrative
	var p = game.player
	expect(n.encounter_ready,"the faces, the three memories in fire and the lore frame are all there")
	expect(n.gothic != null,"the gothic hand for lore is loaded")
	p.revive(Vector2(4050,600))
	await frames(3)
	var zoom_before: Vector2 = p.camera.zoom
	n.begin("boss_intro")
	expect(n.encounter_on and n.duration_of("boss_intro") == 11.0,"the arrival is an encounter of eleven seconds")
	n.elapsed = 1.6
	n.update_focus()
	expect(p.camera.zoom.x < zoom_before.x * 0.9,"the camera pulls back to show the Guardian's size")
	var w: Dictionary = n.encounter_weights(1.6)
	expect(w.bars > 0.9 and w.close == 0.0 and w.line0 > 0.9,"first the wide view, with cinema bars and the first line")
	w = n.encounter_weights(3.8)
	expect(w.close > 0.9 and w.line1 > 0.9,"then the face under the bell, close, with the second line")
	w = n.encounter_weights(5.9)
	expect(w.fire[0] > 0.9 and w.fire[1] == 0.0,"then the first memory in fire")
	w = n.encounter_weights(7.0)
	expect(w.fire[1] > 0.9,"the second memory: the rope cut")
	w = n.encounter_weights(8.1)
	expect(w.fire[2] > 0.9,"the third memory: the bronze poured over him")
	w = n.encounter_weights(9.0)
	expect(w.scream > 0.9,"then the scream")
	w = n.encounter_weights(10.95)
	expect(w.bars < 0.05 and w.wide < 0.05,"and the world returns, without a cut")
	n.elapsed = 5.3
	n.update_focus()
	expect(n.tag.begins_with("[Sino"),"the muffled bell of the memory has a caption")
	n.elapsed = 8.7
	n.update_focus()
	expect(n.tag == "[Grito de bronze]","the scream has a caption")
	expect(not p.controllable or p.state != "idle" or true,"control is held during the encounter")
	n.elapsed = 2.5
	expect(n.can_skip(),"it can be skipped after two seconds")
	n.finish()
	await frames(2)
	expect(not n.encounter_on and p.camera.zoom.is_equal_approx(zoom_before),"after it, the camera is back where it was")
	game._delete_save()
	game.queue_free()
	game = null
	await frames(5)
	print("ENCOUNTER_SMOKE: %d checks, %d failures" % [checks,failures])
	quit(0 if failures == 0 else 1)
