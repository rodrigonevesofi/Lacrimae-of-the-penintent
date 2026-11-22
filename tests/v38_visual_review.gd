extends SceneTree
## Capturas dirigidas com o renderizador real. Não substituem uma partida humana.
var game
var directory:String
var label:Label
func _initialize() -> void:call_deferred("run")
func frames(n:int) -> void:
 for i in range(n):
  await physics_frame
  await process_frame
func capture(name:String,caption:String) -> void:
 label.text=caption
 await frames(2)
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png(directory.path_join(name+".png"))
 print("CAPTURE: ",name)
func gallery(paths:Array,name:String,cols:int=3) -> void:
 var view:=SubViewport.new()
 var lines:=int(ceil(paths.size()/float(cols)))
 view.size=Vector2i(cols*512,lines*360)
 view.render_target_update_mode=SubViewport.UPDATE_ALWAYS
 root.add_child(view)
 var bg:=ColorRect.new();bg.color=Color("292d34");bg.size=Vector2(view.size);view.add_child(bg)
 for i in range(paths.size()):
  var cell:=Vector2((i%cols)*512,(i/cols)*360)
  var art:Texture2D=load("res://"+paths[i])
  var sprite:=Sprite2D.new();sprite.texture=art
  var factor:=minf(500.0/art.get_width(),320.0/art.get_height())
  sprite.scale=Vector2.ONE*factor;sprite.position=cell+Vector2(256,165);view.add_child(sprite)
  var title:=Label.new();title.text=str(paths[i]).get_file();title.position=cell+Vector2(8,333);view.add_child(title)
 await RenderingServer.frame_post_draw
 view.get_texture().get_image().save_png(directory.path_join(name+".png"))
 view.queue_free();await frames(2)
func room(id:String) -> void:
 var data:Dictionary=game.exploration.rooms[id]
 var x:float=data.bounds.position.x+data.bounds.size.x*0.58
 game.exploration.travel(id,Vector2(x,data.floor),1)
 await frames(30)
 game.player.set_physics_process(false)
 game.player.global_position=Vector2(x,data.floor)
 game.player.camera.reset_smoothing()
 await frames(3)
func dissolve_contact(foe) -> void:
 var view:=SubViewport.new();view.size=Vector2i(1280,300);view.render_target_update_mode=SubViewport.UPDATE_ALWAYS;root.add_child(view)
 var bg:=ColorRect.new();bg.size=Vector2(view.size);bg.color=Color("292d34");view.add_child(bg)
 var visuals=foe.get_node("CombatVisuals")
 for i in range(5):
  var sprite:=Sprite2D.new();sprite.texture=foe.animator.sprite_frames.get_frame_texture("death",foe.animator.frame);sprite.position=Vector2(i*256+128,130)
  sprite.material=visuals.material_for();visuals.sync_frame(sprite.material,sprite.texture);sprite.material.set_shader_parameter("progress",i*0.25);view.add_child(sprite)
  var title:=Label.new();title.text="Dissolução: %d%%"%(i*25);title.position=Vector2(i*256+10,275);view.add_child(title)
  if i==0:print("CINZA_BOUNDS: ",sprite.material.get_shader_parameter("vertical_bounds")," frame ",foe.animator.frame)
 await RenderingServer.frame_post_draw
 view.get_texture().get_image().save_png(directory.path_join("20-cinza-progressao.png"));view.queue_free();await frames(2)
func run() -> void:
 directory=OS.get_environment("LACRIMAE_REVIEW_DIR")
 if directory.is_empty():quit(3);return
 await gallery(["assets/animation/flagelado_movimento.png","assets/animation/flagelado_combate.png","assets/animation/flagelado_reacoes.png","assets/animation/flagelado_estados.png","assets/animation/flagelado_transformacao.png","assets/efeitos/placas_flagelado.png"],"01-chefe-contato")
 await gallery(["assets/animation/flagelado_estado1.png","assets/animation/flagelado_estado2.png","assets/animation/flagelado_estado3.png","assets/animation/flagelado_estado4.png","assets/animation/gota_culpa.png"],"02-estados-contato")
 await gallery(["assets/close/close_01.png","assets/close/close_flagelado_elmo.png","assets/close/close_revelacao_maos.png","assets/close/close_dois_rostos.png"],"03-closes-contato",2)
 await gallery(["assets/vale/ceu.png","assets/vale/desfiladeiro_longe.png","assets/vale/desfiladeiro_meio.png","assets/vale/desfiladeiro_perto.png","assets/vale/forcas.png","assets/vale/enforcados.png","assets/vale/arvores_mortas.png","assets/vale/chao.png","assets/animation/corvo.png"],"04-vale-contato")
 await gallery(["assets/vida/pendentes.png","assets/animation/chama_vela.png","assets/animation/fumaca_incenso.png","assets/vida/santo_base.png","assets/vida/santo_movimento.png","assets/vida/ossuario_base.png","assets/vida/ossuario_movimento.png","assets/vida/relicario_base.png","assets/vida/relicario_movimento.png"],"05-vida-contato")
 var fichas:Array=[]
 for name in ["glutao","disciplinantes","meio_enterrado","parcas","sono","romaria","espantalho","dois_velhos","viuva"]:fichas.append("docs/fichas/"+name+".png")
 await gallery(fichas,"06-fichas-contato")
 game=load("res://scenes/main.tscn").instantiate();root.add_child(game);game._start_game(false,false)
 for i in range(3):game.message_t=0;game.advance_message()
 game.exploration.arenas_enabled=false
 for e in get_nodes_in_group("enemies"):e.set_physics_process(false)
 var p=game.player;p.has_weapon=true;p.dev_god=true;p.camera.position_smoothing_enabled=false
 var overlay:=CanvasLayer.new();overlay.layer=100;root.add_child(overlay)
 label=Label.new();label.position=Vector2(380,180);label.add_theme_color_override("font_outline_color",Color.BLACK);label.add_theme_constant_override("outline_size",6);overlay.add_child(label)
 game.enter_vale();await frames(35)
 p.set_physics_process(false);p.global_position=Vector2(31650,600);p.state="idle";p._update_animation()
 game.area_t=0;game.toast_t=0
 var b=game.final_boss;b.global_position=Vector2(31800,600);b.state="idle";b._wear("true");b._process(0)
 await capture("07-vale-calmo","Vale · camadas pintadas, vento e cinzas")
 for stage in range(5):
  b.stage=stage;b._wear("true");b.state="idle" if stage<4 else "kneel";b._process(0)
  await frames(40)
  await capture("08-chefe-estado-%d"%stage,"Flagelado · estado %d · escala 0,62"%stage)
 game.vale_back.mood=1;game.vale_front.mood=1
 await capture("09-vale-culpa","Vale · última placa · atmosfera escurecida")
 game.vale_back.mood=0;game.vale_front.mood=0;b.stage=0;b._wear("true");b._process(0)
 var bv=b.get_node("CombatVisuals");bv.set_process(false)
 b._wear("mirror");bv._process(0.3);b._process(0)
 await frames(18)
 await capture("10-transformacao-ida","Dissolução · forma verdadeira para reflexo · máscara pintada")
 bv._process(0.4);b._wear("true");bv._process(0.3);b._process(0)
 await frames(18)
 await capture("11-transformacao-volta","Dissolução · reflexo para forma verdadeira")
 bv._process(0.4)
 var v=p.get_node("CombatVisuals");v.set_process(false)
 for character in ["penitente","beatriz"]:
  p.character=character;p.apply_character();p.state="attack";p.attack_len=0.32
  for i in range(7):p.state_t=0.32*(0.64-i*0.025);v._process(0.016)
  p._update_animation()
  await capture("12-rastro-"+character,"Line2D · "+character+" · janela ativa")
 p.state="parry";p.parry_hit=true;p._update_animation();game.reduced_pulses=false;v._process(0.2)
 await capture("13-luz-aparo","Aparo · PointLight2D suave · HUD legível")
 game.reduced_pulses=true;v._process(0.01)
 await capture("14-reduzir-pulsos","Reduzir pulsos · luz do aparo desativada")
 game.reduced_pulses=false;p.parry_hit=false;p.state="idle";p._update_animation()
 var foe=game.new_enemy(0);foe.setup(0,Vector2(31730,600),0,p);game.add_child(foe);foe.room_id="vale";foe.set_physics_process(false);foe.spawn_opacity=1
 foe._die();foe.death_age=0.65;foe._process(0);foe.get_node("CombatVisuals").set_process(false);foe.get_node("CombatVisuals")._process(0.01)
 await dissolve_contact(foe)
 await capture("15-cinza-morte","Morte comum · cinzas de baixo para cima")
 foe.queue_free()
 var breathing_foe=game.new_enemy(3);breathing_foe.setup(3,Vector2(31730,600),0,p);game.add_child(breathing_foe);breathing_foe.room_id="vale";breathing_foe.set_physics_process(false);breathing_foe.state="idle";breathing_foe.velocity=Vector2.ZERO;breathing_foe.spawn_opacity=1
 await frames(90)
 await capture("19-respiracao","Criatura parada · Tween de respiração · escala vertical +1,2%")
 breathing_foe.queue_free()
 p.impact_direction=Vector2(1,-0.25);p.shake=6;p._physics_process(0)
 await capture("16-impacto-direcional","Câmera · deslocamento na direção do impacto")
 p.shake=0;p.camera.offset=Vector2(0,-110)
 for id in ["cistern","ossuary","cloister"]:
  await room(id)
  await capture("17-monumento-"+id,"Monumento · "+id+" · duas peças e movimento local")
 await room("vale")
 var finale=load("res://scripts/vale_finale.gd").new();finale.game=game;finale.boss=b;game.add_child(finale);finale.set_process(false)
 for time in [7.0,14.0,18.0]:
  finale.t=time;finale.panel.queue_redraw()
  await capture("18-revelacao-%d"%int(time),"Revelação · %ds"%int(time))
 finale.queue_free();game._delete_save();game.queue_free();game=null;await frames(5);quit()
