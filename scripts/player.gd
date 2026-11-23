extends CharacterBody2D
## O Penitente das Lágrimas (jogador)

const RastroGolpe = preload("res://scripts/rastro_golpe.gd")
const Gore = preload("res://scripts/gore.gd")
const Efeitos = preload("res://scripts/efeitos.gd")

signal died

const SPEED := 280.0
const GRAVITY := 1800.0
const JUMP_V := -620.0
const DJUMP_V := -560.0
const ROLL_SPEED := 540.0
const ROLL_TIME := 0.34
const ATTACK_TIME := 0.36
const COMBO_DURATIONS := [0.30, 0.32, 0.34, 0.50]
## Os quatro golpes da sequência: corte, contracorte, estocada e o arremate descendente.
const COMBO_TIPOS := ["corte", "contracorte", "estocada", "descendente"]
const COMBO_DANO := [20.0, 24.0, 28.0, 40.0]
const INVESTIDA_TIME := 0.28
const ASCENDENTE_TIME := 0.42
## Soltar o golpe pesado antes disso faz o corte ascendente; segurar, o golpe carregado.
const TOQUE_PESADO := 0.18
const PRECE_CUSTO := 25.0
const AIR_ATTACKS_MAX := 2
## Aparo tardio: apertar o aparo logo depois de ser atingido por um golpe aparável ainda vale.
const PERDAO_APARO := 0.12
const INPUT_BUFFER := 0.22
const AIR_ATTACK_TIME := 0.48
const AIR_RECOVERY_TIME := 0.16
const MAX_FALL := 950.0

# Nós montados em scenes/player.tscn (edite-os pelo editor do Godot).
@onready var animator = $Animator
@onready var sword: Sprite2D = $Sword
# Ponto do cabo (na textura) que fica dentro do punho fechado: logo atrás da guarda, que encosta no punho.
const SWORD_GRIP := Vector2(545, 362)
const SWORD_SCALE := 0.042
## Posição do punho em cada desenho de hero_motion.png (coordenadas da célula de 256 x 256), medida quadro a quadro.
## A empunhadura ocupa esse ponto para a mão fechar no cabo, em vez de ficar solta ao lado.
const IDLE_GRIPS := [Vector2(177,159),Vector2(184,157),Vector2(183,154),Vector2(185,147),Vector2(180,156),Vector2(181,158)]
const RUN_GRIPS := [Vector2(210,116),Vector2(202,133),Vector2(209,122),Vector2(222,98),Vector2(196,143),Vector2(200,141)]
var penitence := "none"
var execution_target = null
var execution_contact := false
var execution_zoom_start := Vector2.ONE
const EXECUTION_TIME := 1.15
var execution_length := EXECUTION_TIME
var execution_wound_at := 0.42
var execution_kill_at := 0.66
var cinematic_focus := false
var ritual_clip := "pray"
var ritual_progress := 0.0
var hit_pause := 0.0
var parry_cd := 0.0
var prev_vy := 0.0
var parry_hit := false
var counter_t := 0.0
var counter_attack := false
const PERFECT_DODGE_WINDOW := 0.15
var perfect_dodge_used := false
var perfect_dodges := 0
var air_chain := 0
var execution_wound := false
## Combate: sequência de quatro golpes com arremate no quarto, corte ascendente, golpe pesado carregado, investida,
## dois golpes no ar, ataque descendente e Lâmina de Sangue.
const HEAVY_STRIKE_TIME := 0.32
const HEAVY_FULL := 0.9
var combo_step := 0
var combo_window := 0.0
var finisher := false
var heavy_t := 0.0
var heavy_done := false
var heavy_len := HEAVY_STRIKE_TIME
var parry_buffer := 0.0
var heavy_buffer := 0.0
var swing_effect := false
var input_release_gate := false
var roll_direction := 0.0
var parry_direction := 0.0
var camera_focus_x := 0.0
var plunge_landed := false
var golpe_tipo := "corte"
## Execução: aproximação da câmera e câmera lenta mudam com o jeito de matar.
const EXECUCAO_ZOOM := {"cabeca": 1.75, "vertical": 1.45, "cintura": 1.55, "erguer": 1.6, "coracao": 1.9, "cranio": 1.5}
const EXECUCAO_LENTO := {"cabeca": [0.18, 0.5], "vertical": [0.3, 0.32], "cintura": [0.22, 0.4], "erguer": [0.3, 0.45], "coracao": [0.35, 0.65], "cranio": [0.15, 0.3]}
var execucao_zoom := 1.5
## Depois de uma execução, a armadura fica manchada de sangue e limpa aos poucos.
var ensanguentado := 0.0
var perdao_t := 0.0
var perdao_dano := 0.0
var perdao_de := 0.0
var perdao_quem = null
var roll_fim_t := 0.0
var fantasma_t := 0.0
var prece_cd := 0.0
var bloqueios := 0
var air_attacks := 0
var investida_hits := 0
var ascendente_salto := false
## Modo de desenvolvimento (F3): atravessa paredes e evita dano para apresentar as salas.
## Dois penitentes carregam o mesmo fardo: o Penitente e Beatriz. No modo solo, T troca quem está em cena;
## cada um tem sua vida e, perto da morte, o outro pode sangrar para salvá-lo (H).
const CHARACTERS := {
	"penitente": {"name": "PENITENTE", "speed": 1.0, "reach": 1.0, "damage": 1.0, "attack_time": 1.0, "tint": Color(1, 1, 1)},
	"beatriz": {"name": "BEATRIZ", "speed": 0.92, "reach": 1.6, "damage": 1.2, "attack_time": 1.15, "tint": Color(0.86, 0.74, 0.96)},
}
var character := "penitente"
var partner_hp := 100.0
## A lança de Beatriz pesa mais a cada pecado purgado (contrapasso): fica lenta e forte, até ela orar.
var lance_weight := 0.0
var swap_cd := 0.0
var share_cd := 0.0
var attack_len := ATTACK_TIME
@onready var lance: Node2D = $Lance
## Os dois penitentes caminham juntos. O jogo controla Beatriz até o segundo jogador usar um
## dos comandos dela (prefixo "p2_"). Quem cai ainda pode receber sangue do parceiro para se levantar.
var is_partner := false
var prefix := ""
var ai := false
var ai_held := {}
var ai_tap := {}
var ai_axis := 0.0
var ai_attack_cd := 0.0
## v43: Beatriz no automático também varia os golpes (corte ascendente, investida e Lâmina de Sangue).
var ai_golpes := 0
var ai_prece_cd := 0.0
var ai_pesado_pendente := false
var revive_t := 0.0
signal fell
var dev_fly := false
var dev_god := false
const BLOOD_DECALS_MAX := 14
## Mancha vermelha nas bordas da tela no golpe mortal de uma execução (desenhada pelo HUD).
var gore_flash := 0.0
var parries := 0
const PARRY_TIME := 0.52
const PARRY_WINDOW := 0.36
var jump_elapsed := 0.0
var landing_t := 0.0
var was_grounded := true
var appearance: AtlasTexture
var blood_tears := 0.0
var footstep_t := 0.0
var attack_buffer := 0.0
var roll_buffer := 0.0
var damage_flash := 0.0
var has_weapon := false
var max_hp := 100.0
var maldicao_parcas := 0.0
var maldicao_parceira := 0.0
var hp := 100.0
var culpa := 0.0
var lagrimas := 0
var upgrades := 0
## Progressão (v43): força comprada no altar e relíquias achadas pelo caminho.
var forca := 0           # cada nível: +10% de dano
var frascos_extra := 0   # frascos comprados no altar
var calices := 0         # Cálice de Sangue: +12 de vida máxima cada
var espinhos := 0        # Espinho da Ira: +8% de dano cada
var max_flasks := 3
var flasks := 3
var has_double_jump := false
var facing := 1
var controllable := true
var state := "idle"
var state_t := 0.0
var invuln := 0.0
var coyote := 0.0
var jump_buffer := 0.0
var air_jumps := 0
var air_attack_used := false
var aerial_after_cut := false
var combo := 0
var hit_list: Array = []
var anim_t := 0.0
var pray_duration := 1.0
var penance_fx := 0.0
var safe_pos := Vector2.ZERO
var shake := 0.0
var impact_direction := Vector2.ZERO
var roll_cd := 0.0
@onready var camera: Camera2D = $Camera2D
@onready var light: PointLight2D = $Light


## A estrutura do jogador (espada, lança provisória de Beatriz, colisão, luz, câmera, grupos e camadas
## de colisão) fica em scenes/player.tscn. A ordem dos filhos importa: a espada vem antes do Animator,
## atrás do corpo, para o punho fechado ficar por cima do cabo. Crie o jogador com
## preload("res://scenes/player.tscn").instantiate(), nunca com player.gd.new().
func _ready() -> void:
	appearance = AtlasTexture.new()
	appearance.atlas = load("res://assets/characters.png")
	appearance.region = Rect2(0, 0, 384, 1000)
	appearance.filter_clip = true
	# Os quadros vêm de assets/animation/clips.json; por isso o animador é configurado aqui, não na cena.
	animator.configure("hero", 0.44)
	animator.select("idle_desarmado", facing)
	# SWORD_GRIP também é usado para posicionar a arma provisória.
	sword.offset = -SWORD_GRIP
	# Acompanha o desenho assim que muda: o punho se desloca até 30 pixels entre quadros de corrida.
	animator.frame_changed.connect(_update_sword)
	animator.frame_changed.connect(_passo_no_quadro)
	animator.animation_changed.connect(_update_sword)
	# A câmera do Penitente enquadra o mundo; a câmera da parceira fica desligada.
	if is_partner: camera.enabled = false
	safe_pos = global_position


# ---------- entrada ----------
func pressed(a: String) -> bool:
	if not controllable: return false
	if ai: return bool(ai_tap.get(a, false))
	return InputMap.has_action(prefix + a) and Input.is_action_just_pressed(prefix + a)

func held(a: String) -> bool:
	if ai: return bool(ai_held.get(a, false))
	return InputMap.has_action(prefix + a) and Input.is_action_pressed(prefix + a)


func released(a: String) -> bool:
	if ai: return false
	return controllable and InputMap.has_action(prefix + a) and Input.is_action_just_released(prefix + a)


func axis() -> float:
	if not controllable:
		return 0.0
	if ai: return ai_axis
	return Input.get_axis(prefix + "left", prefix + "right")


func body_rect() -> Rect2:
	return Rect2(global_position + Vector2(-11, -56), Vector2(22, 56))


# ---------- física / estados ----------
func _physics_process(delta: float) -> void:
	# A mancha dura meio segundo real, inclusive durante execução e pausa de impacto.
	gore_flash = maxf(gore_flash - delta / maxf(Engine.time_scale, 0.01), 0.0)
	if is_partner:
		var director = get_tree().get_first_node_in_group("game")
		if director != null and (director.state != "play" or director.narrative.mode != "" or director.exploration.is_transitioning() or director.message_text != "" or director.dev_mode or director.exploration.map_open or director.penitence_menu):
			_clear_combat_input()
			input_release_gate = true
			velocity = Vector2.ZERO
			animator.select(_locomotion_clip(false), facing)
			return
	if ai:
		_ai_think(delta)
	if state == "fallen":
		_clear_combat_input()
		velocity.x = move_toward(velocity.x, 0.0, 900.0 * delta)
		velocity.y = minf(velocity.y + 1800.0 * delta, 900.0)
		move_and_slide()
		animator.select("death", facing, 0.999)
		return
	if standing() and held("share_blood"):
		var other = partner()
		if other != null and other.state == "fallen" and global_position.distance_to(other.global_position) < 110.0:
			revive_t += delta
			if revive_t >= 1.0:
				revive_t = 0.0
				_raise(other)
		else:
			revive_t = 0.0
	else:
		revive_t = 0.0
	var game = get_tree().get_first_node_in_group("game")
	var blocked: bool = not controllable or cinematic_focus or (game != null and (game.state != "play" or game.message_text != "" or game.narrative.mode != "" or game.penitence_menu or (game.exploration != null and (game.exploration.map_open or game.exploration.is_transitioning()))))
	if blocked or state in ["dead", "execution", "pray"]:
		_clear_combat_input()
		input_release_gate = true
	else:
		_capture_combat_input()
	if dev_fly:
		var fly := Vector2(axis(), (1.0 if held("down") else 0.0) - (1.0 if held("jump") else 0.0))
		global_position += fly * 900.0 * delta
		velocity = Vector2.ZERO
		if dev_god: hp = max_hp
		return
	# Lê os comandos de acionamento antes da pausa de impacto; a entrada armazenada persiste durante a pausa.
	if hit_pause > 0:
		# A pausa congela a ação, mas preserva o comando que acabou de chegar.
		hit_pause = maxf(hit_pause - delta, 0.0)
		return
	anim_t += delta
	blood_tears = maxf(blood_tears - delta, 0.0)
	invuln = maxf(invuln - delta, 0.0)
	state_t -= delta
	penance_fx = maxf(penance_fx - delta, 0.0)
	shake = maxf(shake - delta * 30.0, 0.0)
	roll_cd = maxf(roll_cd - delta, 0.0)
	if camera and not cinematic_focus:
		var amplitude := 0.0 if game != null and game.reduced_pulses else shake
		camera.offset = Vector2(camera_focus_x, -110) + Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * amplitude + impact_direction * amplitude * 0.5

	if game != null and game.exploration != null and game.exploration.is_transitioning():
		velocity = Vector2.ZERO
		return

	if state == "dead":
		velocity.x = move_toward(velocity.x, 0.0, 1500.0 * delta)
		velocity.y = minf(velocity.y + GRAVITY * delta, MAX_FALL)
		move_and_slide()
		return

	if game != null and (game.message_text != "" or game.narrative.mode != "" or game.penitence_menu or game.exploration.map_open):
		velocity.x = 0.0
		velocity.y = minf(velocity.y + GRAVITY * delta, MAX_FALL)
		move_and_slide()
		return

	if state == "execution":
		velocity = Vector2.ZERO
		var progress := 1.0 - state_t / execution_length
		camera.zoom = execution_zoom_start.lerp(execution_zoom_start * execucao_zoom, sin(clampf(progress, 0, 1) * PI))
		if is_instance_valid(execution_target):
			execution_target.execution_progress = clampf(progress, 0, 1)
			if progress >= execution_wound_at and not execution_wound:
				# Primeiro ferimento: a lâmina penetra o corpo.
				execution_wound = true
				# Quando ferimento e golpe mortal coincidem, usa apenas o jato final.
				if execution_wound_at < execution_kill_at:
					get_tree().call_group("game", "play_sfx", "hit_carne")
					get_tree().call_group("game", "play_sfx", "carne_rasga")
					var wound := _execution_torso()
					# O primeiro ferimento é contido; o leque grande de sangue fica para o golpe mortal de cada estilo.
					_blood_burst(wound, 0.8, 30)
					get_tree().call_group("game", "blood_splats", execution_target.global_position, facing, 5, 0.9)
					hit_pause = maxf(hit_pause, 0.06)
					shake = maxf(shake, 4.0)
			if progress >= execution_kill_at and not execution_contact:
				execution_contact = true
				var torso := _execution_torso()
				var ground := Vector2(execution_target.global_position.x, execution_target.global_position.y)
				execution_target._die()
				hp = minf(hp + 8, max_hp)
				add_culpa(12)
				shake = 5
				hit_pause = 0.1
				get_tree().call_group("game", "play_sfx", "hit_carne")
				get_tree().call_group("game", "play_sfx", "execucao")
				get_tree().call_group("game", "play_sfx", "execucao_impacto")
				get_tree().call_group("game", "play_sfx", "osso_quebra")
				# Golpe mortal: um jato arterial em pulsos, névoa de sangue, gotas que caem e se espalham
				# pelo chão, uma poça larga e a borda da tela manchada de vermelho.
				hit_pause = 0.16
				shake = 10
				# Cada criatura morre de um jeito: o corte, o jorro e o corpo recortado mudam (scripts/gore.gd).
				var estilo := Gore.estilo_de(execution_target.kind)
				_assinatura_execucao(estilo, torso, execution_target)
				get_tree().call_group("game", "blood_splats", ground, facing, 14, 1.4)
				_blood_decal(ground)
				gore_flash = 0.5
				_blood_tear()
				Gore.finalizar(game, execution_target, estilo, facing, self, global_position.y)
				var lento: Array = EXECUCAO_LENTO.get(estilo, [0.25, 0.3])
				_slow_motion(lento[0], lento[1])
				gore_flash = 0.7
				ensanguentado = 1.0
				add_weight(12.0)
		if state_t <= 0:
			if is_instance_valid(execution_target): execution_target.executing = false
			get_tree().call_group("game", "play_sfx", "lamina_sai")
			execution_target = null
			camera.zoom = execution_zoom_start
			state = "idle"
		return

	var on_floor := is_on_floor()
	var just_landed := on_floor and not was_grounded
	if just_landed and prev_vy > 430.0:
		get_tree().call_group("game", "play_sfx", "aterrissagem")
		get_tree().call_group("game", "spawn_effect", "dust", global_position + Vector2(0.0, -4.0), 1, 0.45)
	landing_t = maxf(landing_t - delta, 0.0)
	if not on_floor:
		jump_elapsed += delta
	elif not was_grounded:
		landing_t = 0.10
	was_grounded = on_floor
	if on_floor:
		air_attack_used = false
		air_attacks = 0
		air_chain = 0
		if just_landed and aerial_after_cut and state == "idle":
			state = "air_recover"
			state_t = AIR_RECOVERY_TIME
		elif state not in ["air_attack","air_recover"]:
			aerial_after_cut = false
		coyote = 0.1
		air_jumps = 0
		safe_pos = global_position
	else:
		coyote -= delta
	jump_buffer -= delta
	if not input_release_gate and pressed("jump") and held("down") and is_on_floor() and can_drop():
		position.y += 28
		velocity.y = 120
		jump_buffer = 0

	velocity.y = minf(velocity.y + GRAVITY * delta, MAX_FALL)
	attack_buffer = maxf(attack_buffer - delta, 0.0)
	roll_buffer = maxf(roll_buffer - delta, 0.0)
	parry_buffer = maxf(parry_buffer - delta, 0.0)
	heavy_buffer = maxf(heavy_buffer - delta, 0.0)
	parry_cd = maxf(parry_cd - delta, 0.0)
	perdao_t = maxf(perdao_t - delta, 0.0)
	roll_fim_t = maxf(roll_fim_t - delta, 0.0)
	prece_cd = maxf(prece_cd - delta, 0.0)
	counter_t = maxf(counter_t - delta, 0.0)
	combo_window = maxf(combo_window - delta, 0.0)
	swap_cd = maxf(swap_cd - delta, 0.0)
	share_cd = maxf(share_cd - delta, 0.0)
	damage_flash = maxf(damage_flash - delta, 0.0)
	var dir := axis()

	match state:
		"idle":
			velocity.x = move_toward(velocity.x, dir * speed(), 2600.0 * delta)
			if dir != 0.0:
				facing = 1 if dir > 0.0 else -1
			if jump_buffer > 0.0 and coyote > 0.0:
				get_tree().call_group("game", "play_sfx", "jump")
				jump_elapsed = 0.0
				velocity.y = JUMP_V
				jump_buffer = 0.0
				coyote = 0.0
				get_tree().call_group("game", "spawn_fx", global_position, Color(0.8, 0.8, 0.9))
			elif pressed("jump") and not on_floor and coyote <= 0.0 and has_double_jump and air_jumps < 1:
				jump_elapsed = 0.0
				velocity.y = DJUMP_V
				air_jumps += 1
				get_tree().call_group("game", "spawn_fx", global_position + Vector2(0, -6), Color(1.0, 0.85, 0.5))
			if released("jump") and not pressed("jump") and velocity.y < -250.0:
				velocity.y *= 0.55
			if _buffered_defense(on_floor):
				pass
			elif heavy_buffer > 0.0 and has_weapon and on_floor:
				_start_charge()
			elif attack_buffer > 0.0 and has_weapon and roll_fim_t > 0.0 and on_floor:
				_start_investida()
			elif attack_buffer > 0.0 and has_weapon:
				_start_attack()
			elif pressed("prece") and has_weapon and not (game != null and game.at_altar()):
				_lancar_prece()
			elif pressed("swap") and partner() == null:
				swap_character()
			elif pressed("share_blood"):
				share_blood()
			elif pressed("heal"):
				_start_heal()
			elif pressed("penance"):
				_do_penance()
		"attack":
			if not on_floor:
				velocity.x = move_toward(velocity.x, dir * speed() * 0.7, 1800.0 * delta)
			else:
				velocity.x = move_toward(velocity.x, facing * 60.0, 2400.0 * delta)
			var p := 1.0 - state_t / attack_len
			var contact_frame := clampi(int(p * 6), 0, 5)
			if contact_frame in [2, 3]:
				_swing_trail()
				_attack_hits()
			# Esquiva desde o primeiro quadro ativo; aparo ainda exige recuperação.
			if p >= 2.0 / 6.0 and _buffered_roll():
				pass
			elif p >= 0.60 and _buffered_defense(on_floor):
				pass
			elif p >= 0.70 and _jump_from_recovery(on_floor):
				pass
			elif p >= 0.76 and heavy_buffer > 0.0 and on_floor:
				_start_charge()
			elif attack_buffer > 0.0 and has_weapon and p >= 0.76:
				_start_attack()
			elif state_t <= 0.0:
				state = "idle"
		"charge":
			velocity.x = move_toward(velocity.x, dir * speed() * 0.22, 1800.0 * delta)
			if heavy_t < 0.25 and dir != 0.0: facing = 1 if dir > 0.0 else -1
			var was_full := heavy_t >= HEAVY_FULL
			heavy_t += delta
			if heavy_t >= HEAVY_FULL and not was_full:
				# Carga completa: confirmação sonora e barra preenchida.
				# A barra cheia e o som confirmam a carga sem repetir o sinal visual de aparo.
				get_tree().call_group("game", "play_sfx", "ui_confirmar")
			if _buffered_defense(on_floor):
				pass
			elif _jump_from_recovery(on_floor):
				pass
			elif not held("heavy") or heavy_t > 2.5:
				if heavy_t < TOQUE_PESADO: _start_ascendente()
				else: _start_heavy()
		"heavy":
			velocity.x = move_toward(velocity.x, facing * 40.0, 2400.0 * delta)
			if not heavy_done and state_t <= heavy_len * 0.7:
				heavy_done = true
				_heavy_hits()
			if state_t <= heavy_len * 0.7 and _buffered_roll():
				pass
			elif state_t <= heavy_len * 0.32 and _buffered_defense(on_floor):
				pass
			elif state_t <= 0.0:
				state = "idle"
		"plunge":
			velocity.x = 0.0
			velocity.y = 950.0
			if _buffered_roll():
				pass
			elif on_floor and not plunge_landed:
				plunge_landed = true
				_plunge_impact()
				state = "air_recover"
				state_t = AIR_RECOVERY_TIME
		"air_attack":
			velocity.x = move_toward(velocity.x, dir * speed() * 0.85, 1200.0 * delta)
			var progress := 1.0 - state_t / AIR_ATTACK_TIME
			if on_floor:
				state = "air_recover"
				state_t = AIR_RECOVERY_TIME
			elif clampi(int(progress * 12),0,11) in [5,6,7]:
				_swing_trail()
				_attack_hits(true)
			if state == "air_attack" and progress >= 5.0 / 12.0 and _buffered_roll():
				pass
			elif state == "air_attack" and progress >= 0.55 and attack_buffer > 0.0 and air_attacks < AIR_ATTACKS_MAX:
				air_attack_used = false
				_start_air_attack()
			elif state == "air_attack" and state_t <= 0:
				state = "idle"
		"air_recover":
			velocity.x = move_toward(velocity.x,0,2100.0*delta)
			if _buffered_defense(on_floor):
				pass
			elif attack_buffer > 0.0 and has_weapon and state_t <= AIR_RECOVERY_TIME * 0.5:
				_start_attack()
			elif state_t <= 0:
				state = "idle"
				aerial_after_cut = false
		"parry":
			velocity.x = move_toward(velocity.x, 0.0, 3200.0 * delta)
			if parry_hit and attack_buffer > 0.0:
				_start_attack()
			elif state_t <= 0.0:
				state = "idle"
				parry_cd = 0.25
		"roll":
			velocity.x = facing * ROLL_SPEED
			if attack_buffer > 0.0 and has_weapon and on_floor and ROLL_TIME - state_t > 0.10:
				_start_investida()
			elif state_t <= 0.0:
				state = "idle"
				roll_fim_t = 0.16
				velocity.x = facing * speed() * 0.6
		"investida":
			var k := clampf(state_t / INVESTIDA_TIME, 0.0, 1.0)
			velocity.x = facing * lerpf(120.0, 720.0, sqrt(k))
			fantasma_t -= delta
			if fantasma_t <= 0.0:
				fantasma_t = 0.035
				_fantasma(Color(1.0, 0.35, 0.28, 0.55))
			_investida_hits()
			if state_t <= INVESTIDA_TIME * 0.35 and _buffered_roll():
				pass
			elif state_t <= 0.0:
				state = "idle"
				velocity.x = facing * 140.0
		"ascendente":
			var pa := 1.0 - state_t / maxf(ASCENDENTE_TIME * attack_scale(), 0.01)
			velocity.x = move_toward(velocity.x, facing * 40.0, 2400.0 * delta)
			if pa >= 0.28 and pa <= 0.62:
				_swing_trail()
				_ascendente_hits()
			if pa >= 0.45 and not ascendente_salto and on_floor:
				# Um pequeno salto acompanha o corte: dá para seguir com os golpes no ar.
				ascendente_salto = true
				velocity.y = -360.0
			if pa >= 0.62 and attack_buffer > 0.0 and not on_floor:
				_start_air_attack()
			elif pa >= 0.62 and _buffered_roll():
				pass
			elif state_t <= 0.0:
				state = "idle"
		"prece":
			velocity.x = move_toward(velocity.x, 0.0, 2400.0 * delta)
			if state_t <= 0.0:
				state = "idle"
		"hurt":
			velocity.x = move_toward(velocity.x, 0.0, 900.0 * delta)
			if state_t <= 0.0:
				state = "idle"
		"heal":
			velocity.x = move_toward(velocity.x, 0.0, 2400.0 * delta)
			if state_t <= 0.0:
				get_tree().call_group("game", "play_sfx", "heal")
				flasks -= 1
				hp = minf(hp + 45.0, max_hp)
				state = "idle"
				get_tree().call_group("game", "spawn_fx", global_position + Vector2(0, -40), Color(0.6, 0.85, 1.0))
		"pray":
			velocity.x = 0.0
			if state_t <= 0.0:
				state = "idle"

	prev_vy = velocity.y
	move_and_slide()
	footstep_t -= delta
	# Correndo, o passo toca no quadro em que o pé encosta no chão (_passo_no_quadro); o relógio fica para
	# os outros casos, como andar empurrado ou animações sem quadros de corrida.
	if is_on_floor() and absf(velocity.x) > 40 and state == "idle" and footstep_t <= 0 and animator.animation not in ["run", "run_desarmado"]:
		get_tree().call_group("game", "play_sfx", "step")
		footstep_t = 0.28

	var fall_limit: float = game.exploration.rooms[game.exploration.room].bounds.end.y + 50 if game != null else 880.0
	if global_position.y > fall_limit:
		_fell()


func _process(_delta: float) -> void:
	_update_animation()
	_update_sword()
	queue_redraw()

func _update_animation() -> void:
	var tint: Color = CHARACTERS[character].tint if animator.actor == "hero" else Color.WHITE
	if ensanguentado > 0.0:
		ensanguentado = maxf(ensanguentado - get_process_delta_time() / 18.0, 0.0)
		tint = tint.lerp(Color(0.86, 0.5, 0.46), ensanguentado * 0.3)
	if invuln > 0 and not cinematic_focus and state not in ["roll", "dead", "execution"]:
		tint.a = 0.6 if int(anim_t * 18) % 2 else 1.0
	animator.modulate = tint
	if cinematic_focus:
		animator.select(ritual_clip, facing, ritual_progress)
		return
	if state == "fallen":
		animator.select("death", facing, 0.999)
		return
	if revive_t > 0.0 and state == "idle" and animator.actor == "beatriz":
		animator.select("raise", facing, minf(revive_t, 0.999))
		return
	match state:
		"execution": animator.select(_execution_clip(), facing, 1 - state_t / execution_length)
		"air_attack":
			var pa := 1.0 - state_t / AIR_ATTACK_TIME
			if golpe_tipo == "aereo2" and _tem_clipe("golpe_aereo2"): animator.select("golpe_aereo2", facing, clampf(pa, 0.0, 0.999))
			else: animator.select("air_attack", facing, pa)
		"air_recover": animator.select("air_land",facing,1-state_t/AIR_RECOVERY_TIME)
		"attack":
			var pg := clampf(1 - state_t / attack_len, 0.0, 0.999)
			if counter_attack: animator.select("strong_counter", facing, pg)
			elif golpe_tipo != "corte" and _tem_clipe("golpe_" + golpe_tipo): animator.select("golpe_" + golpe_tipo, facing, pg)
			else:
				match golpe_tipo:
					"contracorte": animator.select("attack_b", facing, pg)
					"estocada": animator.select("strong_counter", facing, pg)
					"descendente": animator.select("charged_heavy", facing, 0.5 + pg * 0.499)
					_: animator.select("attack_a", facing, pg)
		"investida":
			var pi := clampf(1.0 - state_t / INVESTIDA_TIME, 0.0, 0.999)
			if _tem_clipe("golpe_investida"): animator.select("golpe_investida", facing, pi)
			else: animator.select("strong_counter", facing, 0.15 + pi * 0.6)
		"ascendente":
			var pu := clampf(1.0 - state_t / maxf(ASCENDENTE_TIME * attack_scale(), 0.01), 0.0, 0.999)
			animator.select("golpe_ascendente" if _tem_clipe("golpe_ascendente") else "attack_b", facing, pu)
		"prece":
			var pp := clampf(1.0 - state_t / 0.34, 0.0, 0.999)
			if _tem_clipe("golpe_prece"): animator.select("golpe_prece", facing, pp)
			else: animator.select("strong_counter", facing, pp * 0.6)
		"charge": animator.select("charged_heavy", facing, minf(heavy_t / HEAVY_FULL, 1.0) * 3.99 / 6.0)
		"heavy": animator.select("charged_heavy", facing, (4.0 + clampf(1.0 - state_t / heavy_len, 0.0, 1.0) * 1.99) / 6.0)
		"plunge": animator.select("air_attack", facing, 0.55)
		"roll": animator.select("roll", facing, 1 - state_t / ROLL_TIME)
		"parry": animator.select("parry_recoil" if parry_hit else "parry", facing, clampf(1.0 - state_t / (0.3 if parry_hit else PARRY_TIME), 0.0, 0.999))
		"hurt": animator.select("hurt", facing, 1 - state_t / 0.25)
		"dead": animator.select("death", facing, 1 - state_t / 0.70)
		"heal": animator.select("heal", facing, 1 - state_t / 0.55)
		"pray": animator.select("pray", facing, 1 - state_t / pray_duration)
		_:
			if not is_on_floor() and aerial_after_cut:
				animator.select("air_drift",facing)
			elif not is_on_floor():
				var index := (0 if jump_elapsed < 0.06 else 1) if velocity.y < -120 else (2 if velocity.y < 80 else 3)
				animator.pose("air_drift" if has_weapon else "jump", facing, index)
			elif landing_t > 0:
				animator.pose("air_land" if has_weapon else "jump", facing, 4 if landing_t > 0.05 else 5)
			elif animator.actor == "beatriz" and absf(velocity.x) <= 30.0:
				# Três faixas de peso: 0–33, 34–66 e 67–100.
				var weight_pose := 0 if lance_weight < 34.0 else (1 if lance_weight < 67.0 else 2)
				animator.pose("idle_weight", facing, weight_pose)
			else:
				animator.select(_locomotion_clip(absf(velocity.x) > 30), facing)


func _locomotion_clip(running: bool) -> String:
	var clip := "run" if running else "idle"
	if animator.actor == "hero" and (not has_weapon or character != "penitente"):
		return clip + "_desarmado"
	return clip


# ---------- ações ----------
func _start_attack() -> void:
	if not has_weapon:
		return
	if not is_on_floor() and held("down"):
		_start_plunge()
		return
	if not is_on_floor() or velocity.y < -100.0:
		_start_air_attack()
		return
	var d := axis()
	if d != 0.0:
		facing = 1 if d > 0.0 else -1
	get_tree().call_group("game", "play_sfx", "lanca_estocada" if character == "beatriz" else "swing")
	attack_buffer = 0.0
	# Sequência de três: o terceiro golpe dentro do intervalo é o arremate.
	combo_step = (combo_step + 1) % COMBO_DURATIONS.size() if combo_window > 0.0 else 0
	finisher = combo_step == COMBO_DURATIONS.size() - 1
	golpe_tipo = COMBO_TIPOS[combo_step]
	combo_window = float(COMBO_DURATIONS[combo_step]) * attack_scale() + 0.30
	velocity.x = facing * [125.0, 140.0, 240.0, 200.0][combo_step]
	state = "attack"
	counter_attack = counter_t > 0.0
	counter_t = 0.0
	attack_len = float(COMBO_DURATIONS[combo_step]) * attack_scale()
	state_t = attack_len
	combo = 1 if combo_step == 0 else 0
	swing_effect = false
	hit_list.clear()


func _attack_hits(aerial: bool = false) -> void:
	var width := 86.0 * float(CHARACTERS[character].reach)
	if golpe_tipo == "estocada": width *= 1.4
	elif golpe_tipo == "descendente": width *= 1.15
	var r := Rect2(global_position + Vector2(6.0 if facing > 0 else -(6.0 + width), -66.0), Vector2(width, 66.0))
	if golpe_tipo == "descendente": r = Rect2(r.position + Vector2(0, -24), r.size + Vector2(0, 24))
	if aerial:
		var air_width := 92.0 * float(CHARACTERS[character].reach)
		r = Rect2(global_position + Vector2(8.0 if facing > 0 else -(8.0 + air_width),-108.0),Vector2(air_width,82.0))
	for e in get_tree().get_nodes_in_group("enemies"):
		if e.dead or hit_list.has(e):
			continue
		if r.intersects(e.hurt_rect()) and _clear_strike(e):
			# Guarda o material antes de o golpe quebrar a proteção.
			var impact_kind := _impact_kind(e)
			# Bronze e armadura ressoam; a carne cede.
			get_tree().call_group("game", "play_sfx", "hit_carne" if impact_kind == "sangue" else "hit_metal")
			hit_list.append(e)
			var dmg := (38.0 if counter_attack else (22.0 if aerial else float(COMBO_DANO[clampi(combo_step, 0, 3)]))) * sword_multiplier()
			e.last_hitter = self
			var airborne: bool = e.state == "launched"
			e.take_hit(dmg, global_position.x)
			if aerial and airborne and not e.dead and e.juggle_hits < 3:
				e.juggle_hits += 1
				e.suspend_t = 0.10
				e.velocity.y = -110.0
				e.state = "launched"
				air_chain += 1
				if air_chain < 3: air_attack_used = false
			if finisher and not aerial:
				get_tree().call_group("game", "play_sfx", "arremate")
				_launch(e, 360.0, -220.0)
				if e.dead:
					_slow_motion(0.3, 0.16)
					_desmembrar_morto(e, "vertical" if golpe_tipo == "descendente" else "cintura")
			elif counter_attack and e.dead:
				_desmembrar_morto(e, "cabeca")
			# Cada golpe tem peso: pausa no impacto, pausa maior ao matar, faíscas e sangue.
			var stop := 0.085 if e.dead else (0.065 if finisher or counter_attack else 0.045)
			hit_pause = maxf(hit_pause, stop)
			e.hit_pause = maxf(e.hit_pause, stop)
			add_culpa(3)
			shake = maxf(shake, 6.0 if e.dead else 4.0)
			var spot: Vector2 = e.global_position + Vector2(-float(facing) * 14.0, -e.body_size.y * 0.55)
			# Grandes efeitos pintados: arco da lâmina, estrela no contato, sangue e poça ao matar.
			get_tree().call_group("game", "spawn_effect", "star", spot, facing, 0.5, "golpe")
			# Cada material reage de um jeito: faíscas na armadura, lascas na pedra e sangue na carne.
			get_tree().call_group("game", "spawn_effect", impact_kind, spot + Vector2(float(facing) * 8.0, 4.0), facing, 0.42 if e.dead else 0.34, "impactos")
			if impact_kind == "sangue":
				get_tree().call_group("game", "play_sfx", "carne_rasga")
				# A carne sangra a cada corte: um jato curto e gotas que caem no chão.
				_blood_burst(spot, 0.75 if e.dead else 0.45, 26 if e.dead else 12)
				get_tree().call_group("game", "blood_splats", Vector2(e.global_position.x, e.global_position.y), facing, 6 if e.dead else 2, 1.0 if e.dead else 0.6)
			if e.dead and e.family != "flyer":
				get_tree().call_group("game", "spawn_effect", "pool", Vector2(e.global_position.x, e.global_position.y - 52.0), facing, 0.75, "golpe")


func _start_roll() -> void:
	var d := axis()
	if d == 0.0 and roll_buffer > 0.0: d = roll_direction
	if d != 0.0:
		facing = 1 if d > 0.0 else -1
	get_tree().call_group("game", "play_sfx", "roll")
	_clear_combat_input()
	combo_window = 0.0
	state = "roll"
	state_t = ROLL_TIME
	perfect_dodge_used = false
	invuln = ROLL_TIME
	roll_cd = ROLL_TIME + (0.65 if penitence == "chains" else 0.0)
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if enemy.has_method("imminent_hit") and enemy.imminent_hit(self, PERFECT_DODGE_WINDOW):
			_perfect_dodge()
			break
	if not perfect_dodge_used:
		for hazard in get_tree().get_nodes_in_group("hazards"):
			if hazard.has_method("imminent_hit") and hazard.imminent_hit(self, PERFECT_DODGE_WINDOW):
				_perfect_dodge()
				break

func _perfect_dodge() -> void:
	if perfect_dodge_used: return
	perfect_dodge_used = true
	perfect_dodges += 1
	counter_t = 0.8
	_slow_motion(0.35, 0.3)
	get_tree().call_group("game", "play_sfx", "esquiva_perfeita")
	get_tree().call_group("game", "spawn_effect", "silhueta", global_position + Vector2(-facing * 34, -45), facing, 0.5, "golpe", Color(0.72,0.76,0.85,0.28))


func _start_heal() -> void:
	if flasks > 0 and hp < max_hp and is_on_floor():
		state = "heal"
		state_t = 0.55


func _do_penance() -> void:
	if culpa < 50.0:
		get_tree().call_group("game", "toast", "A culpa ainda é leve demais (precisa de 50%).")
		return
	blood_tears = 3.5
	var used := culpa
	culpa = 0.0
	penance_fx = 0.5
	state = "pray"
	pray_duration = 0.45
	state_t = pray_duration
	invuln = 0.5
	shake = 9.0
	var dmg := (36.0 + used * 0.5) * (1.55 if penitence == "chains" else 1.0)
	for e in get_tree().get_nodes_in_group("enemies"):
		if e.dead:
			continue
		var d: float = e.global_position.distance_to(global_position)
		if d < 300.0:
			e.take_hit(dmg, global_position.x)


func pray(restore: bool = true, duration: float = 1.0) -> void:
	if restore:
		remover_maldicao()
		hp = max_hp
		flasks = max_flasks
	state = "pray"
	pray_duration = duration
	state_t = pray_duration
	velocity = Vector2.ZERO


## Defesa temporizada: nos primeiros instantes do aparo, um golpe leve frontal é desviado e o atacante fica exposto.
## Agarrões pesados, investidas e projéteis não podem ser aparados; é preciso esquivar.
func _start_parry() -> void:
	var direction := axis()
	if direction == 0.0 and parry_buffer > 0.0: direction = parry_direction
	_clear_combat_input()
	combo_window = 0.0
	if direction != 0.0: facing = 1 if direction > 0.0 else -1
	state = "parry"
	parry_hit = false
	state_t = PARRY_TIME
	velocity.x = 0.0
	get_tree().call_group("game", "play_sfx", "swing")

func _parry_success(attacker, from_x: float) -> void:
	parries += 1
	parry_hit = true
	# O próximo golpe dentro de um breve intervalo será o contra-ataque forte.
	counter_t = 0.9
	invuln = 0.5
	hit_pause = 0.12
	shake = maxf(shake, 5.0)
	state_t = 0.3
	get_tree().call_group("game", "play_sfx", "hit")
	get_tree().call_group("game", "play_sfx", "aparo")
	get_tree().call_group("game", "spawn_effect", "parry", global_position + Vector2(facing * 46.0, -54.0), facing, 0.7)
	get_tree().call_group("game", "spawn_effect", "faiscas", global_position + Vector2(facing * 46.0, -54.0), facing, 0.55, "impactos")
	get_tree().call_group("game", "clarao", Color(1.0, 0.93, 0.7, 0.35), 0.12)
	_slow_motion(0.3, 0.16)
	if attacker != null and is_instance_valid(attacker) and attacker.has_method("parried"):
		attacker.parried()
	if parries == 1:
		get_tree().call_group("game", "toast", "Aparo! O inimigo está aberto: golpeie (dano maior) ou execute com E.")

func take_hit(dmg: float, from_x: float, attacker = null, parryable: bool = false) -> void:
	impact_direction = Vector2(signf(global_position.x-from_x),-0.25)
	if dev_god:
		return
	if state == "roll" and ROLL_TIME - state_t <= PERFECT_DODGE_WINDOW and attacker != null:
		_perfect_dodge()
	if state == "parry" and parryable and (from_x - global_position.x) * float(facing) >= -10.0:
		if state_t > PARRY_TIME - PARRY_WINDOW:
			_parry_success(attacker, from_x)
		else:
			_bloqueio(dmg, from_x)
		return
	if state == "dead" or invuln > 0.0 or cinematic_focus or state == "execution":
		return
	get_tree().call_group("game", "play_sfx", "hurt")
	_clear_combat_input()
	combo_window = 0.0
	damage_flash = 0.25
	if parryable and attacker != null and (from_x - global_position.x) * float(facing) >= -10.0 and has_weapon:
		perdao_t = PERDAO_APARO
		perdao_dano = dmg
		perdao_de = from_x
		perdao_quem = attacker
	hp -= dmg
	add_culpa(dmg * 0.6)
	invuln = 0.8
	var kd := signf(global_position.x - from_x)
	if kd == 0.0:
		kd = 1.0
	velocity = Vector2(kd * 260.0, -240.0)
	state = "hurt"
	state_t = 0.25
	shake = maxf(shake, 6.0)
	get_tree().call_group("game", "spawn_fx", global_position + Vector2(0, -30), Color(0.9, 0.15, 0.15))
	if hp <= 0.0:
		die()


func partner() -> Node:
	for other in get_tree().get_nodes_in_group("players"):
		if other != self and is_instance_valid(other): return other
	return null

func standing() -> bool:
	return state != "dead" and state != "fallen"

func die() -> void:
	if state == "dead" or state == "fallen":
		return
	var other = partner()
	if other != null and other.standing():
		# Ainda não morreu: permanece no chão até receber sangue do parceiro.
		get_tree().call_group("game", "play_sfx", "hurt")
		get_tree().call_group("game", "play_sfx", "caido")
		state = "fallen"
		hp = 0.0
		velocity = Vector2(-facing * 80.0, -160.0)
		invuln = 1.0
		fell.emit()
		get_tree().call_group("game", "toast", "%s caiu. Chegue perto e segure H para dar sangue." % str(CHARACTERS[character].name).capitalize())
		return
	if other != null and other.state == "fallen":
		# Os dois caíram: a penitência termina para ambos.
		other.state = "dead"
		other.hp = 0.0
	get_tree().call_group("game", "play_sfx", "death")
	state = "dead"
	state_t = 0.70
	hp = 0.0
	velocity = Vector2(-facing * 120.0, -300.0)
	died.emit()


func _fell() -> void:
	hp -= 25.0
	add_culpa(15)
	global_position = safe_pos + Vector2(-facing * 50.0, 0.0)
	velocity = Vector2.ZERO
	invuln = 1.2
	if hp <= 0.0:
		die()


func revive(pos: Vector2) -> void:
	if state == "execution" and camera: camera.zoom = execution_zoom_start
	execution_target = null
	execution_contact = false
	execution_wound = false
	_clear_combat_input()
	input_release_gate = false
	combo_step = 0
	combo_window = 0.0
	finisher = false
	counter_attack = false
	perfect_dodge_used = false
	air_chain = 0
	counter_t = 0.0
	parry_cd = 0.0
	roll_cd = 0.0
	swing_effect = false
	air_attack_used = false
	aerial_after_cut = false
	hit_pause = 0.0
	attack_buffer = 0.0
	roll_buffer = 0.0
	damage_flash = 0.0
	state = "idle"
	hp = max_hp
	flasks = max_flasks
	invuln = 1.0
	velocity = Vector2.ZERO
	global_position = pos
	safe_pos = pos
	controllable = true


# ---------- visual (representação provisória desenhada por código) ----------
func _draw() -> void:
	draw_ellipse_shadow()
	if state == "dead":
		return
	draw_set_transform(Vector2.ZERO, 0, Vector2(float(facing), 1))
	if state == "execution" and animator.actor == "hero" and _execution_clip() == "execute_devotee" and is_instance_valid(execution_target) and execution_target.humanoid():
		var progress := 1 - state_t / execution_length
		if progress > 0.18 and progress < 0.7:
			var wrist := Vector2(32, -58 + maxf(progress - 0.35, 0) * 75)
			var neck: Vector2 = (execution_target.global_position - global_position) * Vector2(facing, 1) + Vector2(0, -execution_target.body_size.y * 0.78)
			for i in range(8):
				var knot := wrist.lerp(neck, i / 7.0) + Vector2(0, sin(i / 7.0 * PI) * 5)
				draw_circle(knot, 1.1, Color("bc9762"))
	if blood_tears > 0 and not cinematic_focus:
		for i in range(2):
			var eye := Vector2(4 + i * 3, -77)
			draw_line(eye, eye + Vector2(0, 9), Color("7d1723"), 1.7)
			var fall := fmod(anim_t * 25 + i * 17, 50)
			draw_circle(eye + Vector2(1, 8 + fall), 1.8, Color(0.65, 0.025, 0.05, 1 - fall / 65))
	draw_set_transform(Vector2.ZERO, 0, Vector2.ONE)
	if penance_fx > 0:
		var progress := (0.5 - penance_fx) / 0.5
		draw_arc(Vector2(0, -30), 30 + progress * 270, 0, TAU, 48, Color(1, 0.8, 0.35, penance_fx * 2), 5)
	if state == "charge":
		var amount := clampf(heavy_t / HEAVY_FULL, 0.0, 1.0)
		draw_rect(Rect2(-20, -118, 40, 4), Color(0.08, 0.06, 0.06, 0.9))
		draw_rect(Rect2(-20, -118, 40 * amount, 4), Color("e7c17b") if amount >= 1.0 else Color("ae8059"))

func draw_ellipse_shadow() -> void:
	if is_on_floor() and state != "dead":
		draw_set_transform(Vector2(0, -1), 0, Vector2(1, 0.2))
		draw_circle(Vector2.ZERO, 21, Color(0, 0, 0, 0.36))
		draw_set_transform(Vector2.ZERO, 0, Vector2.ONE)


func culpa_capacity() -> float:
	var game = get_tree().get_first_node_in_group("game")
	return 75.0 if game != null and game.stain_active else 100.0

func add_culpa(amount: float) -> void:
	culpa = clampf(culpa + amount, 0, culpa_capacity())

func sword_multiplier() -> float:
	var m := 1.4 if penitence == "nails" else 1.0
	m *= float(CHARACTERS[character].damage)
	m *= 1.0 + 0.10 * forca + 0.08 * espinhos
	if character == "beatriz":
		m *= 1.0 + lance_weight * 0.006
	return m

func speed() -> float:
	return SPEED * float(CHARACTERS[character].speed)

func attack_scale() -> float:
	var s := float(CHARACTERS[character].attack_time)
	if character == "beatriz":
		s *= 1.0 + lance_weight * 0.004
	return s

func add_weight(amount: float) -> void:
	if character == "beatriz":
		lance_weight = clampf(lance_weight + amount, 0.0, 100.0)

## T: o outro penitente assume o fardo; cada um mantém sua própria vida.
func swap_character() -> bool:
	if swap_cd > 0.0 or state != "idle" or not is_on_floor() or cinematic_focus or partner_hp <= 0.0:
		return false
	var keep := hp
	hp = minf(partner_hp, max_hp)
	partner_hp = keep
	character = "beatriz" if character == "penitente" else "penitente"
	apply_character()
	swap_cd = 0.8
	get_tree().call_group("game", "spawn_effect", "dust", global_position + Vector2(0.0, -30.0), facing, 0.9)
	get_tree().call_group("game", "play_sfx", "ui_confirmar")
	get_tree().call_group("game", "toast", ("Beatriz ergue a lança." if character == "beatriz" else "O Penitente retoma a espada."))
	return true

## H: perto da morte, o outro doa parte da vida para salvar quem está em cena; a penitência é compartilhada.
func share_blood() -> bool:
	if share_cd > 0.0 or hp > max_hp * 0.25 or partner_hp <= max_hp * 0.30 or state == "dead":
		return false
	var given := minf(max_hp * 0.35, partner_hp - 1.0)
	partner_hp -= given
	hp = minf(max_hp, hp + given)
	share_cd = 6.0
	get_tree().call_group("game", "spawn_effect", "blood", global_position + Vector2(0.0, -60.0), facing, 0.8)
	get_tree().call_group("game", "play_sfx", "heal")
	get_tree().call_group("game", "toast", "Sangue compartilhado: %s sangra para salvar quem caminha." % ("o Penitente" if character == "beatriz" else "Beatriz"))
	return true

func apply_character() -> void:
	# Usa os desenhos próprios de Beatriz quando as folhas estão disponíveis.
	var own_art: bool = ResourceLoader.exists("res://assets/animation/beatriz_movimento.png") and ResourceLoader.exists("res://assets/animation/beatriz_combate.png")
	if character == "beatriz" and own_art:
		animator.configure("beatriz", 0.44)
		animator.modulate = Color.WHITE
	else:
		if animator.actor != "hero": animator.configure("hero", 0.44)
		animator.modulate = CHARACTERS[character].tint
	if lance != null:
		lance.visible = false
	_update_sword()

func apply_penitence(id: String) -> void:
	penitence = id if id in ["none", "nails", "chains"] else "none"
	max_hp = maxf(30.0,(100.0 + upgrades * 15.0 + calices * 12.0) * (0.7 if penitence == "nails" else 1.0)-maldicao_parcas)
	hp = minf(hp, max_hp)

func begin_execution(target) -> bool:
	# O carregador de caixão só pode ser executado depois que a pedra quebrar.
	if target != null and is_instance_valid(target) and target.kind == 8 and not target.exposed:
		return false
	if state != "idle" or not has_weapon or not is_on_floor() or not is_instance_valid(target): return false
	if target.dead or target.kind == 2 or target.kind == 9 or target.state != "stagger" or target.executing: return false
	if absf(target.position.x - position.x) > 72 or absf(target.position.y - position.y) > (170 if target.family == "flyer" else 80): return false
	execution_zoom_start = camera.zoom
	execucao_zoom = float(EXECUCAO_ZOOM.get(Gore.estilo_de(target.kind), 1.5))
	execution_target = target
	execution_contact = false
	execution_wound = false
	state = "execution"
	get_tree().call_group("game", "play_sfx", "execucao")
	var clip_data: Dictionary = animator.definitions.get(_execution_clip(), {})
	execution_length = float(clip_data.get("duration", EXECUTION_TIME))
	var frames_count := maxf(float(clip_data.get("count", 12)), 1.0)
	execution_wound_at = float(clip_data.wound_frame) / frames_count if clip_data.has("wound_frame") else 0.42
	execution_kill_at = float(clip_data.kill_frame) / frames_count if clip_data.has("kill_frame") else 0.66
	state_t = execution_length
	facing = 1 if target.position.x >= position.x else -1
	target.executing = true
	# Um voador atordoado desce ao nível do penitente para alinhar a animação conjunta com o chão.
	if target.family == "flyer": target.position.y = position.y
	target.execution_progress = 0
	target.velocity = Vector2.ZERO
	target.facing = -facing
	velocity = Vector2.ZERO
	invuln = execution_length + 0.1
	attack_buffer = 0
	roll_buffer = 0
	return true

func _start_charge() -> void:
	_clear_combat_input()
	combo_window = 0.0
	# Reserva o bônus ao começar a carga; completar os 0,9 s não deve perdê-lo.
	counter_attack = counter_t > 0.0
	counter_t = 0.0
	get_tree().call_group("game", "play_sfx", "golpe_carregado_carga")
	state = "charge"
	heavy_t = 0.0
	velocity.x = 0.0

func _start_heavy() -> void:
	counter_attack = (state == "charge" and counter_attack) or counter_t > 0.0
	counter_t = 0.0
	state = "heavy"
	heavy_len = HEAVY_STRIKE_TIME * attack_scale()
	state_t = heavy_len
	heavy_done = false
	hit_list.clear()
	velocity.x = facing * 220.0
	get_tree().call_group("game", "play_sfx", "swing")
	get_tree().call_group("game", "play_sfx", "golpe_carregado_solta")

func _start_plunge() -> void:
	counter_attack = counter_t > 0.0
	counter_t = 0.0
	state = "plunge"
	plunge_landed = false
	hit_list.clear()
	attack_buffer = 0.0
	velocity = Vector2(0.0, 950.0)
	get_tree().call_group("game", "play_sfx", "swing")

## Armadura solta faíscas, o caixão solta pedra e os demais corpos sangram.
func _impact_kind(e) -> String:
	if e.kind == 2 or e.kind == 3 or e.kind == 9:
		return "faiscas"
	if e.kind == 8 and not e.exposed:
		return "pedra"
	return "sangue"

func _room_is(id: String) -> bool:
	var director = get_tree().get_first_node_in_group("game")
	return director != null and director.exploration.room == id

## Arremessa a criatura para trás e, se caminha, para cima.
func _launch(e, push: float, lift: float) -> void:
	if not is_instance_valid(e) or e.dead or e.kind == 2 or e.kind == 9:
		return
	if e.state == "stagger":
		# Não apaga a abertura de execução que o próprio golpe acabou de criar.
		e.velocity = Vector2.ZERO
		return
	if character == "beatriz" and not (e.kind == 8 and not e.exposed):
		# A lança empala e mantém a criatura no lugar.
		get_tree().call_group("game", "play_sfx", "empalar")
		e.state = "stagger"
		e.state_t = 1.2
		e.impaled_t = 1.2
		e.velocity = Vector2.ZERO
		return
	if e.kind == 8 and not e.exposed:
		return
	e.state = "launched"
	e.launch_elapsed = 0.0
	e.juggle_hits = 0
	e.suspend_t = 0.0
	e.poise = e.POISE.get(e.kind, 40.0)
	e.velocity = Vector2(float(facing) * push, lift if e.family == "walker" else lift * 0.5)

## Breve câmera lenta nos golpes mais fortes para dar peso ao impacto.
func _slow_motion(scale: float, seconds: float) -> void:
	var game = get_tree().get_first_node_in_group("game")
	if (game != null and game.reduced_pulses) or Engine.time_scale < 0.99:
		return
	Engine.time_scale = scale
	get_tree().create_timer(seconds, true, false, true).timeout.connect(func(): Engine.time_scale = 1.0)

func _heavy_hits() -> void:
	var full := heavy_t >= HEAVY_FULL
	if full:
		get_tree().call_group("game", "spawn_effect", "anel", global_position + Vector2(facing * 65.0, 0), facing, 0.65, "onda_golpe")
	var long := 134.0 * float(CHARACTERS[character].reach)
	var reach := Rect2(global_position + Vector2(0.0 if facing > 0 else -long, -94.0), Vector2(long, 94.0))
	get_tree().call_group("game", "spawn_effect", "arc", global_position + Vector2(facing * 70.0, -56.0), facing, 0.95, "golpe")
	var landed := false
	for e in get_tree().get_nodes_in_group("enemies"):
		if e.dead or hit_list.has(e) or not reach.intersects(e.hurt_rect()) or not _clear_strike(e):
			continue
		hit_list.append(e)
		landed = true
		var impact_kind := _impact_kind(e)
		var dmg := lerpf(28.0, 62.4, clampf(heavy_t / HEAVY_FULL, 0.0, 1.0)) * sword_multiplier() * (1.5 if counter_attack else 1.0)
		e.last_hitter = self
		e.take_hit(dmg, global_position.x)
		if full and e.kind == 8 and not e.exposed: e._break_coffin()
		if e.dead and full: _desmembrar_morto(e, "cintura")
		_launch(e, 440.0 if full else 230.0, -300.0 if full else -130.0)
		e.hit_pause = maxf(e.hit_pause, 0.085)
		var spot: Vector2 = e.global_position + Vector2(0.0, -e.body_size.y * 0.55)
		get_tree().call_group("game", "spawn_effect", "star", spot, facing, 0.75, "golpe")
		get_tree().call_group("game", "spawn_effect", impact_kind, spot, facing, 0.5, "impactos")
		if e.dead and e.family != "flyer":
			get_tree().call_group("game", "spawn_effect", "pool", Vector2(e.global_position.x, e.global_position.y - 52.0), facing, 0.6, "golpe")
	if landed:
		get_tree().call_group("game", "play_sfx", "hit_carne")
		get_tree().call_group("game", "play_sfx", "chefe_pancada")
		shake = maxf(shake, 10.0)
		hit_pause = 0.085
		add_culpa(5)
		_slow_motion(0.5, 0.09)

func _plunge_impact() -> void:
	shake = maxf(shake, 8.0)
	get_tree().call_group("game", "spawn_effect", "poeira", global_position, facing, 0.85, "onda_golpe")
	var floor_kind := "osso" if _room_is("ossuary") else "pedra"
	get_tree().call_group("game", "spawn_effect", floor_kind, global_position + Vector2(0.0, -20.0), facing, 0.45, "impactos")
	get_tree().call_group("game", "play_sfx", "mergulho_impacto")
	get_tree().call_group("game", "play_sfx", "chefe_pancada")
	for e in get_tree().get_nodes_in_group("enemies"):
		if e.dead: continue
		var d: Vector2 = e.global_position - global_position
		if absf(d.x) < 130.0 and absf(d.y) < 70.0 and _clear_strike(e):
			e.last_hitter = self
			e.take_hit((45.0 if counter_attack else 30.0) * sword_multiplier(), global_position.x)
			if e.dead: _desmembrar_morto(e, "cranio")
			var away := 1 if d.x >= 0.0 else -1
			var keep := facing
			facing = away
			_launch(e, 280.0, -260.0)
			facing = keep

## Sangue compartilhado: doa parte da própria vida para levantar quem caiu.
func _raise(other) -> void:
	var given := minf(max_hp * 0.35, hp - 1.0)
	if given < 5.0:
		get_tree().call_group("game", "toast", "Não há sangue bastante para dar.")
		return
	hp -= given
	other.hp = given
	other.state = "idle"
	other.state_t = 0.0
	other.invuln = 1.5
	get_tree().call_group("game", "spawn_effect", "blood", other.global_position + Vector2(0.0, -40.0), facing, 0.8)
	get_tree().call_group("game", "play_sfx", "heal")
	get_tree().call_group("game", "play_sfx", "sangue_compartilhado")
	get_tree().call_group("game", "play_sfx", "levanta")
	get_tree().call_group("game", "toast", "Sangue compartilhado: %s se levanta." % str(other.CHARACTERS[other.character].name).capitalize())

## O jogo controla Beatriz até o segundo jogador assumir: ela segue, luta, apara e levanta o Penitente.
func _ai_think(delta: float) -> void:
	ai_tap.clear()
	ai_held.clear()
	ai_axis = 0.0
	ai_attack_cd = maxf(ai_attack_cd - delta, 0.0)
	ai_prece_cd = maxf(ai_prece_cd - delta, 0.0)
	var lead = partner()
	if lead == null or not standing():
		return
	if lead.state == "fallen":
		var gap: float = lead.global_position.x - global_position.x
		if absf(gap) > 60.0: ai_axis = signf(gap)
		else: ai_held["share_blood"] = true
		return
	var foe = null
	var best := 99999.0
	for e in get_tree().get_nodes_in_group("enemies"):
		if e.dead or e.spawn_opacity < 1.0: continue
		var d: float = e.global_position.distance_to(lead.global_position)
		if d < 560.0 and absf(e.global_position.y - global_position.y) < 170.0 and d < best:
			best = d
			foe = e
	if foe != null:
		var dx: float = foe.global_position.x - global_position.x
		var reach := 96.0 * float(CHARACTERS[character].reach)
		if absf(dx) > reach * 0.85:
			ai_axis = signf(dx)
			# De longe, com culpa bastante, lança a Lâmina de Sangue.
			if ai_prece_cd <= 0.0 and culpa >= PRECE_CUSTO * 2.0 and absf(dx) < 460.0 and is_on_floor():
				facing = 1 if dx > 0.0 else -1
				ai_tap["prece"] = true
				ai_prece_cd = 5.0
		else:
			facing = 1 if dx > 0.0 else -1
			if foe.state in ["windup", "strike_wind", "alt_windup"] and foe.state_t < 0.22:
				if foe.attack_parryable and parry_cd <= 0.0: ai_tap["parry"] = true
				elif roll_cd <= 0.0:
					ai_tap["roll"] = true
					ai_axis = -signf(dx)
			elif foe.state == "stagger" and is_on_floor():
				ai_tap["interact"] = true
				ai_tap["attack"] = true
			elif roll_fim_t > 0.0 and is_on_floor():
				# Saindo da esquiva, emenda a investida.
				ai_tap["attack"] = true
			elif ai_attack_cd <= 0.0:
				ai_golpes += 1
				if ai_golpes % 5 == 4: ai_pesado_pendente = true
				if ai_pesado_pendente and is_on_floor():
					ai_tap["heavy"] = true
					ai_pesado_pendente = false
				else: ai_tap["attack"] = true
				ai_attack_cd = 0.5
	else:
		var gap: float = lead.global_position.x - global_position.x
		if absf(gap) > 150.0: ai_axis = signf(gap)
		if lead.global_position.y < global_position.y - 90.0 and absf(gap) < 280.0 and is_on_floor():
			ai_tap["jump"] = true
		if hp < max_hp * 0.3 and flasks > 0:
			ai_tap["heal"] = true
	if is_on_wall() and absf(ai_axis) > 0.0 and is_on_floor():
		ai_tap["jump"] = true

## Quadros desenhados para os golpes novos (golpe_contracorte, golpe_estocada, golpe_descendente, golpe_investida,
## golpe_ascendente, golpe_aereo2, golpe_prece). Enquanto não existem em clips.json, os golpes usam quadros antigos.
func _tem_clipe(nome: String) -> bool:
	return animator != null and animator.definitions.has(nome)

## Cada criatura usa sua execução própria quando a animação correspondente existe ("execute_<actor>");
## enquanto isso, usa a execução compartilhada de humanoides ou do Chorão.
func _execution_clip() -> String:
	if is_instance_valid(execution_target):
		var own := "execute_" + str(execution_target.TYPES[execution_target.kind].actor)
		if animator.sprite_frames != null and animator.sprite_frames.has_animation(own):
			return own
		return "execute_devotee" if execution_target.humanoid() else "execute_mourner"
	return "execute_devotee"

func _execution_torso() -> Vector2:
	if is_instance_valid(execution_target):
		return execution_target.global_position + Vector2(0.0, -execution_target.body_size.y * 0.55)
	return global_position + Vector2(facing * 45, -42)

func _blood_burst(at: Vector2, size: float, drops: int, direcao := Vector2.ZERO, abertura := 46.0) -> void:
	get_tree().call_group("game", "play_sfx", "sangue_jato")
	get_tree().call_group("game", "wall_splat", at)
	var game = get_tree().get_first_node_in_group("game")
	if game == null: return
	if direcao == Vector2.ZERO:
		game.spawn_effect("blood", at, facing, size)
		game.spawn_effect("blood", at + Vector2(float(facing) * 18.0, -8.0), facing, size * 0.75)
	else:
		# Jorro com direção (execuções): a mancha redonda fica pequena para a direção do sangue aparecer.
		game.spawn_effect("blood", at, facing, size * 0.45)
	# Gotas arredondadas de sangue escuro (scenes/efeitos/sangue_jato.tscn); aqui só o que depende do golpe.
	var spray: CPUParticles2D = Efeitos.SANGUE_JATO.instantiate()
	spray.amount = maxi(drops, 1)
	spray.direction = Vector2(float(facing), -0.7) if direcao == Vector2.ZERO else direcao
	spray.spread = abertura
	spray.initial_velocity_max = 640.0 * clampf(size, 0.6, 1.6)
	spray.scale_amount_max = 1.0 + 0.5 * clampf(size, 0.0, 1.6)
	spray.position = at
	game.add_child(spray)
	spray.emitting = true
	get_tree().create_timer(2.0).timeout.connect(spray.queue_free)
	if size >= 1.4:
		# Golpe mortal: pedaços de carne arrancados, que giram no ar e caem pesados.
		var chunks: CPUParticles2D = Efeitos.SANGUE_PEDACOS.instantiate()
		chunks.direction = Vector2(float(facing), -1.0)
		chunks.position = at
		game.add_child(chunks)
		chunks.emitting = true
		get_tree().create_timer(1.8).timeout.connect(chunks.queue_free)
	if size >= 0.7:
		# Névoa fina que fica no ar um instante depois de um corte profundo.
		var mist: CPUParticles2D = Efeitos.SANGUE_NEVOA.instantiate()
		mist.amount = int(drops * 0.8)
		mist.direction = Vector2(float(facing), -0.3)
		mist.position = at
		game.add_child(mist)
		mist.emitting = true
		get_tree().create_timer(1.2).timeout.connect(mist.queue_free)

## O Penitente chora sangue, sem entender por quê: depois de cada execução, e sempre que a culpa transborda,
## uma lágrima vermelha escorre da fenda do capacete. (No Vale se descobre de quem é a culpa.)
func _blood_tear() -> void:
	if character != "penitente": return
	var tear: CPUParticles2D = Efeitos.LAGRIMA_SANGUE.instantiate()
	tear.position = Vector2(float(facing) * 7.0, -84.0)
	add_child(tear)
	tear.emitting = true
	get_tree().create_timer(2.2).timeout.connect(tear.queue_free)

## O jato arterial: pulsos de sangue que saem da ferida em sequência, como um coração que ainda bate.
func _arterial_spray(at: Vector2, pulses: int, direcao := Vector2.ZERO, abertura := 46.0) -> void:
	for k in range(pulses):
		var delay := 0.11 * k
		var strength := 1.0 - 0.18 * k
		get_tree().create_timer(delay, true, false, true).timeout.connect(func():
			if not is_inside_tree(): return
			# O desenho do jato arterial aponta sempre para cima e para a frente; nos jorros com direção própria
			# (cada estilo de execução) ele ficaria igual em todos, então só as gotas mostram o sentido.
			if direcao == Vector2.ZERO:
				get_tree().call_group("game", "spawn_effect", "pulse", at, facing, 0.9 * strength, "jato_arterial")
				_blood_burst(at + Vector2(0.0, -4.0 * k), 0.9 * strength, int(34 * strength))
			else:
				_blood_burst(at + Vector2(0.0, -4.0 * k), 1.1 * strength, int(48 * strength), direcao, abertura)
			get_tree().call_group("game", "play_sfx", "sangue_jato")
			get_tree().call_group("game", "blood_splats", Vector2(at.x, global_position.y), facing, 3, 1.0)
		)

## O instante do golpe mortal, diferente em cada estilo: a forma do corte e a direção do sangue
## dizem, antes dos pedaços caírem, o que aconteceu com o corpo.
func _assinatura_execucao(estilo: String, torso: Vector2, alvo) -> void:
	var altura: float = alvo.body_size.y if is_instance_valid(alvo) else 120.0
	var pe: Vector2 = alvo.global_position if is_instance_valid(alvo) else global_position
	var pescoco := pe + Vector2(0.0, -altura * 0.86)
	var cintura := pe + Vector2(0.0, -altura * 0.48)
	var peito := pe + Vector2(0.0, -altura * 0.68)
	var lado := float(facing)
	match estilo:
		"cabeca":
			# Corte horizontal no pescoço e uma fonte de sangue que sobe em pulsos.
			_corte_execucao("contracorte", pescoco, 1.5)
			_blood_burst(pescoco, 1.2, 50, Vector2(0.12 * lado, -1.0), 14.0)
			_arterial_spray(pescoco, 5, Vector2(0.08 * lado, -1.0), 10.0)
		"vertical":
			# Uma linha de cima a baixo e o sangue abrindo para os dois lados.
			_corte_execucao("descendente", peito + Vector2(0.0, -10.0), 1.7)
			_blood_burst(cintura, 1.3, 60, Vector2(-1.0, -0.35), 22.0)
			_blood_burst(cintura, 1.3, 60, Vector2(1.0, -0.35), 22.0)
			_arterial_spray(peito, 3, Vector2(0.0, -1.0), 40.0)
		"cintura":
			# Um talho reto na cintura; o sangue sai deitado, para a frente, e escorre.
			_corte_execucao("corte", cintura, 1.6)
			_blood_burst(cintura, 1.4, 80, Vector2(lado, -0.08), 16.0)
			_arterial_spray(cintura, 3, Vector2(lado, 0.15), 24.0)
			get_tree().call_group("game", "spawn_effect", "sangue", cintura, facing, 0.8, "impactos")
		"erguer":
			# A lâmina sobe pelo corpo e o sangue desce por ela.
			_corte_execucao("ascendente", peito, 1.6)
			_blood_burst(peito, 1.0, 40, Vector2(0.0, 1.0), 26.0)
			_arterial_spray(peito + Vector2(lado * 14.0, 0.0), 6, Vector2(-0.15 * lado, 1.0), 14.0)
		"coracao":
			# Uma estocada no peito; o sangue sai pelas costas.
			_corte_execucao("estocada", peito, 1.4)
			_blood_burst(peito + Vector2(lado * 20.0, 0.0), 1.1, 60, Vector2(lado, -0.3), 30.0)
			_arterial_spray(peito, 2, Vector2(lado, -0.2), 30.0)
		"cranio":
			# Golpe de cima que esmaga: impacto, osso e sangue espirrando para baixo e para os lados.
			_corte_execucao("descendente", pescoco + Vector2(0.0, -20.0), 1.9)
			get_tree().call_group("game", "spawn_effect", "star", pescoco, facing, 0.8, "golpe")
			get_tree().call_group("game", "spawn_effect", "osso", pescoco, facing, 0.9, "impactos")
			_blood_burst(pescoco, 1.6, 90, Vector2(0.0, 0.4), 120.0)
			shake = 16
		_:
			_blood_burst(torso, 1.6, 90)
			_arterial_spray(torso, 4)
			get_tree().call_group("game", "spawn_effect", "sangue", torso, facing, 0.7, "impactos")

## Rastro grande do golpe que executa, com a forma do estilo.
func _corte_execucao(tipo: String, onde: Vector2, tamanho: float) -> void:
	var game = get_tree().get_first_node_in_group("game")
	if game == null: return
	var rastro = RastroGolpe.new()
	rastro.tipo = tipo
	rastro.lado = facing
	rastro.lanca = character == "beatriz"
	rastro.forte = true
	rastro.position = onde
	rastro.scale = Vector2.ONE * tamanho
	game.add_child(rastro)

func _blood_decal(ground: Vector2) -> void:
	var game = get_tree().get_first_node_in_group("game")
	if game == null: return
	var old := get_tree().get_nodes_in_group("blood_decals")
	while old.size() >= BLOOD_DECALS_MAX:
		# Retira da contagem imediatamente; o nó é removido no fim do quadro.
		var oldest = old.pop_front()
		oldest.remove_from_group("blood_decals")
		oldest.queue_free()
	var pool: Sprite2D = Efeitos.MANCHA_CHAO.instantiate()
	pool.texture.region = Rect2(randi_range(4, 7) * 128, 0, 128, 64)
	pool.scale = Vector2(2.1, 0.75)
	pool.flip_h = facing < 0
	var query := PhysicsRayQueryParameters2D.create(ground - Vector2(0, 4), ground + Vector2(0, 1200), 1)
	var floor_hit := get_world_2d().direct_space_state.intersect_ray(query)
	if not floor_hit.is_empty(): ground = floor_hit.position
	pool.position = ground - Vector2(0, 3)
	pool.add_to_group("blood_decals")
	game.add_child(pool)
	var fade := pool.create_tween()
	fade.tween_interval(40.0)
	fade.tween_property(pool, "modulate:a", 0.0, 5.0)
	fade.tween_callback(pool.queue_free)

func can_drop() -> bool:
	for i in range(get_slide_collision_count()):
		var collider = get_slide_collision(i).get_collider()
		if collider != null and collider.get_meta("one_way",false): return true
	return false


## Quadros da corrida em que um pé encosta no chão (um por pé, em ciclos de seis quadros).
const PASSO_QUADROS := [1, 4]
func _passo_no_quadro() -> void:
	if animator.animation not in ["run", "run_desarmado"] or not is_on_floor() or state != "idle" or absf(velocity.x) < 40.0: return
	if not PASSO_QUADROS.has(animator.frame % 6): return
	get_tree().call_group("game", "play_sfx", "step")
	footstep_t = 0.28


func _update_sword() -> void:
	if sword == null: return
	if lance != null: lance.visible = false
	if animator.actor == "beatriz":
		# Os desenhos próprios já incluem a lança.
		sword.visible = false
		return
	var clip: Dictionary = animator.definitions.get(animator.animation, {})
	sword.visible = has_weapon and state == "idle" and not cinematic_focus \
		and not clip.get("espada_integrada", false) and animator.animation in ["idle", "run", "idle_desarmado", "run_desarmado"]
	if not sword.visible: return
	var running: bool = animator.animation in ["run", "run_desarmado"]
	var grips: Array = RUN_GRIPS if running else IDLE_GRIPS
	var wrist: Vector2 = grips[clampi(animator.frame, 0, grips.size() - 1)]
	# Os desenhos já respiram e se movem; a espada acompanha o punho sem movimento adicional.
	var hand := (wrist-Vector2(128,250))*0.44
	# A lâmina acompanha o braço: punho alto e à frente leva a ponta para a frente; punho baixo, para baixo.
	var angle := 0.85
	if running: angle = clampf(0.75 + (wrist.y - 125.0) * 0.015, 0.3, 1.1)
	# Mantém a ponta acima do piso de colisão durante o movimento baixo da espada na corrida.
	var blade_length := (2050-SWORD_GRIP.x)*SWORD_SCALE
	angle = minf(angle,asin(clampf((-3-hand.y)/blade_length,-1,1)))
	sword.position = Vector2(hand.x*facing,hand.y)
	sword.scale = Vector2(SWORD_SCALE*facing,SWORD_SCALE)
	sword.rotation = angle*facing
	sword.modulate = animator.modulate
	if character != "penitente" and lance != null:
		# Beatriz segura a lança no mesmo punho, com a ponta para a frente e para baixo.
		lance.visible = true
		lance.position = sword.position
		lance.rotation = sword.rotation
		lance.scale = Vector2(float(facing), 1.0)
		sword.visible = false


func _start_air_attack() -> void:
	if not has_weapon or air_attack_used or air_attacks >= AIR_ATTACKS_MAX: return
	air_attacks += 1
	golpe_tipo = "aereo" if air_attacks == 1 else "aereo2"
	counter_attack = counter_t > 0.0
	counter_t = 0.0
	var direction := axis()
	if direction != 0: facing = 1 if direction > 0 else -1
	state = "air_attack"
	state_t = AIR_ATTACK_TIME
	air_attack_used = true
	swing_effect = false
	aerial_after_cut = true
	attack_buffer = 0
	hit_list.clear()
	get_tree().call_group("game","play_sfx","swing")


func _capture_combat_input() -> void:
	if input_release_gate:
		for action in ["attack", "heavy", "parry", "roll", "jump"]:
			if held(action): return
		input_release_gate = false
	if pressed("attack") and has_weapon:
		attack_buffer = minf(INPUT_BUFFER * attack_scale(), 0.36)
		# Um comando por golpe fica reservado até a próxima janela, mesmo em Beatriz com lança pesada.
		if state == "attack": attack_buffer = maxf(attack_buffer, maxf(state_t - attack_len * 0.24, 0.0) + 0.06)
	if pressed("heavy") and has_weapon:
		heavy_buffer = INPUT_BUFFER
	if pressed("parry") and has_weapon:
		parry_buffer = 0.18
		parry_direction = axis()
		if perdao_t > 0.0 and state == "hurt" and hp > 0.0:
			_aparo_tardio()
	if pressed("roll"):
		roll_buffer = 0.18
		roll_direction = axis()
	if pressed("jump"):
		jump_buffer = 0.12

func _clear_combat_input() -> void:
	attack_buffer = 0.0
	roll_buffer = 0.0
	parry_buffer = 0.0
	heavy_buffer = 0.0
	jump_buffer = 0.0
	roll_direction = 0.0
	parry_direction = 0.0

func _buffered_defense(on_floor: bool) -> bool:
	if _buffered_roll(): return true
	if not on_floor: return false
	if parry_buffer > 0.0 and has_weapon and parry_cd <= 0.0:
		_start_parry()
		return true
	return false

func _buffered_roll() -> bool:
	if roll_buffer <= 0.0 or roll_cd > 0.0: return false
	_start_roll()
	return true

func _jump_from_recovery(on_floor: bool) -> bool:
	if not on_floor or jump_buffer <= 0.0: return false
	jump_buffer = 0.0
	coyote = 0.0
	jump_elapsed = 0.0
	state = "idle"
	velocity.y = JUMP_V
	get_tree().call_group("game", "play_sfx", "jump")
	return true

func _exit_tree() -> void:
	# Uma troca de cena não deve herdar a câmera lenta de um impacto anterior.
	Engine.time_scale = 1.0

func _clear_strike(target) -> bool:
	# A lâmina alcança o corpo, mas não atravessa paredes ou pisos sólidos.
	var origin := global_position + Vector2(0, -40)
	var end: Vector2 = target.global_position + Vector2(0, -target.body_size.y * 0.55)
	var ray := PhysicsRayQueryParameters2D.create(origin, end, 1)
	ray.exclude = [get_rid()]
	return get_world_2d().direct_space_state.intersect_ray(ray).is_empty()

func _swing_trail() -> void:
	impact_direction = Vector2(facing,0.18)
	if swing_effect: return
	swing_effect = true
	var tipo := golpe_tipo
	if state == "air_attack": tipo = golpe_tipo if golpe_tipo.begins_with("aereo") else "aereo"
	elif state == "ascendente": tipo = "ascendente"
	elif counter_attack: tipo = "contra"
	# Rastro desenhado da lâmina: núcleo claro e borda de sangue, com uma forma para cada golpe.
	var rastro = RastroGolpe.new()
	rastro.tipo = tipo
	rastro.lado = facing
	rastro.lanca = character == "beatriz"
	rastro.forte = finisher or counter_attack
	rastro.position = global_position + Vector2(0.0, -52.0)
	var game = get_tree().get_first_node_in_group("game")
	if game != null: game.add_child(rastro)

## Golpes fortes que matam também desmembram (só criaturas de carne, no chão).
func _desmembrar_morto(e, estilo: String) -> void:
	if not is_instance_valid(e) or e.has_meta("desmembrado") or e.kind in [2, 9] or e.family == "flyer" or _impact_kind(e) != "sangue": return
	var game = get_tree().get_first_node_in_group("game")
	if game == null: return
	Gore.finalizar(game, e, estilo, facing, self)
	gore_flash = maxf(gore_flash, 0.4)

## Uma cópia translúcida do corpo fica para trás na investida.
func _fantasma(cor: Color) -> void:
	var game = get_tree().get_first_node_in_group("game")
	if game == null or animator == null or animator.sprite_frames == null: return
	var copia := Sprite2D.new()
	copia.texture = animator.sprite_frames.get_frame_texture(animator.animation, animator.frame)
	copia.flip_h = animator.flip_h
	copia.scale = animator.scale
	copia.global_position = animator.global_position
	copia.modulate = cor
	copia.z_index = 4
	copia.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	game.add_child(copia)
	var some := copia.create_tween()
	some.tween_property(copia, "modulate:a", 0.0, 0.2)
	some.tween_callback(copia.queue_free)

## Investida: depois de esquivar, um ataque vira uma estocada que atravessa a sala e fura quem estiver no caminho.
func _start_investida() -> void:
	_clear_combat_input()
	combo_window = 0.0
	golpe_tipo = "estocada"
	counter_attack = counter_t > 0.0
	counter_t = 0.0
	state = "investida"
	state_t = INVESTIDA_TIME
	invuln = maxf(invuln, 0.12)
	hit_list.clear()
	swing_effect = false
	investida_hits = 0
	fantasma_t = 0.0
	velocity.x = facing * 720.0
	get_tree().call_group("game", "play_sfx", "lanca_estocada" if character == "beatriz" else "swing")
	get_tree().call_group("game", "play_sfx", "investida")
	_swing_trail()

func _investida_hits() -> void:
	var r := Rect2(global_position + Vector2(-10.0 if facing > 0 else -96.0, -70.0), Vector2(106.0 * float(CHARACTERS[character].reach) * 0.8, 62.0))
	for e in get_tree().get_nodes_in_group("enemies"):
		if e.dead or hit_list.has(e) or not r.intersects(e.hurt_rect()) or not _clear_strike(e): continue
		hit_list.append(e)
		investida_hits += 1
		var kind_hit := _impact_kind(e)
		e.last_hitter = self
		e.take_hit((44.0 if counter_attack else 30.0) * sword_multiplier(), global_position.x)
		e.hit_pause = maxf(e.hit_pause, 0.07)
		hit_pause = maxf(hit_pause, 0.04)
		shake = maxf(shake, 6.0)
		add_culpa(4)
		var spot: Vector2 = e.global_position + Vector2(0.0, -e.body_size.y * 0.55)
		get_tree().call_group("game", "play_sfx", "hit_carne" if kind_hit == "sangue" else "hit_metal")
		get_tree().call_group("game", "spawn_effect", kind_hit, spot, facing, 0.42, "impactos")
		if kind_hit == "sangue":
			_blood_burst(spot, 0.8, 22)
			get_tree().call_group("game", "blood_splats", e.global_position, facing, 4, 1.0)
		if not e.dead: _launch(e, 260.0, -120.0)
		elif e.family != "flyer": _desmembrar_morto(e, "cintura")

## Corte ascendente: um toque no golpe pesado. Joga a criatura para cima e acerta quem voa logo acima.
func _start_ascendente() -> void:
	_clear_combat_input()
	combo_window = 0.0
	counter_attack = counter_attack or counter_t > 0.0
	counter_t = 0.0
	golpe_tipo = "ascendente"
	state = "ascendente"
	state_t = ASCENDENTE_TIME * attack_scale()
	ascendente_salto = false
	hit_list.clear()
	swing_effect = false
	velocity.x = facing * 90.0
	get_tree().call_group("game", "play_sfx", "corte_ascendente")

func _ascendente_hits() -> void:
	var largura := 96.0 * float(CHARACTERS[character].reach)
	var r := Rect2(global_position + Vector2(0.0 if facing > 0 else -largura, -170.0), Vector2(largura, 170.0))
	for e in get_tree().get_nodes_in_group("enemies"):
		if e.dead or hit_list.has(e) or not r.intersects(e.hurt_rect()) or not _clear_strike(e): continue
		hit_list.append(e)
		var kind_hit := _impact_kind(e)
		e.last_hitter = self
		e.take_hit((36.0 if counter_attack else 26.0) * sword_multiplier(), global_position.x)
		e.hit_pause = maxf(e.hit_pause, 0.07)
		hit_pause = maxf(hit_pause, 0.06)
		shake = maxf(shake, 5.0)
		add_culpa(3)
		var spot: Vector2 = e.global_position + Vector2(0.0, -e.body_size.y * 0.55)
		get_tree().call_group("game", "play_sfx", "hit_carne" if kind_hit == "sangue" else "hit_metal")
		get_tree().call_group("game", "spawn_effect", kind_hit, spot, facing, 0.4, "impactos")
		if kind_hit == "sangue": _blood_burst(spot + Vector2(0, -10), 0.7, 18)
		if not e.dead and e.kind != 2 and e.kind != 9 and e.state != "stagger" and not (e.kind == 8 and not e.exposed):
			e.state = "launched"
			e.launch_elapsed = 0.0
			e.juggle_hits = 0
			e.suspend_t = 0.0
			e.velocity = Vector2(float(facing) * 70.0, -560.0 if e.family == "walker" else -260.0)

## Lâmina de Sangue: a culpa acumulada vira um corte que voa. Custa um quarto da barra de culpa.
func _lancar_prece() -> void:
	if prece_cd > 0.0 or not is_on_floor(): return
	if culpa < PRECE_CUSTO:
		get_tree().call_group("game", "toast", "A culpa ainda é leve para a Lâmina de Sangue (precisa de 25%).")
		return
	culpa -= PRECE_CUSTO
	prece_cd = 0.55
	state = "prece"
	state_t = 0.34
	velocity.x = 0.0
	var lamina = Efeitos.LAMINA_SANGUE.instantiate()
	lamina.dono = self
	lamina.lado = facing
	lamina.dano = 34.0 * sword_multiplier()
	lamina.position = global_position + Vector2(float(facing) * 40.0, -54.0)
	var game = get_tree().get_first_node_in_group("game")
	if game != null: game.add_child(lamina)
	get_tree().call_group("game", "play_sfx", "lamina_sangue")
	get_tree().call_group("game", "play_sfx", "sangue_jato")
	shake = maxf(shake, 4.0)

## Aparo atrasado: o golpe aparável chegou depois da janela, mas a guarda ainda estava erguida.
## Bloqueia boa parte do dano e não abre o inimigo.
func _bloqueio(dmg: float, from_x: float) -> void:
	bloqueios += 1
	hp -= dmg * 0.25
	velocity.x = signf(global_position.x - from_x) * 180.0
	hit_pause = maxf(hit_pause, 0.05)
	shake = maxf(shake, 3.0)
	get_tree().call_group("game", "play_sfx", "bloqueio")
	get_tree().call_group("game", "spawn_effect", "faiscas", global_position + Vector2(facing * 40.0, -58.0), facing, 0.4, "impactos")
	if bloqueios == 1:
		get_tree().call_group("game", "toast", "Bloqueio: apare um pouco antes, no brilho dourado, para abrir o inimigo.")
	if hp <= 0.0: die()

## Apertar o aparo logo depois de ser atingido por um golpe aparável ainda conta como aparo.
func _aparo_tardio() -> void:
	hp = minf(hp + perdao_dano, max_hp)
	culpa = maxf(culpa - perdao_dano * 0.6, 0.0)
	damage_flash = 0.0
	state = "parry"
	state_t = PARRY_TIME
	perdao_t = 0.0
	_parry_success(perdao_quem, perdao_de)

## O fio das Parcas só reduz a capacidade; nunca causa uma morte fora da janela de dano.
func receber_maldicao(valor:float) -> void:
	if dev_god or invuln>0 or not standing() or state in ["roll","execution"]:return
	maldicao_parcas=minf(maldicao_parcas+valor,36.0)
	apply_penitence(penitence)
	get_tree().call_group("game","toast","As Parcas cortaram o fio: vida máxima reduzida até a próxima oração.")

func remover_maldicao() -> void:
	maldicao_parcas=0
	apply_penitence(penitence)
