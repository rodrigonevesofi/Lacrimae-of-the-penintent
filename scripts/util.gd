extends RefCounted
## Funções utilitárias (luzes)

static var shared_light_texture: GradientTexture2D

static func light_texture(size: int = 256) -> GradientTexture2D:
	if size == 256 and shared_light_texture != null:
		return shared_light_texture
	var g := Gradient.new()
	g.colors = PackedColorArray([Color(1, 1, 1, 1), Color(1, 1, 1, 0)])
	g.offsets = PackedFloat32Array([0.0, 1.0])
	var t := GradientTexture2D.new()
	t.gradient = g
	t.fill = GradientTexture2D.FILL_RADIAL
	t.fill_from = Vector2(0.5, 0.5)
	t.fill_to = Vector2(1.0, 0.5)
	t.width = size
	t.height = size
	if size == 256:
		shared_light_texture = t
	return t


static func make_light(color: Color, energy: float, scale_f: float) -> PointLight2D:
	var l := PointLight2D.new()
	l.texture = light_texture()
	l.color = color
	l.energy = energy
	l.texture_scale = scale_f
	return l
