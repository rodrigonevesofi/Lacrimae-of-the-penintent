extends SceneTree
## Comportamento dos efeitos: dissolve, arma, luz, peso e cenário móvel.
var game
var checks:=0
var failures:=0
func _initialize() -> void:call_deferred("run")
func expect(ok:bool,label:String) -> void:
 checks+=1
 print("PASS: " if ok else "FAIL: ",label)
 if not ok:failures+=1
func frames(count:int) -> void:
 for i in range(count):
  await physics_frame
  await process_frame
func run() -> void:
 game=load("res://scenes/main.tscn").instantiate()
 root.add_child(game)
 game._start_game(false,false)
 for i in range(3):game.message_t=0;game.advance_message()
 game.exploration.arenas_enabled=false
 await frames(3)
 for e in get_nodes_in_group("enemies"):
  if e!=game.final_boss and e!=game.boss:e.queue_free()
 await frames(2)
 var p=game.player
 p.revive(Vector2(900,600));p.has_weapon=true;p.set_physics_process(false)
 var v=p.get_node("CombatVisuals")
 for character in ["penitente","beatriz"]:
  p.character=character;p.apply_character();p.state="attack";p.attack_len=0.32
  for i in range(5):p.state_t=0.32*(0.64-i*0.03);v._process(0.016)
  expect(v.trail.points.size()>=2 and v.trail.visible,character+": rastro Line2D acompanha janela ativa")
 p.counter_attack=true;v._process(0.01)
 expect(v.trail.default_color.is_equal_approx(Color("e7c17b")),"contra-ataque usa rastro dourado")
 p.counter_attack=false;p.finisher=true;v._process(0.01)
 expect(v.trail.default_color.is_equal_approx(Color("b92d42")),"arremate usa rastro vermelho")
 p.state="idle";v._process(0.2)
 expect(not v.trail.visible,"rastro desaparece após a janela, sem trilha permanente")
 p.state="parry";p.parry_hit=true;game.reduced_pulses=false;v._process(0.01)
 expect(v.glint is PointLight2D and v.glint.energy>0,"aparo acende luz suave")
 game.reduced_pulses=true;v._process(0.01)
 expect(v.glint.energy==0,"reduzir pulsos desativa clarão do aparo")
 p.impact_direction=Vector2.ZERO;p.take_hit(2,p.position.x-30,null,false)
 expect(p.impact_direction.x>0,"impacto vindo da esquerda define tremor para a direita")
 game.reduced_pulses=false
 var e=game.new_enemy(0);e.setup(0,Vector2(1200,600),0,p);game.add_child(e)
 e.set_physics_process(false);e.state="idle";e.velocity=Vector2.ZERO
 var ev=e.get_node("CombatVisuals")
 ev._process(0.01)
 expect(ev.breathing!=null and ev.breathing.is_valid(),"criatura parada respira com Tween")
 e._die();e.death_age=0.9;e._process(0);ev._process(0.01)
 expect(e.animator.material is ShaderMaterial and ev.death_material.get_shader_parameter("progress")>0.4,"morte dissolve a criatura de baixo para cima")
 p.character="penitente";p.apply_character();p.state="idle";p.state_t=0;p.finisher=false;p.parry_hit=false
 p.set_physics_process(true)
 game.enter_vale()
 for i in range(120):
  await frames(1)
  if not game.exploration.is_transitioning():break
 var boss=game.final_boss
 boss.set_physics_process(false)
 boss._wear("true")
 for stage in range(5):
  boss.stage=stage;boss._wear("true")
  expect(boss.animator.actor=="flagelado_%d"%stage,"placa %d seleciona a folha correta"%stage)
 boss.stage=0;boss._wear("true");boss._wear("mirror")
 var bv=boss.get_node("CombatVisuals");bv._process(0.01);boss._process(0)
 expect(bv.transition_t>0 and boss.animator.material is ShaderMaterial,"troca de forma dissolve a anterior e recompõe a nova")
 expect(bv.transition_material.get_shader_parameter("sombra_transformacao")!=null,"dissolução usa a máscara pintada de transformação")
 bv._process(0.7)
 expect(boss.animator.material==bv.original_material,"material original retorna ao terminar a transformação")
 boss._drop_guilt(boss.global_position)
 var drop=get_nodes_in_group("guilt_drops").back()
 expect(drop.get_child(0).actor=="gota_culpa","gota usa seu atlas pintado")
 boss._collect_drop(drop)
 expect(not drop.is_in_group("guilt_drops") and drop.get_child(0).animation=="collect","coleta retira a gota da lógica e toca o quadro de recolher")
 var angle:float=game.vale_back.hanged[0].vel
 game.vale_back.impulse(game.vale_back.hanged[0].x,2.0)
 expect(game.vale_back.hanged[0].vel!=angle,"impulso preserva a física das peças penduradas")
 game.vale_back.set_mood(1);game.vale_back._process(1)
 expect(game.vale_back.mood>0 and game.vale_back.ash==null and game.vale_front.ash.amount==90,"humor escurece o vale sem reduzir cinzas existentes")
 var finale=load("res://scripts/vale_finale.gd").new()
 expect(finale.weights(10).helmet>0.9 and finale.weights(10).hands<0.05,"revelação: primeiro o elmo-gaiola")
 expect(finale.weights(14).hands>0.9 and finale.weights(14).face<0.05,"revelação: depois as mãos e o capirote")
 expect(finale.weights(18).face>0.9 and finale.weights(18).hands<0.05,"revelação: por último os dois rostos")
 finale.free()
 game._delete_save();game.queue_free();game=null
 await frames(4)
 print("V38_EFFECTS: %d checks, %d failures"%[checks,failures])
 quit(0 if failures==0 else 1)
