extends SceneTree
var mode="assets"
var game
var elapsed:=0.0
var captured:=false
var finishing:=false
var actors=[]
var gate
var action_label
var next_attack:=0.0
func _initialize():call_deferred("run")
func label(text: String,pos: Vector2,parent=null,size=20):
	if parent==null:parent=root
	var l=Label.new();l.text=text;l.position=pos;l.add_theme_font_size_override("font_size",size);parent.add_child(l);return l
func hero(path: String,foot: Vector2,scale_factor: float,frame: int):
	var s=Sprite2D.new();s.texture=load(path);s.hframes=6;s.vframes=4;s.centered=false
	s.position=foot-Vector2(128,250)*scale_factor;s.scale=Vector2.ONE*scale_factor;s.frame=frame;root.add_child(s);return s
func run():
	root.size=Vector2i(1280,720);root.content_scale_size=Vector2i(1280,720)
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--mode="):mode=arg.trim_prefix("--mode=")
	if mode=="baseline":
		if not OS.get_environment("XDG_DATA_HOME").begins_with("/tmp/lacrimae-v19-"):
			push_error("Use isolated /tmp/lacrimae-v19-... XDG directories.");quit(3);return
		seed(1901)
		game=load("res://scenes/main.tscn").instantiate();root.add_child(game)
		game._start_game(false,false);game.message_text="";game.prologue_page=-1
		game.player.revive(Vector2(4120,600));game.player.has_weapon=true
		game.exploration.bells=["water","vigil"];game.exploration.update_gate()
		for e in get_nodes_in_group("enemies"):
			if e!=game.boss:e.queue_free()
		game.boss.awaken();game.exploration.set_camera();game.player.camera.reset_smoothing()
		game.soundscape.muted=true
		var layer=CanvasLayer.new();root.add_child(layer)
		label("BASE a21c9c2 · controle programado, sem o combate novo",Vector2(280,185),layer,17)
	else:
		var bg=ColorRect.new();bg.color=Color("11181f");bg.size=Vector2(1280,720);root.add_child(bg)
		label("ATLAS E PORTÕES · prévia isolada, sem colisões ou aparo implementado",Vector2(180,15))
		label("Quadro2 · interceptação",Vector2(35,100))
		hero("res://assets/animation/hero_combate.png",Vector2(180,465),1.25,2)
		actors.append(hero("res://assets/animation/hero_combate.png",Vector2(550,485),1.5,0))
		action_label=label("",Vector2(380,110))
		label("Escala de jogo0,44",Vector2(685,395))
		hero("res://assets/animation/hero_combat.png",Vector2(745,590),.44,0)
		actors.append(hero("res://assets/animation/hero_combate.png",Vector2(900,590),.44,0))
		label("Original",Vector2(712,610),root,16);label("Novo",Vector2(883,610),root,16)
		gate=Sprite2D.new();gate.texture=load("res://assets/arena_portao.png");gate.centered=false;gate.position=Vector2(1110,95);root.add_child(gate)
		label("Portão96×540",Vector2(1040,55),root,16)
		label("Mesmo ponto de origem nos dois estados",Vector2(800,670),root,16)
	while not finishing:
		await process_frame
		tick(root.get_process_delta_time())
func tick(delta: float):
	elapsed+=delta
	if mode=="baseline":
		for a in ["left","right","attack"]:
			if InputMap.has_action(a):Input.action_release(a)
		if game.player.state!="dead" and not game.boss.dead:
			var dx: float=game.boss.position.x-game.player.position.x
			if absf(dx)>75:Input.action_press("right" if dx>0 else "left")
			if absf(dx)<110 and game.player.state=="idle" and elapsed>=next_attack:
				Input.action_press("attack");next_attack=elapsed+.6
	else:
		var row=mini(int(elapsed/2.0),3)
		var durations=[[.08,.08,.20,.08,.08,.08],[.10,.10,.10,.10,.10,.10],[.12,.10,.14,.06,.07,.10],[.15,.15,.15,.22,.07,.10]][row]
		var local=fmod(elapsed,1.0);var frame=5;var end=0.0
		for i in range(6):
			end+=durations[i]
			if local<end:frame=i;break
		for s in actors:s.frame=row*6+frame
		action_label.text=["Aparo · quadro2 com pausa de leitura","Recuo após o aparo","Contra-golpe · preparar e cortar","Golpe carregado · acumular e cortar"][row]
		gate.texture=load("res://assets/arena_portao_aberto.png" if elapsed>=4 else "res://assets/arena_portao.png")
	if elapsed>2.25 and not captured:captured=true;capture()
	if elapsed>8.2:finishing=true;finish()
func capture():
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://docs/imagens/v19-"+mode+".png")
func finish():
	for a in ["left","right","attack"]:
		if InputMap.has_action(a):Input.action_release(a)
	if is_instance_valid(game):game._delete_save();game.queue_free();game=null
	for i in range(12):await process_frame
	load("res://scripts/actor_animation.gd").frames_cache.clear()
	await create_timer(.2).timeout
	quit()
