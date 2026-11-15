extends SceneTree
## Recursos entregues e registro dos quatro estados, sem avaliar estilo por teste de pixels.
var checks:=0
var failures:=0
func expect(ok:bool,label:String) -> void:
 checks+=1
 print("PASS: " if ok else "FAIL: ",label)
 if not ok:failures+=1
func _initialize() -> void:
 var specs:Array=JSON.parse_string(FileAccess.get_file_as_string("res://docs/v38-assets.json"))
 expect(specs.size()==42,"42 pinturas finais ou atlas derivados registrados")
 for entry in specs:
  var path:String="res://"+entry.arquivo
  var art:=Image.load_from_file(ProjectSettings.globalize_path(path))
  expect(not art.is_empty() and art.get_size()==Vector2i(entry.tamanho[0],entry.tamanho[1]),entry.nome+": dimensão contratada")
  if entry.alpha:expect(art.has_mipmaps()==false and art.get_pixel(0,0).a<0.05,entry.nome+": fundo transparente no canto")
 var manifest:Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://assets/animation/clips.json"))
 for stage in range(5):
  var actor=load("res://scripts/actor_animation.gd").new()
  actor.configure("flagelado_%d"%stage,0.62)
  expect(actor.sprite_frames.get_frame_count("idle")==6,"estado %d: seis parados"%stage)
  for clip in ["idle","walk","attack_a","slam","kneel","pray"]:
   actor.select(clip,1,0.5)
   var image:AtlasTexture=actor.sprite_frames.get_frame_texture(clip,actor.frame)
   expect(not image.atlas.resource_path.contains("argon/") and image.atlas.resource_path.contains("flagelado"),"estado %d/%s usa a identidade nova"%[stage,clip])
  actor.free()
 var grid:Array=manifest.gota_culpa.idle.grid
 expect(grid.size()==2 and int(grid[0])==6 and int(grid[1])==1,"gota com seis células em fileira")
 var texture:Texture2D=load("res://assets/close/close_dois_rostos.png")
 expect(texture.get_size()==Vector2(512,512),"dois rostos no close quadrado final")
 print("V38_ART: %d checks, %d failures"%[checks,failures])
 quit(0 if failures==0 else 1)
