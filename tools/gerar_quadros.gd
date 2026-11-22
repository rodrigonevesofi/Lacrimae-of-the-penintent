extends SceneTree
## Gera assets/animation/quadros/<ator>.tres (um SpriteFrames por personagem) a partir de
## assets/animation/clips.json. Rode depois de mudar recortes, fps ou laços em clips.json:
##   godot --headless --path . --script res://tools/gerar_quadros.gd
## tests/quadros_smoke.gd confere se os arquivos gerados batem com clips.json.

const Anim = preload("res://scripts/actor_animation.gd")

func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(Anim.PASTA_QUADROS))
	var gerados := 0
	for ator in Anim.manifesto():
		var quadros: SpriteFrames = Anim.montar_quadros(ator)
		var erro := ResourceSaver.save(quadros, Anim.PASTA_QUADROS + ator + ".tres")
		if erro != OK:
			push_error("Não foi possível gravar os quadros de %s (erro %d)." % [ator, erro])
			quit(1)
			return
		gerados += 1
	print("QUADROS: %d personagens gravados em %s" % [gerados, Anim.PASTA_QUADROS])
	quit(0)
