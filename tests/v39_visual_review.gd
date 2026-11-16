extends SceneTree
## Capturas dirigidas no renderizador; não substituem uma partida de avaliação humana.
var jogo
var pasta:String
var legenda:Label
func _initialize() -> void:call_deferred("executar")
func quadros(quantidade:int) -> void:
 for indice in range(quantidade):
  await physics_frame
  await process_frame
func capturar(nome:String,texto:String) -> void:
 legenda.text=texto
 await quadros(2)
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png(pasta.path_join(nome+".png"))
 print("CAPTURE: ",nome)
func executar() -> void:
 pasta=OS.get_environment("LACRIMAE_REVIEW_DIR")
 if pasta.is_empty():quit(3);return
 jogo=load("res://scenes/main.tscn").instantiate();root.add_child(jogo);jogo._start_game(false,false)
 for indice in range(3):jogo.message_t=0;jogo.advance_message()
 jogo.narrative.finish();jogo.message_text="";jogo.exploration.arenas_enabled=false
 jogo.enable_duo(true)
 var pessoa=jogo.player;var segunda=jogo.partner
 pessoa.has_weapon=true;pessoa.dev_god=true;pessoa.camera.position_smoothing_enabled=false
 segunda.has_weapon=true;segunda.ai=false;segunda.dev_god=true;segunda.set_physics_process(false)
 for inimigo in get_nodes_in_group("enemies"):inimigo.set_physics_process(false)
 var camada:=CanvasLayer.new();camada.layer=100;root.add_child(camada)
 legenda=Label.new();legenda.position=Vector2(330,150);legenda.add_theme_color_override("font_outline_color",Color.BLACK);legenda.add_theme_constant_override("outline_size",6);camada.add_child(legenda)
 for tipo in range(10,19):
  var criatura
  for inimigo in get_nodes_in_group("enemies"):
   if inimigo.kind==tipo:criatura=inimigo;break
  var piso:float=jogo.exploration.rooms[criatura.room_id].floor
  var posicao_x:float=criatura.position.x-160
  var apoio:float=jogo.bichos._chao(posicao_x,piso)
  jogo.exploration.travel(criatura.room_id,Vector2(posicao_x,apoio-2),1)
  segunda.position=Vector2(posicao_x-65,jogo.bichos._chao(posicao_x-65,piso)-2);segunda.velocity=Vector2.ZERO
  segunda.set_physics_process(true)
  pessoa.set_physics_process(true)
  await quadros(35)
  print("PISO: ",tipo," Penitente=",pessoa.is_on_floor()," Beatriz=",segunda.is_on_floor())
  pessoa.set_physics_process(false);pessoa.state="idle";pessoa._update_animation()
  segunda.set_physics_process(false);segunda.state="idle";segunda._update_animation()
  criatura.spawn_opacity=1;criatura.facing=-1;criatura.state="idle";criatura.cd=100
  criatura._process(0)
  jogo.area_t=0;jogo.toast_t=0
  await capturar("criatura-%02d-parada"%tipo,criatura.display_name+" · encontro no mapa · Penitente e Beatriz")
  criatura._preparar_ataque();criatura.state_t=criatura.duracao_aviso*0.4
  await capturar("criatura-%02d-aviso"%tipo,criatura.display_name+" · antecipação do ataque")
  criatura.state="idle"
 # Os closes são acionados pela própria cena de revelação.
 jogo.exploration.travel("vale",Vector2(31650,600),1);await quadros(30)
 var final=load("res://scripts/vale_finale.gd").new();final.game=jogo;final.boss=jogo.final_boss;jogo.add_child(final);final.set_process(false)
 for tempo in [7.0,14.0,18.0]:
  final.t=tempo;final.panel.queue_redraw()
  await capturar("revelacao-%02d"%int(tempo),"Rosto revisado · cena final · %ds"%int(tempo))
 final.queue_free();jogo._delete_save();jogo.queue_free();jogo=null
 await quadros(5);quit()
