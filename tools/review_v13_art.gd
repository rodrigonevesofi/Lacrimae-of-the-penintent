extends SceneTree
var boss: Array=[]
var memorial: Texture2D
var canvas: Control
var index:=0
var sheet:=false
var animation:=false
var frame_index:=0
func _initialize():call_deferred("run")
func paint():
	if animation:
		canvas.draw_rect(Rect2(0,0,640,360),Color("25232a"))
		canvas.draw_texture_rect_region(memorial,Rect2(264,140,112.64,112.64),Rect2((frame_index%6)*256,(frame_index/6)*256,256,256))
		canvas.draw_line(Vector2(0,250),Vector2(640,250),Color("665e50"),1)
		return
	if not sheet:
		canvas.draw_texture_rect(boss[index],Rect2(0,0,1280,720),false)
		canvas.draw_line(Vector2(0,720-160*2.0/3),Vector2(1280,720-160*2.0/3),Color(0,.9,.7,.7),1)
	else:
		canvas.draw_rect(Rect2(0,0,1536,1024),Color("25232a"))
		for i in range(24):
			var pos=Vector2((i%6)*256,(i/6)*256)
			canvas.draw_texture_rect_region(memorial,Rect2(pos,Vector2(256,256)),Rect2(pos,Vector2(256,256)))
			canvas.draw_rect(Rect2(pos,Vector2(256,256)),Color("776b55"),false)
			canvas.draw_line(pos+Vector2(0,250),pos+Vector2(256,250),Color(.5,.7,.5,.5),1)
			canvas.draw_string(ThemeDB.fallback_font,pos+Vector2(8,20),str(i),HORIZONTAL_ALIGNMENT_LEFT,-1,16,Color.WHITE)
func run():
	root.content_scale_mode=Window.CONTENT_SCALE_MODE_DISABLED;root.content_scale_size=Vector2i.ZERO;root.size=Vector2i(1280,720)
	for id in ['01_corda','02_gesto','03_imovel']:boss.append(load('res://assets/boss/guardiao_'+id+'.png'))
	memorial=load('res://assets/animation/hero_memorial.png')
	canvas=Control.new();root.add_child(canvas);canvas.draw.connect(paint)
	if "--animation-only" in OS.get_cmdline_user_args():
		await motion();quit();return
	for i in range(3):
		index=i;canvas.queue_redraw();await process_frame;await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png('res://docs/imagens/guardiao-'+str(i+1)+'.png')
	sheet=true;root.size=Vector2i(1536,1024)
	canvas.queue_redraw();await process_frame;await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png('res://docs/imagens/hero-memorial-contato.png')
	await motion()
	print('V13_ART_REVIEW: three illustrations at1280x720;24frame memorial contact sheet')
	quit()

func motion():
	animation=true;root.size=Vector2i(640,360)
	var sequence=range(12)
	for loop in range(4):sequence.append_array(range(12,18))
	sequence.append_array(range(18,24))
	for i in sequence:
		frame_index=i
		for tick in range(8):
			canvas.queue_redraw();await process_frame
