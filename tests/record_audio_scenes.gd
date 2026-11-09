# Grava áudio e vídeo mixados pelo próprio jogo para análise (sem ganho de captura). Uso: REC_MODE=explore|fight|boss|memory godot --path . --resolution 640x360 --fixed-fps 30 --write-movie out.avi --script res://tests/record_audio_scenes.gd
extends "res://tests/exploration_smoke.gd"
var mode := "explore"
func run() -> void:
	mode = OS.get_environment("REC_MODE")
	game=load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	game._start_game(false,false)
	for i in range(3): await close_message()
	game.exploration.arenas_enabled = false
	var p=game.player
	p.has_weapon=true
	for e in get_nodes_in_group("enemies"): e.queue_free()
	await frames(2)
	p.revive(Vector2(900,600)); p.invuln=0; p.hp=999
	if mode=="explore":
		# Caminha para a direita e a esquerda na cidade por 20 s de tempo do jogo.
		for k in range(4):
			Input.action_press("right"); await frames(150); Input.action_release("right")
			Input.action_press("left"); await frames(150); Input.action_release("left")
	elif mode=="fight":
		for kind in [0,0,4]:
			var e=game.EnemyScript.new(); e.setup(kind,Vector2(1150+randi()%200,600),60,p); e.room_id="city"; e.killed.connect(game._on_enemy_killed); game.add_child(e)
		for f in range(560):
			var nearest=null
			for e in get_nodes_in_group("enemies"):
				if not e.dead and (nearest==null or absf(e.position.x-p.position.x)<absf(nearest.position.x-p.position.x)): nearest=e
			if nearest!=null:
				var dx=nearest.position.x-p.position.x
				if absf(dx)>85: Input.action_press("right" if dx>0 else "left"); Input.action_release("left" if dx>0 else "right")
				else:
					Input.action_release("right"); Input.action_release("left")
					if f%12==0: Input.action_press("attack")
					else: Input.action_release("attack")
			await frames(1)
		Input.action_release("attack"); Input.action_release("left"); Input.action_release("right")
	elif mode=="boss":
		game.narrative.begin("boss_intro"); await frames(int(game.narrative.duration_of("boss_intro")*30)+10)
		if game.narrative.mode!="": game.narrative.finish()
		game.narrative.begin("boss_end"); await frames(int(game.narrative.duration_of("boss_end")*30)+10)
		if game.narrative.mode!="": game.narrative.finish()
	elif mode=="memory":
		game.narrative.begin("memory"); await frames(int(game.narrative.duration_of("memory")*30)+10)
	game._delete_save()
	quit(0)
