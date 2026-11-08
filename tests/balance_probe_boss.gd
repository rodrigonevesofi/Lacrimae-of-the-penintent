extends SceneTree
const Actor=preload("res://tests/boss_probe_actor.gd")
const Player=preload("res://tests/boss_probe_player.gd")
var game
var p
var boss
var rng=RandomNumberGenerator.new()
var rows=[]
func _initialize():call_deferred("run")
func frames(n: int):
	for i in range(n):await physics_frame;await process_frame
func release():
	for action in ["left","right","attack","roll","jump","heal"]:Input.action_release(action)
func trial(number: int):
	release()
	for e in get_nodes_in_group("enemies")+get_nodes_in_group("hazards"):e.queue_free()
	await frames(3)
	rng.seed=1700+number;seed(1700+number)
	game.state="play";game.message_text="";game.prologue_page=-1;game.stain_active=false
	game.narrative.mode="";game.exploration.room="city";game.exploration.map_open=false
	p.received=0.0
	p.hits={"1":{"slam":0,"wave":0,"rain":0,"spikes":0,"unknown":0},"2":{"slam":0,"wave":0,"rain":0,"spikes":0,"unknown":0}}
	p.damage_by_phase={"1":0.0,"2":0.0}
	p.revive(Vector2(4050,600));p.has_weapon=true;p.hp=100;p.max_hp=100;p.flasks=3;p.penitence="none";p.culpa=0
	boss=Actor.new();boss.setup(2,Vector2(4380,600),0,p);boss.announced=true
	boss.display_name="Guardião dos Sinos";game.add_child(boss);game.boss=boss;p.boss=boss
	boss.awaken()
	var elapsed=0.0;var next_attack=.3;var next_heal=0.0;var pending=-1.0
	var old_state="";var reactions=0;var errors=0;var roll_commands=0
	var phase_seconds={"1":0.0,"2":0.0}
	while elapsed<120 and p.hp>0 and p.state!="dead" and not boss.dead:
		var dx: float=boss.position.x-p.position.x
		phase_seconds[str(boss.phase)]+=1.0/60
		if boss.state in ["slam_wind","rain","spike_cast"] and boss.state!=old_state:
			reactions+=1
			if rng.randf()<.1:errors+=1
			else:pending=elapsed+rng.randf_range(.180,.260)
		old_state=boss.state
		var retreat: bool=p.hp<40 and p.flasks>0
		var move=0
		if absf(dx)>75 or retreat:move=(1 if dx>0 else -1)*(-1 if retreat else 1)
		# Arena walls are real collision limits; turn inward instead of running out of bounds.
		if p.position.x<3835 and move<0:move=1
		if p.position.x>4745 and move>0:move=-1
		if move!=0:Input.action_press("right" if move>0 else "left")
		if pending>=0 and elapsed>=pending:
			Input.action_press("roll");roll_commands+=1;pending=-1
		elif retreat and elapsed>=next_heal and p.state=="idle":
			Input.action_press("heal");next_heal=elapsed+1.1
		elif p.state=="idle" and absf(dx)<110 and elapsed>=next_attack:
			# Face the boss even if the last movement was a retreat.
			p.facing=1 if dx>0 else -1
			Input.action_press("attack");next_attack=elapsed+rng.randf_range(.5,.85)
		await frames(1);release();elapsed+=1.0/60
	var dead: bool=p.hp<=0 or p.state=="dead"
	var outcome="morte" if dead else ("venceu" if boss.dead else "limite")
	rows.append({"seed":1700+number,"seconds":snappedf(elapsed,.01),"damage":p.received,"deaths":int(dead),"heals":3-p.flasks,"hits":p.hits.duplicate(true),"damage_by_phase":p.damage_by_phase.duplicate(true),"phase_seconds":phase_seconds,"emitted":boss.emitted.duplicate(true),"reaction_opportunities":reactions,"missed_reactions":errors,"roll_commands":roll_commands,"boss_hp":boss.hp,"outcome":outcome})
	print("BOSS_TRIAL ",number+1,"/10 ",outcome," ",elapsed)
func report():
	FileAccess.open("res://docs/equilibrio-chefe.json",FileAccess.WRITE).store_string(JSON.stringify(rows,"  "))
	var text="# Guardião dos Sinos — primeira sonda com atraso de reação\n\nO chefe não havia sido medido por esta sonda antes desta entrega. A gravação do autor e a estimativa de duração relatada pelo Claude não são uma medição equivalente. Base v17 recebida:450HP, duas fases, arena Cidade x3800–4780. Nenhum valor do jogo foi alterado. Subclasses de teste só observam ataques e dano e chamam os métodos originais.\n\nDez sementes1700–1709;100HP, espada básica, três frascos, sem penitência/salto duplo/execução. Reação programada180–260ms a novo estado de preparação,10% de erro Bernoulli por oportunidade; não significa10% de dano obrigatório. Animação, recarga e invulnerabilidade podem impedir ou atrasar a esquiva. Ataca a cada0,50–0,85s quando livre e próximo; abaixo de40HP recua e tenta curar. Não prevê trajetórias nem planeja saltos. Limite120s por tentativa; sem renascer na mesma semente.\n\n| Semente | Tempo s | Dano acumulado | Mortes | Curas | HP chefe final | Resultado |\n|---|---:|---:|---:|---:|---:|---|\n"
	for r in rows:text+="| %d | %.2f | %.1f | %d | %d | %.1f | %s |\n"%[r.seed,r.seconds,r.damage,r.deaths,r.heals,r.boss_hp,r.outcome]
	text+="\n## Acertos que retiraram HP, por ataque e fase de emissão\n\n| Semente | Fase | Pancada | Onda | Chuva | Espinhos | Não atribuído | Dano | Tempo na fase s |\n|---|---:|---:|---:|---:|---:|---:|---:|---:|\n"
	for r in rows:
		for phase in ["1","2"]:
			var h=r.hits[phase]
			text+="| %d | %s | %d | %d | %d | %d | %d | %.1f | %.2f |\n"%[r.seed,phase,h.slam,h.wave,h.rain,h.spikes,h.unknown,r.damage_by_phase[phase],r.phase_seconds[phase]]
	text+="\nProjéteis e espinhos recebem metadados somente na subclasse observadora, indicando a fase em que foram criados; uma onda antiga não muda de fase só por atingir depois da transição. A pancada direta usa a fase corrente. A contagem registra perda real de HP, incluindo dano depois curado; ataques recusados pela invulnerabilidade não contam. Emissões e oportunidades/erros estão no JSON. Fase não alcançada não significa fase segura.\n\nEsta é simulação de política simples, não um jogador humano. Tempo rápido pode vir de política agressiva; limite pode vir de navegação ruim. Não demonstra diversão, dificuldade ideal, impacto, fluidez nem equivalência a Blasphemous. O Claude deve comparar com a reconstrução futura usando esta mesma base de teste, sem tratar resultados como meta automática de90–120s. É necessário jogar, ouvir e recolher relatos.\n\nRepetir: `XDG_DATA_HOME=/tmp/lacrimae-boss-v17/data XDG_CONFIG_HOME=/tmp/lacrimae-boss-v17/config XDG_CACHE_HOME=/tmp/lacrimae-boss-v17/cache godot --headless --fixed-fps 60 --path . --script res://tests/balance_probe_boss.gd`.\n"
	FileAccess.open("res://docs/equilibrio-chefe.md",FileAccess.WRITE).store_string(text)
func run():
	if not OS.get_environment("XDG_DATA_HOME").begins_with("/tmp/lacrimae-boss-"):
		push_error("Use disposable XDG_DATA_HOME=/tmp/lacrimae-boss-<run>/data");quit(3);return
	game=load("res://scenes/main.tscn").instantiate();root.add_child(game)
	game._start_game(false,false);game.message_text="";game.prologue_page=-1
	game.set_process(false);game.set_physics_process(false);game.narrative.set_process(false)
	game.soundscape.muted=true;game.soundscape.set_process(false)
	game.soundscape.ambience.stop();game.soundscape.incoming.stop();game.soundscape.guilt_layer.stop()
	for voice in game.soundscape.effects.values():voice.stop()
	var original=game.player
	p=Player.new();game.add_child(p);game.player=p;original.queue_free()
	await frames(3)
	for i in range(10):await trial(i)
	release();report();game._delete_save();game.queue_free();game=null;p=null;boss=null
	await frames(8);print("BOSS_PROBE: 10 trials; simulation only");quit()
