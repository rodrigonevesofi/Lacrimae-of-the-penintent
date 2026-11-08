extends SceneTree
var game
var sprites=[]
var elapsed:=0.0
var mode="atlas"
var captured:=false
var finishing:=false
var registration=[]
func _initialize():call_deferred("run")
func label(text: String,pos: Vector2):
	var l=Label.new();l.text=text;l.position=pos;l.add_theme_font_size_override("font_size",20);root.add_child(l)
func add_sprite(path: String,pos: Vector2,scale_factor: float):
	var s=Sprite2D.new();s.texture=load(path);s.hframes=6;s.vframes=4;s.position=pos;s.scale=Vector2.ONE*scale_factor
	root.add_child(s);return s
func run():
	root.size=Vector2i(1280,720);root.content_scale_size=Vector2i(1280,720)
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--mode="):mode=a.trim_prefix("--mode=")
	if mode=="abismo":
		game=load("res://scenes/main.tscn").instantiate();root.add_child(game)
		game._start_game(false,false);game.message_text="";game.prologue_page=-1;game.narrative.mode=""
		game.set_process(false);game.player.set_physics_process(false);game.player.set_process(false)
		for e in get_nodes_in_group("enemies"):e.set_physics_process(false)
		game.player.position=Vector2(1930,600);game.player.has_weapon=true
		game.player.animator.pose("idle",1,0);game.player._update_sword()
		var camera=game.player.camera;camera.zoom=Vector2.ONE;camera.offset=Vector2(200,100);camera.limit_bottom=1500;camera.reset_smoothing()
		var patch=Sprite2D.new();patch.centered=false;patch.texture=load("res://assets/abismo_ponte.png");patch.position=Vector2(2000,600);patch.z_index=5
		var material=CanvasItemMaterial.new();material.light_mode=CanvasItemMaterial.LIGHT_MODE_UNSHADED;patch.material=material
		game.add_child(patch)
	elif mode=="bronze":
		var art=TextureRect.new();art.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;art.texture=load("res://assets/boss/guardiao_03_imovel_v2.png");art.size=Vector2(1280,720);root.add_child(art)
		label("Prévia de leitura · bronze imóvel",Vector2(440,650))
	else:
		var bg=ColorRect.new();bg.color=Color("12161c");bg.size=Vector2(1280,720);root.add_child(bg)
		label("PRÉVIA DOS ATLAS · não é a luta integrada",Vector2(330,15))
		for i in range(4):
			var s=add_sprite("res://assets/animation/efeitos_combate.png",Vector2(160+i*310,155),.8);sprites.append(s)
		label("Faíscas / sangue / aparo / poeira",Vector2(430,255))
		var guardian=add_sprite("res://assets/animation/guardiao_grande.png",Vector2(200,480),1.5);sprites.append(guardian)
		for i in range(4):sprites.append(add_sprite("res://assets/animation/perigos.png",Vector2(490+(i%2)*400,400+(i/2)*200),.7))
		if FileAccess.file_exists("res://docs/v18-arte-medidas.json"):
			registration=JSON.parse_string(FileAccess.get_file_as_string("res://docs/v18-arte-medidas.json")).atlases.guardiao_grande.suggested_per_frame_y_registration
	while elapsed<8.3:
		await process_frame
		tick(root.get_process_delta_time())
func tick(delta: float):
	elapsed+=delta
	if sprites.size()>0:
		for i in range(4):sprites[i].frame=i*6+int(elapsed*12)%6
		var frame=0
		if elapsed<2:frame=int(elapsed*8)%6
		elif elapsed<4:frame=6+int(elapsed*10)%6
		elif elapsed<6:frame=12+int(elapsed*12)%6
		elif elapsed<7:frame=18+int(elapsed*10)%3
		else:frame=21+mini(int((elapsed-7)*6),2)
		sprites[4].frame=frame
		if registration.size()==24:sprites[4].offset.y=float(registration[frame])
		for i in range(4):sprites[5+i].frame=i*6+int(elapsed*10)%6
	if elapsed>1.8 and not captured:
		captured=true;capture()
	if not finishing and (elapsed>8.2 or (mode!="atlas" and elapsed>2.3)):
		finishing=true;finish()
func capture():
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://docs/imagens/v18-"+mode+".png")

func finish():
	if is_instance_valid(game):game._delete_save();game.queue_free();game=null
	for i in range(12):await process_frame
	load("res://scripts/actor_animation.gd").frames_cache.clear()
	await create_timer(.2).timeout
	quit()
