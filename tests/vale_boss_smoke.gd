extends SceneTree
## O Vale dos Flagelados e o chefe final: o reflexo do Penitente.
var game
var p
var b
var checks := 0
var failures := 0
func _initialize() -> void: call_deferred("run")
func expect(ok: bool,label: String) -> void:
	checks += 1
	print("PASS: " if ok else "FAIL: ",label)
	if not ok: failures += 1
func frames(n: int) -> void:
	for i in range(n):
		await physics_frame
		await process_frame
func settle() -> void:
	for i in range(120):
		await frames(1)
		if not game.exploration.is_transitioning(): break
func run() -> void:
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	game._start_game(false,false)
	for i in range(3):
		game.message_t = 0
		game.advance_message()
	await frames(3)
	game.exploration.arenas_enabled = false
	p = game.player
	p.has_weapon = true
	# --- O caminho abre após a queda do Guardião e a memória dos portões.
	p.global_position = Vector2(4700,600)
	await frames(3)
	expect(game.prompt.find("Vale") == -1,"before the Guardian falls there is no way down to the valley")
	game.boss_defeated = true
	game.memory_seen = true
	game.narrative.finish()
	await frames(3)
	expect(game.prompt.find("Vale dos Flagelados") != -1,"after the Guardian, the gates lead down to the Valley (%s)" % game.prompt)
	# --- Beatriz permanece na beira.
	game.enable_duo(true)
	await frames(3)
	game.enter_vale()
	await settle()
	expect(game.exploration.room == "vale" and game.exploration.rooms.vale.name == "VALE DOS FLAGELADOS","the Penitent stands in the Valley of the Flagellated")
	expect(game.beatriz_held and (game.partner == null or not is_instance_valid(game.partner)),"Beatriz does not cross with him: she is held at the edge")
	expect(game.vale_back.visible and game.vale_front.visible,"the valley is drawn live (no painted backdrop)")
	var swing_before: float = game.vale_back.hanged[0].ang
	await frames(40)
	expect(absf(game.vale_back.hanged[0].ang - swing_before) > 0.0005,"the hanged sway in the wind")
	# --- O chefe desperta quando o jogador se aproxima.
	b = game.final_boss
	expect(b != null and not b.awake and b.form == "true","someone waits among the gallows, in his own shape")
	expect(not str(b.NOME).to_lower().contains("penitente"),"his name does not give the ending away (%s)" % b.NOME)
	p.global_position = Vector2(31760,600)
	await frames(4)
	expect(b.awake and b.intro,"he wakes as the Penitent approaches, still himself")
	var hp_intro: float = b.hp
	b.take_hit(50.0, p.global_position.x)
	expect(b.hp == hp_intro,"nothing wounds him while he changes")
	for i in range(240):
		await frames(1)
		if b.form == "mirror": break
	expect(b.form == "mirror" and not b.intro,"then he takes the Penitent's shape")
	b.set_physics_process(false)
	b.global_position = Vector2(31840,600)
	p.facing = 1
	# --- Reflexo: o golpe volta para quem bateu.
	var boss_hp: float = b.hp
	var my_hp: float = p.hp
	p.hit_list.clear()
	p.state = "idle"
	p._attack_hits()
	expect(b.hp == boss_hp and p.hp < my_hp,"as a reflection he loses nothing: the blow returns to the one who struck (%.0f → %.0f)" % [my_hp, p.hp])
	expect(get_nodes_in_group("guilt_drops").size() >= 1,"and a drop of guilt falls to the ground")
	p.hp = 3.0
	p.hit_list.clear()
	p._attack_hits()
	expect(p.hp >= 1.0 and p.state != "dead","the reflection wounds but does not kill by itself")
	p.hp = p.max_hp
	# --- Primeiro caminho: o aparo arranca o reflexo.
	b.parried()
	expect(b.form == "true" and b.reveals_by_parry == 1 and b.form_t > 29.0,"a parry tears the reflection off: he is himself for thirty seconds")
	var minions := 0
	for e in get_nodes_in_group("enemies"):
		if e != b and e.room_id == "vale" and not e.dead: minions += 1
	expect(minions >= 2,"frail, he calls flagellants to guard him (%d)" % minions)
	for e in get_nodes_in_group("enemies"):
		if e != b: e.queue_free()
	await frames(2)
	boss_hp = b.hp
	p.hit_list.clear()
	p._attack_hits()
	expect(b.hp < boss_hp,"in his true form the blade reaches him")
	# --- A primeira placa cai; ele se esconde outra vez no reflexo.
	b.last_hitter = p
	b.take_hit(b.max_hp * 0.26, p.global_position.x)
	expect(b.stage == 1 and b.state == "armor_break","at three quarters of his life the first plate falls")
	b.state_t = 0.0
	b.hit_pause = 0.0
	b.set_physics_process(true)
	await frames(12)
	b.set_physics_process(false)
	expect(b.form == "mirror","wounded, he wears the Penitent's shape again")
	expect(game.vale_back.mood_target > 0.2,"the valley answers: the sky darkens with each plate")
	# --- Segundo caminho: ele recolhe a culpa e reza.
	for drop in get_nodes_in_group("guilt_drops"): drop.queue_free()
	await frames(2)
	for i in range(3): b._drop_guilt(b.global_position + Vector2(40 + i * 30, 0))
	b.state = "idle"
	b.state_t = 0.0
	b.set_physics_process(true)
	var prayed := false
	for i in range(360):
		await frames(1)
		if b.state == "pray":
			prayed = true
			break
	b.set_physics_process(false)
	expect(prayed and b.form == "true" and b.reveals_by_prayer == 1,"he gathers the drops, kneels to pray — and praying, becomes himself")
	for e in get_nodes_in_group("enemies"):
		if e != b: e.queue_free()
	await frames(2)
	# --- A segunda placa: Beatriz atravessa.
	b.take_hit(b.max_hp * 0.26, p.global_position.x)
	await frames(3)
	expect(b.stage == 2,"the second plate falls")
	expect(game.partner != null and is_instance_valid(game.partner) and not game.beatriz_held,"and Beatriz crosses the valley to fight beside him")
	# --- Sem impasse: a culpa pinga enquanto o reflexo encara o jogador.
	for drop in get_nodes_in_group("guilt_drops"): drop.queue_free()
	await frames(2)
	b._wear("mirror")
	b.state = "idle"
	b.state_t = 99.0
	b.drip_t = 0.05
	b.hit_pause = 0.0
	b.set_physics_process(true)
	await frames(8)
	b.set_physics_process(false)
	expect(get_nodes_in_group("guilt_drops").size() >= 1,"guilt drips by itself: a player who never strikes the reflection is not stuck")
	# --- Os trinta segundos terminam.
	# Isola o relógio: um golpe aleatório da IA não deve acrescentar pausa de impacto ao ensaio.
	if game.partner != null and is_instance_valid(game.partner): game.partner.set_physics_process(false)
	b._wear("true")
	b.state = "idle"
	b.state_t = 5.0
	b.form_t = 0.05
	b.hit_pause = 0.0
	b.set_physics_process(true)
	await frames(6)
	b.set_physics_process(false)
	expect(b.form == "mirror","when the time runs out he becomes the reflection again")
	# --- O fim: ele cai de joelhos; o elmo permanece.
	b._wear("true")
	b.form_t = 30.0
	b.take_hit(b.max_hp * 0.26, p.global_position.x)
	b._wear("true")
	b.form_t = 30.0
	b.take_hit(b.max_hp * 0.6, p.global_position.x)
	await frames(3)
	expect(b.fallen and not b.dead and b.stage == 4,"without armour he falls to his knees; he does not die")
	expect(game.finale != null and is_instance_valid(game.finale),"the revelation begins")
	var f = game.finale
	var w: Dictionary = f.weights(10.0)
	expect(w.helmet > 0.9 and w.face < 0.05,"first the helmet, close")
	w = f.weights(18.0)
	expect(w.face > 0.9 and w.helmet < 0.05 and w.lift > 0.9,"then it is lifted, and the face beneath is shown")
	expect(str(f.LINES[3][2]).find("É o seu") != -1,"the face is his own")
	f.t = 3.5
	expect(f.can_skip(),"the scene can be skipped after three seconds")
	f.t = 43.9
	await frames(8)
	expect(game.final_defeated and game.state == "ending","after the revelation, the vigil ends")
	expect(not p.cinematic_focus and p.camera.zoom.is_equal_approx(f.saved_zoom) if is_instance_valid(f) else true,"the camera is given back")
	game._delete_save()
	game.queue_free()
	game = null
	await frames(5)
	print("VALE_BOSS: %d checks, %d failures" % [checks,failures])
	quit(0 if failures == 0 else 1)
