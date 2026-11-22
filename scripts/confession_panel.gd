extends Control
## Confessionário: painel de conversa aberto com C (ou Y na pausa) fora de combate.
## O jogo fica pausado enquanto o painel está aberto. Teclado: digitar e ENTER, ou
## ↑/↓ + ENTER nas perguntas prontas; ESC fecha. Controle: ↑/↓ escolhe, A pergunta, B fecha.

const GOLD := Color(0.86, 0.7, 0.38)
const PANEL := Rect2(170, 60, 940, 600)
const LOG_TOP := 168.0
const LOG_BOTTOM := 400.0
const SUG_TOP := 410.0
const SUG_H := 24.0
const SUG_X := 220.0
const SUG_W := 840.0
const LINE_H := 24.0
const TEXT_SIZE := 18

var game = null
var confessor = null
## Campo de pergunta, montado e estilizado em scenes/interface.tscn.
@onready var input: LineEdit = $Input
var font: Font
var title_font: Font
var panel_art: AtlasTexture
var entries: Array[Dictionary] = []
var altar_name := ""
var listen_t := 0.0
var suggestions: Array[String] = []
var selected := 0
var _stick_dir := 0


## Fica em scenes/interface.tscn (processa mesmo em pausa, ignora o mouse, começa oculto).
## game e confessor precisam ser atribuídos antes de a cena entrar na árvore.
func _ready() -> void:
	font = ThemeDB.fallback_font
	title_font = load("res://assets/title_font.ttf")
	panel_art = AtlasTexture.new()
	panel_art.atlas = load("res://assets/reliquary_ui.png")
	panel_art.region = Rect2(535, 580, 540, 345)
	panel_art.filter_clip = true
	input.text_submitted.connect(_on_submitted)


## Liga o painel ao confessor. A main chama depois que a interface já está na árvore.
func conectar(c) -> void:
	if confessor != null and confessor.answered.is_connected(_on_answered): confessor.answered.disconnect(_on_answered)
	confessor = c
	if confessor == null: return
	input.max_length = confessor.MAX_QUESTION
	confessor.answered.connect(_on_answered)


func open(where: String) -> void:
	altar_name = where
	visible = true
	if entries.is_empty():
		entries.append({"who": "confessor", "text": "Ajoelhe-se, peregrino. Aqui a culpa pode falar sem ser julgada. Diga o que pesa, ou pergunte o que o caminho esconde."})
	_refresh_suggestions()
	input.text = ""
	input.editable = true
	input.grab_focus()


func _refresh_suggestions() -> void:
	suggestions = confessor.suggestions() if confessor != null else []
	selected = clampi(selected, 0, maxi(0, suggestions.size() - 1))


func _move(step: int) -> void:
	if suggestions.is_empty(): return
	selected = (selected + step + suggestions.size()) % suggestions.size()


func _ask_selected() -> void:
	if selected >= 0 and selected < suggestions.size(): _send(suggestions[selected])


func _suggestion_rect(i: int) -> Rect2:
	return Rect2(SUG_X, SUG_TOP + 20 + i * SUG_H, SUG_W, SUG_H - 2)


func close() -> void:
	if not visible: return
	visible = false
	input.release_focus()
	if game != null: game.close_confession()


func _input(event: InputEvent) -> void:
	if not visible: return
	var handled := true
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE and not event.echo:
		close()
	elif event is InputEventKey and event.pressed and event.keycode in [KEY_UP, KEY_DOWN] and input.text.is_empty():
		_move(-1 if event.keycode == KEY_UP else 1)
	elif event is InputEventJoypadButton and event.pressed:
		match event.button_index:
			JOY_BUTTON_B, JOY_BUTTON_START: close()
			JOY_BUTTON_A: _ask_selected()
			JOY_BUTTON_DPAD_UP: _move(-1)
			JOY_BUTTON_DPAD_DOWN: _move(1)
			_: handled = false
	elif event is InputEventJoypadMotion and event.axis == JOY_AXIS_LEFT_Y:
		# O analógico anda uma linha por inclinação, não uma por quadro.
		var dir := 0 if absf(event.axis_value) < 0.6 else (1 if event.axis_value > 0.0 else -1)
		if dir != 0 and dir != _stick_dir: _move(dir)
		_stick_dir = dir
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		handled = false
		for i in range(suggestions.size()):
			if _suggestion_rect(i).has_point(event.position):
				selected = i
				_ask_selected()
				handled = true
	else:
		handled = false
	if handled: get_viewport().set_input_as_handled()


func _on_submitted(text: String) -> void:
	text = text.strip_edges()
	# ENTER com o campo vazio envia a pergunta pronta selecionada.
	if text.is_empty(): _ask_selected()
	else: _send(text)


func _send(text: String) -> void:
	if text.is_empty() or confessor == null or confessor.busy: return
	entries.append({"who": "you", "text": text})
	input.text = ""
	listen_t = 0.0
	confessor.ask(text)


func _on_answered(text: String, _source: String) -> void:
	entries.append({"who": "confessor", "text": text})
	while entries.size() > 24: entries.pop_front()
	_refresh_suggestions()


func _process(delta: float) -> void:
	if not visible: return
	listen_t += delta
	input.editable = confessor == null or not confessor.busy
	if input.editable and not input.has_focus(): input.grab_focus()
	queue_redraw()


func _wrap(text: String, width: float) -> Array[String]:
	var lines: Array[String] = []
	for paragraph in text.split("\n"):
		var line := ""
		for word in paragraph.split(" "):
			var candidate: String = word if line.is_empty() else line + " " + word
			if font.get_string_size(candidate, HORIZONTAL_ALIGNMENT_LEFT, -1, TEXT_SIZE).x > width and not line.is_empty():
				lines.append(line)
				line = word
			else: line = candidate
		lines.append(line)
	return lines


func _text(pos: Vector2, s: String, fsize: int, col: Color, align: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT, w: float = -1.0) -> void:
	draw_string(font, pos + Vector2(2, 2), s, align, w, fsize, Color(0, 0, 0, col.a * 0.8))
	draw_string(font, pos, s, align, w, fsize, col)


func _draw() -> void:
	if not visible: return
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.012, 0.008, 0.014, 0.88))
	draw_texture_rect(panel_art, PANEL, false)
	draw_rect(PANEL.grow(-10), Color(0.015, 0.009, 0.015, 0.82))
	# A grade do confessionário, discreta, atrás da conversa.
	for i in range(1, 12):
		var x := PANEL.position.x + PANEL.size.x * float(i) / 12.0
		draw_line(Vector2(x, LOG_TOP - 8), Vector2(x, LOG_BOTTOM + 4), Color(GOLD, 0.05), 2)
	var heading_pos := Vector2(PANEL.position.x, PANEL.position.y + 56)
	draw_string(title_font, heading_pos + Vector2(0, 3), "CONFESSIONÁRIO", HORIZONTAL_ALIGNMENT_CENTER, PANEL.size.x, 30, Color(0, 0, 0, 0.7))
	draw_string(title_font, heading_pos, "CONFESSIONÁRIO", HORIZONTAL_ALIGNMENT_CENTER, PANEL.size.x, 30, Color("d3b58a"))
	_text(Vector2(PANEL.position.x, PANEL.position.y + 84), altar_name.to_upper(), 13, Color("a8977b"), HORIZONTAL_ALIGNMENT_CENTER, PANEL.size.x)
	draw_line(Vector2(PANEL.position.x + 80, 152), Vector2(PANEL.end.x - 80, 152), Color("765b3d"), 1)
	# Monta as linhas de baixo para cima, para que a fala mais recente fique sempre visível.
	var rows: Array = []
	var width := PANEL.size.x - 130
	for entry in entries:
		var mine: bool = entry.who == "you"
		var prefix := "Você: " if mine else ""
		var color := Color("a9b3b8") if mine else Color("e8d6b6")
		var wrapped := _wrap(prefix + str(entry.text), width)
		for line in wrapped: rows.append([line, color, mine])
		rows.append(["", color, mine])
	if confessor != null and confessor.busy:
		rows.append(["O confessor escuta" + ".".repeat(1 + int(listen_t * 2.5) % 3), Color(GOLD, 0.8), false])
	var capacity := int((LOG_BOTTOM - LOG_TOP) / LINE_H)
	var first := maxi(0, rows.size() - capacity)
	for i in range(first, rows.size()):
		var row: Array = rows[i]
		var x := PANEL.position.x + (85.0 if row[2] else 65.0)
		_text(Vector2(x, LOG_TOP + 14 + (i - first) * LINE_H), row[0], TEXT_SIZE, row[1])
	# Perguntas prontas: para quem joga com controle, ou para quem não sabe o que perguntar.
	var busy: bool = confessor != null and confessor.busy
	_text(Vector2(SUG_X, SUG_TOP + 10), "PERGUNTAS PRONTAS", 12, Color("a8977b"))
	for i in range(suggestions.size()):
		var r := _suggestion_rect(i)
		var on := i == selected
		if on:
			draw_rect(r, Color(0.42, 0.32, 0.17, 0.35))
			draw_rect(r, Color(GOLD, 0.7), false, 1)
		var tone := Color("f0dfbd") if on else Color("b9ad98")
		if busy: tone = Color(tone, 0.45)
		_text(r.position + Vector2(12, 18), ("▶  " if on else "    ") + suggestions[i], 16, tone)
	var voice: String = confessor.voice_label() if confessor != null else ""
	var pad: bool = game != null and game.using_pad
	var hint := "↑↓ escolher     A · perguntar     B · levantar-se" if pad else "ENTER · confessar     ↑↓ perguntas prontas     ESC · levantar-se"
	_text(Vector2(PANEL.position.x + 50, PANEL.end.y - 14), voice, 12, Color("8c8170"))
	_text(Vector2(PANEL.position.x, PANEL.end.y - 14), hint, 13, Color("bba27c"), HORIZONTAL_ALIGNMENT_RIGHT, PANEL.size.x - 50)
