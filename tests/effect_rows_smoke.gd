extends SceneTree
## Confere recorte de folhas de duas fileiras e compatibilidade com grid.
const Actor = preload("res://scripts/actor_animation.gd")
var checks := 0
var failures := 0
func expect(ok: bool, label: String) -> void:
	checks += 1
	print("PASS: " if ok else "FAIL: ", label)
	if not ok: failures += 1
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var manifest: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://assets/animation/clips.json"))
	for name in manifest:
		if name == "beatriz": continue
		var needs_check := false
		for data in manifest[name].values():
			if data.get("rows", 4) == 2: needs_check = true
		if not needs_check: continue
		var actor = Actor.new()
		actor.configure(name, 1.0)
		root.add_child(actor)
		for clip in manifest[name]:
			var data: Dictionary = manifest[name][clip]
			if data.get("rows", 4) != 2: continue
			var texture: Texture2D = load("res://assets/animation/" + data.sheet + ".png")
			var expected := texture.get_size() / Vector2(6, 2)
			var count: int = actor.sprite_frames.get_frame_count(clip)
			expect(count == data.count, name + "/" + clip + ": quantidade de quadros")
			for i in range(count):
				var frame: AtlasTexture = actor.sprite_frames.get_frame_texture(clip, i)
				expect(frame.region.size == expected and frame.region.end.y <= texture.get_height(), name + "/" + clip + ": quadro inteiro %d" % i)
		actor.queue_free()
	await process_frame
	Actor.frames_cache.clear()
	Actor.manifest_cache.clear()
	print("EFFECT_ROWS: %d checks, %d failures" % [checks, failures])
	quit(0 if failures == 0 else 1)
