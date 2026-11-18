extends "res://scripts/enemy.gd"
## Nove criaturas das fichas aprovadas pelo autor. Os contratos de combate herdados são mantidos.
const ProjetilGoya = preload("res://scripts/projetil_goya.gd")
const NOMES := ["glutao","disciplinantes","meio_enterrado","parcas","sono","romaria","espantalho","dois_velhos","viuva"]
var tempo_local := 0.0
var duracao_aviso := 0.8
var duracao_ataque := 0.3
var duracao_abertura := 1.0
var alvo_marcado := Vector2.ZERO
var atingidos := {}
var acordado := false
var enterrado := true
var pernas_caidas := false
var peregrinos := 6
var largura_visual := 1.0
var corpo_inicial := Vector2.ZERO
var disparos := 0
var cortes := 0
var luz_lanterna:PointLight2D
var aviso_lanterna := false

func _ready() -> void:
 super._ready()
 corpo_inicial=body_size
 cd=1.2
 state="idle"
 if kind==18:
  luz_lanterna=Util.make_light(Color("d4ad65"),0.28,1.2)
  luz_lanterna.position=Vector2(15,-55)
  add_child(luz_lanterna)

func _jogo():
 return get_tree().get_first_node_in_group("game")

func escala_visual() -> Vector2:
 return Vector2(animator.unit_scale*largura_visual,animator.unit_scale)

func _mesma_sala(jogo) -> bool:
 return jogo!=null and jogo.exploration.room==room_id

func _physics_process(delta:float) -> void:
 var jogo=_jogo()
 if not _mesma_sala(jogo) or jogo.state!="play" or not jogo.message_text.is_empty() or not jogo.narrative.mode.is_empty() or jogo.penitence_menu or jogo.exploration.map_open or jogo.exploration.is_transitioning():return
 var anterior:String=state
 var havia_pausa:bool=hit_pause>0
 super._physics_process(delta)
 if dead or executing or havia_pausa or spawn_opacity<1 or anterior in ["stagger","launched","knockdown"]:return
 if player==null or not is_instance_valid(player):return
 tempo_local+=delta
 var distancia:float=absf(player.global_position.x-global_position.x)
 if not announced and distancia<480:
  announced=true
  jogo.announce_enemy(kind)
 if state=="hurt":
  velocity.x=move_toward(velocity.x,0,800*delta)
  if state_t<=0:state="recover";state_t=0.45
 elif state=="windup":
  velocity.x=0
  if state_t<=0:
   state="strike";state_t=duracao_ataque;struck=false;atingidos.clear()
 elif state=="strike":
  if not struck:
   struck=true
   _soltar_ataque()
  if kind in [11,12,15,18]:velocity.x=facing*(110.0 if kind!=15 else 160.0)
  if state_t<=0:state="recover";state_t=duracao_abertura;velocity.x=0
 elif state=="recover":
  velocity.x=move_toward(velocity.x,0,700*delta)
  if state_t<=0:
   state="idle";cd=0.7 if kind not in [13,14] else 1.4
   if kind==12:enterrado=true
 else:
  _decidir(distancia,delta)
 if kind==13:
  velocity.y=(home.y+sin(tempo_local*1.4)*12-global_position.y)*3.0
 else:velocity.y=minf(velocity.y+1800*delta,900)
 # Corpos terrestres usam os mesmos pisos e bordas dos inimigos existentes.
 if ledge!=null and absf(velocity.x)>1:
  ledge.position=Vector2(signf(velocity.x)*(body_size.x*0.5+20),-5)
  ledge.target_position=Vector2(0,85)
  ledge.force_raycast_update()
  if is_on_floor() and not ledge.is_colliding():velocity.x=0
 move_and_slide()
 queue_redraw()

func _decidir(distancia:float,delta:float) -> void:
 velocity.x=move_toward(velocity.x,0,800*delta)
 if kind==14 and acordado:return
 if kind==16 and pernas_caidas:return
 var alcance_alerta:=620.0 if float(player.get_meta("lanterna_ate",0.0))>Time.get_ticks_msec()/1000.0 else 440.0
 if distancia>alcance_alerta:return
 if kind==18 and not _linha_livre(player):
  state="idle"
  return
 if state not in ["windup","strike"]:facing=1 if player.global_position.x>global_position.x else -1
 var alcance:float=360 if kind in [10,13,14,17] else (220 if kind==12 else 130)
 if kind==16:alcance=160
 if cd<=0 and distancia<=alcance:
  _preparar_ataque()
 elif kind not in [12,14,17] and distancia>alcance*0.8:
  state="chase"
  var velocidade:=85.0
  if kind==10:velocidade*=1.0+(1.0-hp/max_hp)*0.6
  if kind==15:velocidade=45
  if kind==11:velocidade=65
  velocity.x=facing*velocidade
  if kind==11:
   for outro in _procissao():
    if outro!=self and (outro.global_position.x-global_position.x)*facing>0 and absf(outro.global_position.x-global_position.x)<68:
     velocity.x=0
 else:state="idle"

func _preparar_ataque() -> void:
 state="windup"
 duracao_aviso=0.9 if kind in [13,16,17] else 0.6
 if kind==11:duracao_aviso+=float(get_instance_id()%3)*0.12
 duracao_ataque=0.32
 duracao_abertura=1.2 if kind in [10,12,15,16] else 0.85
 state_t=duracao_aviso
 windup_len=duracao_aviso
 alvo_marcado=player.global_position
 attack_target=alvo_marcado
 attack_parryable=kind in [11,18] or (kind==10 and absf(player.global_position.x-global_position.x)<120)
 attack_warning="gold" if attack_parryable else "red"
 struck=false
 atingidos.clear()
 velocity.x=0
 if kind==12:enterrado=false
 _sfx("aviso_aparavel" if attack_parryable else "aviso_perigo")
 if kind==18:_revelar_pela_lanterna()

func _soltar_ataque() -> void:
 var direcao_tiro:Vector2=(alvo_marcado-Vector2(0,35)-(global_position+Vector2(facing*20,-55))).normalized()
 if kind==10 and absf(alvo_marcado.x-global_position.x)>=120:
  for angulo in [-0.13,0.0,0.13]:_disparar(0,direcao_tiro.rotated(angulo)*410,0,12)
 elif kind==13:
  cortes+=1
  var zona:=Rect2(alvo_marcado-Vector2(52,110),Vector2(104,120))
  for pessoa in get_tree().get_nodes_in_group("players"):
   if pessoa.standing() and zona.intersects(pessoa.body_rect()) and pessoa.has_method("receber_maldicao"):
    pessoa.receber_maldicao(12)
  _jogo().spawn_effect("silhueta",alvo_marcado-Vector2(0,35),facing,0.5,"golpe")
 elif kind==14:
  if acordado:return
  for indice in range(3):_disparar(2+indice%2,direcao_tiro.rotated((indice-1)*0.18)*230,0,8)
 elif kind==17:
  var origem_tiro:=global_position+Vector2(0,-55)
  var destino:=alvo_marcado-Vector2(0,25)
  var velocidade:Vector2=(destino-origem_tiro)/0.8-Vector2(0,480*0.8/2)
  _disparar(1,velocidade,480,13)
 else:
  var zona:=attack_bounds()
  for pessoa in get_tree().get_nodes_in_group("players"):
   if not pessoa.standing() or not zona.intersects(pessoa.body_rect()):continue
   if not _linha_livre(pessoa):continue
   pessoa.take_hit(18 if kind in [15,16] else 13,global_position.x,self,attack_parryable)

func _disparar(quadro:int,velocidade:Vector2,gravidade:float,dano:float) -> void:
 var projetil=ProjetilGoya.new()
 projetil.origem=self;projetil.sala=room_id;projetil.quadro=quadro
 projetil.velocidade=velocidade;projetil.gravidade=gravidade;projetil.dano=dano
 projetil.global_position=global_position+Vector2(facing*20,-55)
 get_parent().add_child(projetil)
 disparos+=1
 _sfx("projetil")

func _linha_livre(pessoa) -> bool:
 var consulta:=PhysicsRayQueryParameters2D.create(global_position-Vector2(0,45),pessoa.global_position-Vector2(0,35),1)
 consulta.exclude=[get_rid()]
 return get_world_2d().direct_space_state.intersect_ray(consulta).is_empty()

func _procissao() -> Array:
 var colegas:Array=[]
 for outro in get_tree().get_nodes_in_group("enemies"):
  if outro.kind==11 and not outro.dead and outro.room_id==room_id and outro.group==group:colegas.append(outro)
 return colegas

func take_hit(dano:float,de_x:float) -> void:
 if dead or executing:return
 var estado_anterior:String=state
 if kind==15:dano*=1.0-float(peregrinos-1)*0.07
 if kind==11 and (de_x-global_position.x)*facing>0:
  for colega in _procissao():
   if colega!=self and (colega.global_position.x-global_position.x)*facing>20 and absf(colega.global_position.x-global_position.x)<150:
    dano*=0.35
    _sfx("hit_metal")
    break
 if kind==13 and estado_anterior=="windup":
  state="recover";state_t=1.2
 if kind==14:
  acordado=true
  state="recover";state_t=1.4
  _limpar_projeteis()
 if kind==16 and not pernas_caidas:
  var atacante=last_hitter if is_instance_valid(last_hitter) else player
  var altura:float=global_position.y-atacante.global_position.y+40 if atacante!=null else 40
  if altura>80:dano*=0.25
  else:
   pernas_caidas=true;body_size=Vector2(75,58)
   _atualizar_colisor()
   state="recover";state_t=1.8
 if kind==17 and de_x>global_position.x and estado_anterior=="windup":
  state="recover";state_t=1.2
 var vida_antes:float=hp
 super.take_hit(dano,de_x)
 if kind==15 and hp<vida_antes:
  peregrinos=maxi(peregrinos-1,1)
  largura_visual=0.65+0.35*float(peregrinos)/6.0
  body_size.x=corpo_inicial.x*largura_visual
  _atualizar_colisor()
  _soltar_peregrino(de_x)

func parried() -> void:
 super.parried()
 if kind==11:
  for colega in _procissao():
   if colega!=self and absf(colega.global_position.x-global_position.x)<180:
    colega.state="stagger";colega.state_t=1.2;colega.velocity=Vector2.ZERO

func _soltar_peregrino(de_x:float) -> void:
 var suporte:=Node2D.new()
 suporte.position=global_position
 get_parent().add_child(suporte)
 var figura=load("res://scripts/actor_animation.gd").new()
 figura.configure("peregrino_soltado",0.4)
 var direcao:=1 if de_x<global_position.x else -1
 figura.select("run",direcao)
 suporte.add_child(figura)
 var fuga:=suporte.create_tween()
 fuga.tween_property(suporte,"position:x",global_position.x+direcao*140,1.4)
 fuga.parallel().tween_property(suporte,"modulate:a",0,0.5).set_delay(0.9)
 fuga.tween_callback(suporte.queue_free)

func _atualizar_colisor() -> void:
 for filho in get_children():
  if filho is CollisionShape2D and filho.shape is RectangleShape2D:
   filho.shape.size=body_size
   filho.position=Vector2(0,-body_size.y/2.0)

func _limpar_projeteis() -> void:
 for perigo in get_tree().get_nodes_in_group("hazards"):
  if perigo.get("origem")==self:perigo.queue_free()

func _revelar_pela_lanterna() -> void:
 for pessoa in get_tree().get_nodes_in_group("players"):
  if not pessoa.standing() or not _linha_livre(pessoa):continue
  var distancia:Vector2=pessoa.global_position-global_position
  if distancia.x*facing>0 and distancia.length()<330 and absf(distancia.y)<110:
   pessoa.set_meta("lanterna_ate",Time.get_ticks_msec()/1000.0+4.0)
   if not aviso_lanterna:
    _jogo().toast("A luz da Viúva o revelou. As criaturas próximas se aproximam.")
    aviso_lanterna=true

func attack_bounds() -> Rect2:
 var alcance:float=170 if kind in [11,15,16] else 125
 return Rect2(global_position+Vector2(0 if facing>0 else -alcance,-body_size.y),Vector2(alcance,body_size.y+8))

func hurt_rect() -> Rect2:
 if kind==12 and enterrado:return Rect2(global_position-Vector2(25,32),Vector2(50,32))
 return super.hurt_rect()

func _process(delta:float) -> void:
 if animator==null:return
 var jogo=_jogo()
 visible=_mesma_sala(jogo)
 if not visible:return
 spawn_opacity=minf(spawn_opacity+delta/0.45,1)
 if dead and jogo!=null and not jogo.narrative.mode.is_empty():
  fade=maxf(fade-delta*1.4,0)
  if fade<=0:queue_free()
 animator.modulate=Color.WHITE.lerp(Color(1.5,1.1,1.0),0.6) if flash>0 else tint
 animator.modulate.a=spawn_opacity*fade
 if animator.has_method("clarao"): animator.clarao(flash/0.12*0.85 if not dead else 0.0)
 var progresso:=0.0
 var clipe:="idle"
 if executing:clipe="executed";progresso=execution_progress
 elif dead:clipe="death";progresso=clampf(death_age/0.65,0,0.999)
 elif state=="stagger":clipe="stagger";progresso=0.5
 elif state=="launched":clipe="launched";progresso=clampf(launch_elapsed/0.6,0,0.999)
 elif state=="knockdown":clipe="launched";progresso=0.999
 elif state=="hurt":clipe="hurt";progresso=clampf(1-state_t/0.3,0,0.999)
 elif kind==16 and pernas_caidas:clipe="recover";progresso=0.999
 elif state=="windup":clipe="emergir" if kind==12 else "attack";progresso=clampf(1-state_t/duracao_aviso,0,0.999)*(1.0 if kind==12 else 0.5)
 elif state=="strike":clipe="attack";progresso=0.5+clampf(1-state_t/duracao_ataque,0,0.999)*0.499
 elif state=="recover":clipe="recover";progresso=clampf(1-state_t/duracao_abertura,0,0.999)
 elif state=="chase":clipe="walk";progresso=-1
 else:progresso=-1
 if kind==14 and acordado and state=="idle":clipe="recover";progresso=0.5
 animator.select(clipe,facing,progresso)
 animator.scale=escala_visual()
 queue_redraw()

func _draw() -> void:
 super._draw()
 if dead or executing:return
 if state=="windup":
  var cor:=Color("e7c17b") if attack_parryable else Color("b92d42")
  if kind in [13,17]:
   draw_arc(alvo_marcado-global_position-Vector2(0,5),42,PI,TAU,28,cor,2)
  if kind==13:draw_line(Vector2(facing*35,-65),alvo_marcado-global_position-Vector2(0,40),Color(0.95,0.87,0.67,0.65),2)
 if kind==18 and state=="windup":
  draw_colored_polygon(PackedVector2Array([Vector2(facing*20,-55),Vector2(facing*300,-130),Vector2(facing*300,10)]),Color(0.8,0.66,0.34,0.09))
