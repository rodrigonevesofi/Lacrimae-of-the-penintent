extends SceneTree
const Fixture=preload("res://tests/reduced_pulses_fixture.gd")
var game
var checks:=0
var failures:=0
var observations: Array=[]
func _initialize():call_deferred("run")
func frames(n: int):
	for i in range(n):await physics_frame;await process_frame
func expect(ok: bool,label: String):
	checks+=1;print("PASS " if ok else "FAIL ",label)
	if not ok:failures+=1
func sample(mode: String,index: int) -> Dictionary:
	var n=game.narrative
	game.message_text=""
	if n.mode!="":n.finish()
	game.message_text=""
	game.observed_scene_shakes=0
	var knocks_before: int=game.soundscape.knock_count
	n.begin(mode,index);n.set_process(false)
	var tags: Array=[]
	if n.tag!="":tags.append(n.tag)
	var peak_flash:=0.0
	var peak_pulse:=0.0
	var duration: float=n.duration_of(mode)
	for tick in range(int(ceil(duration*60))+1):
		n._process(1.0/60)
		peak_flash=maxf(peak_flash,absf(n.flash));peak_pulse=maxf(peak_pulse,absf(n.pulse))
		if n.tag!="" and not tags.has(n.tag):tags.append(n.tag)
		if n.mode=="":break
	if n.mode!="":n.finish()
	return {"mode":mode,"index":index,"duration":duration,"flash":peak_flash,"pulse":peak_pulse,"shakes":game.observed_scene_shakes,"knocks":game.soundscape.knock_count-knocks_before,"captions":tags}
func shutdown(code: int):
	FileAccess.open("res://docs/reduced-pulses-spec-result.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failures":failures,"status":"NOT_IMPLEMENTED" if code==2 else ("PASS" if code==0 else "FAIL"),"samples":observations},"  "))
	game._delete_save();game.queue_free();game=null
	await frames(8);await create_timer(.2).timeout
	print("REDUCED_PULSES_SPEC: ",checks," checks, ",failures," failures; exit=",code)
	quit(code)
func run():
	if not OS.get_environment("XDG_DATA_HOME").begins_with("/tmp/lacrimae-reduced-"):
		push_error("Use XDG_DATA_HOME=/tmp/lacrimae-reduced-<run>/data to isolate settings/save data.");quit(3);return
	game=Fixture.new();root.add_child(game)
	game._start_game(false,false);game.message_text="";game.prologue_page=-1
	game.set_process(false);game.narrative.set_process(false)
	for e in get_nodes_in_group("enemies"):e.set_physics_process(false)
	game.soundscape.muted=true;game.soundscape.set_process(false)
	game.soundscape.ambience.stop();game.soundscape.incoming.stop();game.soundscape.guilt_layer.stop()
	for voice in game.soundscape.effects.values():voice.stop()
	var implemented=game.has_method("set_reduced_pulses") and game.has_method("is_reduced_pulses_enabled")
	if implemented:
		expect(not bool(game.call("is_reduced_pulses_enabled")),"clean settings default is disabled")
		game.call("set_reduced_pulses",false)
	var control=sample("echo",0);observations.append(control)
	expect(control.flash>0 and control.shakes==3 and control.knocks==3,"normal scene exercises real flash/shake/audio-call instrumentation")
	if not implemented:
		print("PENDING: proposed option API is absent; no option was implemented by this test.")
		await shutdown(2);return
	var scenes=[["echo",0],["echo",1],["echo",2],["memorial",0],["memorial",1],["memory",0],["boss_intro",0],["boss_end",0]]
	for entry in scenes:
		game.call("set_reduced_pulses",false)
		var normal=sample(entry[0],entry[1])
		game.call("set_reduced_pulses",true)
		expect(bool(game.call("is_reduced_pulses_enabled")),"option getter reflects enabled state")
		var reduced=sample(entry[0],entry[1]);observations.append(reduced)
		expect(reduced.flash==0,"%s/%d: flash remains zero"%entry)
		expect(reduced.pulse==0,"%s/%d: light-pool impulse remains zero"%entry)
		expect(reduced.shakes==0,"%s/%d: no scene shake_cam call"%entry)
		expect(reduced.knocks==normal.knocks,"%s/%d: sound calls retained"%entry)
		expect(reduced.captions==normal.captions,"%s/%d: sound captions retained"%entry)
		expect(reduced.duration==normal.duration,"%s/%d: scene duration retained"%entry)
	# Aplicar a configuração durante o impulso de uma batida deve interrompê-lo.
	game.call("set_reduced_pulses",false)
	var n=game.narrative;n.begin("echo",0);n.elapsed=2.21;n._process(0)
	game.call("set_reduced_pulses",true);n._process(1.0/60)
	expect(n.flash==0 and n.pulse==0 and game.player.shake==0,"enabling during an impulse clears current light/shake state")
	n.finish();game.call("set_reduced_pulses",false)
	await shutdown(1 if failures else 0)
