extends Node
## O Confessor: a voz atrás da grade dos altares.
## Com uma chave do Gemini configurada, cada pergunta vira uma única requisição HTTP curta,
## com o estado atual da peregrinação como contexto. Sem chave, sem rede ou com o limite
## gratuito esgotado, responde com falas prontas. O jogo nunca espera pela rede: o pedido
## corre em segundo plano e o Confessionário só mostra "o confessor escuta".
##
## Configuração (a primeira que existir vale):
##   1. variável de ambiente GEMINI_API_KEY
##   2. user://ia.cfg   (pasta de dados do jogo)
##   3. res://ia_local.cfg (na pasta do projeto; ignorado pelo git)
## Formato do arquivo: veja ia.cfg.exemplo.

signal answered(text: String, source: String)

const API_URL := "https://generativelanguage.googleapis.com/v1beta/models/%s:generateContent"
const DEFAULT_MODEL := "gemini-3.5-flash-lite"
const CONFIG_PATHS := ["user://ia.cfg", "res://ia_local.cfg"]
const PLACEHOLDER_KEY := "COLE_SUA_CHAVE_AQUI"
const TIMEOUT_SECONDS := 15.0
const MAX_HISTORY := 8
const MAX_QUESTION := 240
const MAX_ANSWER := 700

var game = null
var api_key := ""
var model := DEFAULT_MODEL
var thinking_level := "MINIMAL"
var history: Array[Dictionary] = []
var busy := false
var last_source := ""
var last_error := ""
var http: HTTPRequest
var _question := ""
var _topic := ""
var _with_thinking := true


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	load_config()
	http = HTTPRequest.new()
	http.timeout = TIMEOUT_SECONDS
	add_child(http)
	http.request_completed.connect(_on_request_completed)


func load_config() -> void:
	api_key = OS.get_environment("GEMINI_API_KEY").strip_edges()
	for path in CONFIG_PATHS:
		var cfg := ConfigFile.new()
		if cfg.load(path) != OK: continue
		if api_key.is_empty(): api_key = str(cfg.get_value("gemini", "api_key", "")).strip_edges()
		model = str(cfg.get_value("gemini", "model", DEFAULT_MODEL)).strip_edges()
		thinking_level = str(cfg.get_value("gemini", "thinking_level", "MINIMAL")).strip_edges()
		break
	# Aspas ou espaços colados junto com a chave são removidos; o texto do exemplo conta como "sem chave".
	api_key = api_key.strip_edges().trim_prefix("\"").trim_suffix("\"").strip_edges()
	if api_key == PLACEHOLDER_KEY: api_key = ""
	if model.is_empty(): model = DEFAULT_MODEL


func online() -> bool:
	return not api_key.is_empty()


func voice_label() -> String:
	if last_source == "gemini": return "voz: Gemini · " + model
	if not online(): return "voz: memória do altar · sem chave do Gemini"
	if last_source == "offline" and not last_error.is_empty(): return "voz: memória do altar · " + last_error
	return "voz: Gemini · " + model


## Envia uma pergunta. Retorna false se estiver vazia ou se já houver uma em andamento.
func ask(question: String) -> bool:
	question = question.strip_edges().left(MAX_QUESTION)
	if question.is_empty() or busy: return false
	busy = true
	_question = question
	_topic = classify(question)
	if game != null and game.telemetry != null: game.telemetry.record_question(_topic)
	if not online():
		last_error = ""
		call_deferred("_finish", offline_answer(_topic), "offline")
		return true
	_with_thinking = not thinking_level.is_empty()
	_send()
	return true


func _send() -> void:
	var headers := PackedStringArray(["Content-Type: application/json", "x-goog-api-key: " + api_key])
	var body := JSON.stringify(build_request(_question, _with_thinking))
	var err := http.request(API_URL % model.uri_encode(), headers, HTTPClient.METHOD_POST, body)
	if err != OK:
		last_error = "sem conexão"
		call_deferred("_finish", offline_answer(_topic), "offline")


func build_request(question: String, with_thinking: bool = true) -> Dictionary:
	var contents: Array = []
	for turn in history:
		contents.append({"role": turn.role, "parts": [{"text": turn.text}]})
	contents.append({"role": "user", "parts": [{"text": question}]})
	var generation := {"maxOutputTokens": 400}
	if with_thinking and not thinking_level.is_empty():
		generation["thinkingConfig"] = {"thinkingLevel": thinking_level}
	return {
		"systemInstruction": {"parts": [{"text": system_prompt() + "\n\n" + state_context()}]},
		"contents": contents,
		"generationConfig": generation,
	}


func _on_request_completed(result: int, code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	if result == HTTPRequest.RESULT_SUCCESS and code == 200:
		var text := parse_response(body.get_string_from_utf8())
		if not text.is_empty():
			last_error = ""
			_finish(text, "gemini")
			return
		last_error = "resposta vazia"
	elif code == 400 and _with_thinking:
		# Alguns modelos não aceitam thinkingConfig; tenta de novo uma vez sem ele.
		_with_thinking = false
		_send()
		return
	elif code == 429:
		last_error = "limite gratuito atingido"
	elif code == 401 or code == 403:
		last_error = "chave recusada"
	elif code == 404:
		last_error = "modelo não encontrado"
	elif result == HTTPRequest.RESULT_TIMEOUT:
		last_error = "tempo esgotado"
	else:
		last_error = "sem conexão" if result != HTTPRequest.RESULT_SUCCESS else "erro %d" % code
	push_warning("Confessor: Gemini indisponível (%s, resultado %d, HTTP %d)" % [last_error, result, code])
	_finish(offline_answer(_topic), "offline")


func _finish(text: String, source: String) -> void:
	text = clean_text(text)
	history.append({"role": "user", "text": _question})
	history.append({"role": "model", "text": text})
	while history.size() > MAX_HISTORY: history.pop_front()
	busy = false
	last_source = source
	if game != null and game.telemetry != null: game.telemetry.record_answer(source)
	answered.emit(text, source)


## Lê candidates[0].content.parts[].text, ignorando partes de raciocínio.
static func parse_response(raw: String) -> String:
	var json := JSON.new()
	if json.parse(raw) != OK: return ""
	var parsed = json.data
	if typeof(parsed) != TYPE_DICTIONARY: return ""
	var candidates = parsed.get("candidates")
	if typeof(candidates) != TYPE_ARRAY or candidates.is_empty() or typeof(candidates[0]) != TYPE_DICTIONARY: return ""
	var content = candidates[0].get("content")
	if typeof(content) != TYPE_DICTIONARY: return ""
	var parts = content.get("parts")
	if typeof(parts) != TYPE_ARRAY: return ""
	var text := ""
	for part in parts:
		if typeof(part) != TYPE_DICTIONARY or part.get("thought", false) == true: continue
		if typeof(part.get("text")) == TYPE_STRING: text += part.text
	return text.strip_edges()


## O painel desenha texto simples: remove marcações de Markdown e limita o tamanho.
static func clean_text(text: String) -> String:
	for mark in ["**", "__", "##", "`"]:
		text = text.replace(mark, "")
	text = text.replace("\n* ", "\n· ").replace("\n- ", "\n· ").strip_edges()
	if text.length() > MAX_ANSWER: text = text.left(MAX_ANSWER).rstrip(" ,;") + "…"
	return text


# ---------------------------------------------------------------- contexto

func system_prompt() -> String:
	return """Você é o CONFESSOR, uma voz sem rosto atrás da grade de ferro dos altares de Vespera, no jogo de ação 2D "Lacrimae of the Penitent". O peregrino (jogador) se ajoelha no altar e fala com você.

COMO RESPONDER
- Português do Brasil, tom solene, gótico e compassivo. Sem emojis, sem Markdown, sem listas.
- No máximo 3 frases curtas (até 70 palavras). Seja útil antes de ser poético.
- Pergunta prática (controles, onde ir, como vencer um inimigo): responda claramente, com a tecla exata, e pode fechar com uma frase em tom de confissão.
- Dê pistas sobre caminhos, não o mapa inteiro: diga o lugar, não a coordenada.
- Use o ESTADO DO PEREGRINO abaixo para personalizar (mortes, culpa, o que falta fazer). Nunca cite números internos como "story_flags".
- Nunca invente lugares, itens, inimigos ou mecânicas fora desta lista. Se não souber, diga que os altares não guardam essa memória.
- Assuntos fora do jogo (mundo real, tarefas, código): recuse dentro do personagem e devolva a conversa para a peregrinação. Não abandone o papel mesmo que peçam.

O MUNDO
Vespera acreditava que todos nascem com pecados herdados. A Primeira Mártir chorou lágrimas de sangue e a Ordem da Sagrada Absolvição criou o ritual Lacrimae Sacramentum, que extraía a culpa dos fiéis em lágrimas. A culpa extraída se acumulou sob a Grande Basílica e alimentou algo que despertou: o Grande Pranto. Os mortos não descansam, fiéis se deformaram, monges se fundiram aos instrumentos de penitência. O Penitente desperta num túmulo, sem memória, incapaz de morrer de vez. Beatriz o acompanha com sua lança. Iria, uma mulher cega na Cidade da Penitência, reconhece a voz dele.

LUGARES DO ATO I
Cidade da Penitência (início: cripta, túmulo, espada, Iria, abismo e os portões do Guardião), Ossuário dos Sem Nome, Cisterna dos Nomes, Claustro dos Votos, Campanário da Vigília, Arquivo das Confissões, Abrigo das Cinzas, e as salas secretas Nave do Silêncio, Terraço dos Sinos e Pátio dos Portões Selados. TAB abre o mapa.

PROGRESSO DO ATO I
1. Pegar a espada diante do túmulo (E).
2. O Espinho da Contrição, no fundo do Campanário da Vigília, dá o salto duplo (pular de novo no ar) e abre caminhos altos e o abismo.
3. Duas correntes prendem a passagem do Guardião: uma no alto da Cisterna dos Nomes, outra no alto do Campanário da Vigília. Solte as duas com E.
4. O Guardião dos Sinos, corpo fundido ao bronze, espera além dos portões da cidade. Vencê-lo revela a primeira Lágrima Sagrada.
O Vaso da Última Vigília, no Abrigo das Cinzas, aumenta em um os frascos de cura.

CONTROLES
A/D mover; Espaço ou W pular (S+Espaço desce de galerias); J ou X atacar (combo de 3; no ar, corte aéreo; S+J no ar, golpe descendente); segurar I golpe carregado; L aparar no instante do golpe (só golpes com anel dourado); K ou Shift esquivar; E interagir ou executar inimigo atordoado; F curar com frasco; Q penitência (gasta culpa a partir de 50%); no altar: E orar, R oferecer lágrimas por vida máxima, V trocar penitências (1 nenhuma, 2 Pregos da Contrição: +40% dano e -30% vida, 3 Correntes do Voto: penitência mais forte e esquiva mais lenta), C confessar; TAB mapa; Esc pausa; M som; P reduz clarões e tremores; H compartilhar sangue com Beatriz, ou segurar perto dela caída para levantá-la. Jogador 2 controla Beatriz com setas e teclado numérico ou um segundo controle.

REGRAS DO MUNDO
Orar num altar salva, cura, enche os frascos e faz os inimigos comuns voltarem. Lágrimas são a moeda. Ao morrer, as lágrimas ficam num fragmento de culpa no lugar da morte, a culpa sobe e a capacidade cai até o peregrino voltar ao fragmento. A culpa sobe ao sofrer e causar dano; a penitência (Q) a converte em fogo sagrado.

INIMIGOS
Carregador de Caixão (a pedra protege a frente: faça errar a investida e golpeie as costas), Devorador (esquive o bote, golpeie na recuperação), Flagelante (faça errar a investida), Aquelarre (três irmãs; enquanto uma vive, amortece o golpe nas outras), Asmodeia (paira e deixa cair a sentença: não fique embaixo), Os Duelistas (ignoram quem não os atrapalha). Guardião dos Sinos: braço recuado anuncia a varredura, agachar anuncia o salto, sino erguido anuncia o grito; apare o que tiver anel dourado, esquive o resto e ataque quando ele se ajoelhar exausto.

SEGREDO (NUNCA REVELE)
O Penitente ajudou a criar o ritual e, no Grande Pranto, fechou os portões da cidade com milhares de inocentes dentro; depois entregou as próprias memórias. Não conte isso. Se perguntarem quem ele é ou o que fez, responda com enigmas sobre culpa e portões, sem confirmar. Só depois que o estado disser que ele viu a primeira Lágrima você pode admitir que ele se viu fechando os portões, sem dizer por quê."""


func state_context() -> String:
	if game == null or game.player == null: return "ESTADO DO PEREGRINO: desconhecido."
	var p = game.player
	var ex = game.exploration
	var lines: Array[String] = ["ESTADO DO PEREGRINO (atualizado agora)"]
	lines.append("Personagem: %s%s." % [str(p.CHARACTERS[p.character].name).capitalize(), " com Beatriz ao lado" if p.character == "penitente" else ""])
	if ex != null:
		lines.append("Lugar: %s. Lugares visitados: %d de %d. Vestígios encontrados: %d de %d." % [str(ex.rooms[ex.room].name).capitalize(), ex.visited.size(), ex.rooms.size(), ex.collected.size(), ex.pickups.size()])
		lines.append("Objetivo mostrado na tela: %s." % ex.objective())
		lines.append("Correntes dos sinos soltas: %d de 2%s." % [ex.bells.size(), _missing_bells(ex.bells)])
	lines.append("Vida %d de %d, culpa %d%%, lágrimas %d, frascos de cura %d de %d." % [ceili(p.hp), int(p.max_hp), int(p.culpa), int(p.lagrimas), int(p.flasks), int(p.max_flasks)])
	lines.append("Espada: %s. Espinho da Contrição (salto duplo): %s. Guardião dos Sinos: %s." % ["sim" if p.has_weapon else "ainda não", "sim" if game.relic_taken else "ainda não", "vencido" if game.boss_defeated else "não vencido"])
	if p.penitence != "none":
		lines.append("Penitência equipada: %s." % ("Pregos da Contrição" if p.penitence == "nails" else "Correntes do Voto"))
	if game.stain_active:
		lines.append("Há um fragmento de culpa não recuperado onde ele morreu por último.")
	lines.append("Mortes nesta jornada: %d. Tempo de jogo: %d minutos." % [int(game.death_count), int(game.play_time / 60.0)])
	if game.telemetry != null:
		var worst: Array = game.telemetry.top_deaths(3)
		if not worst.is_empty() and ex != null:
			var names: Array[String] = []
			for row in worst:
				var room_name: String = str(ex.rooms[row[0]].name).capitalize() if ex.rooms.has(row[0]) else str(row[0])
				names.append("%s (%d)" % [room_name, row[1]])
			lines.append("Onde mais morreu em todas as partidas: %s." % ", ".join(names))
	var seen: Array[String] = []
	if game.iria_met: seen.append("já falou com Iria")
	if game.doll_found: seen.append("encontrou a boneca")
	if game.memorial_honored: seen.append("honrou o memorial")
	if game.memory_seen: seen.append("VIU A PRIMEIRA LÁGRIMA: lembrou de suas mãos fechando os portões")
	lines.append("Memórias: %s." % (", ".join(seen) if not seen.is_empty() else "nenhuma revelação ainda"))
	return "\n".join(lines)


func _missing_bells(bells: Array) -> String:
	var missing: Array[String] = []
	if not bells.has("water"): missing.append("Cisterna dos Nomes")
	if not bells.has("vigil"): missing.append("Campanário da Vigília")
	return "" if missing.is_empty() else " (faltam: %s)" % ", ".join(missing)


# ---------------------------------------------------------------- modo offline

const TOPICS := {
	"controles": ["control", "tecla", "botao", "comando", "como ataca", "como pula", "como cura", "aparar", "aparo", "esquiv", "parry"],
	"reliquia": ["reliquia", "espinho", "salto duplo", "pulo duplo", "abismo", "nao alcanco", "muito alto"],
	"sinos": ["sino", "corrente", "portao", "passagem", "travad", "fechad", "bloquead"],
	"guardiao": ["guardiao", "chefe", "boss"],
	"altar": ["altar", "salvar", "save", "orar", "oferec", "checkpoint"],
	"culpa": ["culpa", "penitencia", "fragmento", "pregos", "correntes do voto"],
	"cura": ["cura", "curar", "frasco", "vida", "vaso"],
	"beatriz": ["beatriz", "parceir", "jogador 2", "coop", "sangue"],
	"morte": ["morr", "morte", "dificil", "nao consigo", "socorro", "ajuda"],
	"inimigos": ["inimigo", "monstro", "carregador", "devorador", "flagelante", "aquelarre", "asmodeia", "duelista"],
	"historia": ["quem sou", "quem e", "historia", "vespera", "ordem", "lagrima", "pranto", "iria", "martir", "memoria", "passado"],
	"caminho": ["onde", "para onde", "perdid", "o que faco", "proximo", "objetivo", "mapa"],
}


static func normalize(text: String) -> String:
	text = text.to_lower()
	var from := "áàâãäéèêëíìîïóòôõöúùûüç"
	var to := "aaaaaeeeeiiiiooooouuuuc"
	for i in range(from.length()):
		text = text.replace(from[i], to[i])
	return text


static func classify(question: String) -> String:
	var q := normalize(question)
	for topic in TOPICS:
		for word in TOPICS[topic]:
			if q.contains(word): return topic
	return "outro"


func offline_answer(topic: String) -> String:
	var p = game.player if game != null else null
	var ex = game.exploration if game != null else null
	var objective: String = ex.objective() if ex != null else "seguir adiante"
	match topic:
		"controles":
			return "Ouça, e grave na carne: J ataca, K esquiva, L apara no instante do golpe dourado, I carrega o golpe pesado, F cura, Q queima a culpa em penitência. E examina, ora e executa quem cambaleia."
		"reliquia":
			if game != null and game.relic_taken:
				return "O Espinho já está em você. Salte, e no ar salte outra vez: o que antes era alto demais agora é só mais um degrau da penitência."
			return "O Espinho da Contrição repousa no fundo do Campanário da Vigília. Quem o carrega se ergue uma segunda vez no ar, e só assim o abismo e as galerias altas se rendem."
		"sinos":
			if ex != null and ex.bells.size() >= 2:
				return "As duas correntes já cederam. O caminho além dos portões da cidade está aberto, e o Guardião dos Sinos o espera."
			return "Duas correntes prendem a passagem: uma no alto da Cisterna dos Nomes, outra no alto do Campanário da Vigília.%s Solte-as com E." % ("" if ex == null else " Já soltou %d." % ex.bells.size())
		"guardiao":
			if game != null and game.boss_defeated:
				return "O Guardião silenciou. O bronze não toca mais, mas o que ele guardava agora pesa em você."
			if ex != null and ex.bells.size() < 2:
				return "O Guardião não desperta enquanto as duas correntes prenderem os portões. Primeiro a Cisterna e o Campanário."
			return "Leia o corpo dele: braço recuado é varredura, agachar é salto, sino erguido é grito. Apare o que brilha em ouro com L, esquive o resto com K e fira quando ele se ajoelhar exausto."
		"altar":
			return "Ajoelhado aqui, E ora: salva, cura e enche os frascos, mas devolve os inimigos comuns. R oferece lágrimas por mais vida; V troca as penitências."
		"culpa":
			return "A culpa cresce quando você sofre e quando fere. Acima da metade, Q a converte em fogo sagrado. Ao morrer, suas lágrimas ficam num fragmento: volte a ele antes que o peso o enfraqueça."
		"cura":
			var flasks := "" if p == null else " Restam %d de %d frascos." % [int(p.flasks), int(p.max_flasks)]
			return "F bebe uma lágrima curativa; orar num altar enche os frascos de novo.%s Dizem que no Abrigo das Cinzas uma curandeira deixou um vaso que carrega mais uma." % flasks
		"beatriz":
			return "Beatriz luta por conta própria, mas não é invencível. H divide seu sangue com ela; se cair, chegue perto e segure H para erguê-la. Um segundo jogador pode guiá-la pelas setas e pelo teclado numérico."
		"morte":
			var deaths := 0 if game == null else int(game.death_count)
			if deaths == 0:
				return "Você ainda não caiu nesta jornada. Mesmo assim, ore nos altares que encontrar: o retorno é a sua condenação, mas também o seu recomeço."
			return "Já caiu %d vezes, e a cada queda volta ao último altar. Recupere o fragmento onde morreu, aprenda o aviso de cada golpe e prefira esquivar a trocar feridas. Agora: %s." % [deaths, objective.to_lower()]
		"inimigos":
			return "Cada criatura denuncia o golpe antes de desferi-lo. Faça a investida errar e golpeie pelas costas; o que brilha em ouro pode ser aparado com L, o resto se esquiva com K. Quem cambaleia pode ser executado com E."
		"historia":
			if game != null and game.memory_seen:
				return "Você viu suas próprias mãos nos portões. O porquê ainda não lhe pertence. Continue, peregrino: a verdade vem em lágrimas, uma de cada vez."
			return "Vespera chorou para esquecer o que fez, e a Ordem recolheu essas lágrimas sob a Grande Basílica. O que bebeu delas despertou no Grande Pranto. Quanto a você... há portões que lembram do seu nome melhor que você."
		"caminho":
			return "Os altares não esquecem o seu propósito: %s. TAB mostra a cartografia dos condenados." % objective.to_lower()
	return "O Confessor cala por um instante, e o ferro da grade esfria. Fale da sua jornada, peregrino. Por ora, o caminho é este: %s." % objective.to_lower()
