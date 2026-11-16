extends Node2D
## Pintura viva: a pintura de cada sala passa por um shader que a faz se mexer.
## Antes a pintura era desenhada parada por world_art.gd e só o que ficava por cima dela se movia.
## Agora ela é um Sprite2D com o shader `pintura_viva`: os panos e a hera balançam ao vento, a água
## corre, as nuvens passam, as chamas tremem com o seu halo e os vitrais respiram.
## O que se move em cada pintura vem das máscaras em assets/vivo/ (tools/gerar_mascaras_vivas.py).
##
## No Terraço dos Sinos chove do lado de fora dos arcos e relampeja. O relâmpago é uma animação do
## AnimationPlayer: uma trilha anima o clarão e outra chama o trovão no tempo certo.
## Com "reduzir pulsos" ligado, as chamas não tremem e não há relâmpago; o resto continua.

const SHADER := preload("res://shaders/pintura_viva.gdshader")
const PANORAMA_RECT := Rect2(0, -770, 4800, 1600)

## vento: força do balanço. faixa: a partir de que altura da pintura a água é lâmina parada.
## chuva: tempestade do lado de fora. halo: cor da luz das chamas.
const SALAS := {
	"city": {"vento": 1.0},
	"ossuary": {"vento": 0.45},
	"cistern": {"vento": 0.5, "faixa": 0.925},
	"cloister": {"vento": 1.15},
	"belfry": {"vento": 1.0},
	"archive": {"vento": 0.45},
	"refuge": {"vento": 1.5},
	"nave": {"vento": 0.7, "halo": Color(1.0, 0.70, 0.36)},
	"terrace": {"vento": 1.7, "chuva": 1.0},
	"court": {"vento": 1.25},
}

var game
var sala := ""
var pintura: Sprite2D
var rodape: Sprite2D
var material_vivo: ShaderMaterial
var fundo := Rect2()
var rajada := 0.0
var rajada_x := 0.5
## Animado pelo AnimationPlayer durante o relâmpago.
var clarao := 0.0
var relampago: AnimationPlayer
var proximo_raio := 9.0
var chuva_som: AudioStreamPlayer
var trovoes: Array = []
var trovao_som: AudioStreamPlayer
var raios := 0
## F6: desliga o shader e devolve a pintura parada a world_art.gd.
var desligada := false

func _ready() -> void:
	material_vivo = ShaderMaterial.new()
	material_vivo.shader = SHADER
	pintura = Sprite2D.new()
	pintura.centered = false
	pintura.material = material_vivo
	add_child(pintura)
	# Rodapé: a última faixa da pintura, espelhada e escurecida, continua a pedra para baixo quando a
	# pintura termina antes da borda da tela (acontece nas salas em que o piso pintado fica bem embaixo).
	rodape = Sprite2D.new()
	rodape.centered = false
	rodape.region_enabled = true
	rodape.modulate = Color(0.42, 0.40, 0.43)
	var liso := CanvasItemMaterial.new()
	liso.light_mode = CanvasItemMaterial.LIGHT_MODE_UNSHADED
	rodape.material = liso
	rodape.visible = false
	add_child(rodape)
	_montar_relampago()
	_montar_sons()

## O relâmpago: dois clarões curtos e um mais longo que se apaga; o trovão vem um instante depois.
func _montar_relampago() -> void:
	relampago = AnimationPlayer.new()
	add_child(relampago)
	var anim := Animation.new()
	anim.length = 2.4
	var luz := anim.add_track(Animation.TYPE_VALUE)
	anim.track_set_path(luz, NodePath(".:clarao"))
	for chave in [[0.0, 0.0], [0.05, 1.0], [0.12, 0.2], [0.20, 0.85], [0.34, 0.35], [0.50, 0.6], [1.3, 0.0]]:
		anim.track_insert_key(luz, chave[0], chave[1])
	var chamada := anim.add_track(Animation.TYPE_METHOD)
	anim.track_set_path(chamada, NodePath("."))
	anim.track_insert_key(chamada, 0.45, {"method": "_trovao", "args": []})
	var biblioteca := AnimationLibrary.new()
	biblioteca.add_animation("relampago", anim)
	relampago.add_animation_library("", biblioteca)

func _montar_sons() -> void:
	chuva_som = AudioStreamPlayer.new()
	chuva_som.volume_db = -60.0
	if ResourceLoader.exists("res://assets/audio/amb_chuva.wav"):
		var chuva: AudioStreamWAV = load("res://assets/audio/amb_chuva.wav")
		chuva.loop_mode = AudioStreamWAV.LOOP_FORWARD
		chuva.loop_end = chuva.data.size() / 4
		chuva_som.stream = chuva
	add_child(chuva_som)
	trovao_som = AudioStreamPlayer.new()
	trovao_som.volume_db = -7.0
	add_child(trovao_som)
	for i in range(1, 4):
		var caminho := "res://assets/audio/trovao_0%d.wav" % i
		if ResourceLoader.exists(caminho): trovoes.append(load(caminho))

func _trovao() -> void:
	if trovoes.is_empty() or DisplayServer.get_name() == "headless": return
	trovao_som.stream = trovoes[raios % trovoes.size()]
	trovao_som.pitch_scale = randf_range(0.88, 1.08)
	trovao_som.play()

## A sala tem pintura viva? world_art.gd deixa de desenhar a pintura parada quando tem.
## Monta na hora se a sala acabou de mudar, para não haver um quadro sem fundo.
func ativa(id: String) -> bool:
	if desligada: return false
	if id != sala and _sala_atual() == id: _montar(id)
	return id != "" and id == sala and pintura.visible

func _sala_atual() -> String:
	if game == null or game.exploration == null: return ""
	var id: String = game.exploration.room
	if not SALAS.has(id): return ""
	return id

func _arte(id: String) -> String:
	return str(game.exploration.rooms[id].art)

## Prepara a pintura e as máscaras da sala em que o Penitente acabou de entrar.
func _montar(id: String) -> void:
	sala = id
	pintura.visible = false
	rodape.visible = false
	rajada = 0.0
	if relampago.is_playing(): relampago.stop()
	clarao = 0.0
	proximo_raio = 7.0
	if id == "":
		queue_redraw()
		return
	var arte := _arte(id)
	var marcas_a := "res://assets/vivo/%s_a.png" % arte
	var marcas_b := "res://assets/vivo/%s_b.png" % arte
	if not ResourceLoader.exists(marcas_a) or not ResourceLoader.exists(marcas_b):
		queue_redraw()
		return
	var data: Dictionary = game.exploration.rooms[id]
	var textura: Texture2D = game.art.art_texture(arte)
	var ret: Rect2
	if id == "city":
		ret = PANORAMA_RECT
		fundo = Rect2()
	else:
		var b: Rect2 = data.bounds
		var altura: float = game.exploration.art_height(id)
		ret = Rect2(b.position.x, float(data.floor) - altura * game.exploration.ground_line(id), b.size.x, altura)
		fundo = b
	pintura.texture = textura
	pintura.position = ret.position
	pintura.scale = ret.size / textura.get_size()
	# Quanto falta de pintura abaixo do chão para cobrir o que a câmera mostra (220 unidades).
	var falta: float = float(data.floor) + 226.0 - ret.end.y if id != "city" else 0.0
	rodape.visible = falta > 2.0
	if rodape.visible:
		var faixa: float = minf(falta / pintura.scale.y, textura.get_size().y * 0.12)
		rodape.texture = textura
		rodape.region_rect = Rect2(0, textura.get_size().y - faixa, textura.get_size().x, faixa)
		rodape.scale = Vector2(pintura.scale.x, -falta / faixa)
		rodape.position = Vector2(ret.position.x, ret.end.y + falta)
	var cfg: Dictionary = SALAS[id]
	material_vivo.set_shader_parameter("marcas_a", load(marcas_a))
	material_vivo.set_shader_parameter("marcas_b", load(marcas_b))
	material_vivo.set_shader_parameter("texel", Vector2.ONE / textura.get_size())
	material_vivo.set_shader_parameter("vento", float(cfg.get("vento", 1.0)))
	material_vivo.set_shader_parameter("faixa_agua", float(cfg.get("faixa", 2.0)))
	material_vivo.set_shader_parameter("chuva", float(cfg.get("chuva", 0.0)))
	material_vivo.set_shader_parameter("cor_halo", cfg.get("halo", Color(1.0, 0.62, 0.28)))
	pintura.visible = true
	queue_redraw()

## Um golpe forte por perto sopra os panos da pintura, como já balançava o que pende do teto.
func impulse(at_x: float, strength: float) -> void:
	if not pintura.visible: return
	rajada = minf(rajada + strength * 0.6, 1.6)
	rajada_x = clampf((at_x - pintura.position.x) / (pintura.texture.get_size().x * pintura.scale.x), 0.0, 1.0)

func tem_chuva() -> bool:
	return not desligada and pintura.visible and float(SALAS[sala].get("chuva", 0.0)) > 0.0

func _process(delta: float) -> void:
	var id := _sala_atual()
	if id != sala: _montar(id)
	visible = pintura.visible and not desligada
	var chovendo: bool = tem_chuva() and game.state == "play"
	# O som da chuva entra e sai aos poucos ao trocar de sala.
	if chuva_som.stream != null and DisplayServer.get_name() != "headless":
		var alvo := -15.0 if chovendo else -60.0
		chuva_som.volume_db = move_toward(chuva_som.volume_db, alvo, delta * 40.0)
		if chovendo and not chuva_som.playing: chuva_som.play()
		elif not chovendo and chuva_som.playing and chuva_som.volume_db <= -59.0: chuva_som.stop()
	if not visible: return
	rajada = move_toward(rajada, 0.0, delta * 0.9)
	var reduzido: bool = game.is_reduced_pulses_enabled()
	if tem_chuva():
		proximo_raio -= delta
		if proximo_raio <= 0.0:
			proximo_raio = randf_range(9.0, 19.0)
			raios += 1
			# Sem clarões com "reduzir pulsos": só o trovão distante.
			if reduzido: _trovao()
			else: relampago.play("relampago")
	if reduzido and clarao > 0.0:
		relampago.stop()
		clarao = 0.0
	material_vivo.set_shader_parameter("tempo", game.t)
	material_vivo.set_shader_parameter("rajada", rajada)
	material_vivo.set_shader_parameter("rajada_x", rajada_x)
	material_vivo.set_shader_parameter("pulso", 0.0 if reduzido else 1.0)
	material_vivo.set_shader_parameter("clarao", clarao)

func _draw() -> void:
	# O fundo escuro que world_art.gd desenhava atrás da pintura.
	if pintura != null and pintura.visible and fundo.size.x > 0.0:
		draw_rect(fundo, Color("17181d"))
