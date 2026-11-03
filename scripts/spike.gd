extends Node2D
## Espinhos que brotam do chão (ataque do chefe) - tem telegrafia antes do dano

var player = null
var delay := 0.9
var active_t := 0.35
var dmg := 18.0
var width := 40.0
var hit := false
var t := 0.0


func _process(delta: float) -> void:
	var game = get_tree().get_first_node_in_group("game")
	if game != null and (game.state != "play" or game.message_text != "" or game.narrative.mode != ""):
		return
	t += delta
	if t > delay + active_t:
		queue_free()
		return
	if t >= delay and not hit and player != null and is_instance_valid(player):
		var r := Rect2(global_position + Vector2(-width / 2.0, -90.0), Vector2(width, 90.0))
		if r.intersects(player.body_rect()):
			player.take_hit(dmg, global_position.x)
			hit = true
	queue_redraw()


func _draw() -> void:
	if t < delay:
		var a := t / delay
		draw_rect(Rect2(-width / 2.0, -4.0, width, 4.0), Color(1.0, 0.3, 0.2, 0.3 + 0.6 * a))
		draw_line(Vector2(0, -6), Vector2(0, -6 - 14.0 * a), Color(1.0, 0.3, 0.2, 0.6), 2.0)
	else:
		var p := clampf((t - delay) / 0.1, 0.0, 1.0)
		var h := 90.0 * p
		draw_colored_polygon(PackedVector2Array([
			Vector2(-width / 2.0, 0), Vector2(0, -h), Vector2(width / 2.0, 0)]), Color(0.72, 0.69, 0.6))
		draw_line(Vector2(0, 0), Vector2(0, -h), Color(0.4, 0.37, 0.32), 2.0)
