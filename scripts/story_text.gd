extends RefCounted
## Os textos do universo do jogo ficam aqui; as fontes literárias são documentadas fora do jogo.

const PICKUPS := {
	"doll": "Um pequeno sol foi bordado no pulso esquerdo.\nA costura foi refeita tantas vezes que atravessou o tecido.\n\nEntre os cobertores há espaço para alguém que não chegou.\nQuem a esperava não levou a boneca consigo.",
	"register": "Alba — oito invernos. Boneca: sol bordado no pulso esquerdo.\nJoana — tecelã. Tomé — sineiro.\nAo lado dos três nomes: aguardando.\n\nA página seguinte registra apenas o peso das lágrimas.\nIria talvez saiba quem ainda espera por esses nomes.",
	"vessel": "A última curandeira dividiu a água antes de contar os frascos.\n\nMisericórdia quero, e não sacrifício.\n\nO vaso ainda guarda espaço para uma lágrima curativa.\nCapacidade curativa aumentada em um frasco.",
	"witness": "O nicho guarda o número de um corpo que nunca foi entregue.\nA pedra está limpa de tanto ser tocada.\n\nNum pedaço de pano: voltarei amanhã.\nO pó volta à terra. A espera, não.",
}

static func pickup_text(id: String, fallback: String) -> String:
	return str(PICKUPS.get(id, fallback))

static func chain_line(id: String) -> String:
	if id == "water": return "A água baixa. Sob o sino, uma frase: ainda cabem mais dois."
	return "O bronze cede. No intervalo entre os sinos, você escuta alguém bater do outro lado."

static func iria_pages(has_register: bool, names_read: bool, honored: bool, named: bool, memory: bool) -> Array[Dictionary]:
	var pages: Array[Dictionary] = []
	if has_register and not names_read:
		pages.append({"title":"IRIA — OS NOMES", "text":"Você trouxe nomes, não desculpas.\n\nOs livros da Ordem pesavam as lágrimas.\nO que procura está escrito à margem. Leia."})
		pages.append({"title":"OS QUE ESPERARAM", "text":"Alba. Joana. Tomé.\n\nVocê lê os três nomes em voz baixa.\nIria espera até o último.\n\nPara você, eram linhas numa página.\nPara alguém, ainda são uma porta aberta."})
		if honored and not named:
			pages.append({"title":"IRIA — UM LUGAR PARA O NOME", "text":"O que deixou no memorial já tem um nome.\n\nVolte. Escreva-o onde ainda se possa ler.\nNão é a sua dor que ele precisa guardar."})
		elif not honored:
			pages.append({"title":"IRIA — A TESTEMUNHA", "text":"No pátio há um lugar para o que voltou sem dono.\n\nSe encontrou algo daquele abrigo, deixe-o ali.\nNão por você. Por quem continua faltando."})
		return pages
	if honored:
		var text := "Você deixou algo junto aos nomes.\n\nAinda há quem precise ser lembrado.\nMas não confunda esse gesto com perdão."
		if named: text = "Alba. Agora o nome pode ser lido.\n\nNão sei se alguém virá procurá-lo.\nMas não confunda esse gesto com perdão."
		pages.append({"title":"IRIA — A TESTEMUNHA", "text":text})
		if memory:
			pages.append({"title":"IRIA — DEPOIS DOS SINOS", "text":"Você escutou, enfim.\n\nNão me ofereça outra penitência.\nQuando encontrar uma porta fechada,\nlembre-se de ouvir antes de obedecer."})
		return pages
	if has_register and names_read:
		pages.append({"title":"IRIA — O NOME QUE ESPERA", "text":"Alba não deve voltar a ser um número.\n\nNo abrigo, ainda pode haver algo que lhe pertenceu.\nO memorial do pátio continua esperando."})
		if memory:
			pages.append({"title":"IRIA — DEPOIS DOS SINOS", "text":"Agora você sabe por que os sinos não bastavam.\n\nNão peça a uma lembrança que o liberte.\nEscute o que ela ainda lhe exige."})
		return pages
	if memory:
		return [{"title":"IRIA — DEPOIS DOS SINOS", "text":"Os sinos pararam. Você ainda espera uma sentença.\n\nHá gente que precisa de cuidado, Condenado.\nNem todos precisam da sua confissão."}]
	return [{"title":"IRIA — A TESTEMUNHA", "text":"Condenado... eu reconheceria sua voz.\n\nNão procure aquele que possa perdoá-lo.\nProcure primeiro aqueles que você condenou.\n\nChorai com os que choram.\nNos abrigos, ainda há coisas que esperam por seus donos."}]

static func memorial_text(known_name: bool) -> String:
	if known_name:
		return "O sol bordado e a marca no registro são iguais.\nVocê grava: Alba.\n\nA boneca fica entre as velas.\nO lugar continua vazio. Agora pode ser encontrado."
	return "Você deixa a boneca entre as velas.\nO nome na pedra já não pode ser lido.\n\nUm pequeno sol permanece visível no tecido.\nAinda há algo que você não sabe dizer."

static func memory_line(elapsed: float, knows_alba: bool) -> String:
	if elapsed < 10:
		return "Você lembra o peso do ferro. E as vozes.\nAbra. Ainda estamos aqui."
	if knows_alba:
		return "Alba não estava pedindo absolvição.\nSuas mãos fecharam os portões."
	return "Suas mãos fecham os portões.\nO silêncio não devolve quem ficou do outro lado."
