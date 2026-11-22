extends RefCounted
## O mapa do Ato I. Cada sala é uma cena em scenes/salas/<id>.tscn (edite-as no editor do Godot):
## limites, piso, pintura, plataformas, alvenaria, inimigos, arenas e portas. Este script lê as cenas
## e entrega os mesmos dados de sempre ao jogo (exploration.gd, world_art.gd, main.gd, a prévia do editor).
## As coordenadas devolvidas são do mundo; dentro das cenas, cada sala começa em (0, 0) e "origem" diz onde
## esse canto fica no mundo.
##
## "ground" é a fração da altura da pintura em que fica o piso pintado. O chão de colisão é posto
## exatamente ali: antes várias salas usavam 0,86 por padrão e os personagens andavam acima ou na beira
## do piso desenhado (no Claustro e no Campanário, quase um palmo acima dos bancos e da escada).

## Ordem das salas: é a ordem do mapa, do modo dev e de rooms().keys().
const SALAS := ["city", "ossuary", "cistern", "cloister", "belfry", "archive", "refuge", "nave", "terrace", "court", "vale"]

static var _cache := {}

## Esquece o que foi lido (a prévia do editor chama ao atualizar, depois de editar uma sala).
static func recarregar() -> void:
	_cache.clear()

static func _dados() -> Dictionary:
	if not _cache.is_empty(): return _cache
	var d := {"rooms": {}, "platforms": [] as Array[Rect2], "blocks": [] as Array[Rect2], "arenas": [], "portas": [],
		"enemies": [], "criaturas": [], "city_platforms": [] as Array[Rect2], "city_enemies": [],
		"altars": [], "pickups": [] as Array[Dictionary], "city_lore": [], "city_candles": [] as Array[float], "pontos": {},
		"luzes": [], "city_abyss": Vector2.ZERO, "city_trechos": [], "city_decor": []}
	for id in SALAS:
		var sala: Node2D = load("res://scenes/salas/%s.tscn" % id).instantiate()
		d.rooms[id] = sala.dados()
		var cidade: bool = id == "city"
		for r in _filhos(sala, "Plataformas"): (d.city_platforms if cidade else d.platforms).append(r.retangulo_no_mundo(sala))
		for r in _filhos(sala, "Alvenaria"): d.blocks.append(r.retangulo_no_mundo(sala))
		for m in _filhos(sala, "Inimigos"):
			var p := _no_mundo(m, sala)
			if cidade:
				d.city_enemies.append([m.tipo, p.x, p.y, m.alcance])
			else:
				var e := [id, m.tipo, int(p.x), int(p.y), int(m.alcance)]
				if m.grupo >= 0: e.append(m.grupo)
				(d.criaturas if m.criatura else d.enemies).append(e)
		for a in _filhos(sala, "Arenas"):
			var p := _no_mundo(a, sala)
			var levas := []
			for leva in a.get_children():
				var onda := []
				for m in leva.get_children():
					var q := _no_mundo(m, sala)
					onda.append([m.tipo, int(q.x), int(q.y), int(m.alcance)])
				levas.append(onda)
			d.arenas.append({"id": a.id, "room": id, "x0": p.x, "x1": p.x + a.largura, "floor": p.y, "reward": a.recompensa, "waves": levas})
		for porta in _filhos(sala, "Portas"):
			d.portas.append({"ligacao": porta.ligacao, "lado": porta.lado, "rotulo": porta.rotulo, "trinco": porta.trinco, "sala": id, "pos": _no_mundo(porta, sala)})
		for altar in _filhos(sala, "Altares"):
			d.altars.append({"room": id, "pos": _no_mundo(altar, sala), "name": altar.nome})
		for v in _filhos(sala, "Vestigios"):
			var item := {"id": v.id_vestigio, "room": id, "pos": _no_mundo(v, sala), "name": v.nome, "text": v.texto}
			if v.recompensa >= 0: item["reward"] = v.recompensa
			if v.reliquia: item["relic"] = true
			d.pickups.append(item)
		for luz in _filhos(sala, "Luzes"):
			d.luzes.append({"room": id, "pos": _no_mundo(luz, sala), "color": luz.cor, "energy": luz.energia, "scale": luz.alcance})
		for p in _filhos(sala, "Pontos"):
			if d.pontos.has(p.ponto): push_error("Ponto %s repetido nas salas %s e %s." % [p.ponto, d.pontos[p.ponto].room, id])
			d.pontos[p.ponto] = {"room": id, "pos": _no_mundo(p, sala)}
		if cidade:
			for ins in _filhos(sala, "Inscricoes"):
				d.city_lore.append({"x": _no_mundo(ins, sala).x, "title": ins.titulo, "text": ins.texto})
			for vela in _filhos(sala, "Velas"): d.city_candles.append(_no_mundo(vela, sala).x)
			if sala.has_node("Abismo"):
				var borda := _no_mundo(sala.get_node("Abismo"), sala).x
				d.city_abyss = Vector2(borda, borda + sala.get_node("Abismo").largura)
			for t in _filhos(sala, "Trechos"): d.city_trechos.append([_no_mundo(t, sala).x, t.nome])
			d.city_trechos.sort_custom(func(a, b): return a[0] < b[0])
			for deco in _filhos(sala, "Decoracoes"): d.city_decor.append({"tipo": deco.tipo, "pos": _no_mundo(deco, sala)})
		sala.free()
	d["passages"] = _ligacoes(d.portas)
	d.erase("portas")
	_cache = d
	return _cache

static func _filhos(sala: Node, grupo: String) -> Array:
	return sala.get_node(grupo).get_children() if sala.has_node(grupo) else []

## Posição no mundo de um nó dentro da sala: soma as posições até a raiz (o canto da sala) e a origem dela.
static func _no_mundo(no: Node2D, sala: Node2D) -> Vector2:
	var p := Vector2.ZERO
	var atual: Node = no
	while atual != sala:
		p += atual.position
		atual = atual.get_parent()
	return p + sala.origem

## Junta as duas portas de cada ligação (mesmo "ligacao"); o lado "a" dá o rótulo e o trinco.
static func _ligacoes(portas: Array) -> Array[Dictionary]:
	var por_id := {}
	var ordem: Array[String] = []
	for porta in portas:
		if not por_id.has(porta.ligacao):
			por_id[porta.ligacao] = {}
			ordem.append(porta.ligacao)
		por_id[porta.ligacao][porta.lado] = porta
	var result: Array[Dictionary] = []
	for id in ordem:
		var lados: Dictionary = por_id[id]
		if not (lados.has("a") and lados.has("b")):
			push_error("Passagem %s sem as duas portas (lado a e lado b)." % id)
			continue
		var link := {"id": id, "a": lados.a.sala, "pa": lados.a.pos, "b": lados.b.sala, "pb": lados.b.pos, "label": lados.a.rotulo}
		if lados.a.trinco: link["latch"] = true
		result.append(link)
	return result

static func rooms() -> Dictionary:
	return _dados().rooms.duplicate(true)

static func platforms() -> Array[Rect2]:
	return _dados().platforms.duplicate()

# Alvenaria sólida que molda o chão: montes baixos e estrados escalonados, nunca mais altos que um salto.
static func blocks() -> Array[Rect2]:
	return _dados().blocks.duplicate()

## Combates com saídas bloqueadas: as duas extremidades do trecho se fecham e abrem quando a última leva cai.
## Levas: [tipo, x, y, alcance da patrulha].
static func arenas() -> Array:
	return _dados().arenas.duplicate(true)

static func passages() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for link in _dados().passages: result.append(link.duplicate(true))
	return result

## [sala, tipo, x, y, alcance da patrulha, grupo opcional]. Bruxas e duelistas do mesmo grupo formam um único encontro.
static func enemies() -> Array:
	return _dados().enemies.duplicate(true)

## Encontros das fichas aprovadas (criatura marcada no MarcadorInimigo), no mesmo formato de enemies().
static func criaturas_aprovadas() -> Array:
	return _dados().criaturas.duplicate(true)

## Altares de descanso: {"room", "pos", "name"}, a Cidade primeiro e depois as salas na ordem do mapa.
## O salvamento guarda o índice do altar nesta lista; altares novos entram no fim de cada sala.
static func altars() -> Array:
	return _dados().altars.duplicate(true)

static func city_altars() -> Array[Vector2]:
	var result: Array[Vector2] = []
	for a in _dados().altars:
		if a.room == "city": result.append(a.pos)
	return result

static func city_altar_names() -> Array[String]:
	var result: Array[String] = []
	for a in _dados().altars:
		if a.room == "city": result.append(a.name)
	return result

## Altares fora da Cidade, acrescentados por exploration.gd depois dos da Cidade.
static func extra_altars() -> Array[Vector2]:
	var result: Array[Vector2] = []
	for a in _dados().altars:
		if a.room != "city": result.append(a.pos)
	return result

## Nome de cada altar fora da Cidade, pela posição x (inteira).
static func altar_names_by_x() -> Dictionary:
	var result := {}
	for a in _dados().altars:
		if a.room != "city": result[int(a.pos.x)] = a.name
	return result

## Vestígios coletáveis: {"id", "room", "pos", "name", "text"} e, quando houver, "reward" e "relic".
static func pickups() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for item in _dados().pickups: result.append(item.duplicate(true))
	return result

## Inscrições da Cidade: {"x", "title", "text"}.
static func city_lore() -> Array:
	return _dados().city_lore.duplicate(true)

## Posição x das velas no chão da Cidade.
static func city_candles() -> Array[float]:
	return _dados().city_candles.duplicate()

## Posição no mundo de um ponto especial (nós Pontos das salas, scripts/salas/ponto.gd), pelo nome.
static func ponto(nome: String) -> Vector2:
	if not _dados().pontos.has(nome):
		push_error("Ponto especial %s não está em nenhuma sala (scenes/salas/, nó Pontos)." % nome)
		return Vector2.ZERO
	return _dados().pontos[nome].pos

## Sala em que fica um ponto especial.
static func sala_do_ponto(nome: String) -> String:
	return str(_dados().pontos[nome].room) if _dados().pontos.has(nome) else ""

## Luzes de cenário que tremulam (nós Luzes das salas): {"room", "pos", "color", "energy", "scale"}.
static func luzes() -> Array:
	return _dados().luzes.duplicate(true)

## O vão da ponte quebrada no chão da Cidade, de x (borda esquerda) a y (borda direita).
static func city_abyss() -> Vector2:
	return _dados().city_abyss

## Trechos da Cidade, em ordem de x: [x do começo, nome da área].
static func city_trechos() -> Array:
	return _dados().city_trechos.duplicate(true)

## Nome da área da Cidade numa posição x (o trecho que começa antes dela; antes do primeiro, o primeiro).
static func city_area_at(x: float) -> String:
	var trechos: Array = _dados().city_trechos
	if trechos.is_empty(): return str(_dados().rooms.city.name)
	var nome: String = trechos[0][1]
	for t in trechos:
		if x >= t[0]: nome = t[1]
	return nome

## Posições dos elementos de cenário da Cidade de um tipo ("gaiola", "pano", "corrente").
static func city_decor(tipo: String) -> Array[Vector2]:
	var result: Array[Vector2] = []
	for deco in _dados().city_decor:
		if deco.tipo == tipo: result.append(deco.pos)
	return result

## Plataformas da Cidade, construídas por main.gd (as das outras salas são de exploration.gd).
static func city_platforms() -> Array[Rect2]:
	return _dados().city_platforms.duplicate()

## Inimigos da Cidade: [tipo, x, y, alcance].
static func city_enemies() -> Array:
	return _dados().city_enemies.duplicate(true)


static func passage_face(link: Dictionary, from_a: bool) -> Dictionary:
	# Uma face é uma abertura na parede. Sua direção de chegada descreve a entrada
	# na sala de destino, independentemente dos deslocamentos globais artificiais das salas.
	var room: String = link.a if from_a else link.b
	var arrival := -1 if from_a else 1
	if link.id in ["shelter", "vows", "records"] and from_a: arrival = 1
	if link.id == "archive_return" and not from_a: arrival = -1
	# Portas em prateleiras e galerias: a chegada ocorre caminhando para o interior da plataforma.
	if link.id in ["nave_in", "sky"] and from_a: arrival = 1
	if link.id == "nave_out" and not from_a: arrival = -1
	var themes := {"city":"stone", "ossuary":"burial", "cistern":"water", "cloister":"stone", "belfry":"bell", "archive":"script", "refuge":"burial", "nave":"stone", "terrace":"bell", "court":"stone"}
	var width := 300.0
	if link.id in ["burial", "tower", "vows"]: width = 320.0
	if link.id in ["shelter", "records", "refuge_return"]: width = 280.0
	return {"room":room, "foot":link.pa if from_a else link.pb,
		"arrival_dir":arrival, "facing":-arrival, "width":width,
		"theme":themes[room], "spawn_offset":90.0}
