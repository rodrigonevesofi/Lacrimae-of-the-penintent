extends SceneTree
## Story decisions of the author that Act I must respect: who ordered the gates closed is revealed only in Act II,
## Edran and the Inquisitor belong to Act II, and the Penitent's face is never shown.
var checks := 0
var failures := 0
func expect(ok: bool,label: String) -> void:
	checks += 1
	print("PASS: " if ok else "FAIL: ",label)
	if not ok: failures += 1
func _initialize() -> void:
	var sources := ["res://scripts/exploration.gd","res://scripts/main.gd","res://scripts/story_text.gd","res://scripts/guilt_text.gd","res://scripts/narrative.gd","res://scripts/hud.gd","res://scripts/enemy.gd"]
	var named := []
	var face := []
	for path in sources:
		var text := FileAccess.get_file_as_string(path).to_lower()
		if text.contains("edran"): named.append(path.get_file() + " (Edran)")
		if text.contains("inquisidora"): named.append(path.get_file() + " (Inquisidora)")
		if text.contains("close_01.png"): face.append(path.get_file())
	expect(named.is_empty(),"Act I names neither Edran nor the Inquisitor %s" % str(named))
	expect(face.is_empty(),"the Penitent's unmasked face is never used %s" % str(face))
	expect(ResourceLoader.exists("res://assets/close/close_01_mascarado.png"),"the masked close of the Penitent is ready for the story encounters")
	var gates := FileAccess.get_file_as_string("res://scripts/exploration.gd")
	expect(gates.contains("selo raspado") and gates.contains("raspado a faca"),"the seals at the gates are scraped: who ordered it stays a question")
	print("STORY_DECISIONS: %d checks, %d failures" % [checks,failures])
	quit(0 if failures == 0 else 1)
