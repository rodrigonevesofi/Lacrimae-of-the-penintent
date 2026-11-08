extends SceneTree
## Review only; no campaign scenes or manifest are changed.
var ids=["01_maos_na_roda","02_mao_pequena","02_mao_pequena_sem_sol","03_figura_atras","04_portao_fechado"]
var images: Array=[]
var fragment: Texture2D
var canvas: Control
var selected:=0
var light:=false
var overview:=false
var phase:=0
func _initialize():call_deferred("run")
func paint():
	canvas.draw_rect(Rect2(0,0,1440,900),Color("eeeeee") if light else Color("101116"))
	if not overview:
		canvas.draw_texture_rect(images[selected],Rect2(80,90,1280,720),false)
		canvas.draw_string(ThemeDB.fallback_font,Vector2(80,50),"memoria_"+ids[selected]+" · 1280×720",HORIZONTAL_ALIGNMENT_LEFT,-1,20,Color.BLACK if light else Color.WHITE)
	else:
		for i in range(5):
			var pos=Vector2((i%3)*480,(i/3)*300)
			canvas.draw_texture_rect(images[i],Rect2(pos,Vector2(480,270)),false)
			canvas.draw_string(ThemeDB.fallback_font,pos+Vector2(10,292),ids[i],HORIZONTAL_ALIGNMENT_LEFT,-1,16,Color.WHITE)
		var origin=Vector2(960,300)
		canvas.draw_rect(Rect2(origin,Vector2(480,300)),Color("34383d"))
		canvas.draw_texture_rect_region(fragment,Rect2(origin+Vector2(112,10),Vector2(256,256)),Rect2((phase%6)*256,(phase/6)*256,256,256))
		canvas.draw_string(ThemeDB.fallback_font,origin+Vector2(10,292),"fragmento · quadro "+str(phase),HORIZONTAL_ALIGNMENT_LEFT,-1,16,Color.WHITE)
func run():
	root.content_scale_mode=Window.CONTENT_SCALE_MODE_DISABLED
	root.content_scale_size=Vector2i.ZERO
	root.size=Vector2i(1440,900)
	for id in ids: images.append(load("res://assets/memory/memoria_"+id+".png"))
	fragment=load("res://assets/animation/fragmento_culpa.png")
	canvas=Control.new()
	root.add_child(canvas)
	canvas.draw.connect(paint)
	DirAccess.make_dir_recursive_absolute("res://artifacts/memory")
	for i in range(5):
		selected=i
		for background in [false,true]:
			light=background
			canvas.queue_redraw()
			await process_frame
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png("res://artifacts/memory/"+ids[i]+("-claro" if light else "-escuro")+".png")
	overview=true
	light=false
	for tick in range(180):
		phase=(tick/5)%18
		canvas.queue_redraw()
		await process_frame
		if tick==20:
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png("res://docs/imagens/memorias-previa.png")
	print("MEMORY_REVIEW: five images at1280x720 on two backgrounds;18 fragment poses displayed")
	quit()
