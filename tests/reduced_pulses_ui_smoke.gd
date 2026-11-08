extends SceneTree
## The reduced-pulses option as a person meets it: the key, the default, persistence across sessions,
## and the written state. Uses disposable user data, so it never touches a real player's settings.
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
func press(action: String) -> void:
	var event := InputEventAction.new()
	event.action = action
	event.pressed = true
	game.hud._unhandled_input(event)

func run() -> void:
	if not OS.get_environment("XDG_DATA_HOME").begins_with("/tmp/lacrimae-reduced-"):
		push_error("Use XDG_DATA_HOME=/tmp/lacrimae-reduced-<run>/data so real settings are not touched.")
		quit(3)
		return
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await frames(6)
	expect(game.state == "title" and not game.reduced_pulses,"a clean install starts with the option off")
	press("reduce_pulses")
	expect(game.reduced_pulses and game.is_reduced_pulses_enabled(),"P on the title screen turns the option on, before the opening")
	game.queue_free()
	game = null
	await frames(4)
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await frames(6)
	expect(game.reduced_pulses,"the choice is still on in a new session")
	game._start_game(false,false)
	await frames(4)
	expect(game.reduced_pulses,"starting a new game does not erase the choice")
	game.message_text = ""
	game.toggle_pause()
	await frames(3)
	press("reduce_pulses")
	expect(not game.reduced_pulses,"P in the pause menu turns it off again")
	game.toggle_pause()
	await frames(2)
	press("reduce_pulses")
	expect(not game.reduced_pulses,"P does nothing while playing, so it cannot be hit by accident mid-fight")
	game.set_reduced_pulses(false)
	var source := FileAccess.get_file_as_string("res://scripts/hud.gd")
	expect(source.contains('"LIGADO" if game.reduced_pulses else "DESLIGADO"'),"the state is written out in words, not only colour")
	expect(game.hud.ending_art != null,"the closing illustration of Act I is loaded")
	game._delete_save()
	game.queue_free()
	game = null
	await frames(6)
	print("REDUCED_PULSES_UI: %d checks, %d failures" % [checks,failures])
	quit(0 if failures == 0 else 1)
