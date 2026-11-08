extends SceneTree
const Layout=preload("res://scripts/act_one_layout.gd")
const ProbePlayer=preload("res://tests/balance_probe_player.gd")
const LIMIT=60.0
var game
var p
var rows: Array=[]
var rng=RandomNumberGenerator.new()
func _initialize():call_deferred("run")
func frames(n: int):
	for i in range(n):await physics_frame;await process_frame
func release():
	for action in ["left","right","attack","roll","jump","heal"]:Input.action_release(action)
func clear():
	for e in get_nodes_in_group("enemies")+get_nodes_in_group("hazards"):e.queue_free()
	await frames(3)
func scenarios() -> Array:
	var all=Layout.enemies()
	var result=[]
	for entry in [["aquelarre","archive",5],["duelistas","ossuary",7],["devorador","belfry",3],["flagelante_solo","refuge",4],["flagelantes_claustro","cloister",4],["asmodeia_controle","nave",6]]:
		var selected=[]
		for d in all:
			if d[0]==entry[1] and d[1]==entry[2]:selected.append(d)
		result.append({"name":entry[0],"room":entry[1],"defs":selected})
	return result
func trial(scenario: Dictionary,number: int):
	await clear()
	release()
	rng.seed=1000+number
	seed(1000+number)
	game.state="play"
	game.narrative.mode=""
	game.message_text=""
	game.toast_t=0
	game.stain_active=false
	game.exploration.room=scenario.room
	game.exploration.map_open=false
	var definitions: Array=scenario.defs
	if definitions.is_empty():push_error("Missing real encounter: "+scenario.name);quit(2);return
	var first=definitions[0]
	var spawn_y: float=540 if scenario.name=="devorador" else 600
	p.revive(Vector2(first[2]-(160 if scenario.name=="devorador" else 260),spawn_y))
	p.max_hp=100;p.hp=100;p.flasks=3;p.penitence="none";p.has_weapon=true;p.has_double_jump=false;p.invuln=0;p.roll_cd=0;p.culpa=0
	p.received=0
	for key in p.hits:p.hits[key]=0
	var enemies=[]
	for d in definitions:
		var e=game.EnemyScript.new()
		e.setup(d[1],Vector2(d[2],d[3]),d[4],p)
		e.room_id=d[0]
		e.group=d[5] if d.size()>5 else -1
		e.announced=true
		game.add_child(e)
		e.set_physics_process(false)
		enemies.append(e)
	p.set_physics_process(false)
	await frames(40)
	p.set_physics_process(true)
	for e in enemies:e.set_physics_process(true)
	var begin=Engine.get_physics_frames()
	var elapsed=0.0
	var next_attack=.3
	var next_heal=0.0
	var next_jump=0.0
	var pending=-1.0
	var errors=0
	var reactions=0
	var old_states={}
	var fell=false
	while elapsed<LIMIT and p.hp>0 and p.state!="dead":
		var alive=[]
		for e in enemies:
			if is_instance_valid(e) and not e.dead:alive.append(e)
		if alive.is_empty():break
		var target=alive[0]
		for e in alive:
			if p.position.distance_to(e.position)<p.position.distance_to(target.position):target=e
		var dx: float=target.position.x-p.position.x
		var dy: float=target.position.y-p.position.y
		for e in alive:
			var id=e.get_instance_id()
			if e.state=="windup" and old_states.get(id,"")!="windup" and p.position.distance_to(e.position)<650:
				reactions+=1
				if rng.randf()<.1:errors+=1
				else:
					var scheduled=elapsed+rng.randf_range(.180,.260)
					pending=scheduled if pending<0 else minf(pending,scheduled)
			old_states[id]=e.state
		var retreat: bool=p.hp<40
		if absf(dx)>65 or retreat:Input.action_press("right" if (dx>0)!=retreat else "left")
		if pending>=0 and elapsed>=pending:
			Input.action_press("roll")
			pending=-1
		elif retreat and p.flasks>0 and elapsed>=next_heal and p.state=="idle":
			Input.action_press("heal");next_heal=elapsed+1.1
		elif p.state=="idle" and elapsed>=next_attack and absf(dx)<100 and absf(dy)<120:
			Input.action_press("attack");next_attack=elapsed+rng.randf_range(.5,.85)
		if p.is_on_floor() and elapsed>=next_jump and ((dy< -65 and absf(dx)<220) or p.is_on_wall()):
			Input.action_press("jump");next_jump=elapsed+.7
		await frames(1)
		release()
		elapsed=float(Engine.get_physics_frames()-begin)/Engine.physics_ticks_per_second
		if p.position.y>game.exploration.rooms[scenario.room].bounds.end.y:
			fell=true;break
	var dead: bool=p.hp<=0 or p.state=="dead" or fell
	var remaining=0
	for e in enemies:
		if is_instance_valid(e) and not e.dead:remaining+=1
	var outcome="queda" if fell else ("morte" if dead else ("venceu" if remaining==0 else "limite"))
	rows.append({"encounter":scenario.name,"seed":1000+number,"seconds":snappedf(elapsed,.01),"damage":p.received,"deaths":int(dead),"hits":p.hits.duplicate(),"heals":3-p.flasks,"reactions":reactions,"errors":errors,"remaining":remaining,"outcome":outcome,"end_position":[p.position.x,p.position.y]})
	print("HUMAN_TRIAL ",rows.size(),"/60 ",scenario.name," ",number," ",outcome," ",elapsed)
func report():
	var file=FileAccess.open("res://docs/equilibrio-humano.json",FileAccess.WRITE)
	file.store_string(JSON.stringify(rows,"  "));file.close()
	var text="# Sonda com atraso de reação\n\nSimulação, não substitui jogadores nem comprova equilíbrio.60encontros: cinco cenários pedidos de Layout.enemies() e um controle adicional da Asmodeia para observar estilhaços, dez sementes(1000–1009) cada. IA, posições, grupos, colisões, dano e curas originais.100HP, espada básica, três frascos; sem penitências, execução ou salto duplo. Ataques espaçados aleatoriamente0,50–0,85s; reação programada180–260ms após nova preparação visível, erro Bernoulli10%. Travamento de animação e disponibilidade da esquiva podem atrasar ou impedir o comando; a faixa programada não garante o instante de evasão. Abaixo de40HP recua e tenta curar. Salta por alvos altos e obstáculos; não planeja caminhos. Limite60s.\n\nO par de Flagelantes está nas posições originais do Claustro, separadas1680unidades: encontro sequencial, não dupla simultânea inventada. O Devorador usa sua galeria do Campanário; jogador160unidades à esquerda, dentro da plataforma. Os demais começam260unidades à esquerda do primeiro alvo. Aquelarre e duelistas preservam os grupos da lista. Outros inimigos são removidos para isolar cada encontro; isso difere de uma partida completa.\n\nDano recebido é cumulativo, incluindo o que foi depois curado. Contagens de acerto observam quedas reais deHP em take_hit: projéteis por gravidade/tipo de dano e corpo a corpo por origem/estado. Acertos bloqueados por invulnerabilidade não contam. Eventos simultâneos podem ter atribuição ambígua; não há alteração do código de combate. Queda fora da sala conta como morte, sem inventar dano.\n\n| Encontro | Semente | Tempo s | Dano | Mortes | Bote | Investida | Estilhaços | Leque | Outros | Curas | Resultado |\n|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---|\n"
	for r in rows:
		text+="| %s | %d | %.2f | %.1f | %d | %d | %d | %d | %d | %d | %d | %s |\n"%[r.encounter,r.seed,r.seconds,r.damage,r.deaths,r.hits.bote,r.hits.investida,r.hits.estilhacos,r.hits.leque_lagrimas,r.hits.outros,r.heals,r.outcome]
	text+="\n## Achados da simulação\n\n"
	for name in ["aquelarre","duelistas","devorador","flagelante_solo","flagelantes_claustro","asmodeia_controle"]:
		var deaths=0;var wins=0;var timeouts=0;var damage=0.0
		for r in rows:
			if r.encounter==name:
				deaths+=r.deaths;wins+=int(r.outcome=="venceu");timeouts+=int(r.outcome=="limite");damage+=r.damage
		text+="- %s: %dvitórias, %dmortes, %dlimites; dano médio%.1f.\n"%[name,wins,deaths,timeouts,damage/10]
	text+="\nLimites: navegação rudimentar pode dominar o resultado; limites de tempo não significam equilíbrio, e zero acertos não prova segurança. Asmodeia/estilhaços foram observados num sexto encontro de controle, isolando a Asmodeia da Nave em sua posição original. Dados e contagens de preparação/erros em equilibrio-humano.json.\n\nRepetir: `XDG_DATA_HOME=/tmp/lacrimae-human-data XDG_CONFIG_HOME=/tmp/lacrimae-human-config XDG_CACHE_HOME=/tmp/lacrimae-human-cache godot --headless --fixed-fps 60 --path . --script res://tests/balance_probe_human.gd`. A sonda exige dados descartáveis e grava o relatório.\n"
	FileAccess.open("res://docs/equilibrio-humano.md",FileAccess.WRITE).store_string(text)
func run():
	if OS.get_environment("XDG_DATA_HOME").is_empty():push_error("Use a disposable XDG_DATA_HOME");quit(2);return
	game=load("res://scenes/main.tscn").instantiate();root.add_child(game)
	game._start_game(false,false)
	game.message_text="";game.prologue_page=-1
	game.set_process(false);game.set_physics_process(false)
	game.soundscape.muted=true;game.soundscape.set_process(false)
	game.soundscape.ambience.stop();game.soundscape.incoming.stop();game.soundscape.guilt_layer.stop()
	for voice in game.soundscape.effects.values():voice.stop()
	var old=game.player
	p=ProbePlayer.new();game.add_child(p);game.player=p;old.queue_free()
	await frames(3)
	var only="devorador" if "--only-devorador" in OS.get_cmdline_user_args() else ("asmodeia_controle" if "--only-asmodeia" in OS.get_cmdline_user_args() else "")
	if only!="":
		rows=JSON.parse_string(FileAccess.get_file_as_string("res://docs/equilibrio-humano.json"))
		rows=rows.filter(func(r):return r.encounter!=only)
	for scenario in scenarios():
		if only!="" and scenario.name!=only:continue
		for i in range(10):await trial(scenario,i)
	release();report();game._delete_save();game.queue_free();game=null;p=null
	await frames(10)
	await create_timer(.2).timeout
	print("HUMAN_PROBE: ",rows.size()," encounters")
	quit()
