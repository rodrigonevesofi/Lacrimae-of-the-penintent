extends SceneTree
## Os SpriteFrames gerados (assets/animation/quadros/<ator>.tres) batem com assets/animation/clips.json?
## Se não baterem, rode: godot --headless --path . --script res://tools/gerar_quadros.gd

const Anim = preload("res://scripts/actor_animation.gd")
var checks := 0
var failures := 0

func expect(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		print("FAIL: ", label)

func _initialize() -> void:
	var manifesto: Dictionary = Anim.manifesto()
	for ator in manifesto:
		var arquivo: String = Anim.PASTA_QUADROS + ator + ".tres"
		expect(ResourceLoader.exists(arquivo), "%s tem SpriteFrames gerado" % ator)
		if not ResourceLoader.exists(arquivo): continue
		var salvo: SpriteFrames = load(arquivo)
		var esperado: SpriteFrames = Anim.montar_quadros(ator)
		var nomes_salvos := Array(salvo.get_animation_names())
		var nomes_esperados := Array(esperado.get_animation_names())
		nomes_salvos.sort()
		nomes_esperados.sort()
		expect(nomes_salvos == nomes_esperados, "%s: as animações são as de clips.json" % ator)
		for clip in nomes_esperados:
			if not salvo.has_animation(clip): continue
			var igual := salvo.get_animation_speed(clip) == esperado.get_animation_speed(clip) \
				and salvo.get_animation_loop(clip) == esperado.get_animation_loop(clip) \
				and salvo.get_frame_count(clip) == esperado.get_frame_count(clip)
			if igual:
				for i in esperado.get_frame_count(clip):
					var a: AtlasTexture = salvo.get_frame_texture(clip, i)
					var b: AtlasTexture = esperado.get_frame_texture(clip, i)
					igual = igual and a != null and a.atlas.resource_path == b.atlas.resource_path and a.region == b.region \
						and a.filter_clip == b.filter_clip and salvo.get_frame_duration(clip, i) == esperado.get_frame_duration(clip, i)
			expect(igual, "%s/%s: quadros, fps e laço iguais aos de clips.json" % [ator, clip])
	# Nenhum arquivo sobrando de um personagem que saiu de clips.json.
	for nome in DirAccess.get_files_at(Anim.PASTA_QUADROS):
		if nome.ends_with(".tres"): expect(manifesto.has(nome.get_basename()), "%s ainda existe em clips.json" % nome)
	# O jogador já mostra o Penitente no editor.
	var jogador: Node = load("res://scenes/player.tscn").instantiate()
	var animador: AnimatedSprite2D = jogador.get_node("Animator")
	expect(animador.sprite_frames != null and animador.sprite_frames.resource_path == Anim.PASTA_QUADROS + "hero.tres", "player.tscn usa os quadros do Penitente")
	jogador.free()
	print("QUADROS_SMOKE: %d checks, %d failures" % [checks, failures])
	quit(0 if failures == 0 else 1)
