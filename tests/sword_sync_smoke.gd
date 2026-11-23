extends SceneTree
## Verifica os quadros com espada e as poses originais usadas antes da coleta.
const ARMADO := "res://assets/animation/hero_motion_espada.png"
const DESARMADO := "res://assets/animation/hero_motion.png"
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
	p.free()
	print("SWORD_SYNC: %d checks, %d failures" % [checks, failures])
	quit(0 if failures == 0 else 1)
