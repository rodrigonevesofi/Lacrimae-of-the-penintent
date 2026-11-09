extends RefCounted
## Coordinates describe physical rooms; passages form loops, not a sequence of screens.
static func rooms() -> Dictionary:
	return {
		"city": {"name":"CIDADE DA PENITÊNCIA", "bounds":Rect2(0,-300,4800,1250), "floor":600.0, "art":"vespera_panorama", "map":Vector2(450,330)},
		"ossuary": {"name":"OSSUÁRIO DOS SEM NOME", "bounds":Rect2(5200,-350,2600,1300), "floor":600.0, "art":"ossuary", "map":Vector2(210,430)},
		"cistern": {"name":"CISTERNA DOS NOMES", "bounds":Rect2(8200,-350,2400,1300), "floor":600.0, "art":"cistern", "map":Vector2(450,540)},
		"cloister": {"name":"CLAUSTRO DOS VOTOS", "bounds":Rect2(11000,-450,2800,1400), "floor":600.0, "art":"cloister", "map":Vector2(700,330)},
		"belfry": {"name":"CAMPANÁRIO DA VIGÍLIA", "bounds":Rect2(14200,-650,2000,2050), "floor":1100.0, "art":"tower", "map":Vector2(920,190)},
		"archive": {"name":"ARQUIVO DAS CONFISSÕES", "bounds":Rect2(16600,-350,2000,1300), "floor":600.0, "art":"gallery", "ground":0.756, "art_h":1250.0, "map":Vector2(700,110)},
		"refuge": {"name":"ABRIGO DAS CINZAS", "bounds":Rect2(19000,-350,2000,1300), "floor":600.0, "art":"gates", "ground":0.80, "art_h":1250.0, "outdoor":true, "map":Vector2(210,650)},
		"nave": {"name":"NAVE DO SILÊNCIO", "bounds":Rect2(21400,-450,2600,1400), "floor":600.0, "art":"nave_silencio", "ground":0.86, "art_h":880.0, "map":Vector2(20,230)},
		"terrace": {"name":"TERRAÇO DOS SINOS", "bounds":Rect2(24400,-350,2600,1300), "floor":600.0, "art":"terraco_sinos", "ground":0.86, "art_h":880.0, "map":Vector2(1000,380)},
		"court": {"name":"PÁTIO DOS PORTÕES SELADOS", "bounds":Rect2(27400,-350,2000,1300), "floor":600.0, "art":"patio_portoes", "ground":0.86, "art_h":800.0, "map":Vector2(1000,560)},
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
	# Nave do Silêncio: coro balcony reached by a short climb, and a long loft over the dais.
	result.append(Rect2(21950,520,150,24)); result.append(Rect2(22110,440,150,24)); result.append(Rect2(22270,360,420,26))
	for i in range(4): result.append(Rect2(22800+i*140,520-i*80,145,24))
	result.append(Rect2(23220,200,680,28))
	# Terraço dos Sinos: stair to a high walkway above the bell-rope.
	for i in range(5): result.append(Rect2(25300+i*130,520-i*80,140,24))
	result.append(Rect2(25820,200,640,28))
	# Pátio dos Portões Selados: balustrade over the sealed doors.
	result.append(Rect2(28100,520,200,24)); result.append(Rect2(28300,440,200,24)); result.append(Rect2(28500,360,440,26))
	return result

# Solid masonry that shapes the ground: low mounds and stepped daises, never taller than one jump.
static func blocks() -> Array[Rect2]:
	return [
		Rect2(6900,550,300,50), Rect2(6960,500,180,100),      # ossuary: burial mound
		Rect2(9000,550,240,50),                                # cistern: fallen cornice
		Rect2(12000,550,300,50), Rect2(12060,500,160,100),    # cloister: choir step
		Rect2(16960,550,200,50),                               # archive: toppled desk
		Rect2(19900,550,200,50),                               # refuge: collapsed wall
		Rect2(22000,555,180,45),                               # nave: broken pew base
		Rect2(23350,550,260,50), Rect2(23410,500,140,100),    # nave: dais under the loft
		Rect2(24750,550,240,50),                               # terrace: bell frame
		Rect2(26250,550,220,50), Rect2(26300,500,120,100),    # terrace: parapet
		Rect2(28200,550,200,50),                               # court: threshold step
	]

## Locked fights: the exits close at both ends of a stretch of floor and open when the last wave falls.
## Waves are [kind, x, y, patrol range]. Spans were chosen away from doors, altars, pickups and masonry.
static func arenas() -> Array:
	return [
		{"id":"cistern","room":"cistern","x0":9320.0,"x1":10190.0,"floor":600.0,"reward":200,"waves":[[[0,9480,600,60],[4,10060,600,60]],[[6,9800,480,100],[0,9420,600,60]]]},
		{"id":"cloister","room":"cloister","x0":12380.0,"x1":13310.0,"floor":600.0,"reward":250,"waves":[[[4,12560,600,60],[4,13180,600,60]],[[3,12850,600,50]]]},
		{"id":"belfry","room":"belfry","x0":14630.0,"x1":15830.0,"floor":1100.0,"reward":250,"waves":[[[0,14780,1100,60],[0,15650,1100,60]],[[8,15200,1100,60],[7,15450,1100,60],[7,15520,1100,60]]]},
		{"id":"archive","room":"archive","x0":17240.0,"x1":18220.0,"floor":600.0,"reward":200,"waves":[[[0,17900,600,60],[0,18150,600,60]]]},
	]

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
		{"id":"nave_in", "a":"archive","pa":Vector2(17400,280),"b":"nave","pb":Vector2(21560,600),"label":"Nave do Silêncio"},
		{"id":"nave_out", "a":"nave","pa":Vector2(23850,600),"b":"refuge","pb":Vector2(20260,280),"label":"Passagem do coro"},
		{"id":"sky", "a":"belfry","pa":Vector2(14420,-100),"b":"terrace","pb":Vector2(24560,600),"label":"Terraço dos Sinos"},
		{"id":"seal_road", "a":"terrace","pa":Vector2(26900,600),"b":"court","pb":Vector2(27560,600),"label":"Pátio dos Portões Selados"},
		{"id":"bell_walk", "a":"terrace","pa":Vector2(26600,600),"b":"cloister","pb":Vector2(12950,40),"label":"Passarela dos sinos","latch":true},
	]

## [room, kind, x, y, patrol range, optional group]. Kinds: 0 devotee, 1 weeper, 3 Devourer, 4 flagellant,
## 5 coven witch, 6 Asmodea, 7 duelist. Witches and duelists that share a group fight as one encounter.
static func enemies() -> Array:
	return [
		["ossuary",0,5700,600,160],["ossuary",0,6250,200,170],["ossuary",1,6880,340,160],["ossuary",0,7350,600,110],
		["ossuary",7,6120,600,70,1],["ossuary",7,6200,600,70,1],
		["cistern",0,8680,600,140],["cistern",6,9100,480,130],["cistern",0,9680,40,130],["cistern",0,10100,600,150],
		["cloister",4,11700,600,170],["cloister",0,12400,40,150],["cloister",1,13000,300,130],["cloister",4,13380,600,100],
		["belfry",0,14800,1100,160],["belfry",1,15100,760,130],["belfry",3,15550,540,120],["belfry",1,14780,40,100],
		["archive",0,17380,600,170],["archive",5,17450,525,60,1],["archive",5,17700,510,60,1],["archive",5,17950,525,60,1],
		["refuge",4,19600,600,120],["refuge",0,20480,600,80],["refuge",1,19750,500,110],
		["nave",0,22450,600,120],["nave",6,22600,480,150],["nave",1,23600,90,100],["nave",3,23200,600,70],
		["terrace",1,24900,250,160],["terrace",7,25450,600,60,2],["terrace",7,25530,600,60,2],["terrace",6,26100,80,120],
		["court",3,28650,600,100],["court",1,28300,250,120],["court",0,29050,600,80],["nave",8,22800,600,120],["terrace",8,26000,600,120],
	]


static func passage_face(link: Dictionary, from_a: bool) -> Dictionary:
	# A face is a doorway in a wall. Its arrival direction describes the walk into
	# the destination room, independent of the artificial global room offsets.
	var room: String = link.a if from_a else link.b
	var arrival := -1 if from_a else 1
	if link.id in ["shelter", "vows", "records"] and from_a: arrival = 1
	if link.id == "archive_return" and not from_a: arrival = -1
	# Doors on shelves and galleries: arrive walking toward the interior of the platform.
	if link.id in ["nave_in", "sky"] and from_a: arrival = 1
	if link.id == "nave_out" and not from_a: arrival = -1
	var themes := {"city":"stone", "ossuary":"burial", "cistern":"water", "cloister":"stone", "belfry":"bell", "archive":"script", "refuge":"burial", "nave":"stone", "terrace":"bell", "court":"stone"}
	var width := 300.0
	if link.id in ["burial", "tower", "vows"]: width = 320.0
	if link.id in ["shelter", "records", "refuge_return"]: width = 280.0
	return {"room":room, "foot":link.pa if from_a else link.pb,
		"arrival_dir":arrival, "facing":-arrival, "width":width,
		"theme":themes[room], "spawn_offset":90.0}
