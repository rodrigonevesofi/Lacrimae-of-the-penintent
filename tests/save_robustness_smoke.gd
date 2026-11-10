extends SceneTree
# Código de produção somente para leitura; cada caso corrompido executa em um processo descartável separado.
const CASES=["valid","legacy","truncated","empty","extra_fields","number_text","number_list","negative_numbers","absurd_numbers","empty_lists","wrong_exploration","wrong_stain","array_root"]
var game
func _initialize():call_deferred("run")
func frames(n: int):
	for i in range(n):await physics_frame;await process_frame
func safe_snapshot() -> Dictionary:
	var p=game.player
	var okay=game.respawn_index>=0 and game.respawn_index<game.altars.size()
	okay=okay and is_finite(p.max_hp) and p.max_hp>0 and p.max_hp<=15100
	okay=okay and is_finite(p.hp) and p.hp>0 and p.hp<=p.max_hp
	okay=okay and p.lagrimas>=0 and p.lagrimas<=1000000000 and p.upgrades>=0 and p.upgrades<=1000
	okay=okay and is_finite(p.culpa) and p.culpa>=0 and p.culpa<=100
	okay=okay and game.echo_count>=0 and game.echo_count<=99
	okay=okay and game.exploration.rooms.has(game.exploration.room)
	return {"safe":okay,"altar":game.respawn_index,"hp":p.hp,"max_hp":p.max_hp,"currency":p.lagrimas,"upgrades":p.upgrades,"culpa":p.culpa,"echo_count":game.echo_count,"room":game.exploration.room}
func child(name: String):
	create_timer(8.0).timeout.connect(func():print("SAVE_TIMEOUT ",name);quit(4))
	game=load("res://scenes/main.tscn").instantiate();root.add_child(game)
	game._start_game(false,false);game.message_text="";game.prologue_page=-1
	game.set_process(false);game.player.set_physics_process(false)
	game.player.has_weapon=true;game.player.lagrimas=73;game.player.upgrades=2;game.echo_count=3
	game.story_flags.append("names_read");game.respawn_index=1
	game._save()
	var valid: Dictionary=JSON.parse_string(FileAccess.get_file_as_string(game.SAVE_PATH))
	var fixture=valid.duplicate(true)
	match name:
		"legacy":fixture={"altar":0,"lagrimas":42,"weapon":true}
		"extra_fields":fixture["future_field"]={"nested":[1,2,3]}
		"number_text":fixture["altar"]="not a number";fixture["upgrades"]="bad";fixture["culpa"]="bad"
		"number_list":fixture["altar"]=[];fixture["lagrimas"]={"invalid":true}
		"negative_numbers":fixture["lagrimas"]=-900;fixture["upgrades"]=-1000;fixture["culpa"]=-500
		"absurd_numbers":fixture["altar"]=1e18;fixture["upgrades"]=1e12;fixture["lagrimas"]=1e20;fixture["culpa"]=1e30
		"empty_lists":fixture["story_flags"]=[];fixture["stain_pos"]=[];fixture["exploration"]={"visited":[],"opened":[],"collected":[],"bells":[]}
		"wrong_exploration":fixture["exploration"]="unexpected"
		"wrong_stain":fixture["stain_pos"]="unexpected"
	var raw=JSON.stringify(fixture)
	if name=="truncated":raw='{"altar":0,"lagrimas":'
	if name=="empty":raw=""
	if name=="array_root":raw="[]"
	FileAccess.open(game.SAVE_PATH,FileAccess.WRITE).store_string(raw)
	game._start_game(true,false)
	var observed=safe_snapshot()
	if name in ["valid","extra_fields"]:
		observed.safe=observed.safe and game.echo_count==3 and game.player.upgrades==2 and game.player.lagrimas==73 and game.story_flags.has("names_read") and game.respawn_index==1
	elif name=="legacy":observed.safe=observed.safe and game.echo_count==0 and game.story_flags.is_empty() and game.player.lagrimas==42
	observed["case"]=name;observed["completed"]=true
	print("SAVE_OBSERVATION ",JSON.stringify(observed))
	game._delete_save();game.queue_free();game=null
	await frames(12);await create_timer(.3).timeout;quit(0 if observed.safe else 1)
func run():
	if not OS.get_environment("XDG_DATA_HOME").begins_with("/tmp/lacrimae-save-"):
		push_error("Isolate XDG_DATA_HOME=/tmp/lacrimae-save-<run>/data and other XDG directories.");quit(3);return
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--case="):
			await child(arg.trim_prefix("--case="));return
	var results=[];var failed=0
	for name in CASES:
		var output=[]
		var code=OS.execute(OS.get_executable_path(),["--headless","--audio-driver","Dummy","--path",ProjectSettings.globalize_path("res://"),"--script","res://tests/save_robustness_smoke.gd","--","--case="+name],output,true)
		var log="\n".join(output);var errors=[];var snapshot={};var shutdown_diagnostics=[]
		for line in log.split("\n"):
			if "resources still in use at exit" in line:shutdown_diagnostics.append(line.strip_edges())
			if "SCRIPT ERROR" in line or ("ERROR:" in line and not "resources still in use at exit" in line):errors.append(line.strip_edges())
			if line.begins_with("SAVE_OBSERVATION "):snapshot=JSON.parse_string(line.trim_prefix("SAVE_OBSERVATION "))
		var passed=code==0 and errors.is_empty() and bool(snapshot.get("safe",false)) and bool(snapshot.get("completed",false))
		if not passed:failed+=1
		var item={"case":name,"passed":passed,"exit":code,"errors":errors,"shutdown_diagnostics":shutdown_diagnostics,"observed":snapshot}
		results.append(item)
		print("SAVE_CASE ",name," PASS" if passed else " FAIL")
	FileAccess.open("res://docs/robustez-salvamento.json",FileAccess.WRITE).store_string(JSON.stringify(results,"  "))
	var text="# Robustez do salvamento — base v17\n\nCada fixture foi escrita e carregada pela rotina real `_start_game(true,false)`, em processo separado e dados descartáveis. Nenhum script de produção foi alterado. Um caso só passa se completa a carga, não emite erro de script nem erro de carga do engine e conserva um estado seguro; uma carga que recupera valores mas imprime erro ainda falha.\n\nCritérios de sanidade da sonda: altar existente, sala conhecida, HP finito e positivo até o máximo, culpa0–100, eco0–99. Para detectar números absurdos, limites de triagem propostos: melhorias0–1000 e moeda0–1bilhão; esses limites não são uma decisão de balanceamento. O Claude precisa definir os tetos oficiais. A fixture válida verifica também moeda, altar, melhorias, eco e flag restaurados exatamente.\n\n| Caso | Resultado | Saída | Observação |\n|---|---|---:|---|\n"
	for r in results:
		text+="| %s | %s | %d | %s |\n"%[r.case,"PASSOU" if r.passed else "FALHOU",r.exit,"; ".join(r.errors).replace("|","/") if not r.errors.is_empty() else ("Estado seguro" if r.passed else "Estado fora dos limites de sanidade ou carga incompleta")]
	text+="\nResultados completos em robustez-salvamento.json. Avisos de recursos ainda em uso apenas no encerramento não são classificados como falha de migração; erros de script e de parsing continuam sendo falhas.  São falhas observadas, não corrigidas: manter a proteção de scripts pedida. Recomendações ao integrador: validar tipos antes de conversões e chamadas tipadas; tratar JSON vazio/truncado sem erro não controlado; normalizar limites antes de calcular HP; aceitar campos desconhecidos e migrar campos ausentes. Não testar arquivos reais corrompendo o salvamento do autor.\n\nRepetir: `XDG_DATA_HOME=/tmp/lacrimae-save-v17/data XDG_CONFIG_HOME=/tmp/lacrimae-save-v17/config XDG_CACHE_HOME=/tmp/lacrimae-save-v17/cache godot --headless --script res://tests/save_robustness_smoke.gd --path .`. Código0 significa todos os casos aprovados;1 indica falha medida;3 indica ambiente não isolado. JSON truncado e tipos inválidos podem imprimir erros intencionais nos filhos: o relatório os conserva, sem esconder. A simulação não testa queda de energia durante escrita, disco cheio, permissões ou todas as versões históricas de save.\n"
	FileAccess.open("res://docs/robustez-salvamento.md",FileAccess.WRITE).store_string(text)
	print("SAVE_ROBUSTNESS: ",results.size()," cases, ",failed," failures")
	quit(1 if failed else 0)
