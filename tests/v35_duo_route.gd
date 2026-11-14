extends "res://tests/exploration_smoke.gd"
## Repete a rota física existente com Beatriz presente, por IA ou por J2 em espera.
var duo_checked := false
func frames(n: int) -> void:
	if game != null and game.partner == null:
		game.enable_duo(true)
		game.partner.ai = OS.get_environment("LACRIMAE_DUO_ROUTE") != "p2"
		if not duo_checked:
			duo_checked = true
			print("DUO_ROUTE: ", "IA" if game.partner.ai else "J2 em espera")
	await super.frames(n)
