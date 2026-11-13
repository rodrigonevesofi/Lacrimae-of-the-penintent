extends SceneTree
## Verifica a identidade visual de Beatriz e os sons novos nos eventos reais.
var game
var checks := 0
var failures := 0
func _initialize() -> void: call_deferred("run")
func expect(ok: bool, label: String) -> void:
	checks += 1
	print("PASS: " if ok else "FAIL: ", label)
	if not ok: failures += 1
func frames(n: int) -> void:
	for i in range(n):
		await physics_frame
		await process_frame
func run() -> void:
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	game._start_game(false, false)
	game.enable_duo(true)
	for i in range(3):
		game.message_t = 0
		game.advance_message()
	await frames(5)
	for e in get_nodes_in_group("enemies"): e.queue_free()
	await frames(2)
	var b = game.partner
	var p = game.player
	b.ai = false
	b.set_physics_process(false)
	b.set_process(false)
	b.has_weapon = true
	b.cinematic_focus = false
	b.invuln = 0.0
	expect(b.animator.actor == "beatriz", "Beatriz usa a própria arte")
	for name in b.animator.definitions:
		var definition: Dictionary = b.animator.definitions[name]
		expect(str(definition.sheet).begins_with("beatriz_"), name + ": preserva a identidade de Beatriz")
	for state in ["idle", "attack", "charge", "heavy", "parry", "hurt", "dead", "fallen", "heal", "pray", "execution", "air_attack"]:
		b.state = state
		b._update_animation()
		var tex: AtlasTexture = b.animator.sprite_frames.get_frame_texture(b.animator.animation, b.animator.frame)
		expect(tex.atlas.resource_path.contains("beatriz_"), state + ": desenha Beatriz")
	b.state = "fallen"
	b._update_animation()
	expect(b.animator.animation == "death" and b.animator.frame == 4, "quem caiu permanece deitada")
	b.state = "idle"
	b.revive_t = 0.5
	b._update_animation()
	expect(b.animator.animation == "raise", "doar sangue usa o gesto de resgate")
	b.revive_t = 0.0
	var s = game.soundscape
	for name in ["arremate", "caido", "empalar", "golpe_carregado_carga", "golpe_carregado_solta", "lanca_estocada_01", "lanca_estocada_02", "lanca_estocada_03", "levanta", "mergulho_impacto", "sangue_compartilhado"]:
		expect(s.effects.has(name) and s.effects[name].stream != null and s.effects[name].stream.get_length() > 0.1, name + ": gravação importada e carregada")
	var variants := {}
	for i in range(60): variants[s.resolve("lanca_estocada")] = true
	expect(variants.size() == 3, "estocadas alternam entre as três gravações")
	s.played.clear()
	b._start_attack()
	b._start_charge()
	b.heavy_t = b.HEAVY_FULL
	b._start_heavy()
	b._plunge_impact()
	for name in ["lanca_estocada", "golpe_carregado_carga", "golpe_carregado_solta", "mergulho_impacto"]:
		expect(s.played.get(name, 0) > 0, name + ": evento dispara o som")
	p.state = "fallen"
	p.hp = 0.0
	b.hp = b.max_hp
	b._raise(p)
	expect(s.played.get("levanta", 0) > 0 and s.played.get("sangue_compartilhado", 0) > 0, "resgate dispara os dois sons e restaura o parceiro")
	game.soundscape.set_process(false)
	for voice in s.effects.values(): voice.stop()
	game._delete_save()
	game.queue_free()
	game = null
	await frames(5)
	print("V32_RESOURCES: %d checks, %d failures" % [checks, failures])
	quit(0 if failures == 0 else 1)
