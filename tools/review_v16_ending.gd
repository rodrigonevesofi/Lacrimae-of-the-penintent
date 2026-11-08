extends SceneTree
# Standalone art review, never changes or loads the production main scene.
func _initialize():call_deferred("run")
func run():
	root.size=Vector2i(1280,720)
	root.content_scale_size=Vector2i(1280,720)
	var art=TextureRect.new()
	art.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
	art.stretch_mode=TextureRect.STRETCH_SCALE
	art.texture=load("res://assets/ending/ato1_portoes_v2.png")
	art.size=Vector2(1280,720)
	root.add_child(art)
	var caption=Label.new()
	caption.text="Os sinos pararam. Os portões continuam fechados."
	caption.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	caption.position=Vector2(40,640);caption.size=Vector2(1200,40)
	caption.add_theme_font_size_override("font_size",24)
	caption.add_theme_color_override("font_color",Color("e3dac7"))
	root.add_child(caption)
	await process_frame;await process_frame
	await RenderingServer.frame_post_draw
	var err=root.get_texture().get_image().save_png("res://docs/imagens/v16-encerramento-legenda.png")
	print("ENDING_REVIEW capture=",err)
	quit(0 if err==OK else 1)
