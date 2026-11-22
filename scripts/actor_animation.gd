extends AnimatedSprite2D
## Os quadros de animação são desenhos distintos recortados de uma grade regular de origem.
## A jogabilidade e o contato visual compartilham a linha do tempo normalizada de cada ação.
##
## Os quadros de cada personagem ficam num SpriteFrames em assets/animation/quadros/<ator>.tres (abra no painel
## SpriteFrames do editor para ver attack_a, hurt, parry...). Esses arquivos são gerados a partir de
## assets/animation/clips.json por tools/gerar_quadros.gd: para mudar recortes, fps ou laços, edite clips.json e
## rode o gerador (tests/quadros_smoke.gd acusa quando os dois divergem). clips.json também guarda o que o
## SpriteFrames não tem: a âncora dos pés e os deslocamentos usados em select().
const PASTA_QUADROS := "res://assets/animation/quadros/"
static var manifest_cache: Dictionary = {}
static var frames_cache: Dictionary = {}
var definitions: Dictionary = {}
var actor := ""
var unit_scale := 0.44
var manual := false

const SHADER_ATOR := preload("res://shaders/ator_legivel.gdshader")

## Como cada personagem se destaca. O Penitente tem borda dourada; Beatriz, prateada; os inimigos,
## uma borda vermelha fraca; Iria, que não é inimiga, tem uma aura clara e quase nenhum contorno.
## Efeitos (sangue, golpes, poeira) ficam de fora.
const INIMIGOS := ["devotee", "mourner", "devorador", "flagelante", "duelista", "bruxa", "asmodeia", "carregador", "glutao", "disciplinantes", "meio_enterrado", "parcas", "sono", "romaria", "espantalho", "dois_velhos", "viuva", "peregrino_soltado", "guardian", "guardiao_grande", "guardiao_colosso"]
## Clarão do golpe recebido (0 a 1), desenhado pelo shader de destaque.
func clarao(valor: float) -> void:
	if material is ShaderMaterial:
		material.set_shader_parameter("clarao", clampf(valor, 0.0, 1.0))

static func destaque_de(nome: String) -> Dictionary:
	if nome == "hero":
		return {"cor_borda": Color(1.0, 0.80, 0.48), "borda": 0.7, "realce": 1.14, "saturacao": 1.1, "brilho": 1.04, "raio": 5.0, "contorno": 0.95}
	if nome == "beatriz":
		return {"cor_borda": Color(0.74, 0.86, 1.0), "borda": 0.8, "realce": 1.18, "saturacao": 1.05, "brilho": 1.1, "raio": 5.0, "contorno": 0.95}
	if nome == "iria":
		return {"cor_borda": Color(1.0, 0.96, 0.84), "borda": 0.9, "realce": 1.0, "saturacao": 0.95, "brilho": 1.06, "raio": 4.0, "contorno": 0.35, "cor_contorno": Color(0.3, 0.24, 0.16), "aura": 0.6, "raio_aura": 20.0, "cor_aura": Color(1.0, 0.92, 0.7)}
	if nome.begins_with("flagelado"):
		return {"cor_borda": Color(0.9, 0.25, 0.2), "borda": 0.45, "realce": 1.15, "saturacao": 1.05, "brilho": 1.05, "raio": 5.0, "contorno": 0.95}
	if nome in INIMIGOS:
		var grande := nome.begins_with("guardi")
		return {"cor_borda": Color(0.92, 0.22, 0.16), "borda": 0.5, "realce": 1.14, "saturacao": 1.06, "brilho": 1.02, "raio": 3.0 if grande else 5.0, "contorno": 0.92}
	return {}

func configure(actor_name: String, scale_factor: float) -> void:
	var surface := CanvasItemMaterial.new()
	surface.light_mode = CanvasItemMaterial.LIGHT_MODE_UNSHADED
	material = surface
	var destaque: Dictionary = destaque_de(actor_name)
	if not destaque.is_empty():
		# Personagens se destacam do cenário: contorno escuro, luz de borda e um pouco mais de contraste.
		var legivel := ShaderMaterial.new()
		legivel.shader = SHADER_ATOR
		for chave in destaque: legivel.set_shader_parameter(chave, destaque[chave])
		material = legivel
	actor = actor_name
	unit_scale = scale_factor
	if not frame_changed.is_connected(_atualizar_limites):
		frame_changed.connect(_atualizar_limites)
		animation_changed.connect(_atualizar_limites)
	scale = Vector2.ONE * unit_scale
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	definitions = manifesto()[actor]
	if frames_cache.has(actor):
		sprite_frames = frames_cache[actor]
		play("idle")
		return
	var arquivo := PASTA_QUADROS + actor + ".tres"
	sprite_frames = load(arquivo) if ResourceLoader.exists(arquivo) else montar_quadros(actor)
	frames_cache[actor] = sprite_frames
	play("idle")

## Os quadros de um personagem montados direto de clips.json (o gerador grava isto em quadros/<ator>.tres).
static func montar_quadros(ator: String) -> SpriteFrames:
	var quadros := SpriteFrames.new()
	quadros.remove_animation("default")
	var definicoes: Dictionary = manifesto()[ator]
	for clip in definicoes:
		var data: Dictionary = definicoes[clip]
		var sheet: Texture2D = load("res://assets/animation/" + data["sheet"] + ".png")
		quadros.add_animation(clip)
		quadros.set_animation_loop(clip, data.get("loop", true))
		quadros.set_animation_speed(clip, float(data.get("fps", 12)))
		for i in range(int(data["count"])):
			quadros.add_frame(clip, quadro(data, i, sheet))
	return quadros

## As definições de assets/animation/clips.json, lidas uma vez.
static func manifesto() -> Dictionary:
	if manifest_cache.is_empty():
		manifest_cache = JSON.parse_string(FileAccess.get_file_as_string("res://assets/animation/clips.json"))
	return manifest_cache

## O quadro i de um clipe (uma definição de clips.json), recortado da folha.
static func quadro(data: Dictionary, i: int, sheet: Texture2D = null) -> AtlasTexture:
	if sheet == null: sheet = load("res://assets/animation/" + data["sheet"] + ".png")
	# Aceita o formato legado grid e a quantidade de fileiras da v32.
	var grid: Array = data.get("grid", [6, int(data.get("rows", 4))])
	var columns := int(grid[0])
	var cell := sheet.get_size() / Vector2(columns, int(grid[1]))
	var indices: Array = data.get("frames", [])
	var index := int(indices[i]) if not indices.is_empty() else int(data["start"]) + i
	var row := floori(float(index) / columns)
	var start := Vector2(roundf((index % columns) * cell.x), roundf(row * cell.y))
	var end := Vector2(roundf((index % columns + 1) * cell.x), roundf((row + 1) * cell.y))
	var region := AtlasTexture.new()
	region.atlas = sheet
	region.region = Rect2(start, end - start)
	region.filter_clip = true
	return region


func select(clip: String, direction: int, progress: float = -1.0) -> void:
	if not definitions.has(clip):
		clip = "idle"
	var data: Dictionary = definitions[clip]
	if animation != clip:
		play(clip)
	elif progress < 0 and not is_playing():
		play()
	manual = progress >= 0
	if manual:
		pause()
		frame = clampi(int(progress * sprite_frames.get_frame_count(clip)), 0, sprite_frames.get_frame_count(clip) - 1)
	flip_h = direction < 0
	# Toda a arte usa uma âncora comum nos pés. As células da grade não são aparadas.
	var cell := sprite_frames.get_frame_texture(clip, frame).get_size()
	var anchor: Array = data.get("anchor", [128, 250])
	# Quadros reencaixados (tools/polir_folhas.py): o desenho foi deslocado dentro da célula para a
	# lâmina caber inteira; aqui ele volta para o lugar, e a ponta que antes era cortada aparece.
	var deslocamentos: Array = data.get("deslocamentos", [])
	var desvio := float(deslocamentos[frame]) if frame < deslocamentos.size() else 0.0
	position = Vector2((cell.x / 2 - float(anchor[0]) + desvio) * direction, cell.y / 2 - float(anchor[1])) * unit_scale
	_atualizar_limites()

## O shader de destaque lê os vizinhos de cada ponto; precisa saber em que célula da folha está o quadro atual,
## inclusive quando a animação avança sozinha (corrida, parado).
func _atualizar_limites() -> void:
	if not (material is ShaderMaterial) or sprite_frames == null or not sprite_frames.has_animation(animation): return
	var image = sprite_frames.get_frame_texture(animation, frame)
	if not (image is AtlasTexture): return
	var sheet_size: Vector2 = image.atlas.get_size()
	var bounds := Vector4(image.region.position.x / sheet_size.x, image.region.position.y / sheet_size.y, image.region.end.x / sheet_size.x, image.region.end.y / sheet_size.y)
	material.set_shader_parameter("frame_bounds", bounds)

func pose(clip: String, direction: int, index: int) -> void:
	var count := sprite_frames.get_frame_count(clip)
	select(clip, direction, float(index) / count + 0.001)
