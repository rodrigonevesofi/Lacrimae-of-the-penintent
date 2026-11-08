extends SceneTree
# Visual atlas review, independent from enemy AI and the campaign manifest.
var ids = ["devorador","flagelante","bruxa","asmodeia","duelista"]
var sheets: Array = []
var victims: Array = []
var backgrounds: Array = []
var canvas: Control
var current := 0
var source_index := 0
func _initialize(): call_deferred("run")
func paint():
	for panel in range(4):
		var origin := Vector2((panel%2)*640,(panel/2)*360)
		canvas.draw_texture_rect(backgrounds[panel],Rect2(origin,Vector2(640,360)),false)
		canvas.draw_rect(Rect2(origin,Vector2(640,360)),Color(0,0,0,0.17))
		canvas.draw_string(ThemeDB.fallback_font,origin+Vector2(12,24),["Arquivo (referência: Claustro)","Exterior da Cidade","Nave (Basílica)","Ossuário"][panel],HORIZONTAL_ALIGNMENT_LEFT,-1,17,Color.WHITE)
		for i in range(5):
			var pos := origin+Vector2(128*i,125)
			var texture: Texture2D = victims[i] if current==5 else sheets[i]
			canvas.draw_texture_rect_region(texture,Rect2(pos,Vector2(128,128)),Rect2((source_index%6)*256,(source_index/6)*256,256,256))
			canvas.draw_string(ThemeDB.fallback_font,pos+Vector2(6,155),ids[i],HORIZONTAL_ALIGNMENT_LEFT,-1,14,Color.WHITE)
func run():
	for id in ids:
		sheets.append(load("res://assets/animation/"+id+".png"))
		victims.append(load("res://assets/animation/"+id+"_executado.png"))
	for id in ["cloister","vespera_panorama","basilica","ossuary"]: backgrounds.append(load("res://assets/"+id+".png"))
	canvas=Control.new()
	root.add_child(canvas)
	canvas.draw.connect(paint)
	var clean := ShaderMaterial.new()
	var shader := Shader.new()
	shader.code="shader_type canvas_item; render_mode unshaded; void fragment(){ vec4 p=texture(TEXTURE,UV); if(p.a<0.02){ discard; } }"
	clean.shader=shader
	canvas.material=clean
	var starts=[0,6,12,18,21,12]
	var counts=[6,6,6,3,3,12]
	var labels=["repouso","movimento","ataque","dano","queda","execucao"]
	for clip in range(6):
		current=clip
		for tick in range(counts[clip]*5):
			source_index=starts[clip]+tick/5
			canvas.queue_redraw()
			await process_frame
			if tick==((4 if clip==2 else 1)*5):
				await RenderingServer.frame_post_draw
				root.get_texture().get_image().save_png("res://docs/imagens/bestiario-"+labels[clip]+".png")
	quit()
