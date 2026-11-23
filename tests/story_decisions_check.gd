extends SceneTree
## Decisões narrativas do autor que o Ato I deve respeitar: quem ordenou o fechamento dos portões só é revelado no Ato II,
## Edran e o Inquisidor pertencem ao Ato II, e o rosto do Penitente só aparece na revelação final.
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
	expect(face.is_empty(),"outside the final revelation, the Penitent's face is never used %s" % str(face))
	# Decisão do autor na v38: o rosto aparece uma única vez — no Vale, quando Beatriz tira o capacete.
	var finale := FileAccess.get_file_as_string("res://scripts/vale_finale.gd")
	expect(finale.contains("close_01.png") and finale.contains("close_flagelado_elmo.png") and finale.contains("close_revelacao_maos.png") and finale.contains("close_dois_rostos.png"),"the face is shown once: in the Valley, when Beatriz lifts the helmet")
	var all_scripts := DirAccess.get_files_at("res://scripts")
	var users := []
	for f in all_scripts:
		if f.ends_with(".gd") and f != "vale_finale.gd":
			var code := FileAccess.get_file_as_string("res://scripts/" + f)
			for asset in ["close_01.png","close_revelacao_maos.png","close_dois_rostos.png"]:
				if code.contains(asset): users.append(f)
	expect(users.is_empty(),"no other script shows the face %s" % str(users))
	expect(ResourceLoader.exists("res://assets/close/close_01_mascarado.png"),"the masked close of the Penitent is ready for the story encounters")
	# Desde a separação por salas, os textos de cada sala moram em scenes/salas/<sala>.tscn.
	var gates := FileAccess.get_file_as_string("res://scripts/exploration.gd") + FileAccess.get_file_as_string("res://scenes/salas/court.tscn")
	expect(gates.contains("selo raspado") and gates.contains("raspado a faca"),"the seals at the gates are scraped: who ordered it stays a question")
	print("STORY_DECISIONS: %d checks, %d failures" % [checks,failures])
	quit(0 if failures == 0 else 1)
