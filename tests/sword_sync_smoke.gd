extends SceneTree
## Verifica os quadros com espada e as poses originais usadas antes da coleta.
const ARMADO := "res://assets/animation/hero_motion_espada.png"
const DESARMADO := "res://assets/animation/hero_motion.png"
const ACOES_ARMADAS := "res://assets/animation/hero_acoes_espada.png"
const REACOES_DESARMADAS := "res://assets/animation/hero_reactions.png"
const GOLPES_ARMADOS := "res://assets/animation/hero_golpes_novos.png"
const GOLPES := {
	"contracorte": ["attack", 6],
	"estocada": ["attack", 6],
	"descendente": ["attack", 7],
	"ascendente": ["ascendente", 6],
	"investida": ["investida", 6],
	"aereo2": ["air_attack", 5],
	"prece": ["prece", 6],
}
var checks := 0
var failures := 0

func _initialize() -> void:
	call_deferred("run")

func expect(ok: bool, label: String) -> void:
	checks += 1
	print("PASS: " if ok else "FAIL: ", label)
	if not ok:
		failures += 1

func verificar_quadros(p, clipe: String, folha: String, linha: int) -> bool:
	if p.animator.sprite_frames.get_frame_count(clipe) != 6:
		return false
	for i in range(6):
		for direcao in [-1, 1]:
			p.facing = direcao
			p.animator.pose(clipe, direcao, i)
			p._update_sword()
			var quadro := p.animator.sprite_frames.get_frame_texture(clipe, i) as AtlasTexture
			if p.sword.visible or quadro == null or quadro.atlas.resource_path != folha:
				return false
			if p.animator.flip_h != (direcao < 0) or quadro.region != Rect2(i * 256, linha * 256, 256, 256):
				return false
	return true

func run() -> void:
	var p = load("res://scenes/player.tscn").instantiate()
	root.add_child(p)
	p.set_physics_process(false)
	p.set_process(false)
	p.state = "idle"
	expect(p.animator.animation == "idle_desarmado", "o Penitente começa com as mãos vazias")
	for running in [false, true]:
		var linha := 1 if running else 0
		var nome := "corrida" if running else "parado"
		p.has_weapon = false
		expect(verificar_quadros(p, p._locomotion_clip(running), DESARMADO, linha), "%s sem arma: seis quadros originais" % nome)
		p.has_weapon = true
		expect(verificar_quadros(p, p._locomotion_clip(running), ARMADO, linha), "%s com arma: seis quadros com espada e sem sobreposição" % nome)
	for acao in ["roll", "hurt"]:
		p.state = acao
		p.state_t = p.ROLL_TIME if acao == "roll" else 0.25
		p.has_weapon = false
		p._update_animation()
		expect(p.animator.animation == acao + "_desarmado", "%s mantém a pose sem arma antes da coleta" % acao)
		p.has_weapon = true
		p._update_animation()
		expect(p.animator.animation == acao and verificar_quadros(p, acao, ACOES_ARMADAS, 0 if acao == "roll" else 2), "%s usa a espada desenhada em todos os quadros" % acao)
	p.state = "idle"
	p.has_weapon = false
	p._update_animation()
	expect(p.animator.animation == "jump_desarmado" and verificar_quadros(p, "jump_desarmado", REACOES_DESARMADAS, 0), "salto antes da coleta mantém os quadros sem arma")
	p.has_weapon = true
	p._update_animation()
	expect(p.animator.animation == "air_drift", "salto armado usa o clipe de voo")
	for clipe in ["jump", "air_drift", "air_land"]:
		expect(verificar_quadros(p, clipe, ACOES_ARMADAS, 1), "%s usa os seis quadros de salto com espada" % clipe)
	for golpe in GOLPES:
		var clipe: String = "golpe_" + golpe
		p.state = GOLPES[golpe][0]
		p.golpe_tipo = golpe
		p.attack_len = 0.4
		p.state_t = 0.1
		p._update_animation()
		p._update_sword()
		var quadro := p.animator.sprite_frames.get_frame_texture(clipe, p.animator.frame) as AtlasTexture
		expect(p.animator.animation == clipe and not p.sword.visible and quadro != null
			and quadro.atlas.resource_path == GOLPES_ARMADOS and quadro.region.size == Vector2(256, 256)
			and p.animator.sprite_frames.get_frame_count(clipe) == GOLPES[golpe][1]
			and not p.animator.sprite_frames.get_animation_loop(clipe), "%s seleciona os quadros próprios, sem repetição nem espada solta" % golpe)
	p.free()
	print("SWORD_SYNC: %d checks, %d failures" % [checks, failures])
	quit(0 if failures == 0 else 1)
