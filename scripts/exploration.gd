extends Node
const Layout = preload("res://scripts/act_one_layout.gd")
var game
var rooms := Layout.rooms()
var passages := Layout.passages()
var ledges := Layout.platforms()
var room := "city"
var visited: Array = ["city"]
var opened: Array = []
var collected: Array = []
var bells: Array = []
var map_open := false
var transition := 0.0
var gate: StaticBody2D
var journey_distance := 0.0
var last_position := Vector2.ZERO
var extra_altars: Array[Vector2] = [Vector2(5500,600),Vector2(11250,600),Vector2(14420,1100)]
var pickups: Array[Dictionary] = [
	{"id":"doll","room":"refuge","pos":Vector2(20030,280),"name":"Boneca coberta de cinzas","text":"A boneca estava entre cobertores pequenos.\nAlguém preparou abrigo para quem nunca chegou.\n\nNo pátio, há um memorial sem nomes legíveis."},
	{"id":"register","room":"archive","pos":Vector2(17800,280),"name":"Registro dos que esperaram","text":"Uma lista de famílias, sem sentença ou confissão.\nAo lado de cada nome, a mesma palavra: aguardando.\n\nA Ordem chamou o silêncio de consentimento.\nVocê pode levar estes nomes até Iria."},
	{"id":"vessel","room":"refuge","pos":Vector2(20600,600),"name":"Vaso da Última Vigília","text":"Uma curandeira manteve esta chama acesa até o fim.\nSeu pequeno frasco ainda pode carregar uma lágrima.\n\nCapacidade curativa aumentada em um frasco."},
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
	for pos in extra_altars:
		game.altars.append(pos)
		game.altar_names.append({5500:"Altar dos Sem Nome",11250:"Altar dos Votos",14420:"Altar da Vigília"}[int(pos.x)])
	update_gate()

func reset() -> void:
	room = "city"
	visited = ["city"]
	opened = []
	collected = []
	bells = []
	map_open = false
	transition = 0
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
	var graphic_top: float = -770 if room == "city" else rooms[room].floor - (1900 if room == "belfry" else 1100) * 0.86
	# Camera2D applies its -110 offset after limits; compensate to keep the floor visible.
	c.limit_top = int(maxf(b.position.y,graphic_top)+110)
	c.limit_bottom = int(rooms[room].floor + 220)
	c.reset_smoothing()

func travel(id: String, pos: Vector2) -> void:
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
	game.player.controllable = true
	game.player.camera.zoom = Vector2.ONE
	set_camera()
	transition = 0.4
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
		e.killed.connect(game._on_enemy_killed)
		game.add_child(e)

func serialize() -> Dictionary:
	return {"room":room,"visited":visited,"opened":opened,"collected":collected,"bells":bells,"distance":journey_distance}

func restore(data: Dictionary) -> void:
	room = str(data.get("room","city"))
	if not rooms.has(room): room = "city"
	visited = data.get("visited",["city"])
	opened = data.get("opened",[])
	collected = data.get("collected",[])
	bells = data.get("bells",[])
	journey_distance = float(data.get("distance",0))
	if game.doll_found and not collected.has("doll"): collected.append("doll")
	game.player.max_flasks = 4 if collected.has("vessel") else 3
	update_gate()

func _process(delta: float) -> void:
	transition = maxf(transition-delta,0)
	if game.state != "play" or map_open or game.narrative.mode != "": return
	if room_at(game.player.position) != room:
		room = room_at(game.player.position)
		if not visited.has(room): visited.append(room)
		set_camera()
	if last_position != Vector2.ZERO:
		var distance: float = game.player.position.distance_to(last_position)
		if distance < 30: journey_distance += distance
	last_position = game.player.position

func update(_delta: float) -> bool:
	if map_open: return true
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
				travel(link.b if forward else link.a,(link.pb if forward else link.pa) + Vector2(45 if forward else -45,0))
		return true
	# Both bell mechanisms are in different vertical routes, not on the main corridor.
	for entry in [{"id":"water","room":"cistern","pos":Vector2(9650,40)}, {"id":"vigil","room":"belfry","pos":Vector2(15120,-260)}]:
		if room != entry.room or p.distance_to(entry.pos) > 65 or bells.has(entry.id): continue
		game.prompt = "[E] Soltar a corrente dos sinos"
		if Input.is_action_just_pressed("interact") and game.player.state == "idle":
			bells.append(entry.id)
			update_gate()
			game.soundscape.play_sfx("bell")
			game.shake_cam(4)
			game.toast("Uma corrente cedeu. %d de 2 mecanismos liberados." % bells.size())
			game._save()
		return true
	for item in pickups:
		if item.room != room or collected.has(item.id) or p.distance_to(item.pos) > 55: continue
		game.prompt = "[E] Examinar · " + item.name
		if Input.is_action_just_pressed("interact"):
			collected.append(item.id)
			if item.id == "doll":
				game.doll_found = true
				game.player.blood_tears = 5
			if item.id == "vessel":
				game.player.max_flasks = 4
				game.player.flasks = mini(game.player.flasks+1,4)
			game.show_message(item.name,item.text)
			game._save()
		return true
	if room == "city" and p.x > 3640 and p.x < 3790 and bells.size() < 2:
		game.prompt = "Duas correntes prendem a passagem · cisterna e campanário"
	if room != "city":
		game.area_name = rooms[room].name
		# Altars in branches use the same prayer, equipment and checkpoint systems.
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
