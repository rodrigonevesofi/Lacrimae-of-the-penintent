extends SceneTree
var images: Array=[]
var ids=["nave_silencio","terraco_sinos","patio_portoes"]
var current:=0
var canvas: Control
var hero: AtlasTexture
func _initialize():call_deferred("run")
func paint():
	canvas.draw_rect(Rect2(0,0,1280,720),Color("17191e"))
	# O panorama mantém a proporção nativa de 3:1; a área de exibição de 1280x720 acrescenta faixas.
	var height=1280.0*724/2172
	var top=(720-height)/2
	canvas.draw_texture_rect(images[current],Rect2(0,top,1280,height),false)
	var floor_y=top+height*.86
	canvas.draw_line(Vector2(0,floor_y),Vector2(1280,floor_y),Color(0,1,.65,.8),1)
	# A silhueta do herói tem 90 px de altura na tela, com as solas exatamente sobre a guia.
	canvas.draw_texture_rect(hero,Rect2(610,floor_y-90,256.0*90/250,256.0*90/250),false)
	canvas.draw_string(ThemeDB.fallback_font,Vector2(20,60),ids[current]+" · guia86% · Penitente90px",HORIZONTAL_ALIGNMENT_LEFT,-1,20,Color.WHITE)
func run():
	root.content_scale_mode=Window.CONTENT_SCALE_MODE_DISABLED
	root.content_scale_size=Vector2i.ZERO
	root.size=Vector2i(1280,720)
	for id in ids:images.append(load("res://assets/"+id+".png"))
	hero=AtlasTexture.new();hero.atlas=load("res://assets/animation/hero_motion.png");hero.region=Rect2(0,0,256,256);hero.filter_clip=true
	canvas=Control.new();root.add_child(canvas);canvas.draw.connect(paint)
	for i in range(3):
		current=i;canvas.queue_redraw()
		await process_frame;await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://docs/imagens/fundo-"+ids[i]+".png")
	print("SECRET_BACKGROUND_REVIEW: three panoramas at1280x720,86percent guide,90px hero")
	quit()
