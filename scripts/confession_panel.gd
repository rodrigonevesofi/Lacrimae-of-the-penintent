extends Control
## Confessionário: painel de conversa aberto em um altar com C.
## O jogo fica pausado enquanto o painel está aberto; ENTER envia, ESC fecha.

const GOLD := Color(0.86, 0.7, 0.38)
const PANEL := Rect2(170, 60, 940, 600)
const LOG_TOP := 168.0
const LOG_BOTTOM := 548.0
const LINE_H := 24.0
const TEXT_SIZE := 18

var game = null
var confessor = null
var input: LineEdit
var font: Font
var title_font: Font
var panel_art: AtlasTexture
var entries: Array[Dictionary] = []
var altar_name := ""
var listen_t := 0.0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	size = Vector2(1280, 720)
	visible = false
	font = ThemeDB.fallback_font
	title_font = load("res://assets/title_font.ttf")
	panel_art = AtlasTexture.new()
	panel_art.atlas = load("res://assets/reliquary_ui.png")
	panel_art.region = Rect2(535, 580, 540, 345)
	panel_art.filter_clip = true
	input = LineEdit.new()
	input.position = Vector2(PANEL.position.x + 50, 562)
	input.size = Vector2(PANEL.size.x - 100, 40)
	input.max_length = confessor.MAX_QUESTION if confessor != null else 240
	input.placeholder_text = "Escreva sua confissão ou sua dúvida…"
	input.add_theme_font_size_override("font_size", 18)
	input.add_theme_color_override("font_color", Color("eadcc4"))
	input.add_theme_color_override("font_placeholder_color", Color(0.75, 0.68, 0.58, 0.55))
	input.add_theme_color_override("caret_color", GOLD)
	var box := StyleBoxFlat.new()
	box.bg_color = Color(0.03, 0.02, 0.03, 0.92)
	box.border_color = Color(GOLD, 0.6)
	box.set_border_width_all(1)
	box.set_content_margin_all(8)
	input.add_theme_stylebox_override("normal", box)
	input.add_theme_stylebox_override("focus", box)
	add_child(input)
	input.text_submitted.connect(_on_submitted)
	if confessor != null: confessor.answered.connect(_on_answered)


func open(name_of_altar: String) -> void:
	altar_name = name_of_altar
	visible = true
	if entries.is_empty():
		entries.append({"who": "confessor", "text": "Ajoelhe-se, peregrino. Aqui a culpa pode falar sem ser julgada. Diga o que pesa, ou pergunte o que o caminho esconde."})
	input.text = ""
	input.editable = true
	input.grab_focus()


func close() -> void:
	if not visible: return
	visible = false
	input.release_focus()
	if game != null: game.close_confession()


func _input(event: InputEvent) -> void:
	if not visible: return
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
		close()
		get_viewport().set_input_as_handled()


func _on_submitted(text: String) -> void:
	text = text.strip_edges()
	if text.is_empty() or confessor == null or confessor.busy: return
	entries.append({"who": "you", "text": text})
	input.text = ""
	listen_t = 0.0
	confessor.ask(text)


func _on_answered(text: String, _source: String) -> void:
	entries.append({"who": "confessor", "text": text})
	while entries.size() > 24: entries.pop_front()


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
	var voice: String = confessor.voice_label() if confessor != null else ""
	_text(Vector2(PANEL.position.x + 50, PANEL.end.y - 14), voice, 12, Color("8c8170"))
	_text(Vector2(PANEL.position.x, PANEL.end.y - 14), "ENTER · confessar     ESC · levantar-se", 13, Color("bba27c"), HORIZONTAL_ALIGNMENT_RIGHT, PANEL.size.x - 50)
