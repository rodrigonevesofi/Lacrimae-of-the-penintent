extends SceneTree
func _initialize():
	var failures := 0
	for path in ["assets/animation/carregador_exposto.png", "assets/animation/guardiao_colosso_ataques.png", "assets/detritos_caixao.png"]:
		if load("res://"+path)==null: failures+=1
	print("ART_V22_RESOURCES: 3 resources, %d failures" % failures)
	quit(0 if failures==0 else 1)
