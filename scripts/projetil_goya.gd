extends Node2D
## Colheres, tigelas e aves do Sono; atingem qualquer integrante da dupla e respeitam paredes.
var origem=null
var sala:="city"
var quadro:=0
var velocidade:=Vector2.ZERO
var gravidade:=0.0
var dano:=12.0
var restante:=4.0
var poca:=false
var contatos:={}
var desenho:Sprite2D
func _ready() -> void:
 add_to_group("hazards")
 desenho=Sprite2D.new()
 var recorte:=AtlasTexture.new();recorte.atlas=load("res://assets/animation/goya_projeteis.png");recorte.region=Rect2(quadro*128,0,128,128)
 desenho.texture=recorte;desenho.scale=Vector2.ONE*(0.25 if quadro<2 else 0.35)
 add_child(desenho)
 z_index=4
func _physics_process(delta:float) -> void:
 var jogo=get_tree().get_first_node_in_group("game")
 if jogo==null:return
 if jogo.exploration.room!=sala:queue_free();return
 if jogo.state!="play" or jogo.paused or jogo.penitence_menu or not jogo.message_text.is_empty() or not jogo.narrative.mode.is_empty() or jogo.exploration.map_open or jogo.exploration.is_transitioning():return
 restante-=delta
 if restante<=0:queue_free();return
 if not poca:
  velocidade.y+=gravidade*delta
  var destino:=global_position+velocidade*delta
  var consulta:=PhysicsRayQueryParameters2D.create(global_position,destino,1)
  var toque:=get_world_2d().direct_space_state.intersect_ray(consulta)
  if not toque.is_empty():
   if quadro==1 and toque.normal.y< -0.5:
    poca=true;global_position=toque.position;restante=2;velocidade=Vector2.ZERO;desenho.visible=false
   else:queue_free();return
  else:global_position=destino
  desenho.rotation+=delta*6 if quadro<2 else 0.0
 for pessoa in get_tree().get_nodes_in_group("players"):
  if not pessoa.standing() or contatos.get(pessoa.get_instance_id(),0.0)>Time.get_ticks_msec()/1000.0:continue
  if pessoa.body_rect().grow(24 if poca else 7).has_point(global_position):
   pessoa.take_hit(dano,global_position.x,origem if is_instance_valid(origem) else self,false)
   contatos[pessoa.get_instance_id()]=Time.get_ticks_msec()/1000.0+0.65
   jogo.play_sfx("projetil_impacto")
   if not poca:queue_free();return
 queue_redraw()
func _draw() -> void:
 if poca:
  _desenhar_poca()
func _desenhar_poca() -> void:
 draw_set_transform(Vector2.ZERO,0,Vector2(1,0.22))
 draw_circle(Vector2.ZERO,30,Color(0.5,0.32,0.14,0.5*minf(restante,1)))
 draw_set_transform(Vector2.ZERO)
