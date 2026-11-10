extends "res://scripts/main.gd"
## Apenas observação; não fornece implementação da opção proposta.
var observed_scene_shakes:=0
func shake_cam(amount: float) -> void:
	if narrative!=null and narrative.mode!="" and amount>0:observed_scene_shakes+=1
	super.shake_cam(amount)
