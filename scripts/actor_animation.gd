extends AnimatedSprite2D
## Os quadros de animação são desenhos distintos recortados de uma grade regular de origem.
## A jogabilidade e o contato visual usam a mesma linha do tempo normalizada de seis quadros.
static var manifest_cache: Dictionary = {}
static var frames_cache: Dictionary = {}
var definitions: Dictionary = {}
var actor := ""
var unit_scale := 0.44
var manual := false

func configure(actor_name: String, scale_factor: float) -> void:
	var surface := CanvasItemMaterial.new()
	surface.light_mode = CanvasItemMaterial.LIGHT_MODE_UNSHADED
	material = surface
	if actor_name == "hero":
		var readable := ShaderMaterial.new()
		readable.shader = load("res://shaders/penitent_readability.gdshader")
		material = readable
	actor = actor_name
	unit_scale = scale_factor
	scale = Vector2.ONE * unit_scale
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	if manifest_cache.is_empty():
		manifest_cache = JSON.parse_string(FileAccess.get_file_as_string("res://assets/animation/clips.json"))
	definitions = manifest_cache[actor]
	if frames_cache.has(actor):
		sprite_frames = frames_cache[actor]
		play("idle")
		return
	sprite_frames = SpriteFrames.new()
	sprite_frames.remove_animation("default")
	for clip in definitions:
		var data: Dictionary = definitions[clip]
		var sheet: Texture2D = load("res://assets/animation/" + data["sheet"] + ".png")
		# Aceita o formato legado grid e a quantidade de fileiras da v32.
		var grid: Array = data.get("grid", [6, int(data.get("rows", 4))])
		var columns := int(grid[0])
		var cell := sheet.get_size() / Vector2(columns, int(grid[1]))
		sprite_frames.add_animation(clip)
		sprite_frames.set_animation_loop(clip, data.get("loop", true))
		sprite_frames.set_animation_speed(clip, float(data.get("fps", 12)))
		for i in range(int(data["count"])):
			var index := int(data["start"]) + i
			var row := floori(float(index) / columns)
			var start := Vector2(roundf((index % columns) * cell.x), roundf(row * cell.y))
			var end := Vector2(roundf((index % columns + 1) * cell.x), roundf((row + 1) * cell.y))
			var region := AtlasTexture.new()
			region.atlas = sheet
			region.region = Rect2(start, end - start)
			region.filter_clip = true
			sprite_frames.add_frame(clip, region)
	frames_cache[actor] = sprite_frames
	play("idle")

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
	position = Vector2((cell.x / 2 - float(anchor[0])) * direction, cell.y / 2 - float(anchor[1])) * unit_scale
	if material is ShaderMaterial:
		var image: AtlasTexture = sprite_frames.get_frame_texture(clip, frame)
		var sheet_size := image.atlas.get_size()
		var bounds := Vector4(image.region.position.x / sheet_size.x, image.region.position.y / sheet_size.y, image.region.end.x / sheet_size.x, image.region.end.y / sheet_size.y)
		material.set_shader_parameter("frame_bounds", bounds)

func pose(clip: String, direction: int, index: int) -> void:
	var count := sprite_frames.get_frame_count(clip)
	select(clip, direction, float(index) / count + 0.001)
