extends "res://scripts/player.gd"
var boss
var received:=0.0
var hits={"1":{"slam":0,"wave":0,"rain":0,"spikes":0,"unknown":0},"2":{"slam":0,"wave":0,"rain":0,"spikes":0,"unknown":0},"3":{"slam":0,"wave":0,"rain":0,"spikes":0,"unknown":0}}
var damage_by_phase={"1":0.0,"2":0.0,"3":0.0}
func take_hit(dmg: float,from_x: float,attacker=null,parryable: bool=false):
	var before=hp
	var attack="slam" if is_equal_approx(dmg,26) else "unknown"
	var source_phase: int=boss.phase if is_instance_valid(boss) else 1
	for h in get_tree().get_nodes_in_group("hazards"):
		if absf(h.global_position.x-from_x)<.1 and h.has_meta("probe_attack"):
			attack=str(h.get_meta("probe_attack"));source_phase=int(h.get_meta("probe_phase"));break
	super.take_hit(dmg,from_x,attacker,parryable)
	if hp<before:
		var amount=before-hp
		received+=amount;hits[str(source_phase)][attack]+=1;damage_by_phase[str(source_phase)]+=amount
