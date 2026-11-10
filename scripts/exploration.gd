extends Node
const Layout = preload("res://scripts/act_one_layout.gd")
var game
var rooms := Layout.rooms()
var passages := Layout.passages()
var ledges := Layout.platforms()
var blocks := Layout.blocks()
var room := "city"
var visited: Array = ["city"]
var opened: Array = []
var collected: Array = []
var bells: Array = []
var map_open := false
var transition := 0.0
var transition_phase := ""
var transition_elapsed := 0.0
var transition_blocks := false
var pending_destination := ""
var pending_spawn := Vector2.ZERO
var pending_facing := 0
const FADE_OUT_TIME := 0.16
const FADE_IN_TIME := 0.22
var gate: StaticBody2D
var journey_distance := 0.0
var last_position := Vector2.ZERO
var extra_altars: Array[Vector2] = [Vector2(5500,600),Vector2(11250,600),Vector2(14420,1100),Vector2(21800,600),Vector2(25100,600),Vector2(27950,600)]
const ALTAR_NAMES := {5500:"Altar dos Sem Nome",11250:"Altar dos Votos",14420:"Altar da Vigília",21800:"Altar da Santa Calada",25100:"Altar dos Sinos Partidos",27950:"Altar dos Portões Selados"}
var arenas_done: Array = []
var arenas_enabled := true
var arena_active := ""
var arena_wave := 0
var arena_enemies: Array = []
var arena_bodies: Array = []
var arena_rects: Array[Rect2] = []

var pickups: Array[Dictionary] = [
	{"id":"doll","room":"refuge","pos":Vector2(20030,280),"name":"Boneca coberta de cinzas","text":"A boneca estava entre cobertores pequenos.\nAlguém preparou abrigo para quem nunca chegou.\n\nNo pátio, há um memorial sem nomes legíveis."},
	{"id":"register","room":"archive","pos":Vector2(17800,280),"name":"Registro dos que esperaram","text":"Uma lista de famílias, sem sentença ou confissão.\nAo lado de cada nome, a mesma palavra: aguardando.\n\nA Ordem chamou o silêncio de consentimento.\nVocê pode levar estes nomes até Iria."},
	{"id":"vessel","room":"refuge","pos":Vector2(20600,600),"name":"Vaso da Última Vigília","text":"Uma curandeira manteve esta chama acesa até o fim.\nSeu pequeno frasco ainda pode carregar uma lágrima.\n\nCapacidade curativa aumentada em um frasco."},
	{"id":"pews","room":"nave","pos":Vector2(22480,360),"name":"Bancos voltados para a parede","reward":120,"text":"Todos os bancos da nave foram virados para a pedra nua.\n\n\"Porque os seus ouvidos se fecharam, e eles não ouviram.\"\n\nHá lágrimas secas nas fendas da madeira.\n\n+120 lágrimas."},
	{"id":"silence","room":"nave","pos":Vector2(23600,200),"name":"Terço de contas apagadas","reward":250,"text":"Cada conta foi lixada até perder o nome que levava.\nRestou o fio, e o fio ainda está quente.\n\nUma mão devota esteve aqui antes de você.\n\n+250 lágrimas."},
	{"id":"rope","room":"terrace","pos":Vector2(26100,200),"name":"Corda do sino sem badalo","reward":150,"text":"O sino foi calado por dentro, antes de tocar a última vez.\nA corda foi cortada à altura da mão.\n\nNa Ordem, quem tocava o sino sem ordem era punido.\n\n+150 lágrimas."},
	{"id":"seal","room":"court","pos":Vector2(28800,600),"name":"Os Portões Selados","reward":0,"text":"Os portões estão fechados por fora, com correntes que ninguém forjou aqui.\nGravado na madeira, sob um selo raspado: \"POR ORDEM DO SELO: NINGUÉM SAIRÁ, NINGUÉM ENTRARÁ.\"\n\nAbaixo, riscado por unhas: \"Pai, abra. Estamos aqui.\"\n\nEste caminho ainda não se abre.\nAlgo que você carrega ainda é a chave."},
	{"id":"decree","room":"court","pos":Vector2(28700,360),"name":"Decreto selado em cera","reward":200,"text":"\"Quem lamentar será tratado como cúmplice da praga.\nQuem chorar será contado entre os culpados.\"\n\nO nome no selo foi raspado a faca. O pulso que assinou tremia.\nPela primeira vez, você duvida de quem ordenou.\n\n+200 lágrimas."},
	{"id":"witness","room":"ossuary","pos":Vector2(6550,600),"name":"O lugar vazio","text":"Aqui não se enterravam nomes: enterravam-se números.\nUm espaço entre os túmulos continua limpo.\n\nAlguém voltou por uma pessoa que não encontrou."},
]

func build() -> void:
	for id in rooms:
		if id == "city": continue
		var data: Dictionary = rooms[id]
		var bounds: Rect2 = data.bounds
		game._add_solid(Rect2(bounds.position.x, data.floor, bounds.size.x, 500), false)
		game._add_solid(Rect2(bounds.position.x-40,bounds.position.y,40,bounds.size.y+300),false)
		game._add_solid(Rect2(bounds.end.x,bounds.position.y,40,bounds.size.y+300),false)
	for ledge in ledges: game._add_solid(ledge,true)
	for block in blocks: game._add_solid(block,false)
	for pos in extra_altars:
		game.altars.append(pos)
		game.altar_names.append(ALTAR_NAMES[int(pos.x)])
	update_gate()

func reset() -> void:
	room = "city"
	visited = ["city"]
	opened = []
	collected = []
	bells = []
	arenas_done = []
	abort_arena()
	map_open = false
	transition = 0
	transition_phase = ""
	transition_blocks = false
	pending_destination = ""
	journey_distance = 0
	last_position = Vector2.ZERO
	update_gate()

func room_at(pos: Vector2) -> String:
	for id in rooms:
		var b: Rect2 = rooms[id].bounds
		if pos.x >= b.position.x and pos.x <= b.end.x: return id
	return "city"

func set_camera() -> void:
	var b: Rect2 = rooms[room].bounds
	var c: Camera2D = game.player.camera
	c.limit_left = int(b.position.x)
	c.limit_right = int(b.end.x)
	var graphic_top: float = -770 if room == "city" else rooms[room].floor - art_height(room) * ground_line(room)
	# Camera2D aplica o deslocamento de -110 após os limites; compensa para manter o chão visível.
	c.limit_top = int(maxf(b.position.y,graphic_top)+110)
	c.limit_bottom = int(rooms[room].floor + 220)
	c.reset_smoothing()

func art_height(id: String) -> float:
	return float(rooms[id].get("art_h",1900.0 if id == "belfry" else 1100.0))

func ground_line(id: String) -> float:
	return float(rooms[id].get("ground",0.86))

func travel(id: String, pos: Vector2, arrival_facing: int = 0, blocking: bool = false) -> void:
	for hazard in get_tree().get_nodes_in_group("hazards"): hazard.queue_free()
	room = id
	if not visited.has(room): visited.append(room)
	game.player.position = pos
	game.player.safe_pos = pos
	game.player.velocity = Vector2.ZERO
	game.player.state = "idle"
	game.player.attack_buffer = 0
	game.player.roll_buffer = 0
	game.player.invuln = 0.65
	if arrival_facing != 0: game.player.facing = arrival_facing
	transition_blocks = blocking
	game.player.controllable = not blocking
	game.player.camera.zoom = Vector2.ONE
	set_camera()
	transition = 0.4
	transition_phase = "in"
	transition_elapsed = 0
	game.area_name = rooms[room].name
	game.area_t = 4.5
	last_position = pos
	game._save()

func update_gate() -> void:
	if is_instance_valid(gate): gate.queue_free()
	gate = null
	if bells.size() < 2:
		gate = game._add_solid(Rect2(3780,-200,28,800),false)

func spawn_enemies() -> void:
	for d in Layout.enemies():
		var e = game.EnemyScript.new()
		e.setup(d[1],Vector2(d[2],d[3]),d[4],game.player)
		e.room_id = d[0]
		if d.size() > 5: e.group = int(d[5])
		e.killed.connect(game._on_enemy_killed)
		game.add_child(e)

func serialize() -> Dictionary:
	return {"room":room,"visited":visited,"opened":opened,"collected":collected,"bells":bells,"arenas_done":arenas_done,"distance":journey_distance}

func _names(value, fallback: Array, allowed: Array = []) -> Array:
	var clean: Array = []
	if not value is Array: return fallback.duplicate()
	for item in value:
		if item is String and not clean.has(item) and (allowed.is_empty() or allowed.has(item)): clean.append(item)
	return clean if not clean.is_empty() or fallback.is_empty() else fallback.duplicate()

func restore(data: Dictionary) -> void:
	abort_arena()
	var saved_room = data.get("room","city")
	room = saved_room if saved_room is String and rooms.has(saved_room) else "city"
	visited = _names(data.get("visited"),["city"],rooms.keys())
	var passage_ids: Array = []
	for link in passages: passage_ids.append(link.id)
	opened = _names(data.get("opened"),[],passage_ids)
	var pickup_ids: Array = []
	for item in pickups: pickup_ids.append(item.id)
	collected = _names(data.get("collected"),[],pickup_ids + ["doll","vessel","register","witness"])
	bells = _names(data.get("bells"),[],["water","vigil"])
	var arena_ids: Array = []
	for a in Layout.arenas(): arena_ids.append(a.id)
	arenas_done = _names(data.get("arenas_done"),[],arena_ids)
	var distance = data.get("distance",0)
	journey_distance = clampf(float(distance),0.0,1.0e9) if distance is int or distance is float else 0.0
	if game.doll_found and not collected.has("doll"): collected.append("doll")
	game.player.max_flasks = 4 if collected.has("vessel") else 3
	update_gate()

func is_transitioning() -> bool:
	return transition_blocks and transition_phase != ""

func request_travel(id: String, pos: Vector2, arrival_facing: int) -> void:
	if is_transitioning() or not rooms.has(id): return
	game.soundscape.play_sfx("porta")
	pending_destination = id
	pending_spawn = pos
	pending_facing = arrival_facing
	transition_phase = "out"
	transition_elapsed = 0
	transition = 0
	transition_blocks = true
	game.player.controllable = false
	game.player.velocity = Vector2.ZERO
	game.player.invuln = maxf(game.player.invuln, FADE_OUT_TIME + FADE_IN_TIME + 0.1)

func _process(delta: float) -> void:
	if transition_phase != "":
		transition_elapsed += delta
		if transition_phase == "out":
			transition = 0.4 * clampf(transition_elapsed / FADE_OUT_TIME,0,1)
			if transition_elapsed >= FADE_OUT_TIME:
				travel(pending_destination,pending_spawn,pending_facing,true)
				pending_destination = ""
		else:
			transition = 0.4 * (1 - clampf(transition_elapsed / FADE_IN_TIME,0,1))
			if transition_elapsed >= FADE_IN_TIME:
				transition = 0
				transition_phase = ""
				if transition_blocks and game.state == "play" and game.message_text == "" and game.narrative.mode == "":
					game.player.controllable = true
				transition_blocks = false
		if is_transitioning(): game.player.velocity = Vector2.ZERO
	if game.state != "play" or map_open or is_transitioning() or game.narrative.mode != "": return
	if room_at(game.player.position) != room:
		room = room_at(game.player.position)
		if not visited.has(room): visited.append(room)
		set_camera()
	if last_position != Vector2.ZERO:
		var distance: float = game.player.position.distance_to(last_position)
		if distance < 30: journey_distance += distance
	last_position = game.player.position

func arena_by_id(id: String) -> Dictionary:
	for a in Layout.arenas():
		if a.id == id: return a
	return {}

func _start_arena(a: Dictionary) -> void:
	arena_active = a.id
	arena_wave = 0
	arena_rects.clear()
	for edge in [a.x0, a.x1]:
		var wall := Rect2(edge - 24.0, a.floor - 540.0, 48.0, 600.0)
		arena_rects.append(wall)
		arena_bodies.append(game._add_solid(wall, false))
	game.toast("A saída se fecha. Só se abre quando o último cair.")
	game.soundscape.play_sfx("bell")
	game.soundscape.play_sfx("portao_fecha")
	game.shake_cam(7.0)
	_spawn_wave(a)

func _spawn_wave(a: Dictionary) -> void:
	arena_enemies.clear()
	for d in a.waves[arena_wave]:
		var e = game.EnemyScript.new()
		e.setup(d[0],Vector2(d[1],d[2]),d[3],game.player)
		e.room_id = a.room
		e.killed.connect(game._on_enemy_killed)
		game.add_child(e)
		if e.family == "walker": e.state = "chase"
		arena_enemies.append(e)
		game.spawn_effect("dust",Vector2(d[1],d[2]) + Vector2(0,-30),1,0.8)

func _release_arena() -> void:
	for body in arena_bodies:
		if is_instance_valid(body): body.queue_free()
	arena_bodies.clear()
	arena_rects.clear()

func _finish_arena(a: Dictionary) -> void:
	arenas_done.append(a.id)
	arena_active = ""
	_release_arena()
	game.player.lagrimas += int(a.reward)
	game.toast("O caminho se abre. +%d lágrimas" % int(a.reward))
	game.soundscape.play_sfx("altar")
	game.soundscape.play_sfx("portao_abre")
	game._save()

func abort_arena() -> void:
	## O penitente caiu ou saiu: o combate reinicia e pode ser tentado novamente.
	for e in arena_enemies:
		if is_instance_valid(e): e.queue_free()
	arena_enemies.clear()
	arena_active = ""
	_release_arena()

func update_arena() -> void:
	if not arenas_enabled or game.state != "play":
		return
	var player = game.player
	if arena_active == "":
		for a in Layout.arenas():
			if a.room == room and not arenas_done.has(a.id):
				var pos: Vector2 = player.global_position
				if pos.x > a.x0 + 80.0 and pos.x < a.x1 - 80.0 and absf(pos.y - a.floor) < 90.0 and player.state != "dead":
					_start_arena(a)
					return
		return
	if player.state == "dead" or room != arena_by_id(arena_active).get("room",""):
		abort_arena()
		return
	for e in arena_enemies:
		if is_instance_valid(e) and not e.dead: return
	var a := arena_by_id(arena_active)
	arena_wave += 1
	if arena_wave >= a.waves.size(): _finish_arena(a)
	else: _spawn_wave(a)

func update(_delta: float) -> bool:
	update_arena()
	if map_open or is_transitioning(): return true
	var p: Vector2 = game.player.position
	for link in passages:
		var forward: bool = room == link.a
		if not forward and room != link.b: continue
		var here: Vector2 = link.pa if forward else link.pb
		if p.distance_to(here) > 65: continue
		var locked: bool = link.get("latch",false) and not forward and not opened.has(link.id)
		game.prompt = "[E] " + ("Grade fechada pelo outro lado" if locked else "Atravessar · " + str(rooms[link.b if forward else link.a].name))
		if Input.is_action_just_pressed("interact") and game.player.state == "idle":
			if locked: game.toast("A corrente foi presa pelo outro lado. Procure outro caminho.")
			else:
				if link.get("latch",false) and not opened.has(link.id): opened.append(link.id)
				var face := Layout.passage_face(link,not forward)
				request_travel(str(face.room),face.foot + Vector2(face.arrival_dir * face.spawn_offset,0),int(face.arrival_dir))
		return true
	# Os dois mecanismos do sino ficam em rotas verticais distintas, fora do corredor principal.
	for entry in [{"id":"water","room":"cistern","pos":Vector2(9650,40)}, {"id":"vigil","room":"belfry","pos":Vector2(15120,-260)}]:
		if room != entry.room or p.distance_to(entry.pos) > 65 or bells.has(entry.id): continue
		game.prompt = "[E] Soltar a corrente dos sinos"
		if Input.is_action_just_pressed("interact") and game.player.state == "idle":
			bells.append(entry.id)
			update_gate()
			game.soundscape.play_sfx("bell")
			game.shake_cam(4)
			game.story_chain_released(str(entry.id))
			game._save()
		return true
	for item in pickups:
		if item.room != room or collected.has(item.id) or p.distance_to(item.pos) > 55: continue
		game.prompt = "[E] Examinar · " + item.name
		if Input.is_action_just_pressed("interact"):
			collected.append(item.id)
			game.soundscape.play_sfx("coleta")
			if item.id == "doll":
				game.doll_found = true
				game.player.blood_tears = 5
			if item.get("reward",0) > 0: game.player.lagrimas += int(item.reward)
			if item.id == "vessel":
				game.player.max_flasks = 4
				game.player.flasks = mini(game.player.flasks+1,4)
			game.show_message(item.name,game.story_pickup_text(str(item.id),str(item.text)))
			game._save()
		return true
	if room == "city" and p.x > 3640 and p.x < 3790 and bells.size() < 2:
		game.prompt = "Duas correntes prendem a passagem · cisterna e campanário"
	if room != "city":
		game.area_name = rooms[room].name
		# Os altares das ramificações usam os mesmos sistemas de oração, equipamento e pontos de controle.
		for i in range(3,game.altars.size()):
			if p.distance_to(game.altars[i]) < 65:
				game.prompt = "[E] Orar  ·  [V] Penitências  ·  [R] Oferecer %d lágrimas" % (100 * (game.player.upgrades+1))
				if Input.is_action_just_pressed("interact"): game._pray(i)
				elif Input.is_action_just_pressed("offer"): game.offer_health()
		if not game.relic_taken and p.distance_to(game.relic_pos) < 55:
			game._take_relic()
		return true
	return false

func objective() -> String:
	if game.boss_defeated: return "A primeira Lágrima · revisite os caminhos ou encerre a vigília nos portões"
	if not game.player.has_weapon: return "Recolha a espada diante do túmulo"
	if not game.relic_taken: return "Explore as passagens · encontre o Espinho no campanário"
	if bells.size() < 2: return "Liberte as correntes dos sinos · %d / 2" % bells.size()
	return "As correntes cederam · procure o Guardião"
