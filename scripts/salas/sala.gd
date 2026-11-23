@tool
extends Node2D
## Uma sala do Ato I (scenes/salas/<id>.tscn). A sala começa no canto (0, 0) da cena e vai até
## "tamanho"; tudo dentro dela (plataformas, alvenaria, inimigos, arenas, portas, piso) usa essas
## coordenadas locais. "origem" diz onde esse canto fica no mundo do jogo, que põe as salas lado a lado.
## act_one_layout.gd lê estas cenas e entrega os dados ao jogo já em coordenadas do mundo.
##
## Filhos esperados: Plataformas (Retangulo, atravessáveis por baixo), Alvenaria (Retangulo, sólidos),
## Inimigos (MarcadorInimigo), Arenas (Arena), Portas (Porta), Altares (Altar), Vestigios (Vestigio) e
## Pontos (Ponto: túmulo, espada, Iria, chefes, correntes do sino...), Zonas (Zona: portão dos sinos, parede
## do chefe...) e Luzes (Luz).
## Só na Cidade: Inscricoes (Inscricao), Velas (Vela), Abismo (o vão da ponte), Trechos (Trecho: nomes de área)
## e Decoracoes (Decoracao: gaiolas, panos, correntes). Todos são opcionais.
##
## No editor, a sala mostra a pintura de fundo posicionada como em world_art.gd, o chão e os limites.
##
## A main.tscn instancia as onze salas sob o nó Salas. Lá cada instância fica em "origem" (o script a põe ali
## sozinho): para mudar onde a sala fica no mundo, altere "origem" na cena da sala, não arraste a instância.
## Quando o jogo roda, a sala cria os próprios corpos de colisão (chão, paredes, plataformas e alvenaria).

## Liga o desenho de editor fora do editor (para capturas de conferência).
static var desenhar_fora_do_editor := false

const PANORAMA_RECT := Rect2(0, -770, 4800, 1600)  # o mesmo de world_art.gd, em coordenadas do mundo

@export var id := ""
@export var nome := ""
## Onde o canto superior esquerdo da sala fica no mundo do jogo.
@export var origem := Vector2.ZERO:
	set(valor):
		origem = valor
		_seguir_origem()
		queue_redraw()
## Largura e altura da sala.
@export var tamanho := Vector2(2000, 1300):
	set(valor):
		tamanho = valor
		queue_redraw()
## Altura do chão de colisão, medida do topo da sala.
@export var piso := 950.0:
	set(valor):
		piso = valor
		queue_redraw()
## Nome da pintura de fundo em assets/ (sem extensão).
@export var arte := "":
	set(valor):
		arte = valor
		queue_redraw()
## Fração da altura da pintura em que fica o piso pintado. Negativo: usa o padrão do jogo (0,86).
@export var linha_do_chao := -1.0:
	set(valor):
		linha_do_chao = valor
		queue_redraw()
## Altura da pintura no mundo. Negativo: usa o padrão do jogo.
@export var altura_arte := -1.0:
	set(valor):
		altura_arte = valor
		queue_redraw()
@export var ao_ar_livre := false
## Cenário gerado por código (Vale), sem pintura própria: o fundo mostrado no editor é só referência.
@export var procedural := false
## Posição da sala no mapa (aba TAB).
@export var posicao_no_mapa := Vector2.ZERO

@export_group("Som")
## Passos do Penitente nesta sala (família de sons de soundscape.gd).
@export_enum("step_pedra", "step_osso", "step_agua", "step_madeira") var passos := "step_pedra"
## Quanto da cauda acústica da sala os efeitos carregam (reverberação do barramento SFX).
@export_range(0.0, 1.0, 0.01) var reverberacao := 0.12
## Música da sala fora de combate e de cena: exploração, templo ou uma faixa própria. Na Cidade, a zona
## musica_do_templo põe o canto do templo no começo da sala.
@export_enum("exploration", "temple", "nave", "terraco", "patio") var musica := "exploration"
## Laço de ambiente em assets/audio/ (sem extensão), tocado sob a música enquanto o Penitente está aqui.
@export var ambiente := ""

@export_group("Colisão")
## Espessura do chão de colisão, para baixo do piso.
@export var espessura_piso := 500.0
## Largura das paredes, logo fora das bordas esquerda e direita.
@export var espessura_parede := 40.0
## Quanto as paredes sobem acima do topo da sala e descem abaixo do fundo dela.
@export var parede_acima := 0.0
@export var parede_abaixo := 300.0
@export_group("")

## Texturas desenhadas no editor. Ficam guardadas aqui: se só uma variável local de _draw() as segurasse,
## seriam liberadas antes de o quadro ser desenhado e apareceriam brancas.
var _texturas := {}

static func visivel() -> bool:
	return Engine.is_editor_hint() or desenhar_fora_do_editor

func limites() -> Rect2:
	return Rect2(origem, tamanho)

## Mesmo formato de act_one_layout.gd rooms(), em coordenadas do mundo; as chaves opcionais só aparecem
## quando definidas.
func dados() -> Dictionary:
	var d := {"name": nome, "bounds": limites(), "floor": origem.y + piso, "art": arte}
	if linha_do_chao >= 0.0: d["ground"] = linha_do_chao
	if altura_arte >= 0.0: d["art_h"] = altura_arte
	if ao_ar_livre: d["outdoor"] = true
	if procedural: d["procedural"] = true
	d["sound"] = {"steps": passos, "reverb": reverberacao, "music": musica, "ambience": ambiente}
	d["map"] = posicao_no_mapa
	return d

func _ready() -> void:
	_seguir_origem()
	if visivel(): queue_redraw()

## Instanciada em outra cena (a main), a sala fica no mundo em "origem". Na própria cena, a raiz fica em (0, 0).
func _seguir_origem() -> void:
	if owner != null: position = origem

## Trechos do chão em x local: a Cidade tem o vão do abismo (nó Abismo); as outras salas têm chão inteiro.
func _trechos_do_chao() -> Array[Vector2]:
	if has_node("Abismo"):
		var vao: Node2D = get_node("Abismo")
		return [Vector2(0, vao.position.x), Vector2(vao.position.x + vao.largura, tamanho.x)]
	return [Vector2(0, tamanho.x)]

## Corpos de colisão da sala, em coordenadas do mundo e na ordem em que são criados: [Rect2, atravessável].
## Chão, parede esquerda, parede direita, plataformas (atravessáveis por baixo) e alvenaria.
func colisoes() -> Array:
	var lista := []
	for t in _trechos_do_chao(): lista.append([Rect2(origem.x + t.x, origem.y + piso, t.y - t.x, espessura_piso), false])
	var altura := tamanho.y + parede_acima + parede_abaixo
	lista.append([Rect2(origem.x - espessura_parede, origem.y - parede_acima, espessura_parede, altura), false])
	lista.append([Rect2(origem.x + tamanho.x, origem.y - parede_acima, espessura_parede, altura), false])
	for grupo in [["Plataformas", true], ["Alvenaria", false]]:
		if has_node(grupo[0]):
			for r in get_node(grupo[0]).get_children(): lista.append([r.retangulo_no_mundo(self), grupo[1]])
	return lista

func _textura(nome_arte: String) -> Texture2D:
	if not _texturas.has(nome_arte):
		var caminho := "res://assets/%s.png" % nome_arte
		_texturas[nome_arte] = load(caminho) if ResourceLoader.exists(caminho) else null
	return _texturas[nome_arte]

func _draw() -> void:
	if not visivel(): return
	var sala := Rect2(Vector2.ZERO, tamanho)
	draw_rect(sala, Color("17181d"))
	# Pintura de fundo, posicionada como em world_art.gd .
	if id == "city":
		var pano := _textura("vespera_panorama")
		if pano: draw_texture_rect(pano, Rect2(PANORAMA_RECT.position - origem, PANORAMA_RECT.size), false)
		var abismo := _textura("abismo_ponte")
		if abismo and has_node("Abismo"):
			var vao: Node2D = get_node("Abismo")
			draw_texture_rect(abismo, Rect2(vao.position + Vector2(0, -4), Vector2(vao.largura, 400)), false)
	else:
		var fundo := _textura(arte) if not arte.is_empty() else null
		var altura := altura_arte if altura_arte >= 0.0 else (1900.0 if id == "belfry" else 1100.0)
		var chao_pintado := linha_do_chao if linha_do_chao >= 0.0 else 0.86
		if fundo: draw_texture_rect(fundo, Rect2(0, piso - altura * chao_pintado, tamanho.x, altura), false)
	# Chão de colisão e limites (as paredes ficam logo fora das bordas).
	for t in _trechos_do_chao():
		var x0: float = t.x
		var x1: float = t.y
		draw_rect(Rect2(x0, piso, x1 - x0, 120), Color(0.25, 0.85, 0.45, 0.35))
		draw_line(Vector2(x0, piso), Vector2(x1, piso), Color(0.5, 0.85, 0.5, 0.9), 3.0)
	draw_rect(sala, Color(0.86, 0.7, 0.38, 0.9), false, 6.0)
	var fonte := ThemeDB.fallback_font
	var titulo := "%s  (%s)%s" % [nome, id, "  · cenário procedural" if procedural else ""]
	draw_string_outline(fonte, Vector2(24, 70), titulo, HORIZONTAL_ALIGNMENT_LEFT, -1, 48, 10, Color(0, 0, 0, 0.85))
	draw_string(fonte, Vector2(24, 70), titulo, HORIZONTAL_ALIGNMENT_LEFT, -1, 48, Color("e8d6b0"))
	draw_string_outline(fonte, Vector2(24, piso - 12), "piso", HORIZONTAL_ALIGNMENT_LEFT, -1, 22, 6, Color(0, 0, 0, 0.85))
	draw_string(fonte, Vector2(24, piso - 12), "piso", HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color(0.5, 0.85, 0.5))
