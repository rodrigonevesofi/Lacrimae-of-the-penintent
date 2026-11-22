extends SceneTree
## Comportamentos, contrapontos, dupla e persistência das criaturas aprovadas.
var jogo
var pessoa
var verificacoes:=0
var falhas:=0
func _initialize() -> void:call_deferred("executar")
func conferir(condicao:bool,rotulo:String) -> void:
 verificacoes+=1
 print("PASS: " if condicao else "FAIL: ",rotulo)
 if not condicao:falhas+=1
func quadros(quantidade:int) -> void:
 for indice in range(quantidade):
  await physics_frame
  await process_frame
func criar(tipo:int,x:float=1400,y:float=600):
 var criatura=jogo.new_enemy(tipo, jogo.CriaturaGoyaScript)
 criatura.setup(tipo,Vector2(x,y),70,pessoa)
 criatura.room_id=jogo.exploration.room
 jogo.add_child(criatura)
 criatura.spawn_opacity=1
 criatura.set_physics_process(false)
 criatura.set_process(false)
 criatura.announced=true
 return criatura
func limpar() -> void:
 for perigo in get_nodes_in_group("hazards"):perigo.queue_free()
 for inimigo in get_nodes_in_group("enemies"):inimigo.queue_free()
func executar() -> void:
 jogo=load("res://scenes/main.tscn").instantiate();root.add_child(jogo)
 jogo._start_game(false,false)
 for indice in range(3):jogo.message_t=0;jogo.advance_message()
 jogo.narrative.finish();jogo.message_text=""
 jogo.exploration.arenas_enabled=false
 pessoa=jogo.player;pessoa.has_weapon=true;pessoa.set_physics_process(false)
 await quadros(3)
 var vistos:={}
 # Cada encontro terrestre assenta no piso real; a única forma aérea permanece acessível.
 for inimigo in get_nodes_in_group("enemies"):
  if inimigo.kind>=10:
   vistos[inimigo.kind]=true
   inimigo.set_physics_process(false)
   inimigo.announced=true
 for inimigo in get_nodes_in_group("enemies"):
  if inimigo.kind<10:inimigo.set_physics_process(false)
 for inimigo in get_nodes_in_group("enemies"):
  if inimigo.kind<10:continue
  jogo.exploration.room=inimigo.room_id
  var limites:Rect2=jogo.exploration.rooms[inimigo.room_id].bounds
  var lado:float=-700 if inimigo.position.x-limites.position.x>800 else 700
  pessoa.position=inimigo.position+Vector2(lado,0)
  inimigo.cd=100;inimigo.spawn_opacity=1;inimigo.set_physics_process(true)
  await quadros(20)
  conferir(inimigo.is_on_floor() if inimigo.kind!=13 else absf(inimigo.position.y-inimigo.home.y)<20,"apoio físico: "+inimigo.display_name)
  conferir(absf(inimigo.position.y-inimigo.home.y)<8 if inimigo.kind!=13 else inimigo.position.y>450,"altura inicial compatível: "+inimigo.display_name)
  inimigo.set_physics_process(false)
 conferir(vistos.size()==9,"as nove espécies existem no mapa normal")
 limpar();await quadros(3)
 jogo.exploration.room="city";pessoa.position=Vector2(1650,600)
 var glutao=criar(10)
 glutao.facing=1;glutao._preparar_ataque()
 conferir(glutao.state=="windup" and not glutao.attack_parryable,"colheres têm aviso vermelho")
 glutao._soltar_ataque()
 conferir(glutao.disparos==3,"Glutão lança três colheres")
 pessoa.position.x=1470;glutao._preparar_ataque()
 conferir(glutao.attack_parryable,"palmada próxima permite aparo")
 glutao.cd=10;pessoa.position.x=1800;glutao.hp=glutao.max_hp;glutao._decidir(400,1.0)
 var velocidade_cheia:float=absf(glutao.velocity.x)
 glutao.hp=glutao.max_hp*0.2;glutao._decidir(400,1.0)
 conferir(absf(glutao.velocity.x)>velocidade_cheia,"Glutão fica mais veloz ferido")
 for perigo in get_nodes_in_group("hazards"):perigo.queue_free()
 await quadros(2)
 pessoa.position=Vector2(1650,600);pessoa.hp=pessoa.max_hp;pessoa.invuln=0
 glutao._preparar_ataque();glutao._soltar_ataque()
 await quadros(42)
 conferir(pessoa.hp<pessoa.max_hp,"colheres realmente alcançam o corpo na trajetória anunciada")
 var primeiro=criar(11,1450);var segundo=criar(11,1380)
 primeiro.group=123;segundo.group=123;primeiro.facing=1;segundo.facing=1
 var vida:float=segundo.hp;segundo.take_hit(20,1550)
 conferir(is_equal_approx(vida-segundo.hp,7),"primeiro disciplinante protege quem vem atrás")
 primeiro.parried()
 conferir(segundo.state=="stagger" and segundo.state_t>=1.2,"aparo quebra a formação próxima")
 var enterrado=criar(12)
 conferir(enterrado.hurt_rect().size.y==32,"Meio-Enterrado começa com o corpo sob a terra")
 enterrado._preparar_ataque()
 conferir(not enterrado.enterrado and enterrado.state_t>=0.6,"Meio-Enterrado emerge antes do bote")
 var parcas=criar(13)
 pessoa.position=Vector2(1460,600);pessoa.dev_god=false;pessoa.invuln=0;pessoa.state="idle"
 var capacidade:float=pessoa.max_hp
 parcas.facing=1;parcas._preparar_ataque();parcas._soltar_ataque()
 conferir(pessoa.maldicao_parcas==12 and pessoa.max_hp==capacidade-12,"corte reduz vida máxima")
 pessoa.state="roll";parcas._soltar_ataque()
 conferir(pessoa.maldicao_parcas==12,"rolamento evita novo corte")
 pessoa.state="idle";pessoa.remover_maldicao()
 conferir(pessoa.max_hp==capacidade,"oração restaura a capacidade perdida")
 parcas._preparar_ataque();parcas.take_hit(5,1300)
 conferir(parcas.state!="windup","golpe interrompe o fio das Parcas")
 var sono=criar(14)
 sono._preparar_ataque();sono._soltar_ataque()
 conferir(sono.disparos==3,"Sono produz enxame enquanto dorme")
 sono.take_hit(4,1300)
 await quadros(2)
 var aves:=0
 for perigo in get_nodes_in_group("hazards"):
  if perigo.get("origem")==sono:aves+=1
 conferir(sono.acordado and aves==0,"acordar desfaz o enxame existente")
 var tiros_antes:int=sono.disparos;sono._soltar_ataque()
 conferir(sono.disparos==tiros_antes,"Sono acordado deixa de produzir aves")
 var romaria=criar(15)
 var largura:float=romaria.body_size.x
 vida=romaria.hp;romaria.take_hit(5,1300)
 var dano_inicial:float=vida-romaria.hp
 conferir(romaria.peregrinos==5 and romaria.body_size.x<largura,"golpe dispersa um peregrino e estreita o corpo")
 for filho in romaria.get_children():
  if filho is CollisionShape2D:conferir(filho.shape.size==romaria.body_size,"colisor acompanha a massa da Romaria")
 vida=romaria.hp;romaria.take_hit(5,1300)
 conferir(vida-romaria.hp>dano_inicial,"dispersar a Romaria também enfraquece sua proteção")
 var espantalho=criar(16)
 pessoa.position.y=600;espantalho.last_hitter=pessoa;espantalho.take_hit(5,1300)
 conferir(espantalho.pernas_caidas and espantalho.body_size.y==58,"golpe baixo derruba pernas de pau")
 espantalho._decidir(30,1)
 conferir(espantalho.velocity.x==0,"operador exposto perde a perseguição alta")
 var velhos=criar(17)
 velhos._preparar_ataque();velhos._soltar_ataque()
 conferir(velhos.disparos==1,"Dois Velhos arremessam tigela")
 velhos._preparar_ataque();velhos.take_hit(5,1500)
 conferir(velhos.state!="windup","golpear o apontador interrompe o aviso")
 var viuva=criar(18)
 viuva.facing=1;pessoa.position=Vector2(1530,600);viuva._revelar_pela_lanterna()
 conferir(float(pessoa.get_meta("lanterna_ate",0.0))>Time.get_ticks_msec()/1000.0,"facho revela a posição por tempo limitado")
 # Parede entre a lanterna e o alvo: não há visão nem marcação através de pedra.
 pessoa.set_meta("lanterna_ate",0.0)
 var parede:=StaticBody2D.new();parede.collision_layer=1
 var colisao:=CollisionShape2D.new();var forma:=RectangleShape2D.new();forma.size=Vector2(20,200)
 colisao.shape=forma;parede.add_child(colisao);parede.position=Vector2(1460,530);jogo.add_child(parede)
 await quadros(2);viuva._revelar_pela_lanterna()
 conferir(float(pessoa.get_meta("lanterna_ate",0.0))==0,"parede bloqueia o facho")
 var projetil=jogo.CriaturaGoyaScript.ProjetilGoya.new()
 projetil.sala="city";projetil.position=Vector2(1425,545);projetil.velocidade=Vector2(410,0);jogo.add_child(projetil)
 pessoa.invuln=0;pessoa.hp=pessoa.max_hp
 await quadros(20)
 conferir(not is_instance_valid(projetil) and pessoa.hp==pessoa.max_hp,"parede detém a colher antes de atingir o jogador")
 parede.queue_free()
 jogo.enable_duo(true);await quadros(2)
 jogo.partner.set_physics_process(false);jogo.partner.ai=false
 jogo.partner.invuln=0;jogo.partner.state="idle";jogo.partner.receber_maldicao(24)
 pessoa.invuln=0;pessoa.state="idle";pessoa.receber_maldicao(12)
 jogo._save()
 pessoa.remover_maldicao();pessoa.maldicao_parceira=0
 jogo._load()
 conferir(pessoa.maldicao_parcas==12 and pessoa.maldicao_parceira==24,"salvamento mantém a maldição de ambos")
 jogo.pending_altar=0;jogo.complete_prayer()
 conferir(pessoa.maldicao_parcas==0 and jogo.partner.maldicao_parcas==0,"descanso purifica os dois integrantes")
 limpar();jogo.enable_duo(false);await quadros(3)
 jogo.exploration.room="city";jogo.narrative.finish();jogo.message_text=""
 for tipo in range(10,19):
  pessoa.revive(Vector2(900,600));pessoa.has_weapon=true;pessoa.set_physics_process(true)
  await quadros(3)
  var vitima=criar(tipo,950)
  vitima.state="stagger";vitima.state_t=2
  var inicio:bool=pessoa.begin_execution(vitima)
  var ferimento:=false;var golpe_final:=false
  for indice in range(200):
   await quadros(1)
   ferimento=ferimento or pessoa.execution_wound
   golpe_final=golpe_final or pessoa.execution_contact
   if pessoa.state!="execution":break
  conferir(inicio and is_instance_valid(vitima) and vitima.dead,"execução completa da espécie %d"%tipo)
  conferir(ferimento and golpe_final and get_nodes_in_group("blood_spray").size()>0,"sangue preservado na execução da espécie %d"%tipo)
  if is_instance_valid(vitima):vitima.queue_free()
 limpar();jogo._delete_save();jogo.queue_free();jogo=null
 await quadros(5)
 print("V39_CRIATURAS: %d checks, %d failures"%[verificacoes,falhas])
 quit(0 if falhas==0 else 1)
