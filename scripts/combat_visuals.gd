extends Node2D
## Efeitos visuais locais; não alteram dano nem janelas de controle.
var subject
var trail: Line2D
var glint: PointLight2D
var breathing: Tween
var was_idle := false
var age := 0.0
var transition_t := 0.0
var transition_material: ShaderMaterial
var original_material: Material
var death_material: ShaderMaterial
var samples: Array = []
var elapsed := 0.0
var player_actor := false
static var coverage_cache:Dictionary={}

func _ready() -> void:
 subject=get_parent()
 player_actor=subject.has_method("_start_attack")
 trail=Line2D.new()
 trail.top_level=true
 trail.width=7.0 if player_actor else 5.0
 trail.z_index=8
 var taper:=Curve.new()
 taper.add_point(Vector2(0,0));taper.add_point(Vector2(0.65,0.8));taper.add_point(Vector2(1,1))
 trail.width_curve=taper
 trail.joint_mode=Line2D.LINE_JOINT_ROUND
 add_child(trail)
 glint=PointLight2D.new()
 var gradient:=Gradient.new()
 gradient.colors=PackedColorArray([Color.WHITE,Color(1,1,1,0)])
 var radial:=GradientTexture2D.new()
 radial.gradient=gradient;radial.width=128;radial.height=128
 radial.fill=GradientTexture2D.FILL_RADIAL;radial.fill_from=Vector2(0.5,0.5);radial.fill_to=Vector2(1,0.5)
 glint.texture=radial;glint.texture_scale=1.6;glint.color=Color(1,0.80,0.38);glint.energy=0.0
 glint.position=Vector2(0,-50)
 add_child(glint)

func material_for() -> ShaderMaterial:
 var m:=ShaderMaterial.new()
 m.shader=load("res://shaders/dissolve_ash.gdshader")
 m.set_shader_parameter("sombra_transformacao",load("res://assets/animation/flagelado_transformacao.png"))
 return m

## Atualiza a região já no primeiro quadro do efeito, sem esperar a próxima seleção de pose.
func sync_frame(m:ShaderMaterial,texture:AtlasTexture=null) -> void:
 if texture==null:texture=subject.animator.sprite_frames.get_frame_texture(subject.animator.animation,subject.animator.frame)
 var size:=texture.atlas.get_size()
 m.set_shader_parameter("frame_bounds",Vector4(texture.region.position.x/size.x,texture.region.position.y/size.y,texture.region.end.x/size.x,texture.region.end.y/size.y))
 var key:=texture.atlas.resource_path+str(texture.region)
 if not coverage_cache.has(key):
  var pixels:=texture.atlas.get_image()
  if pixels.is_compressed():pixels.decompress()
  var cell:=pixels.get_region(Rect2i(texture.region))
  cell.convert(Image.FORMAT_RGBA8)
  var bytes:=cell.get_data()
  var top:=cell.get_height();var bottom:=0
  # Ignora o ruído quase transparente das folhas, sem mudar os arquivos de arte.
  for y in range(cell.get_height()):
   for x in range(cell.get_width()):
    if bytes[(y*cell.get_width()+x)*4+3]>32:
     top=mini(top,y);bottom=maxi(bottom,y+1);break
  coverage_cache[key]=Vector2(float(top)/cell.get_height(),float(bottom)/cell.get_height()) if bottom>top else Vector2(0,1)
 m.set_shader_parameter("vertical_bounds",coverage_cache[key])

## A forma antiga se desfaz; a nova aparece pelo caminho inverso.
func transform_out() -> void:
 if subject.animator==null:return
 if breathing!=null and breathing.is_valid():breathing.kill()
 was_idle=false
 var old:=Sprite2D.new()
 old.texture=subject.animator.sprite_frames.get_frame_texture(subject.animator.animation,subject.animator.frame)
 old.position=subject.animator.position
 old.scale=subject.animator.scale
 old.flip_h=subject.animator.flip_h
 old.modulate=subject.animator.modulate
 old.material=material_for()
 # O shader recebe a região real do quadro no atlas, evitando ler o quadro vizinho.
 var texture:AtlasTexture=old.texture
 sync_frame(old.material,texture)
 add_child(old)
 var tween:=old.create_tween()
 tween.tween_method(func(value:float):old.material.set_shader_parameter("progress",value),0.0,1.0,0.6)
 tween.tween_callback(old.queue_free)
 transition_t=0.6
 transition_material=null

func _process(delta:float) -> void:
 if not is_instance_valid(subject) or subject.is_queued_for_deletion() or subject.animator==null:return
 age+=delta;elapsed+=delta
 var game=get_tree().get_first_node_in_group("game")
 var reduced:bool=game!=null and game.reduced_pulses
 var is_player:bool=player_actor
 var idle:bool=not is_player and not subject.dead and subject.state in ["idle","patrol","sleep"] and absf(subject.velocity.x)<1.0
 if idle!=was_idle:
  was_idle=idle
  if breathing!=null and breathing.is_valid():breathing.kill()
  subject.animator.scale=Vector2.ONE*subject.animator.unit_scale
  if idle:
   breathing=create_tween().set_loops()
   breathing.tween_property(subject.animator,"scale",Vector2(0.995,1.012)*subject.animator.unit_scale,1.5)
   breathing.tween_property(subject.animator,"scale",Vector2.ONE*subject.animator.unit_scale,1.5)
 if not is_player and subject.dead and not subject.executing:
  if death_material==null:death_material=material_for()
  subject.animator.material=death_material
  sync_frame(death_material)
  death_material.set_shader_parameter("progress",clampf((subject.death_age-0.25)/1.2,0.0,1.0))
 if transition_t>0.0:
  if transition_material==null:
   original_material=subject.animator.material
   transition_material=material_for()
  transition_t=maxf(transition_t-delta,0.0)
  subject.animator.material=transition_material
  sync_frame(transition_material)
  transition_material.set_shader_parameter("progress",transition_t/0.6)
  if transition_t<=0.0:subject.animator.material=original_material
 # Os rastros acompanham a arma e desaparecem rapidamente após a janela ativa.
 var active:=false
 var progress:=0.0
 var length:=54.0
 var arc:=0.0
 if is_player:
  if subject.state=="attack":progress=1.0-subject.state_t/subject.attack_len;active=progress>=1.0/3.0 and progress<2.0/3.0
  elif subject.state=="heavy":progress=1.0-subject.state_t/subject.heavy_len;active=progress>=0.30 and progress<0.75
  elif subject.state=="air_attack":progress=1.0-subject.state_t/subject.AIR_ATTACK_TIME;active=progress>=5.0/12.0 and progress<8.0/12.0
  length=76.0 if subject.character=="beatriz" else 54.0
  arc=clampf((progress-0.30)/0.45,0,1) if subject.state=="heavy" else clampf((progress-1.0/3.0)*3.0,0,1)
  trail.default_color=Color("e7c17b") if subject.counter_attack else (Color("b92d42") if subject.finisher or subject.state=="heavy" else Color("c2b2a2"))
  var shine:bool=subject.state=="parry" and subject.parry_hit
  glint.energy=0.0 if reduced or not shine else 0.65
 if active:
  var angle:=lerpf(-1.5,1.1,arc)
  samples.append({"p":subject.global_position+Vector2(subject.facing*cos(angle)*length,-45+sin(angle)*length*0.55),"t":elapsed})
 while not samples.is_empty() and (elapsed-float(samples[0].t)>0.12 or samples.size()>12):samples.pop_front()
 trail.clear_points()
 for sample in samples:trail.add_point(sample.p)
 trail.visible=samples.size()>1
