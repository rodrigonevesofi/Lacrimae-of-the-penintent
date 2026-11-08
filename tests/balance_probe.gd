extends SceneTree
## Isolated input-driven probe. No game source or balancing values are changed.
const Enemy = preload("res://scripts/enemy.gd")
const LIMIT := 40.0
const SEEDS := [11,23,37]
var game
var rows: Array = []
var legacy := false
func _initialize(): call_deferred("run")
func frames(n: int):
	for i in range(n):
		await physics_frame
		await process_frame
func release_inputs():
	for action in ["left","right","attack","roll","jump"]: Input.action_release(action)
func specs() -> Array:
	var enemy_script: Script = load("res://scripts/enemy.gd")
	var constants: Dictionary = enemy_script.get_script_constant_map()
	if not constants.has("TYPES"):
		legacy=true
		return [{"id":0,"name":"Devoto Corrompido"},{"id":1,"name":"Chorão"}]
	var result: Array=[]
	var types=constants.TYPES
	var keys=types.keys() if types is Dictionary else range(types.size())
	for key in keys:
		var info=types[key]
		var id=key if key is int else (info if info is int else (info.get("id",-1) if info is Dictionary else -1))
		if not id is int or id<0:
			push_error("Unsupported Enemy.TYPES entry: "+str(key))
			return []
		if id==2 or (info is Dictionary and (info.get("boss",false) or info.get("is_boss",false))): continue
		result.append({"id":id,"name":str(info.get("name",key)) if info is Dictionary else str(key)})
	return result
func clear_combat():
	for node in get_nodes_in_group("enemies")+get_nodes_in_group("hazards"): node.queue_free()
	await frames(3)
func trial(spec: Dictionary, trial_seed: int):
	await clear_combat()
	seed(trial_seed)
	release_inputs()
	game.state="play"
	game.message_text=""
	game.narrative.mode=""
	game.exploration.room="city"
	game.exploration.map_open=false
	game.player.revive(Vector2(1200,600))
	var p=game.player
	p.max_hp=100
	p.hp=100
	p.has_weapon=true
	p.has_double_jump=false
	p.penitence="none"
	p.invuln=0
	p.roll_cd=0
	p.culpa=0
	p.lagrimas=0
	var enemy=Enemy.new()
	enemy.setup(spec.id,Vector2(1480,600),150,p)
	game.add_child(enemy)
	p.set_physics_process(false)
	enemy.set_physics_process(false)
	for step in range(120):
		if enemy.spawn_opacity>=1:break
		await frames(1)
	p.set_physics_process(true)
	enemy.set_physics_process(true)
	var name: String=enemy.display_name
	var start_tick:=Engine.get_physics_frames()
	var damage:=0.0
	var hp_before:=100.0
	var successful:=0
	var attempts:=0
	var window:=0
	var roll_hp:=0.0
	var elapsed:=0.0
	var previous_state: String=p.state
	while elapsed<LIMIT and not enemy.dead and p.hp>0 and p.state!="dead":
		var dx: float=enemy.position.x-p.position.x
		var dy: float=enemy.position.y-p.position.y
		var threat: bool=("wind" in enemy.state or "cast" in enemy.state or enemy.state in ["attack","slam","strike"]) and absf(dx)<160
		if absf(dx)>55:
			Input.action_press("right" if dx>0 else "left")
		if threat and p.roll_cd<=0 and p.is_on_floor() and window==0:
			Input.action_press("roll")
		elif absf(dx)<90 and p.state not in ["roll","hurt","air_recover"]:
			if dy < -60 and p.is_on_floor(): Input.action_press("jump")
			if absf(dy)<105: Input.action_press("attack")
		await frames(1)
		release_inputs()
		damage+=maxf(0,hp_before-p.hp)
		hp_before=p.hp
		if p.state=="roll" and previous_state!="roll":
			attempts+=1
			if threat:
				window=36
				roll_hp=p.hp
		if window>0:
			window-=1
			if window==0 and p.hp>=roll_hp and p.hp>0:successful+=1
		previous_state=p.state
		elapsed=float(Engine.get_physics_frames()-start_tick)/Engine.physics_ticks_per_second
	var outcome="derrotado" if enemy.dead else ("jogador morreu" if p.hp<=0 or p.state=="dead" else "limite de tempo")
	rows.append([name,str(spec.id),str(trial_seed),"%.2f"%elapsed,"%.1f"%damage,str(successful),str(attempts),outcome])
	print("BALANCE_TRIAL: ",rows.back())
func report():
	var text="# Sonda de equilíbrio\n\nSimulação simples por entradas de controle; não prova equilíbrio com pessoas.\n\n"
	text+="Base sem Enemy.TYPES: medidos somente Devoto e Chorão. Os cinco inimigos do Claude ainda não estão disponíveis; nenhuma conclusão sobre seu equilíbrio.\n\n" if legacy else "Tipos comuns descobertos em Enemy.TYPES; chefe de id2 e entradas marcadas boss/is_boss excluídos.\n\n"
	text+="100 de vida, espada básica, sem cura, penitência, execução ou salto duplo. Três sementes por tipo; limite40s por encontro. Separação inicial280unidades; a contagem começa após a aparição visual, com ambos imóveis durante essa aparição. Persegue até55unidades, ataca abaixo de90 e esquiva ao detectar preparação próxima. Salta para alvos altos. IA, colisões e dano são os do jogo; o controlador é simplificado.\n\n"
	text+="Esquiva bem-sucedida aqui é uma aproximação: início da esquiva durante uma ameaça a menos de160unidades, seguido de0,6s sem perder vida. Não comprova que um golpe teria acertado sem a esquiva. A coluna tempo só é tempo para derrotar quando o resultado diz derrotado; nos demais casos é duração observada.\n\n"
	text+="| Inimigo | Tipo | Semente | Tempo(s) | Dano recebido | Esquivas sem dano | Esquivas iniciadas | Resultado |\n|---|---:|---:|---:|---:|---:|---:|---|\n"
	for row in rows:text+="| "+" | ".join(row)+" |\n"
	text+="\nNesta rodada o controlador venceu antes de iniciar esquivas. Os zeros não demonstram que esquivar seja desnecessário em outros encontros. As sementes não produziram variação observável neste cenário simples.\n"
	text+="\nPara repetir em Linux com salvamento isolado:\n\n```sh\nXDG_DATA_HOME=/tmp/lacrimae-balance-data XDG_CONFIG_HOME=/tmp/lacrimae-balance-config XDG_CACHE_HOME=/tmp/lacrimae-balance-cache godot --headless --fixed-fps 60 --path . --script res://tests/balance_probe.gd\n```\n\nA sonda grava apenas este relatório e o salvamento descartável do ambiente isolado. Para a v11, rodar novamente e revisar a descoberta de TYPES se a API tiver outro formato. Variação de tempo de reação, alcances, plataformas, grupos de inimigos e leitura humana não foram avaliados.\n"
	var file=FileAccess.open("res://docs/equilibrio.md",FileAccess.WRITE)
	file.store_string(text)
func run():
	if OS.get_environment("XDG_DATA_HOME").is_empty():
		push_error("Set XDG_DATA_HOME to a disposable directory before running the probe.")
		quit(2)
		return
	var entries=specs()
	if entries.is_empty(): quit(2); return
	game=load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	game._start_game(false,false)
	for i in range(10):
		if game.message_text=="":break
		game.message_t=0
		game.advance_message()
	game.soundscape.muted=true
	game.soundscape.set_process(false)
	game.soundscape.ambience.stop()
	game.soundscape.incoming.stop()
	game.soundscape.guilt_layer.stop()
	for voice in game.soundscape.effects.values():voice.stop()
	for entry in entries:
		for trial_seed in SEEDS:await trial(entry,trial_seed)
	release_inputs()
	report()
	game._delete_save()
	game.queue_free()
	game=null
	await frames(10)
	await create_timer(0.2).timeout
	print("BALANCE_PROBE: ",rows.size()," encounters; legacy=",legacy)
	quit()
