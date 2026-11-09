extends "res://scripts/enemy.gd"
# Observation only: all original attack methods execute unchanged.
var emitted={"1":{"slam":0,"wave":0,"rain":0,"spikes":0},"2":{"slam":0,"wave":0,"rain":0,"spikes":0},"3":{"slam":0,"wave":0,"rain":0,"spikes":0}}
func hazard_ids() -> Array:
	return get_tree().get_nodes_in_group("hazards").map(func(h):return h.get_instance_id())
func annotate(old: Array,kind: String):
	for h in get_tree().get_nodes_in_group("hazards"):
		if not old.has(h.get_instance_id()):
			h.set_meta("probe_phase",phase);h.set_meta("probe_attack",kind)
			emitted[str(phase)][kind]+=1
func _slam():
	var old=hazard_ids();emitted[str(phase)].slam+=1
	super._slam();annotate(old,"wave")
func _rain_drop():
	var old=hazard_ids();super._rain_drop();annotate(old,"rain")
func _spikes():
	var old=hazard_ids();super._spikes();annotate(old,"spikes")
