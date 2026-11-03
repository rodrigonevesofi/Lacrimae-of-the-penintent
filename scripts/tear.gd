extends Node2D
## Projétil de lágrima (também usado como onda de choque do chefe)

const Util = preload("res://scripts/util.gd")

var animator
var player = null
var vel := Vector2.ZERO
var grav := 0.0
var dmg := 14.0
var life := 4.0
var radius := 9.0
var wave := false
var ground_y := 100000.0
var t := 0.0


func _ready() -> void:
	animator = preload("res://scripts/actor_animation.gd").new()
	animator.configure("fx", 0.24 if wave else 0.14)
	add_child(animator)
	animator.select("projectile", 1)
	var l := Util.make_light(Color(0.65, 0.82, 1.0), 0.6, 0.8)
	add_child(l)


func _process(delta: float) -> void:
	var game = get_tree().get_first_node_in_group("game")
	if game != null and (game.state != "play" or game.message_text != "" or game.narrative.mode != ""):
		return
	animator.rotation = vel.angle()
	t += delta
	life -= delta
	vel.y += grav * delta
	position += vel * delta
	if life <= 0.0 or position.y > ground_y:
		queue_free()
		return
	if player != null and is_instance_valid(player) and player.state != "dead" and player.invuln <= 0.0:
		var r: Rect2 = player.body_rect()
		var closest := Vector2(
			clampf(global_position.x, r.position.x, r.end.x),
			clampf(global_position.y, r.position.y, r.end.y))
		if global_position.distance_to(closest) < radius:
			player.take_hit(dmg, global_position.x)
			queue_free()
			return
	queue_redraw()


func _draw() -> void:
	if wave:
		draw_arc(Vector2.ZERO, radius + 4, PI, TAU, 20, Color(0.9, 0.58, 0.2, 0.4), 2)
