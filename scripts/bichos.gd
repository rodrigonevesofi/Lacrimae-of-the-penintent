extends Node2D
## Bichos: a vida pequena das salas, que percebe o Penitente e reage a ele.
##  - Corvos pousados no chão e nas galerias. Levantam voo quando alguém chega perto ou quando um
##    golpe forte estala por perto, e voltam a pousar em outro lugar depois de um tempo.
##    São AnimatedSprite2D com a arte pintada do corvo; o voo e o pouso são Tweens.
##  - Morcegos pendurados sob as galerias. Saem em revoada quando se passa por baixo.
##  - Ratos que farejam o chão e fogem correndo.
##  - Mariposas em volta das lamparinas e folhas secas que caem da hera (CPUParticles2D).
## Nada aqui tem colisão nem causa dano: é só o mundo reagindo.

const SALAS := {
	"city": {"corvos": 4},
	"ossuary": {"morcegos": 7, "ratos": 3},
	"cistern": {"morcegos": 5, "ratos": 2},
	"cloister": {"corvos": 3, "folhas": Color(0.62, 0.16, 0.12)},
	"belfry": {"morcegos": 8, "corvos": 2},
	"archive": {"ratos": 3, "mariposas": true},
	"refuge": {"corvos": 4},
	"nave": {"morcegos": 4, "mariposas": true},
	"terrace": {"corvos": 5},
	"court": {"corvos": 4, "folhas": Color(0.66, 0.20, 0.12)},
}
const TINTA := Color(0.07, 0.055, 0.06)

var game
var sala := ""
var t := 0.0
var textura_morcego:Texture2D = preload("res://assets/animation/morcego.png")
var textura_rato:Texture2D = preload("res://assets/animation/rato.png")
var quadros: SpriteFrames
var corvos: Array = []
var morcegos: Array = []
var ratos: Array = []
var folhas: CPUParticles2D
var mariposas := false
## Quantos corvos já levantaram voo e quantos morcegos já saíram em revoada (para os testes).
var voos := 0
var revoadas := 0

func _ready() -> void:
	# O pouso, a bicada e o impulso têm quadros próprios antes da faixa de voo existente.
	var folha: Texture2D = load("res://assets/animation/corvo.png")
	quadros = SpriteFrames.new()
	quadros.add_animation("voo")
	quadros.set_animation_speed("voo", 13.0)
	quadros.set_animation_loop("voo", true)
	for i in range(6):
		var quadro := AtlasTexture.new()
		quadro.atlas = folha
		quadro.region = Rect2(i * 128, 0, 128, 128)
		quadros.add_frame("voo", quadro)
	var pouso:Texture2D=load("res://assets/animation/corvo_pousado.png")
	for nome in ["pousado","bicando","levantar"]:
		quadros.add_animation(nome)
		quadros.set_animation_speed(nome,12.0 if nome=="levantar" else 6.0)
		quadros.set_animation_loop(nome,nome=="pousado")
		var inicio:=0 if nome=="pousado" else (2 if nome=="bicando" else 4)
		for indice in range(inicio,inicio+2):
			var quadro:=AtlasTexture.new()
			quadro.atlas=pouso
			quadro.region=Rect2(indice*128,0,128,128)
			quadros.add_frame(nome,quadro)
	# Folhas secas: um pontinho alongado que gira enquanto cai.
	var imagem := Image.create(5, 3, false, Image.FORMAT_RGBA8)
	imagem.fill(Color.WHITE)
	imagem.set_pixel(0, 0, Color(1, 1, 1, 0))
	imagem.set_pixel(4, 2, Color(1, 1, 1, 0))
	folhas = CPUParticles2D.new()
	folhas.texture = ImageTexture.create_from_image(imagem)
	folhas.amount = 26
	folhas.lifetime = 9.0
	folhas.preprocess = 9.0
	folhas.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	folhas.emission_rect_extents = Vector2(820, 30)
	folhas.direction = Vector2(-0.35, 1.0)
	folhas.spread = 22.0
	folhas.gravity = Vector2(-6, 16)
	folhas.initial_velocity_min = 28.0
	folhas.initial_velocity_max = 64.0
	folhas.angular_velocity_min = -160.0
	folhas.angular_velocity_max = 160.0
	folhas.angle_min = 0.0
	folhas.angle_max = 360.0
	folhas.scale_amount_min = 1.0
	folhas.scale_amount_max = 2.0
	folhas.emitting = false
	add_child(folhas)

func _sala_atual() -> String:
	if game == null or game.exploration == null: return ""
	var id: String = game.exploration.room
	return id if SALAS.has(id) else ""

## A altura do chão em x: o piso da sala ou o topo de um bloco de alvenaria.
func _chao(x: float, piso: float) -> float:
	var y := piso
	for bloco in game.exploration.blocks:
		if x > bloco.position.x - 6.0 and x < bloco.end.x + 6.0: y = minf(y, bloco.position.y)
	return y

func _galerias(b: Rect2) -> Array:
	var lista: Array = []
	for g in game.exploration.ledges:
		if g.position.x >= b.position.x and g.end.x <= b.end.x and g.size.x >= 300.0: lista.append(g)
	return lista

## Monta os bichos da sala. A mesma sala monta sempre igual.
func _montar(id: String) -> void:
	sala = id
	for c in corvos: c.no.queue_free()
	corvos.clear()
	morcegos.clear()
	ratos.clear()
	folhas.emitting = false
	mariposas = false
	if id == "": return
	var data: Dictionary = game.exploration.rooms[id]
	var b: Rect2 = data.bounds
	var piso: float = data.floor
	var cfg: Dictionary = SALAS[id]
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(id) + 4141
	var galerias := _galerias(b)
	for i in range(int(cfg.get("corvos", 0))):
		var no := AnimatedSprite2D.new()
		no.sprite_frames = quadros
		no.offset = Vector2(0, -62)
		no.modulate = Color(0.78, 0.76, 0.8)
		add_child(no)
		no.animation_finished.connect(func():
			if no.animation=="levantar":
				no.offset=Vector2(0,-46)
				no.play("voo")
			elif no.animation=="bicando":no.play("pousado"))
		var corvo := {"no": no, "estado": "pousado", "espera": 0.0, "bica": rng.randf_range(1.0, 5.0), "rng": rng.randi()}
		corvos.append(corvo)
		_pousar(corvo, _poleiro(b, piso, galerias, rng), true)
	for i in range(int(cfg.get("morcegos", 0))):
		if galerias.is_empty(): break
		var g: Rect2 = galerias[i % galerias.size()]
		var casa := Vector2(rng.randf_range(g.position.x + 30.0, g.end.x - 30.0), g.end.y + 1.0)
		morcegos.append({"casa": casa, "pos": casa, "vel": Vector2.ZERO, "estado": "pendurado", "fase": rng.randf() * TAU, "espera": 0.0, "grupo": i % galerias.size()})
	for i in range(int(cfg.get("ratos", 0))):
		var x := rng.randf_range(b.position.x + 400.0, b.end.x - 400.0)
		ratos.append({"pos": Vector2(x, _chao(x, piso)), "dir": 1.0 if rng.randf() < 0.5 else -1.0, "corre": 0.0, "fase": rng.randf() * TAU, "anda": rng.randf_range(2.0, 6.0)})
	if cfg.has("folhas"):
		folhas.color = cfg.folhas
		folhas.emitting = true
	mariposas = bool(cfg.get("mariposas", false))

func _poleiro(b: Rect2, piso: float, galerias: Array, rng: RandomNumberGenerator) -> Vector2:
	# Metade dos corvos prefere as galerias, quando existem.
	if not galerias.is_empty() and rng.randf() < 0.5:
		var g: Rect2 = galerias[rng.randi() % galerias.size()]
		return Vector2(rng.randf_range(g.position.x + 30.0, g.end.x - 30.0), g.position.y)
	var x := rng.randf_range(b.position.x + 350.0, b.end.x - 350.0)
	return Vector2(x, _chao(x, piso))

func _pousar(corvo: Dictionary, onde: Vector2, imediato: bool) -> void:
	var no: AnimatedSprite2D = corvo.no
	corvo.poleiro = onde
	if imediato:
		no.offset=Vector2(0,-62)
		no.position = onde
		no.scale = Vector2.ONE * 0.36
		no.modulate.a = 1.0
		no.rotation = 0.0
		no.play("pousado")
		corvo.estado = "pousado"
		return
	# Volta de longe: desce em curva até o poleiro e fecha as asas ao tocar o chão.
	var lado := -1.0 if (corvo.rng + voos) % 2 == 0 else 1.0
	no.position = onde + Vector2(lado * 620.0, -560.0)
	no.flip_h = lado > 0.0
	no.scale = Vector2.ONE * 0.36
	no.modulate.a = 0.0
	no.rotation = 0.0
	no.offset=Vector2(0,-46)
	no.play("voo")
	corvo.estado = "voltando"
	var volta := no.create_tween()
	volta.set_parallel(true)
	volta.tween_property(no, "position", onde, 2.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	volta.tween_property(no, "modulate:a", 1.0, 0.8)
	volta.chain().tween_callback(func():
		no.offset=Vector2(0,-62)
		no.play("pousado")
		corvo.estado = "pousado")

func _levantar(corvo: Dictionary, de_onde: Vector2) -> void:
	if corvo.estado != "pousado": return
	var no: AnimatedSprite2D = corvo.no
	corvo.estado = "voando"
	corvo.espera = 14.0 + float(corvo.rng % 9)
	voos += 1
	# Foge para o lado oposto de quem assustou, subindo.
	var lado := 1.0 if no.position.x >= de_onde.x else -1.0
	no.flip_h = lado < 0.0
	no.rotation = 0.0
	no.play("levantar")
	var destino := no.position + Vector2(lado * (520.0 + float(corvo.rng % 260)), -620.0)
	var fuga := no.create_tween()
	fuga.tween_interval(2.0/12.0)
	fuga.set_parallel(false)
	fuga.tween_property(no, "position:x", destino.x, 2.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	fuga.parallel().tween_property(no, "position:y", destino.y, 2.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	fuga.parallel().tween_property(no, "scale", Vector2.ONE * 0.27, 2.3)
	fuga.parallel().tween_property(no, "modulate:a", 0.0, 0.7).set_delay(1.6)
	fuga.chain().tween_callback(func(): corvo.estado = "longe")

## Um estalo forte: corvos e morcegos por perto se espantam.
func susto(onde: Vector2, raio: float) -> void:
	for corvo in corvos:
		if corvo.estado == "pousado" and corvo.no.position.distance_to(onde) < raio: _levantar(corvo, onde)
	for m in morcegos:
		if m.estado == "pendurado" and m.casa.distance_to(onde) < raio: _revoada(m.grupo, onde)

func _revoada(grupo: int, de_onde: Vector2) -> void:
	var saiu := false
	for m in morcegos:
		if m.grupo != grupo or m.estado != "pendurado": continue
		m.estado = "voando"
		m.espera = 26.0
		var lado := 1.0 if m.casa.x >= de_onde.x else -1.0
		m.vel = Vector2(lado * (150.0 + 130.0 * absf(sin(m.fase * 3.0))), -60.0 - 110.0 * absf(cos(m.fase * 2.0)))
		saiu = true
	if saiu: revoadas += 1

func _alvos() -> Array:
	var lista: Array = []
	if game.player != null: lista.append(game.player.global_position)
	var segunda = game.get("partner")
	if segunda != null and is_instance_valid(segunda) and segunda.visible: lista.append(segunda.global_position)
	return lista

func _process(delta: float) -> void:
	var id := _sala_atual()
	if id != sala: _montar(id)
	visible = id != ""
	if not visible: return
	t += delta
	var alvos := _alvos()
	var data: Dictionary = game.exploration.rooms[sala]
	var b: Rect2 = data.bounds
	var piso: float = data.floor
	var cam: Vector2 = game.player.camera.get_screen_center_position()
	folhas.position = cam + Vector2(0, -400)
	# ---- corvos
	for corvo in corvos:
		var no: AnimatedSprite2D = corvo.no
		match str(corvo.estado):
			"pousado":
				for alvo in alvos:
					if absf(alvo.x - no.position.x) < 230.0 and absf(alvo.y - no.position.y) < 210.0:
						_levantar(corvo, alvo)
						break
				# A bicada usa os quadros pintados; o gatilho de fuga continua independente.
				corvo.bica -= delta
				if corvo.bica<=0.0 and corvo.estado=="pousado":
					corvo.bica=2.5+float((corvo.rng+int(t*3.0))%5)
					no.play("bicando")
			"longe":
				corvo.espera -= delta
				if corvo.espera <= 0.0:
					# Pousa longe de quem está na sala.
					var rng := RandomNumberGenerator.new()
					rng.seed = corvo.rng + voos * 31
					var onde := _poleiro(b, piso, _galerias(b), rng)
					var livre := true
					for alvo in alvos:
						if absf(alvo.x - onde.x) < 520.0: livre = false
					if livre: _pousar(corvo, onde, false)
					else: corvo.espera = 3.0
	# ---- morcegos
	for m in morcegos:
		match str(m.estado):
			"pendurado":
				for alvo in alvos:
					if absf(alvo.x - m.casa.x) < 150.0 and alvo.y > m.casa.y - 20.0 and alvo.y - m.casa.y < 330.0:
						_revoada(m.grupo, alvo)
						break
			"voando":
				# Voo nervoso: a direção muda o tempo todo, e sempre um pouco para cima.
				m.vel += Vector2(sin(t * 7.0 + m.fase) * 520.0, cos(t * 5.3 + m.fase * 1.7) * 380.0 - 70.0) * delta
				m.vel = m.vel.limit_length(330.0)
				m.pos += m.vel * delta
				m.espera -= delta
				if m.espera <= 0.0:
					var perto := false
					for alvo in alvos:
						if absf(alvo.x - m.casa.x) < 620.0: perto = true
					if perto: m.espera = 4.0
					else:
						m.estado = "pendurado"
						m.pos = m.casa
	# ---- ratos
	for r in ratos:
		if r.corre > 0.0:
			r.corre -= delta
			var x: float = clampf(r.pos.x + r.dir * 300.0 * delta, b.position.x + 120.0, b.end.x - 120.0)
			if is_equal_approx(x, r.pos.x): r.corre = 0.0
			r.pos = Vector2(x, _chao(x, piso))
		else:
			for alvo in alvos:
				if absf(alvo.x - r.pos.x) < 210.0 and absf(alvo.y - r.pos.y) < 150.0:
					r.dir = 1.0 if r.pos.x >= alvo.x else -1.0
					r.corre = 1.5 + 0.6 * absf(sin(r.fase + t))
					break
			# Sem ninguém por perto, anda um pouquinho e para para farejar.
			r.anda -= delta
			if r.anda <= 0.0:
				r.anda = 3.0 + 3.0 * absf(sin(r.fase + t * 0.3))
				r.dir = -r.dir if sin(r.fase * 5.0 + t) > 0.0 else r.dir
			elif r.anda < 0.8 and r.corre <= 0.0:
				var x2: float = clampf(r.pos.x + r.dir * 60.0 * delta, b.position.x + 120.0, b.end.x - 120.0)
				r.pos = Vector2(x2, _chao(x2, piso))
	queue_redraw()

func _draw() -> void:
	if sala == "": return
	var cam: Vector2 = game.player.camera.get_screen_center_position()
	var vista := Rect2(cam - Vector2(720, 460), Vector2(1440, 920))
	# As posições e os gatilhos são os mesmos; a silhueta vem das folhas pintadas.
	for m in morcegos:
		if not vista.has_point(m.pos):continue
		var indice:=0 if m.estado=="pendurado" else 1+int(t*14.0+m.fase)%5
		var canto:=Vector2(m.pos)-Vector2(16,0 if indice==0 else 16)
		draw_texture_rect_region(textura_morcego,Rect2(canto,Vector2(32,32)),Rect2(indice*64,0,64,64))
	for r in ratos:
		if not vista.has_point(r.pos):continue
		var indice:=2+int(t*16.0+r.fase)%4 if r.corre>0.0 else int(t*4.0+r.fase)%2
		draw_set_transform(r.pos,0,Vector2(r.dir,1))
		draw_texture_rect_region(textura_rato,Rect2(-20,-20,40,20),Rect2(indice*64,0,64,32))
		draw_set_transform(Vector2.ZERO)
	# ---- mariposas: pontos claros que rondam as lamparinas mais próximas.
	if mariposas and game.life_back != null:
		for h in game.life_back.hung:
			if str(h.kind) != "lamp" or absf(h.x - cam.x) > 760.0: continue
			var luz: Vector2 = Vector2(h.x, h.top) + Vector2(sin(h.ang), cos(h.ang)) * float(h.len) * 0.93
			for i in range(4):
				var a: float = t * (1.7 + i * 0.6) + h.phase + i * 1.9
				var q := luz + Vector2(cos(a) * (16.0 + 9.0 * sin(t * 2.3 + i)), sin(a * 1.3) * (12.0 + 6.0 * cos(t * 1.7 + i)))
				draw_circle(q, 1.4, Color(1.0, 0.9, 0.7, 0.55 + 0.3 * sin(t * 20.0 + i)))
