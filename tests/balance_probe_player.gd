extends "res://scripts/player.gd"
# Test instrumentation only: observe successful damage, never alter its value.
var received:=0.0
var hits={"bote":0,"investida":0,"estilhacos":0,"leque_lagrimas":0,"outros":0}
func take_hit(dmg: float,from_x: float,attacker=null,parryable: bool=false) -> void:
	var before: float=hp
	var tag: String="outros"
	for h in get_tree().get_nodes_in_group("hazards"):
		if h.get_script()==load("res://scripts/tear.gd") and absf(h.global_position.x-from_x)<.1:
			tag="estilhacos" if h.grav>0 else ("leque_lagrimas" if (h.dmg==7 or h.dmg==11) else "outros")
			break
	if tag=="outros":
		for e in get_tree().get_nodes_in_group("enemies"):
			if absf(e.global_position.x-from_x)<.1:
				if e.kind==3 and e.state=="strike":tag="bote"
				elif e.kind==4 and e.state=="charge":tag="investida"
	super.take_hit(dmg,from_x,attacker,parryable)
	if hp<before:
		received+=before-hp
		hits[tag]+=1
