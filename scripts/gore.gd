extends RefCounted
## Gore: desmembramento a partir do quadro em que a criatura morreu.
## O quadro é congelado e recortado em pedaços (shaders/corte_gore.gdshader); cada pedaço cai,
## rola ou tomba com o seu próprio peso, deixa um rastro de gotas e fica no chão por meio minuto.
## Cada criatura morre de um jeito: decapitada, partida ao meio, cortada na cintura, erguida na lâmina,
## com o coração arrancado ou com o crânio esmagado.

const SHADER := preload("res://shaders/corte_gore.gdshader")
const VIDA_NO_CHAO := 30.0
const MAX_PEDACOS := 26

## Estilo de execução de cada criatura (pelo tipo).
const ESTILOS := {
	0: "cabeca", 7: "cabeca", 11: "cabeca", 18: "cabeca",
	4: "vertical", 16: "vertical",
	3: "cintura", 10: "cintura", 15: "cintura",
	8: "erguer", 12: "erguer",
	5: "coracao", 6: "coracao", 13: "coracao",
	1: "cranio", 14: "cranio", 17: "cranio",
}
const NOMES := {"cabeca": "Decapitação", "vertical": "Partido ao meio", "cintura": "Cortado na cintura", "erguer": "Erguido na lâmina", "coracao": "Coração arrancado", "cranio": "Crânio esmagado"}

static var _cobertura: Dictionary = {}

static func estilo_de(kind: int) -> String:
	return ESTILOS.get(kind, "cintura")

## Recorta e espalha o corpo. `lado` é para onde o golpe empurra (o lado do matador).
static func finalizar(game, e, estilo: String, lado: int, matador = null, chao := NAN) -> void:
	if game == null or e == null or not is_instance_valid(e) or e.animator == null: return
	var q := _quadro(e)
	if q.is_empty(): return
	if is_nan(chao): chao = _chao(game, e.global_position)
	e.animator.visible = false
	e.set_meta("desmembrado", true)
	_limitar(game)
	var u: Rect2 = q.usado
	var topo := u.position.y
	var base := u.end.y
	var altura := u.size.y
	match estilo:
		"cabeca":
			var corte := topo + altura * 0.24
			var pe := _pe(q, lado, u.position.x, u.end.x)
			var corpo = _peca(game, q, Vector3(0, 1, -corte), pe, chao)
			corpo.tombar(lado, 0.35)
			var cabeca = _peca(game, q, Vector3(0, -1, corte), Vector2(u.get_center().x, topo + altura * 0.13), chao)
			cabeca.voar(Vector2(lado * randf_range(150, 260), randf_range(-620, -480)), lado * randf_range(8.0, 13.0))
			jato(corpo, _local(q, Vector2(u.get_center().x, corte), pe), Vector2(0.15 * lado, -1), 1.5, 1.15, game)
			game.sangue_na_tela(7)
			game.play_sfx("decapitacao")
		"vertical":
			var meio := u.get_center().x
			var sinal := -1 if q.flip else 1
			# A metade da esquerda da folha cai para o seu lado de fora; a da direita, para o outro.
			var esquerda = _peca(game, q, Vector3(-1, 0, meio), Vector2(u.position.x, base), chao)
			var direita = _peca(game, q, Vector3(1, 0, -meio), Vector2(u.end.x, base), chao)
			esquerda.tombar(-sinal, 0.08, 0.92)
			direita.tombar(sinal, 0.08, 0.92)
			esquerda.vel = Vector2(-sinal * 60.0, 0)
			direita.vel = Vector2(sinal * 60.0, 0)
			jato(esquerda, _local(q, Vector2(meio, topo + altura * 0.45), Vector2(u.position.x, base)), Vector2(0, -1), 0.8, 0.9, game)
			_cortina(game, q.pos + Vector2(0, 0), altura * q.tex.get_size().y * q.scale.y)
			game.sangue_na_tela(9)
			game.play_sfx("corpo_partido")
		"cintura":
			var cintura := topo + altura * 0.52
			var pe_c := _pe(q, -lado, u.position.x, u.end.x)
			var pernas = _peca(game, q, Vector3(0, 1, -cintura), pe_c, chao)
			pernas.tombar(-lado, 0.7)
			var tronco = _peca(game, q, Vector3(0, -1, cintura), Vector2(u.get_center().x, topo + altura * 0.3), chao)
			tronco.voar(Vector2(lado * randf_range(200, 300), randf_range(-430, -330)), lado * randf_range(4.0, 7.0))
			jato(pernas, _local(q, Vector2(u.get_center().x, cintura), pe_c), Vector2(0.1 * lado, -1), 1.1, 1.0, game)
			jato(tronco, _local(q, Vector2(u.get_center().x, cintura), Vector2(u.get_center().x, topo + altura * 0.3)), Vector2(-0.2 * lado, 1), 0.7, 0.7, game)
			game.sangue_na_tela(6)
			game.play_sfx("corpo_partido")
		"erguer":
			var inteiro = _peca(game, q, Vector3(0, 0, 1), Vector2(u.get_center().x, topo + altura * 0.5), chao)
			inteiro.voar(Vector2(lado * 90.0, -460.0), lado * 2.5)
			jato(inteiro, Vector2.ZERO, Vector2(0, 1), 0.9, 0.8, game)
			game.sangue_na_tela(5)
			game.play_sfx("empalar")
		"coracao":
			var pe_k := _pe(q, lado, u.position.x, u.end.x)
			var corpo = _peca(game, q, Vector3(0, 0, 1), pe_k, chao)
			corpo.tombar(lado, 0.3)
			var mao: Vector2 = (matador.global_position + Vector2(-lado * -34.0, -64.0)) if matador != null and is_instance_valid(matador) else q.pos
			var coracao = Coracao.new()
			coracao.game = game
			coracao.chao = chao
			coracao.lado = lado
			game.add_child(coracao)
			coracao.global_position = mao
			jato(corpo, _local(q, Vector2(u.get_center().x, topo + altura * 0.38), pe_k), Vector2(-0.4 * lado, -1), 0.9, 0.8, game)
			game.sangue_na_tela(5)
			game.play_sfx("coracao_arrancado")
		"cranio":
			var corte := topo + altura * 0.26
			var pe_x := _pe(q, lado, u.position.x, u.end.x)
			var corpo = _peca(game, q, Vector3(0, 1, -corte), pe_x, chao)
			corpo.tombar(lado, 0.25)
			var onde: Vector2 = q.pos + _local(q, Vector2(u.get_center().x, topo + altura * 0.13), Vector2(0.5, 0.5))
			_estilhacos(game, onde, lado)
			jato(corpo, _local(q, Vector2(u.get_center().x, corte), pe_x), Vector2(0, -1), 1.0, 0.9, game)
			game.sangue_na_tela(12)
			game.play_sfx("cranio_esmagado")
		_:
			var inteiro = _peca(game, q, Vector3(0, 0, 1), _pe(q, lado, u.position.x, u.end.x), chao)
			inteiro.tombar(lado, 0.2)
	# Uma poça larga que cresce devagar debaixo do que sobrou.
	game.blood_splats(Vector2(q.pos.x, chao), lado, 18, 1.6)
	if game.player != null: game.player._blood_decal(Vector2(q.pos.x, chao - 4.0))

## Pé do lado para onde o corpo cai: girar em volta dele deita o corpo sobre o chão, sem afundar.
static func _pe(q: Dictionary, lado: int, de_u: float, ate_u: float) -> Vector2:
	var direita := (lado > 0) != bool(q.flip)
	return Vector2(ate_u if direita else de_u, q.usado.end.y)

## Quadro atual da criatura: textura, espelhamento, escala, centro no mundo e retângulo ocupado (0..1).
static func _quadro(e) -> Dictionary:
	var an = e.animator
	if an.sprite_frames == null or not an.sprite_frames.has_animation(an.animation): return {}
	var tex = an.sprite_frames.get_frame_texture(an.animation, an.frame)
	if not (tex is AtlasTexture): return {}
	var chave: String = tex.atlas.resource_path + str(tex.region)
	if not _cobertura.has(chave):
		var img: Image = tex.atlas.get_image()
		if img == null: return {}
		if img.is_compressed(): img.decompress()
		var cel := img.get_region(Rect2i(tex.region))
		var usado := cel.get_used_rect()
		var tam := Vector2(cel.get_size())
		_cobertura[chave] = Rect2(Vector2(usado.position) / tam, Vector2(usado.size) / tam) if usado.size.x > 0 else Rect2(0.2, 0.1, 0.6, 0.85)
	return {"tex": tex, "flip": an.flip_h, "scale": an.global_scale, "pos": an.global_position, "usado": _cobertura[chave]}

## Converte um ponto da célula (u, v) para coordenadas em relação a outro ponto da célula (o pivô), no mundo.
static func _local(q: Dictionary, ponto: Vector2, pivo: Vector2) -> Vector2:
	var cel: Vector2 = q.tex.get_size()
	var d := (ponto - pivo) * cel
	if q.flip: d.x = -d.x
	return d * q.scale

static func _peca(game, q: Dictionary, plano: Vector3, pivo: Vector2, chao: float):
	var p = Pedaco.new()
	p.game = game
	p.chao = chao
	var spr := Sprite2D.new()
	spr.texture = q.tex
	spr.flip_h = q.flip
	spr.scale = q.scale
	spr.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	var m := ShaderMaterial.new()
	m.shader = SHADER
	var size: Vector2 = q.tex.atlas.get_size()
	var reg: Rect2 = q.tex.region
	m.set_shader_parameter("frame_bounds", Vector4(reg.position.x / size.x, reg.position.y / size.y, reg.end.x / size.x, reg.end.y / size.y))
	m.set_shader_parameter("plano", plano)
	m.set_shader_parameter("semente", randf() * 100.0)
	spr.material = m
	var deslocamento := _local(q, pivo, Vector2(0.5, 0.5))
	spr.position = -deslocamento
	p.add_child(spr)
	p.z_index = 5
	p.add_to_group("pedacos_gore")
	game.add_child(p)
	p.global_position = q.pos + deslocamento
	# Quanto o pedaço se estende abaixo do pivô (para não afundar no chão).
	var u: Rect2 = q.usado
	# Extensão do próprio pedaço (o corte limita a parte visível do quadro).
	var fundo_v := u.end.y
	if plano.y < -0.5: fundo_v = minf(plano.z, u.end.y)
	var largura_u := u.size.x * (0.5 if absf(plano.x) > 0.5 else 1.0)
	p.abaixo = maxf((fundo_v - pivo.y) * q.tex.get_size().y * q.scale.y, 4.0)
	p.largura = largura_u * q.tex.get_size().x * q.scale.x
	return p

static func _chao(game, perto: Vector2) -> float:
	var consulta := PhysicsRayQueryParameters2D.create(perto + Vector2(0, -8), perto + Vector2(0, 1400), 1)
	var hit: Dictionary = game.get_world_2d().direct_space_state.intersect_ray(consulta)
	return hit.position.y if not hit.is_empty() else perto.y

static func _limitar(game) -> void:
	var velhos: Array = game.get_tree().get_nodes_in_group("pedacos_gore")
	while velhos.size() > MAX_PEDACOS:
		var primeiro = velhos.pop_front()
		primeiro.remove_from_group("pedacos_gore")
		primeiro.queue_free()

## Jato de sangue contínuo, preso a um pedaço (gira junto quando ele tomba).
static func jato(pai: Node2D, local: Vector2, direcao: Vector2, duracao: float, forca: float, game = null) -> void:
	var j := CPUParticles2D.new()
	j.amount = 90
	j.lifetime = 1.0
	j.direction = direcao.normalized()
	j.spread = 9.0
	j.initial_velocity_min = 240.0 * forca
	j.initial_velocity_max = 620.0 * forca
	j.gravity = Vector2(0, 1500)
	j.scale_amount_min = 1.6
	j.scale_amount_max = 4.2
	var tons := Gradient.new()
	tons.colors = PackedColorArray([Color(0.7, 0.02, 0.05), Color(0.34, 0.0, 0.02)])
	j.color_initial_ramp = tons
	j.position = local
	j.z_index = 7
	pai.add_child(j)
	j.emitting = true
	# Os temporizadores ficam dentro do próprio jato: se o pedaço sumir antes, eles somem junto.
	var pulsos := Timer.new()
	pulsos.wait_time = 0.22
	pulsos.autostart = true
	j.add_child(pulsos)
	j.set_meta("pulso", 0)
	pulsos.timeout.connect(func():
		var k: int = int(j.get_meta("pulso")) + 1
		j.set_meta("pulso", k)
		j.initial_velocity_max = 620.0 * forca * maxf(1.0 - 0.12 * k, 0.3)
		if game != null and float(k) * 0.22 < duracao:
			var dono = j.get_parent()
			var y_chao: float = dono.chao if "chao" in dono else dono.global_position.y
			game.blood_splats(Vector2(dono.global_position.x, y_chao), 1 if randf() < 0.5 else -1, 2, 0.6)
	)
	var fim := Timer.new()
	fim.wait_time = duracao
	fim.one_shot = true
	fim.autostart = true
	j.add_child(fim)
	fim.timeout.connect(func():
		j.emitting = false
		pulsos.stop()
		var apaga := Timer.new()
		apaga.wait_time = 1.3
		apaga.one_shot = true
		apaga.autostart = true
		j.add_child(apaga)
		apaga.timeout.connect(j.queue_free)
	)

## Cortina de sangue entre as duas metades.
static func _cortina(game, onde: Vector2, altura: float) -> void:
	var c := CPUParticles2D.new()
	c.one_shot = true
	c.amount = 120
	c.lifetime = 1.1
	c.explosiveness = 0.85
	c.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	c.emission_rect_extents = Vector2(4, altura * 0.45)
	c.direction = Vector2(0, -1)
	c.spread = 80.0
	c.initial_velocity_min = 80.0
	c.initial_velocity_max = 380.0
	c.gravity = Vector2(0, 1400)
	c.scale_amount_min = 1.5
	c.scale_amount_max = 3.8
	c.color = Color(0.55, 0.01, 0.04)
	c.z_index = 7
	game.add_child(c)
	c.global_position = onde
	c.emitting = true
	game.get_tree().create_timer(2.0).timeout.connect(c.queue_free)

## Crânio esmagado: estilhaços de osso, massa escura e uma névoa vermelha.
static func _estilhacos(game, onde: Vector2, lado: int) -> void:
	var ossos := CPUParticles2D.new()
	ossos.one_shot = true
	ossos.amount = 14
	ossos.lifetime = 1.4
	ossos.explosiveness = 1.0
	ossos.direction = Vector2(lado, -1)
	ossos.spread = 80.0
	ossos.initial_velocity_min = 200.0
	ossos.initial_velocity_max = 560.0
	ossos.gravity = Vector2(0, 1700)
	ossos.angular_velocity_min = -720.0
	ossos.angular_velocity_max = 720.0
	var debris := AtlasTexture.new()
	debris.atlas = load("res://assets/animation/pedacos.png")
	debris.region = Rect2(0, 0, 384, 256)
	ossos.texture = debris
	var flip := CanvasItemMaterial.new()
	flip.particles_animation = true
	flip.particles_anim_h_frames = 3
	flip.particles_anim_v_frames = 2
	flip.particles_anim_loop = false
	ossos.material = flip
	ossos.anim_offset_max = 0.999
	ossos.scale_amount_min = 0.1
	ossos.scale_amount_max = 0.2
	ossos.z_index = 7
	game.add_child(ossos)
	ossos.global_position = onde
	ossos.emitting = true
	var massa := CPUParticles2D.new()
	massa.one_shot = true
	massa.amount = 70
	massa.lifetime = 1.2
	massa.explosiveness = 1.0
	massa.direction = Vector2(0, -1)
	massa.spread = 180.0
	massa.initial_velocity_min = 120.0
	massa.initial_velocity_max = 520.0
	massa.gravity = Vector2(0, 1500)
	massa.scale_amount_min = 2.0
	massa.scale_amount_max = 5.5
	var tons := Gradient.new()
	tons.colors = PackedColorArray([Color(0.62, 0.05, 0.07), Color(0.3, 0.0, 0.02), Color(0.55, 0.22, 0.22)])
	massa.color_initial_ramp = tons
	massa.z_index = 7
	game.add_child(massa)
	massa.global_position = onde
	massa.emitting = true
	game.spawn_effect("sangue", onde, lado, 0.9, "impactos")
	game.spawn_effect("osso", onde, lado, 0.7, "impactos")
	game.wall_splat(onde)
	game.get_tree().create_timer(2.2).timeout.connect(func():
		if is_instance_valid(ossos): ossos.queue_free()
		if is_instance_valid(massa): massa.queue_free()
	)


## Um pedaço de corpo com física simples: voa, quica, rola, ou tomba a partir dos pés.
class Pedaco extends Node2D:
	var game
	var vel := Vector2.ZERO
	var giro := 0.0
	var chao := 0.0
	var abaixo := 10.0
	var largura := 20.0
	var parado := false
	var voando := false
	var vida := VIDA_NO_CHAO
	var rasto_t := 0.0
	var quicou := false

	func voar(velocidade: Vector2, rotacao: float) -> void:
		vel = velocidade
		giro = rotacao
		voando = true

	## Fica de pé um instante e cai para o lado, girando em volta dos pés.
	func tombar(lado: int, espera: float, angulo := 0.92) -> void:
		var queda := create_tween()
		queda.tween_interval(espera)
		queda.tween_property(self, "rotation", float(lado) * PI * 0.5 * angulo, 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		queda.tween_callback(func():
			parado = true
			if game != null:
				game.play_sfx("corpo_cai_carne")
				game.shake_cam(3.0)
				game.blood_splats(Vector2(global_position.x + lado * abaixo * 0.4, chao), lado, 6, 1.0)
		)

	func _physics_process(delta: float) -> void:
		if parado or not voando:
			if parado:
				vida -= delta
				if vida < 4.0: modulate.a = maxf(vida / 4.0, 0.0)
				if vida <= 0.0: queue_free()
			else:
				position += vel * delta
				vel = vel.move_toward(Vector2.ZERO, 300.0 * delta)
			return
		vel.y += 1700.0 * delta
		position += vel * delta
		rotation += giro * delta
		rasto_t -= delta
		if rasto_t <= 0.0 and game != null:
			rasto_t = 0.07
			game.blood_splats(Vector2(global_position.x, chao), 1, 1, 0.2)
		var fundo := maxf(abaixo, largura * 0.35)
		if global_position.y + fundo * 0.6 >= chao and vel.y > 0.0:
			global_position.y = chao - fundo * 0.6
			if not quicou and vel.y > 300.0:
				quicou = true
				vel = Vector2(vel.x * 0.5, -vel.y * 0.25)
				giro *= 0.4
				if game != null:
					game.play_sfx("respingo_chao")
					game.blood_splats(Vector2(global_position.x, chao), 1, 5, 0.8)
			else:
				# Deita do lado mais próximo e escorrega até parar.
				voando = false
				parado = true
				var deitado := PI * 0.5 * (1.0 if fposmod(rotation, TAU) < PI else -1.0)
				create_tween().tween_property(self, "rotation", deitado if largura < abaixo * 1.2 else 0.0, 0.18)
				if game != null: game.play_sfx("corpo_cai_carne")


## O coração arrancado: fica um instante na mão, ainda batendo e espirrando, e cai.
class Coracao extends Node2D:
	var game
	var chao := 0.0
	var lado := 1
	var t := 0.0
	var vel := Vector2.ZERO
	var solto := false
	var parado := false
	var vida := VIDA_NO_CHAO

	func _ready() -> void:
		z_index = 9

	func _physics_process(delta: float) -> void:
		t += delta
		if not solto:
			if int(t / 0.18) != int((t - delta) / 0.18) and game != null:
				game.player._blood_burst(global_position, 0.45, 10)
			if t >= 0.6:
				solto = true
				vel = Vector2(lado * 90.0, -120.0)
				if game != null: game.play_sfx("carne_rasga")
		elif not parado:
			vel.y += 1600.0 * delta
			position += vel * delta
			if global_position.y + 6.0 >= chao:
				global_position.y = chao - 6.0
				parado = true
				if game != null:
					game.play_sfx("respingo_chao")
					game.blood_splats(Vector2(global_position.x, chao), lado, 6, 0.7)
		else:
			vida -= delta
			if vida < 4.0: modulate.a = maxf(vida / 4.0, 0.0)
			if vida <= 0.0: queue_free()
		queue_redraw()

	func _draw() -> void:
		var bate := 1.0 + (0.16 * maxf(sin(t * 18.0), 0.0) if not parado else 0.0)
		var s := 9.0 * bate
		var escuro := Color(0.38, 0.02, 0.04)
		var vivo := Color(0.66, 0.05, 0.08)
		draw_circle(Vector2(-s * 0.45, -s * 0.2), s * 0.62, escuro)
		draw_circle(Vector2(s * 0.45, -s * 0.2), s * 0.62, escuro)
		draw_colored_polygon(PackedVector2Array([Vector2(-s * 1.05, 0), Vector2(s * 1.05, 0), Vector2(0, s * 1.35)]), escuro)
		draw_circle(Vector2(-s * 0.35, -s * 0.3), s * 0.38, vivo)
		draw_line(Vector2(-s * 0.1, -s * 0.9), Vector2(-s * 0.3, -s * 1.5), Color(0.5, 0.1, 0.12), 2.5)
		draw_line(Vector2(s * 0.2, -s * 0.85), Vector2(s * 0.4, -s * 1.45), Color(0.45, 0.08, 0.1), 2.0)
		draw_circle(Vector2(-s * 0.5, -s * 0.45), s * 0.12, Color(0.95, 0.6, 0.55, 0.7))
