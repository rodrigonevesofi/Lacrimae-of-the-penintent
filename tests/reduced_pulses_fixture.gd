extends "res://scripts/main.gd"
## Observation only; does not supply an implementation of the proposed option.
var observed_scene_shakes:=0
func shake_cam(amount: float) -> void:
	if narrative!=null and narrative.mode!="" and amount>0:observed_scene_shakes+=1
	super.shake_cam(amount)
