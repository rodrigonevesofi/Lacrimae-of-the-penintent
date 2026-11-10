extends RefCounted
## Textos das cenas de culpa. Separados de story_text.gd para evitar conflitos entre o trabalho narrativo e o das cenas.
## Nada aqui revela o ritual, o pedido de esquecimento ou a quem pertencem as vozes.

const ECHO := [
	"Longe, alguém bate.\nTrês vezes. Depois, nada.",
	"Uma voz pequena, do outro lado da pedra:\nabra.",
	"Ainda estamos aqui.",
]

const WHISPERS := [
	"O fragmento se desfaz. A batida continua em algum lugar.",
	"Você recolhe a culpa. Ela não pesa menos.",
	"Do outro lado, alguém ainda espera.",
]

const DEATH := [
	"A pedra guarda seu lugar.",
	"Você volta. Outros não voltaram.",
	"Mais uma vez, o silêncio responde.",
	"O fragmento espera onde você caiu.",
]

const MEMORY_CAPTIONS := [
	"Você lembra o peso do ferro.\nE as vozes.",
	"Uma mão pequena segura a grade.",
	"Atrás de você, uma figura espera.\nVocê não consegue ver o rosto.",
]

const BOSS_INTRO := [
	"O Guardião dos Sinos puxa uma corda que já não existe.",
	"\"Enquanto tocar, alguém virá abrir.\"",
]

const BOSS_END := [
	"A mão continua o gesto da corda por um instante.",
	"Não veio ninguém.",
]

static func echo_line(index: int) -> String:
	return ECHO[clampi(index, 0, ECHO.size() - 1)]

static func whisper(index: int) -> String:
	return WHISPERS[index % WHISPERS.size()]

static func death_line(count: int) -> String:
	return DEATH[count % DEATH.size()]
