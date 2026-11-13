extends SceneTree
## Exercita comandos reais e transições de combate, sem tocar em dados do jogador.
var game
var p
var checks := 0
var failures := 0

func _initialize() -> void: call_deferred("run")
func frames(n: int) -> void:
	for i in range(n):
		await physics_frame
		await process_frame
func expect(ok: bool, label: String) -> void:
	checks += 1
	print("PASS: " if ok else "FAIL: ", label)
	if not ok: failures += 1
func tap(action: String) -> void:
	Input.action_press(action)
	await frames(1)
	Input.action_release(action)
	await frames(1)
func reset() -> void:
	for action in ["attack", "roll", "parry", "heavy", "left", "right", "jump", "down"]: Input.action_release(action)
	for e in get_nodes_in_group("enemies"): e.queue_free()
	p.character = "penitente"
	p.lance_weight = 0
	p.revive(Vector2(1300, 600))
	p.facing = 1
	p.has_weapon = true
	await frames(4)
func enemy_at(pos: Vector2, kind: int = 0):
	var e = game.EnemyScript.new()
	e.setup(kind, pos, 0, p)
	e.room_id = "city"
	game.add_child(e)
	e.set_physics_process(false)
	e.spawn_opacity = 1.0
	return e
func run() -> void:
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	game._start_game(false, false)
	for i in range(3):
		game.message_t = 0
		game.advance_message()
	await frames(3)
	p = game.player
	await reset()
	# O próximo toque durante a pausa não desaparece nem repete indefinidamente.
	p._start_attack()
	p.state_t = p.attack_len * 0.22
	p.hit_pause = 0.065
	await tap("attack")
	await frames(8)
	expect(p.combo_step == 1, "entrada durante impacto encadeia o segundo golpe")
	await frames(45)
	expect(p.state == "idle" and p.combo_step == 1, "um toque não gera ataques automáticos adicionais")
	await reset()
	p._start_attack()
	p.state_t = p.attack_len * 0.35
	await tap("roll")
	expect(p.state == "roll", "esquiva cancela recuperação após contato")
	await reset()
	p._start_attack()
	p.state_t = p.attack_len * 0.25
	p.hit_pause = 0.065
	Input.action_press("left")
	await tap("roll")
	Input.action_release("left")
	await frames(8)
	expect(p.state == "roll" and p.facing == -1, "direção da esquiva é preservada durante a pausa de impacto")
	await reset()
	p._start_attack()
	p.state_t = p.attack_len * 0.92
	await tap("roll")
	expect(p.state == "attack", "esquiva não apaga a preparação do golpe")
	await reset()
	p._start_attack()
	p.state_t = p.attack_len * 0.35
	await tap("parry")
	expect(p.state == "parry", "aparo pode sair da recuperação do ataque")
	var e = enemy_at(p.position + Vector2(55, 0))
	p.take_hit(16, e.position.x, e, true)
	expect(p.parry_hit and e.state == "stagger", "aparo preserva abertura real do inimigo")
	await tap("attack")
	await frames(8)
	expect(p.state == "attack" and p.counter_attack, "contra-ataque responde logo depois do aparo")
	await reset()
	Input.action_press("heavy")
	p._start_charge()
	await tap("roll")
	expect(p.state == "roll", "carregamento pode ser abandonado com esquiva")
	Input.action_release("heavy")
	await reset()
	p._start_attack()
	p.state_t = p.attack_len * 0.24
	await tap("jump")
	expect(p.state == "idle" and p.velocity.y < 0, "salto sai da recuperação sem esperar a animação inteira")
	Input.action_release("jump")
	await reset()
	await tap("heavy")
	expect(p.state == "heavy", "toque curto no pesado produz golpe, não comando perdido")
	await reset()
	p.character = "beatriz"
	p.lance_weight = 100
	p._start_attack()
	var first_len: float = p.attack_len
	p.state = "idle"
	p._start_attack()
	p.state = "idle"
	p._start_attack()
	expect(p.finisher and p.attack_len > first_len, "Beatriz com lança pesada ainda completa a cadeia de três")
	p.position = Vector2(1300, 500)
	p.facing = -1
	var aerial = enemy_at(Vector2(1160, 500))
	var hp_before: float = aerial.hp
	p.hit_list.clear()
	p._attack_hits(true)
	expect(aerial.hp < hp_before, "lança conserva alcance e espelhamento no ar")
	await reset()
	var victim = enemy_at(p.position + Vector2(60, 0))
	victim.hp = 200
	p.hit_list.clear()
	p._attack_hits()
	var once: float = victim.hp
	p._attack_hits()
	expect(is_equal_approx(victim.hp, once), "um golpe causa dano uma vez por alvo")
	expect(is_equal_approx(p.hit_pause, 0.045), "impacto leve usa pausa curta de 45 ms")
	# Uma parede sólida entre a lâmina e o corpo deve bloquear o ataque.
	var wall := StaticBody2D.new()
	wall.collision_layer = 1
	var shape := CollisionShape2D.new()
	var box := RectangleShape2D.new()
	box.size = Vector2(10, 120)
	shape.shape = box
	wall.add_child(shape)
	wall.position = p.position + Vector2(30, -60)
	game.add_child(wall)
	await frames(2)
	p.hit_list.clear()
	var blocked_hp: float = victim.hp
	p._attack_hits()
	expect(is_equal_approx(victim.hp, blocked_hp), "golpe não atravessa parede")
	wall.queue_free()
	await reset()
	p.partner_hp = 31
	p.hp = 10
	p.share_cd = 0
	p.share_blood()
	expect(p.partner_hp >= 1, "sangue compartilhado nunca deixa parceiro com vida negativa")
	game.reduced_pulses = true
	p._slow_motion(0.3, 0.15)
	expect(is_equal_approx(Engine.time_scale, 1), "pulsos reduzidos também desativam câmera lenta de impacto")
	await reset()
	var lead = enemy_at(p.position + Vector2(55, 0))
	var waiting = enemy_at(p.position + Vector2(65, 0))
	lead.state = "windup"
	expect(not waiting._melee_slot_available(), "inimigos do mesmo lado não sobrepõem preparação de ataque")
	lead.state = "recover"
	expect(waiting._melee_slot_available(), "o próximo inimigo pode atacar durante recuperação do primeiro")
	p._start_attack()
	p.state_t = p.attack_len * 0.2
	p.hit_pause = 0.06
	game.message_text = "Pausa de narrativa"
	await tap("attack")
	expect(p.attack_buffer == 0, "mensagens não acumulam ataques para disparar ao fechar")
	game.message_text = ""
	await reset()
	game.message_text = "Fechar com salto"
	game.message_t = 0
	await tap("jump")
	expect(p.velocity.y >= 0 and p.is_on_floor(), "salto usado para fechar diálogo não faz o personagem pular")
	p.revive(Vector2(1300, 600))
	expect(p.combo_window == 0 and p.counter_t == 0 and p.roll_cd == 0, "reviver limpa combo, contra-ataque e recarga")
	game.queue_free()
	game = null
	await frames(8)
	print("COMBAT_FLOW: %d checks, %d failures" % [checks, failures])
	quit(0 if failures == 0 else 1)
