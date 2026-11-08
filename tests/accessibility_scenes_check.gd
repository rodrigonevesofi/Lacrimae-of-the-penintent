extends SceneTree
var game
var results: Array=[]
var failures:=0
func _initialize():call_deferred("run")
func frames(n: int):
	for i in range(n):await physics_frame;await process_frame
func record(scene: String,item: String,ok: bool,note: String):
	results.append({"scene":scene,"item":item,"ok":ok,"note":note})
	if not ok:failures+=1
	print("PASS " if ok else "FAIL ",scene," / ",item," / ",note)
func sample(scene: String,index: int):
	var n=game.narrative
	if n.mode!="":n.finish()
	n.begin(scene,index)
	n.set_process(false)
	var events: Array=[]
	var ticks=int(ceil(n.duration_of(scene)*60))
	var prior_flash=0.0
	for i in range(ticks):
		n._process(1.0/60)
		if n.flash>prior_flash+.0001:events.append(float(i+1)/60)
		prior_flash=n.flash
	var maximum=0
	for time in events:
		var count=0
		for other in events:
			if other>=time and other<time+1:count+=1
		maximum=maxi(maximum,count)
	var label=scene+str(index) if scene=="echo" else scene
	record(label,"flashes",maximum<=3,"Picos brancos observados em60Hz: "+str(events)+"; máximo por janela1s="+str(maximum))
	if scene=="echo" and index==0:
		record(label,"batidas",events.size()==3 and n.GuiltText.echo_line(0).to_lower().contains("três"),"Três pulsos visuais e legenda que informa três batidas.")
	elif scene=="echo":
		record(label,"vozes",n.voice_played and n.GuiltText.echo_line(index).length()>0,"Voz abstrata acompanhada por fala escrita de echo_line.")
	elif scene=="memory":
		record(label,"batidas",events.size()==3,"Cada batida final aciona um pulso branco; contagem visual três.")
		record(label,"vozes",n.voice_played and n.GuiltText.MEMORY_CAPTIONS[0].to_lower().contains("vozes"),"Legenda menciona vozes; montagem também escreve Abra/Ainda estamos aqui.")
	if scene in ["memorial","memory"]:
		# Conservative criterion: an explicit bell subtitle or an identifiable animated bell,
		# rather than assuming that any camera zoom means a bell to a deaf player.
		var source=FileAccess.get_file_as_string("res://scripts/narrative.gd")
		var explicit_bell=source.contains('"[Sino') or source.contains('"[Badalada') or source.contains("draw_bell(")
		record(label,"sino",explicit_bell,"Não foi encontrado equivalente explícito para a badalada inicial. Zoom/título sinalizam a cena, mas não identificam um sino. Revisar se o som é apenas atmosférico ou informação essencial.")
	# Exercise the actual input path before and after the defined minimum.
	if n.mode!="":n.finish()
	n.begin(scene,index);n.set_process(true)
	var minimum={"echo":2.0,"memorial":2.8,"memory":n.GRIEF_DURATION+.2}[scene]
	n.elapsed=minimum-.15
	Input.action_press("interact");await frames(1);Input.action_release("interact")
	record(label,"mínimo",n.mode==scene,"Interação anterior ao tempo mínimo preserva a cena.")
	await frames(2)
	n.elapsed=minimum+.05
	Input.action_press("interact");await frames(2);Input.action_release("interact")
	record(label,"pular",n.mode=="" and (game.player.controllable or not game.message_text.is_empty()),"Interação após mínimo encerra a cinemática; memorial pode abrir seu registro legível separado.")
	for page in range(12):
		if game.message_text.is_empty():break
		game.message_t=0;game.advance_message();await frames(1)
func report():
	var text="# Acessibilidade das cenas de culpa\n\nChecagem funcional e conservadora, não certificação de acessibilidade nem teste com pessoas surdas/fotossensíveis. As três variantes do eco, memorial e memória foram examinadas.\n\n| Cena | Item | Resultado | Evidência/limite |\n|---|---|---|---|\n"
	for r in results:text+="| %s | %s | %s | %s |\n"%[r.scene,r.item,"PASSOU" if r.ok else "FALHOU",r.note]
	text+="\nPendências: badaladas iniciais de memorial e memória não têm legenda explícita nem sino animado identificável na camada de cena. O título e o foco visual comunicam a entrada na cena, mas não o timbre/evento específico. Se esses sons forem considerados essenciais, acrescentar descrição como [badalada abafada] ou equivalente visual identificável. Se forem apenas ambientação, essa classificação precisa ser uma decisão editorial registrada. Nenhum script protegido foi alterado para corrigir isso.\n\nFlashes: contador observa elevações da propriedade flash com amostragem60Hz e calcula o máximo em janelas móveis de1s. Não analisa luminância de cada pixel, área luminosa, contraste vermelho, efeitos fora da cena ou queda de quadros. Não comprova conformidade com WCAG nem segurança para todas as pessoas. Legendas foram verificadas por vínculo textual/estado, não por contraste, velocidade de leitura ou tamanho em todos os monitores. A soma de som, luz e legenda deve ser avaliada por pessoas.\n\nRepetir com dados descartáveis: `XDG_DATA_HOME=/tmp/lacrimae-a11y-data XDG_CONFIG_HOME=/tmp/lacrimae-a11y-config XDG_CACHE_HOME=/tmp/lacrimae-a11y-cache godot --headless --path . --script res://tests/accessibility_scenes_check.gd`. O teste termina com código1 quando encontra pendências; isso é esperado nesta base.\n"
	FileAccess.open("res://docs/acessibilidade-cenas.md",FileAccess.WRITE).store_string(text)
func run():
	if OS.get_environment("XDG_DATA_HOME").is_empty():push_error("Use disposable XDG_DATA_HOME");quit(2);return
	game=load("res://scenes/main.tscn").instantiate();root.add_child(game)
	game._start_game(false,false);game.message_text="";game.prologue_page=-1
	for e in get_nodes_in_group("enemies"):e.set_physics_process(false)
	game.soundscape.muted=true;game.soundscape.set_process(false)
	game.soundscape.ambience.stop();game.soundscape.incoming.stop();game.soundscape.guilt_layer.stop()
	for voice in game.soundscape.effects.values():voice.stop()
	await sample("echo",0);await sample("echo",1);await sample("echo",2);await sample("memorial",0);await sample("memory",0)
	report();game._delete_save();game.queue_free();game=null
	await frames(8);await create_timer(.2).timeout
	print("ACCESSIBILITY_SCENES: ",results.size()," checks, ",failures," findings")
	quit(1 if failures else 0)
