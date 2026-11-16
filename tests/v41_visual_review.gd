extends SceneTree
## Revisão com o renderizador: cena atual e modo de vídeo com a amostra de teste, sem instalar clipes no jogo.
const Revelacao=preload("res://scripts/vale_finale.gd")
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
 jogo.exploration.arenas_enabled=false
 for inimigo in get_nodes_in_group("enemies"):inimigo.set_physics_process(false)
 jogo.player.dev_god=true;jogo.player.has_weapon=true
 jogo.exploration.travel("vale",Vector2(31650,600),1)
 await quadros(35)
 var camada:=CanvasLayer.new();camada.layer=100;root.add_child(camada)
 legenda=Label.new();legenda.position=Vector2(20,16);legenda.add_theme_color_override("font_outline_color",Color.BLACK);legenda.add_theme_constant_override("outline_size",6);camada.add_child(legenda)
 var cena=Revelacao.new();cena.game=jogo;cena.boss=jogo.final_boss;jogo.finale=cena;jogo.add_child(cena);cena.set_process(false)
 print("PADRAO: filme=",cena.filme," duracao=",cena.duracao())
 for tempo in [14.0,24.0]:
  cena.t=tempo;cena.panel.queue_redraw()
  await capturar("padrao-%02d"%int(tempo),"V41 · cena entregue sem clipes · %ds"%int(tempo))
 cena.queue_free();await quadros(2)
 var filme=Revelacao.new();filme.game=jogo;filme.boss=jogo.final_boss;filme.pasta_clipes="res://tests/dados/";jogo.finale=filme;jogo.add_child(filme);filme.set_process(false)
 print("AMOSTRA: filme=",filme.filme," videos=",filme.videos.size()," duracao=",filme.duracao())
 for tempo in [3.8,11.9,20.2,28.0,44.2,51.2]:
  filme.t=tempo;filme._avancar_filme()
  await quadros(10)
  filme.panel.queue_redraw()
  await capturar("amostra-%02d"%int(tempo),"V41 · teste de vídeo e closes de reserva · %0.1fs"%tempo)
 filme.queue_free();jogo._delete_save();jogo.queue_free();jogo=null
 await quadros(5);quit()
