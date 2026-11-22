extends Node2D
## Cenário procedural original; a geometria corresponde ao leiaute de colisão de main.gd.

var game
var redraw_clock := 0.0
var panorama: Texture2D
var abyss_art: Texture2D
var gate_closed: Texture2D
var gate_open: Texture2D
var sacred_props: Texture2D
var room_textures: Dictionary = {}
var doorway_art: Texture2D
var memorial_base: Sprite2D
var memorial_doll: Sprite2D
var gate_memory: AtlasTexture
const PANORAMA_RECT := Rect2(0, -770, 4800, 1600)
var iria_animation
## A cor da pedra de cada sala, medida na própria pintura: [piso, parede].
## Galerias e alvenaria tomam a cor do piso; portas, altares e monumentos, a da parede.
## Antes tudo usava o mesmo cinza da cidade e parecia colado por cima da pintura.
const PEDRA := {
	"city": [Color(1.11, 1.11, 1.09), Color(1.0, 0.90, 0.85)],
	"ossuary": [Color(1.21, 1.27, 1.22), Color(1.0, 0.89, 0.77)],
	"cistern": [Color(1.34, 1.45, 1.23), Color(0.98, 0.92, 0.76)],
	"cloister": [Color(1.34, 1.12, 0.98), Color(1.0, 0.82, 0.74)],
	"belfry": [Color(1.37, 1.14, 0.92), Color(1.0, 0.80, 0.73)],
	"archive": [Color(0.87, 1.04, 1.21), Color(0.93, 0.91, 0.94)],
	"refuge": [Color(1.03, 0.93, 0.99), Color(1.0, 0.86, 0.85)],
	"nave": [Color(1.5, 1.42, 1.26), Color(1.0, 0.88, 0.80)],
	"terrace": [Color(1.25, 1.35, 1.34), Color(0.97, 0.95, 0.93)],
	"court": [Color(1.5, 1.30, 1.05), Color(1.0, 0.80, 0.68)],
}
const GROUND_Y := 600.0
const INK := Color("17191e")
const STONE := Color("34383d")
const EDGE := Color("68665f")
## Sem o shader (F6), o cenário recua só escurecendo, para os personagens continuarem à frente.
const RECUO := Color(0.80, 0.77, 0.79)
const GOLD := Color("a58a59")

func _ready() -> void:
	var surface := CanvasItemMaterial.new()
	surface.light_mode = CanvasItemMaterial.LIGHT_MODE_UNSHADED
	material = surface
	iria_animation = preload("res://scripts/actor_animation.gd").new()
	iria_animation.configure("iria", 0.38)
	var iria_anchor := Node2D.new()
	iria_anchor.position = game.IRIA_POS
	add_child(iria_anchor)
	iria_anchor.add_child(iria_animation)
	sacred_props = load("res://assets/sacred_props.png")
	doorway_art = load("res://assets/doorways.png")
	build_memorial()
	for room in ["ossuary","cistern","cloister","tower"]: room_textures[room] = load("res://assets/"+room+".png")
	# Fundos adicionais (basílica, galeria, portões, cidade, pátio) são carregados quando uma sala precisa deles pela primeira vez.
	panorama = load("res://assets/vespera_panorama.png")
	if ResourceLoader.exists("res://assets/abismo_ponte.png"): abyss_art = load("res://assets/abismo_ponte.png")
	if ResourceLoader.exists("res://assets/arena_portao.png"): gate_closed = load("res://assets/arena_portao.png")
	if ResourceLoader.exists("res://assets/arena_portao_aberto.png"): gate_open = load("res://assets/arena_portao_aberto.png")
	gate_memory = AtlasTexture.new()
	gate_memory.atlas = panorama
	var size := panorama.get_size()
	gate_memory.region = Rect2(size.x * 0.57, size.y * 0.15, size.x * 0.43, size.x * 0.43 * 9.0 / 16.0)

func _process(delta: float) -> void:
	if memorial_doll: memorial_doll.visible = game.memorial_honored and game.narrative.mode != "memorial"
	if iria_animation:
		iria_animation.select("talk" if game.message_title == "IRIA — A TESTEMUNHA" and game.message_text != "" else "idle", -1)
	redraw_clock += delta
	if redraw_clock >= 1.0 / 24.0:
		redraw_clock = 0.0
		queue_redraw()

## A pintura desta sala está sendo desenhada, animada, por pintura_viva.gd?
func _pintura_viva(id: String) -> bool:
	return game.get("pintura") != null and game.pintura.ativa(id)

## Cor da pedra da sala atual: 0 = piso, 1 = parede.
func pedra(qual: int, id: String = "") -> Color:
	if id == "": id = game.exploration.room if game.exploration != null else "city"
	return PEDRA[id][qual] if PEDRA.has(id) else Color.WHITE

func polygon(points: Array, color: Color) -> void:
	draw_colored_polygon(PackedVector2Array(points), color)

func arch(x: float, y: float, width: float, height: float, color: Color, thickness: float) -> void:
	var points := PackedVector2Array()
	points.append(Vector2(x, y))
	points.append(Vector2(x, y - height * 0.62))
	for i in range(17):
		var f := float(i) / 16.0
		points.append(Vector2(x + width * f, y - height * (0.62 + 0.38 * sin(f * PI))))
	points.append(Vector2(x + width, y))
	draw_polyline(points, color, thickness, true)

func candle(pos: Vector2, height: float, phase: float) -> void:
	draw_rect(Rect2(pos.x - 2, pos.y - height, 4, height), Color("b9a682"))
	draw_line(pos + Vector2(-2, -height + 3), pos + Vector2(-2, -height + 8), Color("e5cfa4"), 1)
	var tip := pos + Vector2(sin(game.t * 4 + phase), -height - 3)
	draw_circle(tip, 8, Color(1, 0.55, 0.16, 0.035))
	draw_circle(tip, 4, Color(1, 0.65, 0.22, 0.13))
	polygon([tip + Vector2(-2, 2), tip + Vector2(0, -5), tip + Vector2(2, 2)], Color("ffd58a"))
	draw_circle(tip, 1, Color("fff1c5"))

## Relíquias que fortalecem: o Cálice de Sangue (vida) e o Espinho da Ira (dano), flutuando sobre um pedestal.
func relic(pos: Vector2, calice: bool) -> void:
	var bob := sin(game.t * 2.4 + pos.x) * 5.0
	var c := pos + Vector2(0, -56 + bob)
	draw_rect(Rect2(pos.x - 16, pos.y - 22, 32, 22), Color("2a2224"))
	draw_rect(Rect2(pos.x - 20, pos.y - 26, 40, 6), GOLD)
	var halo := Color(0.85, 0.12, 0.12, 0.22) if calice else Color(0.95, 0.75, 0.4, 0.2)
	draw_circle(c, 26 + sin(game.t * 3.0) * 3.0, halo)
	draw_circle(c, 15, Color(halo.r, halo.g, halo.b, 0.35))
	if calice:
		draw_colored_polygon(PackedVector2Array([c + Vector2(-13, -12), c + Vector2(13, -12), c + Vector2(6, 4), c + Vector2(-6, 4)]), Color("b08a4e"))
		draw_colored_polygon(PackedVector2Array([c + Vector2(-10, -10), c + Vector2(10, -10), c + Vector2(5, 1), c + Vector2(-5, 1)]), Color(0.55, 0.02, 0.05))
		draw_rect(Rect2(c.x - 2, c.y + 4, 4, 9), Color("9a7743"))
		draw_rect(Rect2(c.x - 8, c.y + 13, 16, 3), Color("b08a4e"))
		draw_circle(c + Vector2(-5, -9), 2, Color(1, 0.6, 0.6, 0.6))
	else:
		draw_colored_polygon(PackedVector2Array([c + Vector2(-3, 16), c + Vector2(3, 16), c + Vector2(1, -18), c + Vector2(-1, -18)]), Color("4a4648"))
		for k in range(3):
			var y := -8.0 + k * 8.0
			draw_line(c + Vector2(0, y), c + Vector2(7, y - 5), Color("6b6567"), 2.0)
			draw_line(c + Vector2(0, y + 3), c + Vector2(-7, y - 2), Color("6b6567"), 2.0)
		draw_circle(c + Vector2(0, -18), 2, Color(0.8, 0.1, 0.1))

func _draw() -> void:
	if game == null:
		return
	if game.exploration != null and game.exploration.room != "city":
		draw_branch()
		return
	# Toda a fase de 4800 unidades compartilha um panorama fixo no espaço do mundo.
	# Sem imagem seguindo a câmera, repetição de textura, troca por sala ou dissolução temporal.
	# Com a pintura viva ligada, quem desenha o panorama é pintura_viva.gd, com o shader.
	if not _pintura_viva("city"): draw_texture_rect(panorama, PANORAMA_RECT, false, RECUO)
	if game.exploration != null: draw_passages("city")
	# A ponte quebrada é um buraco real no plano de caminhada em primeiro plano.
	if abyss_art != null:
		# Abismo pintado: pedra quebrada nas duas bordas, névoa subindo e luz tênue ao fundo.
		draw_rect(Rect2(2000, 600, 270, 330), Color("0b0e12"))
		draw_texture_rect(abyss_art, Rect2(2000, 596, 270, 400), false)
	else:
		draw_rect(Rect2(2000, 600, 270, 310), Color("12171d"))
		for edge in [2000, 2270]:
			var side := -1 if edge == 2000 else 1
			polygon([Vector2(edge, 600), Vector2(edge + side * 35, 600), Vector2(edge + side * 22, 666), Vector2(edge + side * 12, 631)], Color("595149"))
	# O primeiro plano deve corresponder exatamente às plataformas de colisão.
	_draw_ground(0, 2000)
	_draw_ground(2270, 4800)
	for p in game.platforms:
		# Suportes esculpidos conectam fisicamente as saliências ao edifício atrás.
		for end_x in [p.position.x + 12, p.end.x - 12]:
			draw_texture_rect_region(panorama, Rect2(end_x - 10, p.end.y, 20, 600 - p.end.y), Rect2(550, 250, 26, 365))
		draw_texture_rect_region(panorama, p, Rect2(1120, 615, 140, 22))
		draw_line(p.position, Vector2(p.end.x, p.position.y), Color("b5a084"), 2)
	# Iria permanece separada dos combatentes; a bengala identifica sua silhueta.
	# Gaiolas vazias suspensas: silhuetas de fundo, nunca colisões ocultas.
	for x in range(1430, 3200, 360):
		var sway := sin(game.t * 0.65 + x) * 5
		var pos := Vector2(x + sway, 190)
		draw_line(Vector2(x, -100), pos, Color("252228"), 2)
		draw_arc(pos + Vector2(0, 22), 22, PI, TAU, 16, Color("6d5a43"), 2)
		draw_rect(Rect2(pos.x - 22, pos.y + 22, 44, 60), Color("3a3433"), false, 2)
		for dx in [-14, -5, 5, 14]:
			draw_line(pos + Vector2(dx, 22), pos + Vector2(dx, 82), Color("6d5a43"), 2)
	draw_set_transform(game.MEMORIAL_POS + Vector2(0, -1),0,Vector2(1,0.13))
	draw_circle(Vector2.ZERO,95,Color(0,0,0,0.25))
	draw_set_transform(Vector2.ZERO)
	var tumulo: Vector2 = game.TOMB_POS
	prop(1,tumulo,260)
	# Coroa deixada ao lado do túmulo.
	draw_arc(tumulo + Vector2(95, -7), 12, PI, TAU, 10, GOLD, 2)
	for i in range(5):
		draw_line(tumulo + Vector2(84 + i * 5, -10), tumulo + Vector2(82 + i * 5, -16), GOLD, 1)
	if not game.player.has_weapon:
		var x: float = game.SWORD_POS.x
		var y: float = game.SWORD_POS.y
		draw_line(Vector2(x, y - 3), Vector2(x, y - 73), Color("c1bfad"), 4)
		draw_line(Vector2(x - 13, y - 57), Vector2(x + 13, y - 57), GOLD, 3)
		draw_line(Vector2(x, y - 57), Vector2(x, y - 77), Color("5d342b"), 5)
		draw_circle(Vector2(x, y - 79), 4, GOLD)
		for i in range(5):
			draw_line(Vector2(x, y - 47 + i * 7), Vector2(x + 5, y - 50 + i * 7), GOLD, 1)
		draw_circle(Vector2(x, y - 47), 25 + sin(game.t * 2) * 3, Color(0.8, 0.63, 0.3, 0.04))
	for altar in game.altars:
		if altar.x < 4800: prop(0,altar,185)
	for entry in game.lore: prop(2,Vector2(entry.x,600),120)
	var rng := RandomNumberGenerator.new()
	rng.seed = 7413
	for cx in game.candle_xs:
		for i in range(3): candle(Vector2(cx + rng.randf_range(-18,18),599),rng.randf_range(9,22),float(i))
	if game.exploration != null and game.exploration.bells.size() < 2:
		for x in [3781,3794]:
			for y in range(-70,600,18): draw_arc(Vector2(x,y),7,0,TAU,12,Color("967853"),3)
	# Entulho, ossos pequenos e raízes no chão. Determinísticos entre quadros.
	for i in range(120):
		var x := rng.randf_range(10, 4790)
		if x > 2000 and x < 2270:
			continue
		polygon([Vector2(x - 4, 600), Vector2(x - 2, 594), Vector2(x + 5, 596), Vector2(x + 7, 600)], Color("4b4945"))
	for anchor in [Vector2(1160, 170), Vector2(2550, 110), Vector2(3380, 180)]:
		for i in range(8):
			var yy: float = anchor.y + i * 17
			var sway := sin(game.t * 1.2 + i * 0.4) * i * 0.75
			draw_line(Vector2(anchor.x + sway, yy), Vector2(anchor.x + sway + 13 - i, yy + 18), Color("542d32"), 7)
	# Poeira e névoa lentas criam movimento sem ocultar o plano de colisão.
	for i in range(50):
		var x := fmod(i * 107.5 + game.t * (2 + i % 3), 4800)
		var y := 90 + fmod(i * 77.3 + game.t * 4, 480)
		draw_circle(Vector2(x, y), 1, Color(0.88, 0.80, 0.64, 0.17))


func _draw_ground(x0: float, x1: float) -> void:
	# O panorama já contém uma fundação esculpida contínua em y=600.
	# Mantém apenas a borda de caminhada; tijolos planos provisórios já não cobrem a arte.
	draw_line(Vector2(x0, GROUND_Y), Vector2(x1, GROUND_Y), Color("8b7d67"), 2)


func prop(index: int, foot: Vector2, width: float, tint: Color = Color.WHITE, facing: int = 1) -> void:
	var cell := sacred_props.get_size() / Vector2(3,2)
	var source := Rect2(Vector2(index%3,index/3)*cell,cell)
	var floor_anchor := 482.0 if index < 3 else 494.0
	draw_set_transform(foot + Vector2(0,-1),0,Vector2(1,0.13))
	draw_circle(Vector2.ZERO,width*0.4,Color(0,0,0,0.26))
	draw_set_transform(foot,0,Vector2(float(facing),1))
	draw_texture_rect_region(sacred_props,Rect2(-width/2,-width*floor_anchor/cell.y,width,width),source,tint*pedra(1))
	draw_set_transform(Vector2.ZERO)

func draw_passages(room: String) -> void:
	for link in game.exploration.passages:
		if link.a != room and link.b != room: continue
		var from_a: bool = link.a == room
		var face: Dictionary = game.exploration.Layout.passage_face(link,from_a)
		var locked: bool = link.get("latch",false) and not game.exploration.opened.has(link.id)
		draw_doorway(face,locked)

func draw_doorway(face: Dictionary, locked: bool) -> void:
	var foot: Vector2 = face.foot
	var width: float = face.width
	var variant := 0 if face.theme == "burial" else (1 if face.theme == "water" else 2)
	var source := Rect2(variant*512,512 if locked else 0,512,512)
	# O módulo inclui as laterais da parede, um vestíbulo profundo e a soleira.
	# Usa a própria âncora do piso de origem em vez de redimensionar um objeto isolado.
	var floor_anchor := 488.0
	draw_set_transform(foot+Vector2(0,-1),0,Vector2(1,0.13))
	draw_circle(Vector2.ZERO,width*0.43,Color(0,0,0,0.28))
	draw_set_transform(foot,0,Vector2(float(face.facing),1))
	draw_texture_rect_region(doorway_art,Rect2(-width/2,-width*floor_anchor/512,width,width),source,pedra(1,face.room)*Color(0.86,0.86,0.86))
	draw_set_transform(Vector2.ZERO)
	# Toda passagem precisa ser reconhecível: arco iluminado sobre a abertura, luz na
	# soleira e símbolo acima dela. Dourado quando aberta, vermelho quando bloqueada.
	var col := Color(0.95, 0.33, 0.28) if locked else Color(1.0, 0.82, 0.42)
	var mid := foot + Vector2(0, -width * 0.40)
	draw_rect(Rect2(foot.x - width * 0.30, foot.y - width * 0.78, width * 0.60, width * 0.78), Color(col, 0.07))
	draw_arc(mid, width * 0.36, PI, TAU, 32, Color(col, 0.75), 3.0)
	draw_line(mid + Vector2(-width * 0.36, 0), Vector2(foot.x - width * 0.36, foot.y), Color(col, 0.55), 2.0)
	draw_line(mid + Vector2(width * 0.36, 0), Vector2(foot.x + width * 0.36, foot.y), Color(col, 0.55), 2.0)
	draw_rect(Rect2(foot.x - width * 0.36, foot.y - 4.0, width * 0.72, 4.0), Color(col, 0.6))
	var sigil := mid + Vector2(0, -width * 0.36 - 26.0)
	draw_colored_polygon(PackedVector2Array([sigil + Vector2(0, -12), sigil + Vector2(9, 0), sigil + Vector2(0, 12), sigil + Vector2(-9, 0)]), Color(col, 0.95))
	draw_polyline(PackedVector2Array([sigil + Vector2(-8, 18), sigil + Vector2(0, 26), sigil + Vector2(8, 18)]), Color(col, 0.9), 2.5)

func build_memorial() -> void:
	memorial_base = Sprite2D.new()
	memorial_base.texture = load("res://assets/memorial_empty.png")
	var size := memorial_base.texture.get_size()
	var unit := 220.0/size.x
	memorial_base.scale = Vector2.ONE*unit
	memorial_base.position = game.MEMORIAL_POS + Vector2(0,(size.y/2-1008)*unit)
	# A imagem de origem tem brilho translúcido suave em torno da silhueta. Este material de recorte
	# remove o halo durante a renderização e preserva a suavização das bordas da pedra.
	var shader := Shader.new()
	shader.code = "shader_type canvas_item; render_mode unshaded; void fragment(){ vec4 sample_color = texture(TEXTURE,UV); sample_color.a *= smoothstep(0.38,0.72,sample_color.a); COLOR = sample_color; }"
	var cutout := ShaderMaterial.new()
	cutout.shader = shader
	memorial_base.material = cutout
	add_child(memorial_base)
	memorial_doll = Sprite2D.new()
	memorial_doll.texture = load("res://assets/cloth_doll.png")
	memorial_doll.scale = Vector2.ONE*0.037
	memorial_doll.position = game.MEMORIAL_POS + Vector2(0,-57+(627-1136)*0.037)
	memorial_doll.visible = false
	add_child(memorial_doll)

func art_texture(art: String) -> Texture2D:
	if not room_textures.has(art): room_textures[art] = load("res://assets/"+art+".png")
	return room_textures[art]

## Galeria de pedra presa à parede: sombra projetada na pintura, mísulas em degraus e a laje na cor
## do piso da sala. Substitui as lajes cinzentas com triângulos chapados, que pareciam flutuar.
func draw_ledge(ledge: Rect2) -> void:
	var cor := pedra(0)
	var base := ledge.end.y
	# A sombra que a laje e as mísulas lançam na parede atrás.
	draw_polygon(PackedVector2Array([Vector2(ledge.position.x + 4, base), Vector2(ledge.end.x - 4, base), Vector2(ledge.end.x - 22, base + 46), Vector2(ledge.position.x + 22, base + 46)]),
		PackedColorArray([Color(0, 0, 0, 0.46), Color(0, 0, 0, 0.46), Color(0, 0, 0, 0), Color(0, 0, 0, 0)]))
	# Mísulas: três fiadas de pedra, cada uma mais estreita, como se saíssem da parede.
	var lados: Array = [ledge.position.x + 26.0, ledge.end.x - 26.0] if ledge.size.x >= 110.0 else [ledge.get_center().x]
	for cx in lados:
		for i in range(3):
			var meia := 20.0 - i * 6.0
			var fiada := Rect2(cx - meia, base + i * 10.0 - 1.0, meia * 2.0, 11.0)
			draw_texture_rect_region(panorama, fiada, Rect2(1130 + i * 30, 617, meia * 2.0, 11), Color(cor.r * (0.62 - i * 0.11), cor.g * (0.60 - i * 0.11), cor.b * (0.60 - i * 0.10)))
			draw_line(fiada.position, Vector2(fiada.end.x, fiada.position.y), Color(0, 0, 0, 0.45), 1)
			draw_line(Vector2(fiada.position.x, fiada.position.y + 1), Vector2(fiada.position.x, fiada.end.y), Color(1, 0.9, 0.75, 0.10), 1)
	draw_texture_rect_region(panorama,ledge,Rect2(1120,615,140,22),cor)
	draw_rect(Rect2(ledge.position.x,ledge.end.y-5,ledge.size.x,5),Color(0,0,0,0.40))
	draw_line(ledge.position,Vector2(ledge.end.x,ledge.position.y),Color(minf(cor.r * 0.80, 1.0), minf(cor.g * 0.72, 1.0), minf(cor.b * 0.62, 1.0)),2)
	draw_line(Vector2(ledge.position.x,ledge.position.y+3),Vector2(ledge.end.x,ledge.position.y+3),Color(0,0,0,0.25),1)
	# As pontas da laje, em sombra, para não terminar num corte reto.
	draw_rect(Rect2(ledge.position.x, ledge.position.y, 3, ledge.size.y), Color(0, 0, 0, 0.30))
	draw_rect(Rect2(ledge.end.x - 3, ledge.position.y, 3, ledge.size.y), Color(0, 0, 0, 0.30))

## Monte ou estrado de alvenaria que molda o plano de caminhada; fiadas alternadas como em uma construção real.
func draw_block(r: Rect2) -> void:
	var cor := pedra(0)
	# Sombra de contato no chão, para a alvenaria pesar sobre o piso pintado.
	draw_set_transform(Vector2(r.get_center().x, r.end.y - 1), 0, Vector2(1, 0.10))
	draw_circle(Vector2.ZERO, r.size.x * 0.58, Color(0, 0, 0, 0.30))
	draw_set_transform(Vector2.ZERO)
	var row := 0
	var y := r.position.y
	while y < r.end.y:
		var h := minf(22.0,r.end.y-y)
		var x := r.position.x - (70.0 if row % 2 == 1 else 0.0)
		while x < r.end.x:
			var x0 := maxf(x,r.position.x)
			var x1 := minf(x+140.0,r.end.x)
			if x1 > x0:
				var src := Rect2(1120+(x0-x)*140.0/140.0,615,x1-x0,22*h/22.0)
				draw_texture_rect_region(panorama,Rect2(x0,y,x1-x0,h),src,Color(0.66*cor.r,0.64*cor.g,0.64*cor.b))
				draw_line(Vector2(x0,y+h),Vector2(x1,y+h),Color(0,0,0,0.42),1)
				if x > r.position.x - 1.0: draw_line(Vector2(x0,y),Vector2(x0,y+h),Color(0,0,0,0.35),1)
			x += 140.0
		y += 22.0
		row += 1
	draw_line(r.position+Vector2(-2,0),Vector2(r.end.x+2,r.position.y),Color(minf(cor.r*0.80,1.0),minf(cor.g*0.72,1.0),minf(cor.b*0.62,1.0)),3)
	draw_rect(Rect2(r.position.x-2,r.position.y,r.size.x+4,r.size.y),Color(0,0,0,0.5),false,2)
	draw_rect(Rect2(r.position.x-6,r.position.y-6,r.size.x+12,6),Color(0,0,0,0.12))

func draw_foundation(b: Rect2, floor_y: float) -> void:
	# Fundos ao ar livre se dissolvem em névoa na base; a fundação esculpida da cidade sustenta o plano de caminhada.
	var tile := 1768.0
	var x := b.position.x
	while x < b.end.x:
		var w := minf(tile,b.end.x-x)
		draw_texture_rect_region(panorama,Rect2(x,floor_y-11,w,241),Rect2(900,615,w/tile*800.0,109))
		x += tile
	draw_rect(Rect2(b.position.x,floor_y+228,b.size.x,400),Color("17181d"))
	draw_line(Vector2(b.position.x,floor_y),Vector2(b.end.x,floor_y),Color("8b7d67"),2)

func draw_branch() -> void:
	var ex = game.exploration
	var data: Dictionary = ex.rooms[ex.room]
	var b: Rect2 = data.bounds
	var floor_y: float = data.floor
	if data.get("procedural", false):
		# O Vale é desenhado e animado por vale_scene.gd; aqui só as passagens.
		draw_passages(ex.room)
		return
	var texture: Texture2D = art_texture(data.art)
	var height: float = ex.art_height(ex.room)
	# Uma sala alta recebe outra composição, em vez de esticar uma parede horizontal.
	var art_rect := Rect2(b.position.x,floor_y-height*ex.ground_line(ex.room),b.size.x,height)
	if not _pintura_viva(ex.room):
		draw_rect(b,Color("17181d"))
		draw_texture_rect(texture,art_rect,false,RECUO)
	if data.get("outdoor",false): draw_foundation(b,floor_y)
	draw_passages(ex.room)
	for block in ex.blocks:
		if block.position.x < b.position.x or block.end.x > b.end.x: continue
		draw_block(block)
	for wall in ex.arena_rects:
		if wall.position.x < b.position.x or wall.end.x > b.end.x: continue
		if gate_closed != null:
			# O portão desceu: barras de ferro e correntes da abóbada ao chão.
			# A parede de colisão desce 60 abaixo do chão; o portão pintado termina no piso, com o pé apoiado nele.
			draw_texture_rect(gate_closed, Rect2(wall.position.x - 24.0, wall.position.y - 20.0, wall.size.x + 48.0, wall.size.y - 40.0), false)
		else:
			draw_block(wall)
		draw_rect(Rect2(wall.position.x - 8.0, wall.position.y, wall.size.x + 16.0, wall.size.y), Color(0.55, 0.05, 0.08, 0.10))
	if gate_open != null:
		# Antes do combate, os portões erguidos ficam sob a abóbada, indicando que o trecho será fechado.
		for a in preload("res://scripts/act_one_layout.gd").arenas():
			if a.x0 < b.position.x or a.x1 > b.end.x or ex.arenas_done.has(a.id) or ex.arena_active == a.id: continue
			for edge in [a.x0, a.x1]:
				draw_texture_rect(gate_open, Rect2(edge - 48.0, a.floor - 560.0, 96.0, 540.0), false)
	for ledge in ex.ledges:
		if ledge.position.x < b.position.x or ledge.end.x > b.end.x: continue
		draw_ledge(ledge)
	for altar in ex.extra_altars:
		if altar.x > b.position.x and altar.x < b.end.x: prop(0,altar,185)
	for item in ex.pickups:
		if item.room != ex.room or ex.collected.has(item.id): continue
		if item.get("relic", false):
			relic(item.pos, str(item.id).begins_with("calice"))
			continue
		prop(2,item.pos,100)
		var glow: Vector2 = item.pos+Vector2(0,-52)
		draw_circle(glow,7+sin(game.t*3)*2,Color(0.85,0.75,0.5,0.25))
	for entry in ex.bell_chains():
		if entry.room == ex.room:
			prop(4,entry.pos,150,Color(0.65,0.65,0.62) if ex.bells.has(entry.id) else Color.WHITE)
	if not game.relic_taken and ex.room == "belfry":
		prop(2,game.relic_pos,110)
	# A névoa baixa suaviza a linha do chão e dá a cada sala sua própria atmosfera de cor.
	var mist: Color = data.get("mist",Color(0.55,0.5,0.6))
	var points := PackedVector2Array([Vector2(b.position.x,floor_y-150),Vector2(b.end.x,floor_y-150),Vector2(b.end.x,floor_y),Vector2(b.position.x,floor_y)])
	draw_polygon(points,PackedColorArray([Color(mist,0),Color(mist,0),Color(mist,0.16),Color(mist,0.16)]))
	# Os detalhes locais ficam ancorados na sala explorada, em vez de acompanhar a câmera.
	for i in range(20):
		var x: float = b.position.x + 70 + i*(b.size.x-140)/20
		candle(Vector2(x,floor_y),12 + i%4*3,i)
	for i in range(22):
		var pos := Vector2(b.position.x+fmod(i*131+game.t*3,b.size.x),floor_y-50-fmod(i*77,700))
		draw_circle(pos,1,Color(0.8,0.72,0.57,0.16))
