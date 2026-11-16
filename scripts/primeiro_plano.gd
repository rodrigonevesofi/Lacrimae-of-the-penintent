extends Node2D
## Primeiro plano: silhuetas escuras penduradas entre a câmera e a cena.
## Correntes, gaiolas, rosários e ganchos em contraluz passam mais depressa que a sala quando o
## Penitente anda. É isso que dá profundidade: a pintura ao fundo, os personagens no meio e algo
## desfocado e escuro na frente.
## Usa o nó Parallax2D do Godot (o primeiro plano corre 35% mais rápido que a câmera e fica preso
## à tela na vertical) e Tweens em laço para o balanço de cada peça.
## Ficam só no alto da tela, para nunca cobrir a luta.

## Quais peças da folha pintada (assets/vida/pendentes.png) cada sala pendura na frente.
## 0 sino, 1 lamparina, 2 incensário, 3 gaiola, 4 estandarte, 5 rosário, 6 ex-votos, 7 gancho.
const SALAS := {
	"city": [3, 5, 0],
	"ossuary": [5, 7, 0],
	"cistern": [0, 7, 5],
	"cloister": [6, 5, 0],
	"belfry": [0, 7, 0],
	"archive": [6, 5],
	"refuge": [3, 7, 6],
	"nave": [2, 5, 6],
	"terrace": [0, 7],
	"court": [3, 0, 7],
}
const VELOCIDADE := 1.35
const SOMBRA := Color(0.075, 0.065, 0.085, 0.97)

var game
var sala := ""
var plano: Parallax2D
var pecas: Array = []

func _ready() -> void:
	z_index = 11
	plano = Parallax2D.new()
	plano.scroll_scale = Vector2(VELOCIDADE, 0.0)
	plano.repeat_size = Vector2.ZERO
	add_child(plano)

func _sala_atual() -> String:
	if game == null or game.exploration == null: return ""
	var id: String = game.exploration.room
	return id if SALAS.has(id) else ""

## Onde pôr a peça na camada para ela cruzar o centro da tela quando a câmera estiver em mundo_x.
func _x_na_camada(mundo_x: float) -> float:
	return mundo_x * VELOCIDADE - 640.0 * (VELOCIDADE - 1.0)

func _montar(id: String) -> void:
	sala = id
	for p in pecas: p.queue_free()
	pecas.clear()
	if id == "": return
	var b: Rect2 = game.exploration.rooms[id].bounds
	var folha: Texture2D = load("res://assets/vida/pendentes.png")
	var tipos: Array = SALAS[id]
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(id) + 909
	var x := b.position.x + rng.randf_range(500.0, 800.0)
	var i := 0
	while x < b.end.x - 300.0:
		var recorte := AtlasTexture.new()
		recorte.atlas = folha
		recorte.region = Rect2(int(tipos[i % tipos.size()]) * 128, 0, 128, 512)
		var peca := Sprite2D.new()
		peca.texture = recorte
		peca.centered = false
		peca.offset = Vector2(-64, 0)
		# Grandes e largas, como algo perto demais da câmera; terminam antes da altura da luta.
		var escala := rng.randf_range(0.80, 1.0)
		peca.scale = Vector2(escala * 1.7, escala)
		peca.position = Vector2(_x_na_camada(x), -150.0 - rng.randf_range(0.0, 60.0))
		peca.modulate = SOMBRA
		plano.add_child(peca)
		pecas.append(peca)
		# Balanço: um Tween em laço, cada peça com o seu tempo.
		var giro := rng.randf_range(0.035, 0.075)
		var tempo := rng.randf_range(2.2, 3.6)
		peca.rotation = -giro
		var balanco: Tween = peca.create_tween().set_loops()
		balanco.tween_property(peca, "rotation", giro, tempo).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		balanco.tween_property(peca, "rotation", -giro, tempo).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		x += rng.randf_range(640.0, 980.0)
		i += 1

## Um golpe forte dá um tranco nas peças próximas.
func impulse(strength: float) -> void:
	for peca in pecas:
		var tranco: Tween = peca.create_tween()
		tranco.tween_property(peca, "skew", clampf(strength, 0.0, 1.5) * 0.10, 0.10)
		tranco.tween_property(peca, "skew", 0.0, 0.9).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)

func _process(_delta: float) -> void:
	var id := _sala_atual()
	if id != sala: _montar(id)
	visible = id != "" and game.state != "title"
