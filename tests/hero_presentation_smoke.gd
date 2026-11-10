extends SceneTree
var game
var checks := 0
var failures := 0
func _initialize() -> void: call_deferred("run")
func expect(ok: bool,label: String) -> void:
	checks+=1
	print("PASS: " if ok else "FAIL: ",label)
	if not ok:failures+=1
func frames(n: int) -> void:
	for i in range(n):
		await physics_frame
		await process_frame
func run() -> void:
	game=load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	game._start_game(false,false)
	for i in range(3):
		game.message_t=0
		game.advance_message()
	for enemy in get_nodes_in_group("enemies"):enemy.set_physics_process(false)
	var p=game.player
	p.has_weapon=true
	p.position=Vector2(1500,600)
	await frames(8)
	expect(p.animator.material is ShaderMaterial,"hero uses local readability material")
	expect(game.art.material is CanvasItemMaterial,"backdrop material is independent of hero correction")
	expect(p.sword.texture!=null and p.sword.texture.get_width()>2000,"resting weapon uses original detailed texture")
	expect(p.body_rect().size==Vector2(22,56),"presentation preserves physical body rectangle")
	p.set_process(false)
	for frame_index in range(6):
		p.state="idle"
		p.facing=1
		p.animator.pose("run",1,frame_index)
		p._update_sword()
		var right:Vector2=p.sword.position
		var angle:float=p.sword.rotation
		var tip:Vector2=p.sword.transform*(Vector2(2050,360)-p.SWORD_GRIP)
		expect(p.sword.visible and tip.y<=-2.8,"run weapon tip stays above ground frame %d"%frame_index)
		p.facing=-1
		p.animator.pose("run",-1,frame_index)
		p._update_sword()
		expect(is_equal_approx(p.sword.position.x,-right.x) and is_equal_approx(p.sword.position.y,right.y) and is_equal_approx(p.sword.rotation,-angle),"weapon grip mirrors with actor frame %d"%frame_index)
	p.state="attack"
	p._update_sword()
	expect(not p.sword.visible,"painted attack blade is never duplicated")
	p.state="idle"
	p.cinematic_focus=true
	p._update_sword()
	expect(not p.sword.visible,"ritual blade is never duplicated")
	p.cinematic_focus=false
	p.set_process(true)
	p.hit_pause=0.045
	Input.action_press("attack")
	p._physics_process(0.016)
	Input.action_release("attack")
	expect(p.attack_buffer>0 and p.hit_pause>0,"attack input is captured during impact pause")
	await frames(2)
	p.hit_pause=0
	p.attack_buffer=0
	p.facing=1
	p.revive(Vector2(1500,600))
	await frames(4)
	Input.action_press("jump")
	await frames(10)
	expect(not p.is_on_floor() and p.animator.animation=="air_drift","armed jump retains textured weapon in aerial drawings")
	var victim=game.EnemyScript.new()
	victim.setup(1,p.position+Vector2(55,-55),0,p)
	game.add_child(victim)
	victim.set_physics_process(false)
	Input.action_press("attack")
	await frames(1)
	Input.action_release("attack")
	Input.action_release("jump")
	expect(p.state=="air_attack" and p.air_attack_used,"attack in flight selects dedicated aerial cut")
	expect(p.animator.sprite_frames.get_frame_count("air_attack")==12,"aerial cut has twelve distinct source poses")
	await frames(7)
	expect(victim.hp==victim.max_hp,"air anticipation has no damage")
	await frames(12)
	expect(is_equal_approx(victim.hp,victim.max_hp-22),"aerial contact deals its own damage once")
	var hp:float=victim.hp
	p._attack_hits(true)
	expect(victim.hp==hp,"same air swing cannot hit victim twice")
	var remaining:float=p.state_t
	p._start_air_attack()
	expect(p.state_t==remaining,"aerial move cannot restart repeatedly in the same jump")
	await frames(55)
	expect(p.state=="idle" and p.is_on_floor() and not p.aerial_after_cut,"landing recovery returns to grounded control")
	expect(p.sword.visible,"weapon returns to grip after aerial recovery")
	# Espelha a área dedicada de golpe aéreo contra um alvo à esquerda.
	var left_target=game.EnemyScript.new()
	left_target.setup(1,p.position+Vector2(-55,-65),0,p)
	game.add_child(left_target)
	left_target.set_physics_process(false)
	p.facing=-1
	p.hit_list.clear()
	p._attack_hits(true)
	expect(is_equal_approx(left_target.hp,left_target.max_hp-22),"aerial hit area mirrors to the left")
	p.revive(Vector2(1500,600))
	await frames(4)
	Input.action_press("jump")
	Input.action_press("attack")
	await frames(2)
	Input.action_release("jump")
	Input.action_release("attack")
	expect(p.state=="air_attack","simultaneous jump and attack choose aerial move without grounded-frame delay")
	game.soundscape.set_process(false)
	p.set_physics_process(false)
	for enemy in get_nodes_in_group("enemies"):enemy.set_physics_process(false)
	game.soundscape.ambience.stop()
	game.soundscape.incoming.stop()
	game.soundscape.guilt_layer.stop()
	for voice in game.soundscape.effects.values():voice.stop()
	await create_timer(0.2).timeout
	game._delete_save()
	game.queue_free()
	game=null
	await frames(4)
	print("HERO_PRESENTATION_SMOKE: %d checks, %d failures"%[checks,failures])
	quit(0 if failures==0 else 1)
