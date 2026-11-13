extends RefCounted
## Telemetria local da peregrinação: mortes e tempo por lugar, dúvidas feitas ao Confessor.
## Fica só no computador do jogador (user://telemetria.json); nada é enviado pela rede.
## Serve de contexto para o Confessor e de dado bruto para relatórios (tools/relatorio_telemetria.py).

const DEFAULT_PATH := "user://telemetria.json"
const AUTOSAVE_SECONDS := 30.0

var path := DEFAULT_PATH
var data := {}
var _since_save := 0.0


func _init() -> void:
	data = _empty()


func _empty() -> Dictionary:
	return {"version": 1, "sessions": 0, "deaths_by_room": {}, "seconds_by_room": {}, "questions": 0, "questions_by_topic": {}, "answers_by_source": {}}


func load_data() -> void:
	data = _empty()
	if not FileAccess.file_exists(path): return
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(path))
	if typeof(parsed) != TYPE_DICTIONARY: return
	for key in data:
		if not parsed.has(key): continue
		var value = parsed[key]
		# O JSON devolve todo número como float; contadores voltam a ser inteiros.
		if typeof(data[key]) == TYPE_INT and typeof(value) in [TYPE_INT, TYPE_FLOAT]:
			data[key] = maxi(0, int(value))
		elif typeof(value) == typeof(data[key]):
			data[key] = value


func save() -> void:
	_since_save = 0.0
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null: return
	file.store_string(JSON.stringify(data, "\t"))


func start_session() -> void:
	data.sessions = int(data.sessions) + 1
	save()


func _bump(table: String, key: String, amount: float = 1.0) -> void:
	var counts: Dictionary = data[table]
	counts[key] = float(counts.get(key, 0.0)) + amount


func record_death(room: String) -> void:
	_bump("deaths_by_room", room)
	save()


func record_question(topic: String) -> void:
	data.questions = int(data.questions) + 1
	_bump("questions_by_topic", topic)
	save()


func record_answer(source: String) -> void:
	_bump("answers_by_source", source)


func tick(delta: float, room: String) -> void:
	_bump("seconds_by_room", room, delta)
	_since_save += delta
	if _since_save >= AUTOSAVE_SECONDS: save()


## Lugares com mais mortes, do maior para o menor: [[sala, mortes], ...]
func top_deaths(limit: int = 3) -> Array:
	var rows: Array = []
	for room in data.deaths_by_room:
		rows.append([room, int(data.deaths_by_room[room])])
	rows.sort_custom(func(a, b): return a[1] > b[1])
	return rows.slice(0, limit)
