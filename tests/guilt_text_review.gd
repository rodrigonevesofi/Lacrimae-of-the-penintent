extends SceneTree
var checked:=0
var failures:=0
func _initialize():call_deferred("run")
func examine(phrase: String, source: String, guilt: bool, expected_block: bool=false):
	checked+=1
	print("PHRASE [",source,"]: ",phrase.replace("\n"," / "))
	var rules=["lacrimae sacramentum","(implor|pedi|escolh|quis|decid).{0,40}(esquec|apagar.{0,15}mem[oó]ria)","(meu nome [eé]|me chamo|nome (verdadeiro |anterior )?do (penitente|protagonista) [eé])","(alba.{0,30}(filha|sobrinha|irm[aã]|neta).{0,20}iria|iria.{0,30}(m[aã]e|tia|irm[aã]|av[oó]).{0,20}alba)","alba.{0,35}(sobreviveu|est[aá] viva|n[aã]o morreu|continua viva|permanece viva|foi resgatada|foi salva)"]
	if guilt:rules.append("(voc[eê] (ser[aá]|est[aá]) perdoad|(receber[aá]|concedo|conceder[aá]|prometo|ter[aá]).{0,20}(perd[aã]o|cura|recompensa)|ganhar[aá]|vida.{0,15}restaurada|culpa.{0,15}apagada)")
	var blocked:=false
	for rule in rules:
		var regex:=RegEx.new()
		regex.compile("(?i)"+rule)
		if regex.search(phrase):
			blocked=true
	if blocked!=expected_block:
		push_error("Lexical expectation failed: "+phrase)
		failures+=1
func run():
	for fixture in ["Lacrimae Sacramentum", "Você pediu para esquecer.", "Meu nome é Fulano.", "Iria é mãe de Alba.", "Alba continua viva.", "Eu lhe concedo perdão.", "Você receberá uma recompensa."]:
		examine(fixture,"synthetic forbidden fixture",true,true)
	var constants: Dictionary=load("res://scripts/guilt_text.gd").get_script_constant_map()
	for key in constants:
		if constants[key] is Array:
			for phrase in constants[key]:examine(str(phrase),"guilt_text/"+str(key),true)
	# Aproximação conservadora por excesso da prosa citada na narrativa, incluindo ramificações.
	var source:=FileAccess.get_file_as_string("res://scripts/narrative.gd")
	var regex:=RegEx.new()
	regex.compile('"(?:[^"\\\\]|\\\\.)*"')
	for match_string in regex.search_all(source):
		var phrase: String=match_string.get_string().substr(1,match_string.get_string().length()-2).c_unescape()
		if phrase.contains(" ") and not phrase.begins_with("res://"):
			# A interface de oração descreve a cura explicitamente; não é uma promessa da cena de culpa.
			examine(phrase,"narrative literal",not phrase.begins_with("Ao concluir:"))
	print("GUILT_TEXT_REVIEW: ",checked," phrases; ",failures," failures. Lexical coverage only; unknown proper name and paraphrases require editorial review.")
	quit(0 if failures==0 else 1)
