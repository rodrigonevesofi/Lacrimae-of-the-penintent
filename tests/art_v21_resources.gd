extends SceneTree
func _initialize() -> void:
	var failures := 0
	var paths := ["assets/animation/guardiao_colosso.png", "assets/animation/efeitos_golpe.png", "assets/animation/carregador.png", "assets/boss/guardiao_rosto.png", "assets/ui/moldura_lore.png", "assets/fonts/UnifrakturMaguntia-Book.ttf"]
	for i in range(1,7): paths.append("assets/close/close_%02d.png" % i)
	for path in paths:
		var resource = load("res://" + path)
		if resource == null:
			failures += 1
			push_error("Could not import " + path)
	print("ART_V21_RESOURCES: %d resources, %d failures" % [paths.size(),failures])
	quit(0 if failures == 0 else 1)
