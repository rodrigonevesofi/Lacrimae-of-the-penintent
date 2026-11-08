extends RefCounted
## Coordinates describe physical rooms; passages form loops, not a sequence of screens.
static func rooms() -> Dictionary:
	return {
		"city": {"name":"CIDADE DA PENITÊNCIA", "bounds":Rect2(0,-300,4800,1250), "floor":600.0, "art":"vespera_panorama", "map":Vector2(450,330)},
		"ossuary": {"name":"OSSUÁRIO DOS SEM NOME", "bounds":Rect2(5200,-350,2600,1300), "floor":600.0, "art":"ossuary", "map":Vector2(210,430)},
		"cistern": {"name":"CISTERNA DOS NOMES", "bounds":Rect2(8200,-350,2400,1300), "floor":600.0, "art":"cistern", "map":Vector2(450,540)},
		"cloister": {"name":"CLAUSTRO DOS VOTOS", "bounds":Rect2(11000,-450,2800,1400), "floor":600.0, "art":"cloister", "map":Vector2(700,330)},
		"belfry": {"name":"CAMPANÁRIO DA VIGÍLIA", "bounds":Rect2(14200,-650,2000,2050), "floor":1100.0, "art":"tower", "map":Vector2(920,190)},
		"archive": {"name":"ARQUIVO DAS CONFISSÕES", "bounds":Rect2(16600,-350,2000,1300), "floor":600.0, "art":"cloister", "map":Vector2(700,110)},
		"refuge": {"name":"ABRIGO DAS CINZAS", "bounds":Rect2(19000,-350,2000,1300), "floor":600.0, "art":"ossuary", "map":Vector2(210,650)},
	}

static func platforms() -> Array[Rect2]:
	var result: Array[Rect2] = []
	# Ossuary upper burial gallery, a traversable alternate route to the refuge.
	for i in range(5): result.append(Rect2(5480+i*140,520-i*80,140,24))
	result.append(Rect2(6100,200,680,28))
	for i in range(4): result.append(Rect2(6780+i*135,280+i*80,150,24))
	# Cistern: a staggered ascent to the first bell mechanism; no double jump needed.
	for i in range(7): result.append(Rect2(8560+i*140,520-i*80,145,24))
	result.append(Rect2(9400,40,500,28))
	for i in range(5): result.append(Rect2(9840+i*130,120+i*80,150,24))
	# Cloister two-level loop: the lower passage and upper gallery reconnect.
	for i in range(7): result.append(Rect2(11320+i*140,520-i*80,145,24))
	result.append(Rect2(12160,40,1000,28))
	for i in range(5): result.append(Rect2(13160+i*110,120+i*80,145,24))
	# Bell tower: switchback stair flights, landings and a last double-jump gap.
	for i in range(7): result.append(Rect2(14500+i*140,1020-i*80,145,24))
	result.append(Rect2(15340,540,500,28))
	for i in range(7): result.append(Rect2(15340-i*140,460-i*80,145,24))
	result.append(Rect2(14350,-100,400,28))
	result.append(Rect2(14900,-260,450,28))
	# Archive high document shelf and refuge shrine.
	for base in [16880,19300]:
		for i in range(4): result.append(Rect2(base+i*140,520-i*80,145,24))
		result.append(Rect2(base+420,280,600,26))
	return result

static func passages() -> Array[Dictionary]:
	return [
		{"id":"burial", "a":"city","pa":Vector2(1160,600),"b":"ossuary","pb":Vector2(5360,600),"label":"Ossuário dos Sem Nome"},
		{"id":"drain", "a":"ossuary","pa":Vector2(7630,600),"b":"cistern","pb":Vector2(8370,600),"label":"Canal das lágrimas"},
		{"id":"shelter", "a":"ossuary","pa":Vector2(6450,200),"b":"refuge","pb":Vector2(19160,600),"label":"Abrigo das Cinzas"},
		{"id":"water_return", "a":"cistern","pa":Vector2(10400,600),"b":"city","pb":Vector2(2400,600),"label":"Grade do pátio","latch":true},
		{"id":"refuge_return", "a":"refuge","pa":Vector2(20830,600),"b":"cistern","pb":Vector2(8840,360),"label":"Escadaria do abrigo"},
		{"id":"vows", "a":"city","pa":Vector2(3080,600),"b":"cloister","pb":Vector2(11160,600),"label":"Claustro dos Votos"},
		{"id":"tower", "a":"cloister","pa":Vector2(13520,600),"b":"belfry","pb":Vector2(14350,1100),"label":"Campanário da Vigília"},
		{"id":"records", "a":"cloister","pa":Vector2(12800,40),"b":"archive","pb":Vector2(16760,600),"label":"Arquivo das Confissões"},
		{"id":"archive_return", "a":"archive","pa":Vector2(18430,600),"b":"belfry","pb":Vector2(15720,540),"label":"Passadiço dos copistas","latch":true},
		{"id":"tower_return", "a":"belfry","pa":Vector2(16040,1100),"b":"city","pb":Vector2(3380,600),"label":"Porta da vigília","latch":true},
	]

static func enemies() -> Array:
	return [
		["ossuary",0,5700,600,160],["ossuary",0,6250,200,170],["ossuary",1,6880,340,160],["ossuary",0,7350,600,110],
		["cistern",0,8680,600,140],["cistern",1,9180,300,130],["cistern",0,9680,40,130],["cistern",0,10100,600,150],
		["cloister",0,11700,600,170],["cloister",0,12400,40,150],["cloister",1,13000,300,130],["cloister",0,13380,600,100],
		["belfry",0,14800,1100,160],["belfry",1,15100,760,130],["belfry",0,15550,540,120],["belfry",1,14780,40,100],
		["archive",0,17380,600,170],["archive",1,17700,360,100],["refuge",0,19600,600,120],
	]


static func passage_face(link: Dictionary, from_a: bool) -> Dictionary:
	# A face is a doorway in a wall. Its arrival direction describes the walk into
	# the destination room, independent of the artificial global room offsets.
	var room: String = link.a if from_a else link.b
	var arrival := -1 if from_a else 1
	if link.id in ["shelter", "vows", "records"] and from_a: arrival = 1
	if link.id == "archive_return" and not from_a: arrival = -1
	var themes := {"city":"stone", "ossuary":"burial", "cistern":"water", "cloister":"stone", "belfry":"bell", "archive":"script", "refuge":"burial"}
	var width := 300.0
	if link.id in ["burial", "tower", "vows"]: width = 320.0
	if link.id in ["shelter", "records", "refuge_return"]: width = 280.0
	return {"room":room, "foot":link.pa if from_a else link.pb,
		"arrival_dir":arrival, "facing":-arrival, "width":width,
		"theme":themes[room], "spawn_offset":90.0}
