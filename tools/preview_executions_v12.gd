extends SceneTree
var measurements: Dictionary
var manifest: Dictionary
var images: Dictionary={}
var actor: String
var canvas: Control
func _initialize():call_deferred("run")
func sprite(sheet: String,index: int,feet: Vector2,unit: float,anchor: Array,direction: int):
	canvas.draw_set_transform(feet,0,Vector2(direction*unit,unit))
	canvas.draw_texture_rect_region(images[sheet],Rect2(-float(anchor[0]),-float(anchor[1]),256,256),Rect2((index%6)*256,(index/6)*256,256,256))
	canvas.draw_set_transform(Vector2.ZERO)
func paint():
	canvas.draw_rect(Rect2(0,0,1600,1200),Color("202128"))
	var d: Dictionary=manifest[actor].executed
	var h: Dictionary=manifest.hero["execute_mourner" if actor in ["bruxa","asmodeia"] else "execute_devotee"]
	var m: Dictionary=measurements[actor]
	for i in range(12):
		var origin=Vector2((i%4)*400,(i/4)*400)
		canvas.draw_rect(Rect2(origin,Vector2(400,400)),Color("6a6056"),false)
		canvas.draw_string(ThemeDB.fallback_font,origin+Vector2(10,22),actor+" · quadro "+str(i),HORIZONTAL_ALIGNMENT_LEFT,-1,17,Color.WHITE)
		for after in [false,true]:
			var y=355 if after else 180
			canvas.draw_line(origin+Vector2(0,y),origin+Vector2(400,y),Color("a58a59"),1)
			sprite(h.sheet,h.start+i,origin+Vector2(95,y),.44,h.anchor,1)
			sprite(d.sheet,d.start+i,origin+Vector2(270,y),float(m.scale),m.after_anchor if after else m.before_anchor,-1)
			var delta=float(m.frames[i].after if after else m.frames[i].before)
			canvas.draw_string(ThemeDB.fallback_font,origin+Vector2(10,y+20),("Depois " if after else "Antes ")+str(delta)+" px",HORIZONTAL_ALIGNMENT_LEFT,-1,15,Color.WHITE)
func run():
	root.content_scale_mode=Window.CONTENT_SCALE_MODE_DISABLED
	root.content_scale_size=Vector2i.ZERO
	root.size=Vector2i(1600,1200)
	measurements=JSON.parse_string(FileAccess.get_file_as_string("res://docs/execucoes-medidas.json"))
	manifest=JSON.parse_string(FileAccess.get_file_as_string("res://assets/animation/clips.json"))
	for id in measurements:
		for sheet in [manifest[id].executed.sheet,"execute_devotee","execute_mourner"]:
			if not images.has(sheet):images[sheet]=load("res://assets/animation/"+sheet+".png")
	canvas=Control.new();root.add_child(canvas);canvas.draw.connect(paint)
	for id in measurements:
		actor=id;canvas.queue_redraw()
		await process_frame;await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://docs/imagens/execucao-"+id+".png")
	print("EXECUTION_REVIEW: five sheets,12paired frames,before/after")
	quit()
