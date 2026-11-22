extends Node2D
## Projétil de lágrima (também usado como onda de choque do chefe)

## Criado a partir de scenes/projeteis/lagrima.tscn (animador e luz ficam na cena).
@onready var animator = $Animator
var player = null
var vel := Vector2.ZERO
var grav := 0.0
var dmg := 14.0
var life := 4.0
var radius := 9.0
var wave := false
var parryable := false
var source = null

func imminent_hit(who, window: float) -> bool:
	if player != who: return false
	var body: Rect2 = who.body_rect().grow(radius)
	for i in range(7):
		var dt := float(i) * window / 6.0
		if body.has_point(global_position + vel * dt + Vector2(0, grav * dt * dt * 0.5)): return true
	return false
var ground_y := 100000.0
var t := 0.0


func _ready() -> void:
	# A onda de choque do chefe usa o mesmo desenho, maior; "wave" é definido antes de entrar na árvore.
	animator.configure("fx", 0.24 if wave else 0.14)
	animator.select("projectile", 1)
	call_deferred("_announce")


func _announce() -> void:
	var director = get_tree().get_first_node_in_group("game")
	if director != null and is_inside_tree():
		director.soundscape.play_sfx_at("projetil", global_position)


func _process(delta: float) -> void:
	var game = get_tree().get_first_node_in_group("game")
	if game != null and (game.state != "play" or game.message_text != "" or game.narrative.mode != "" or game.penitence_menu or (game.exploration != null and (game.exploration.map_open or game.exploration.is_transitioning()))):
		return
	animator.rotation = vel.angle()
	t += delta
	life -= delta
	vel.y += grav * delta
	position += vel * delta
	if life <= 0.0 or position.y > ground_y:
		queue_free()
		return
	if player != null and is_instance_valid(player) and player.state != "dead":
		var r: Rect2 = player.body_rect()
		var closest := Vector2(
			clampf(global_position.x, r.position.x, r.end.x),
			clampf(global_position.y, r.position.y, r.end.y))
		if global_position.distance_to(closest) < radius:
			player.take_hit(dmg, global_position.x, source if is_instance_valid(source) else self, parryable)
			get_tree().call_group("game", "play_sfx", "projetil_impacto")
			queue_free()
			return
	queue_redraw()


func _draw() -> void:
	if wave:
		draw_arc(Vector2.ZERO, radius + 4, PI, TAU, 20, Color(0.9, 0.58, 0.2, 0.4), 2)
