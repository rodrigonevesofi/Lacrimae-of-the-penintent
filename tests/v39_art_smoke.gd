extends SceneTree
## Valida contratos de arquivo e atlas; a revisão de aparência é visual.
var verificacoes:=0
var falhas:=0
func conferir(condicao:bool,rotulo:String) -> void:
 verificacoes+=1
 print("PASS: " if condicao else "FAIL: ",rotulo)
 if not condicao:falhas+=1
func _initialize() -> void:
 var itens:Array=JSON.parse_string(FileAccess.get_file_as_string("res://docs/v39-assets.json"))
 conferir(itens.size()==26,"26 PNGs finais registrados")
 for item in itens:
  var imagem:=Image.load_from_file(ProjectSettings.globalize_path("res://"+item.arquivo))
  conferir(imagem.get_size()==Vector2i(item.dimensoes[0],item.dimensoes[1]),item.arquivo+": dimensões")
  if item.transparente:conferir(imagem.get_pixel(0,0).a<0.05,item.arquivo+": transparência")
 var tipos=load("res://scripts/enemy.gd").TYPES
 for tipo in range(10,19):
  var ator=load("res://scripts/actor_animation.gd").new()
  ator.configure(tipos[tipo].actor,tipos[tipo].scale)
  for clipe in ["idle","walk","attack","recover","hurt","stagger","launched","death","executed"]:
   conferir(ator.definitions.has(clipe) and ator.sprite_frames.get_frame_count(clipe)>=3,"%s/%s"%[tipos[tipo].name,clipe])
   ator.select(clipe,1,0.999)
   var textura:AtlasTexture=ator.sprite_frames.get_frame_texture(clipe,ator.frame)
   conferir(Rect2(Vector2.ZERO,textura.atlas.get_size()).encloses(textura.region),"recorte dentro da folha")
  ator.free()
 print("V39_ART: %d checks, %d failures"%[verificacoes,falhas])
 quit(0 if falhas==0 else 1)
