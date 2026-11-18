extends Node2D
## Rastro da lâmina: um arco desenhado que varre o espaço do golpe e some em um quinto de segundo.
## Cada golpe tem a sua forma; o núcleo é claro, quase branco, e a borda de dentro é cor de sangue.
## A lança de Beatriz deixa um rastro frio, prateado.

var tipo := "corte"
var lado := 1
var lanca := false
var forte := false
var t := 0.0
const DURACAO := 0.17

## Forma de cada golpe: ângulos de começo e fim (graus, 0 = à frente, positivo = para baixo), raio, espessura e centro.
const FORMAS := {
	"corte":       {"de": -75.0, "ate": 45.0, "raio": 68.0, "grossura": 20.0, "centro": Vector2(8, 0)},
	"contracorte": {"de": 60.0, "ate": -70.0, "raio": 64.0, "grossura": 18.0, "centro": Vector2(10, -2)},
	"descendente": {"de": -120.0, "ate": 75.0, "raio": 84.0, "grossura": 28.0, "centro": Vector2(14, 4)},
	"ascendente":  {"de": 80.0, "ate": -110.0, "raio": 80.0, "grossura": 24.0, "centro": Vector2(12, -8)},
	"aereo":       {"de": -50.0, "ate": 115.0, "raio": 70.0, "grossura": 20.0, "centro": Vector2(10, -6)},
	"aereo2":      {"de": 100.0, "ate": -60.0, "raio": 66.0, "grossura": 18.0, "centro": Vector2(10, -6)},
	"contra":      {"de": -95.0, "ate": 70.0, "raio": 98.0, "grossura": 32.0, "centro": Vector2(18, 0)},
}

func _ready() -> void:
	z_index = 8
	var cru := CanvasItemMaterial.new()
	cru.blend_mode = CanvasItemMaterial.BLEND_MODE_MIX
	cru.light_mode = CanvasItemMaterial.LIGHT_MODE_UNSHADED
	material = cru

func _process(delta: float) -> void:
	t += delta
	if t >= DURACAO:
		queue_free()
		return
	queue_redraw()

func _cores() -> Array:
	if lanca:
		return [Color(0.92, 0.97, 1.0), Color(0.62, 0.72, 0.86), Color(0.45, 0.04, 0.08)]
	if forte:
		return [Color(1.0, 0.98, 0.86), Color(1.0, 0.72, 0.34), Color(0.62, 0.03, 0.05)]
	return [Color(1.0, 0.95, 0.84), Color(0.95, 0.62, 0.42), Color(0.58, 0.02, 0.05)]

func _draw() -> void:
	var k := t / DURACAO
	var c: Array = _cores()
	var alfa := 1.0 - smoothstep(0.35, 1.0, k)
	if tipo == "estocada":
		_estocada(k, alfa, c)
		return
	var f: Dictionary = FORMAS.get(tipo, FORMAS["corte"])
	var de: float = deg_to_rad(f["de"])
	var ate: float = deg_to_rad(f["ate"])
	# A ponta do rastro avança rápido; a cauda vem atrás e alcança a ponta enquanto o rastro some.
	var ponta: float = lerpf(de, ate, minf(k / 0.45, 1.0))
	var cauda: float = lerpf(de, ate, clampf((k - 0.15) / 0.85, 0.0, 1.0) * 0.85)
	if absf(ponta - cauda) < 0.02: return
	var raio: float = float(f["raio"]) * (1.15 if forte else 1.0)
	var grossura: float = float(f["grossura"]) * (1.2 if forte else 1.0)
	var centro: Vector2 = f["centro"]
	centro.x *= lado
	var fora := PackedVector2Array()
	var dentro := PackedVector2Array()
	var cores := PackedColorArray()
	var passos := 18
	for i in range(passos + 1):
		var u := float(i) / passos
		var a := lerpf(cauda, ponta, u)
		var largura := grossura * sin(u * PI * 0.92 + 0.08) * (0.4 + 0.6 * u)
		var dir := Vector2(cos(a) * lado, sin(a))
		fora.append(centro + dir * raio)
		dentro.append(centro + dir * (raio - largura))
	var pontos := PackedVector2Array()
	for i in range(fora.size()):
		pontos.append(fora[i])
		var u := float(i) / passos
		cores.append(Color(c[0].r, c[0].g, c[0].b, alfa * (0.25 + 0.75 * u)))
	for i in range(dentro.size() - 1, -1, -1):
		pontos.append(dentro[i])
		var u := float(i) / passos
		cores.append(Color(c[2].r, c[2].g, c[2].b, alfa * 0.55 * u))
	draw_polygon(pontos, cores)
	# Fio de luz na borda cortante.
	var fio := PackedVector2Array()
	for i in range(passos / 3, fora.size()): fio.append(fora[i])
	if fio.size() > 1: draw_polyline(fio, Color(c[1].r, c[1].g, c[1].b, alfa * 0.9), 2.0, true)

func _estocada(k: float, alfa: float, c: Array) -> void:
	# A estocada é uma cunha reta: nasce na mão e corre até a ponta.
	var comprimento := lerpf(40.0, 190.0, minf(k / 0.35, 1.0)) * (1.15 if forte else 1.0)
	var base := Vector2(14.0 * lado, -2.0)
	var ponta := base + Vector2(comprimento * lado, 0.0)
	var meia := 11.0 * (1.0 - k * 0.5)
	var pts := PackedVector2Array([base + Vector2(0, -meia), ponta, base + Vector2(0, meia)])
	draw_polygon(pts, PackedColorArray([Color(c[2].r, c[2].g, c[2].b, alfa * 0.5), Color(c[0].r, c[0].g, c[0].b, alfa), Color(c[2].r, c[2].g, c[2].b, alfa * 0.5)]))
	draw_line(base, ponta, Color(c[0].r, c[0].g, c[0].b, alfa), 2.5, true)
	for i in range(3):
		var y := -meia * 1.6 + i * meia * 1.6
		draw_line(base + Vector2(-20.0 * lado, y), base + Vector2((comprimento * 0.55) * lado, y * 0.4), Color(c[1].r, c[1].g, c[1].b, alfa * 0.35), 1.5, true)
