extends CharacterBody2D

# --- SINAIS (Para conectar com a Interface/Barra de Vida) ---
signal vida_atualizada(nova_vida)
signal jogador_morreu()

# --- SISTEMA DE VIDA E SPAWN ---
@export var vida_maxima: int = 100
var vida_atual: int = 100
var posicao_inicial: Vector2
var esta_morto: bool = false # Trava de segurança anti-bugs

# --- VARIÁVEIS DE MOVIMENTO E PULO ---
@export var SPEED: float = 150.0
@export var SPRINT_SPEED: float = 300.0 # Lembre-se de ajustar no Inspetor da Godot!
@export var JUMP_VELOCITY: float = -400.0
var pode_pulo_duplo: bool = false 

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# --- REFERÊNCIAS AOS NÓS ---
@onready var sprite = $AnimatedSprite2D
@onready var camera = $Camera2D # Pega a câmera conectada na personagem

# Guarda os limites originais da câmera para quando ela sair da caverna
var limite_topo_original: int
var limite_baixo_original: int

func _ready():
	# 1. Adiciona a personagem ao grupo "Player" (COM 'P' MAIÚSCULO PARA A ONÇA ACHAR!)
	add_to_group("Player")
	
	# 2. Salva o ponto seguro onde a fase começou
	posicao_inicial = global_position
	vida_atual = vida_maxima
	
	# 3. Salva a configuração original da câmera (se ela existir)
	if camera:
		limite_topo_original = camera.limit_top
		limite_baixo_original = camera.limit_bottom
		
	if sprite:
		sprite.play("idle")

func _physics_process(delta):
	# TRAVA ANTI-BUG: Se estiver morta, ignora os comandos
	if esta_morto:
		return

	# 1. Gravidade e Reset do Pulo Duplo
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		pode_pulo_duplo = true

	# 2. Pulo e Pulo Duplo (Usando a ação 'pulo' configurada no seu Input Map)
	if Input.is_action_just_pressed("pulo"):
		if is_on_floor():
			velocity.y = JUMP_VELOCITY
		elif pode_pulo_duplo:
			velocity.y = JUMP_VELOCITY
			pode_pulo_duplo = false # Gasta o pulo duplo

	# 3. Movimento Horizontal e SISTEMA DE CORRIDA
	var direction = Input.get_axis("esquerda", "direita")
	var velocidade_atual = SPEED
	
	# Verifica se está segurando a tecla de correr e se movendo
	var esta_correndo = Input.is_action_pressed("correr")
	if esta_correndo and direction != 0:
		velocidade_atual = SPRINT_SPEED
	
	if direction != 0:
		velocity.x = direction * velocidade_atual
		sprite.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	# 4. Aplica o movimento na física
	move_and_slide()
	
	# 5. Controle de Animações
	_update_animations(direction, esta_correndo)
	
	# 6. Controle de Limites da Câmera (Caverna)
	_controlar_camera()

func _update_animations(direction, correndo):
	if sprite == null: return
	
	if not is_on_floor():
		sprite.play("Jump")
		sprite.speed_scale = 1.0
	elif direction != 0:
		sprite.play("walk")
		# Se estiver correndo, acelera a animação de andar em 1.5x
		if correndo:
			sprite.speed_scale = 1.5
		else:
			sprite.speed_scale = 1.0
	else:
		sprite.play("idle")
		sprite.speed_scale = 1.0

func _controlar_camera():
	if camera:
		# Se a posição X da personagem passar de 4048 (entrada da caverna)
		if global_position.x >= 4048:
			# Trava o topo para esconder o céu. 
			camera.limit_top = 264
			# Deixa o limite de baixo grande para a câmera não bugar na altura da tela
			camera.limit_bottom = 2000 
		else:
			# Voltou para fora (X menor que 4048), a câmera volta aos limites do céu
			camera.limit_top = limite_topo_original
			camera.limit_bottom = limite_baixo_original

# ==========================================
# SISTEMA DE VIDA E MORTE À PROVA DE BUGS
# ==========================================

func tomar_dano(quantidade: int):
	# Se já estiver morta, ignora o dano extra
	if esta_morto: return 
		
	vida_atual -= quantidade
	vida_atual = clampi(vida_atual, 0, vida_maxima) # Impede que a vida fique negativa
	
	emit_signal("vida_atualizada", vida_atual)
	print("Sofreu dano! Vida atual: ", vida_atual)
	
	if vida_atual <= 0:
		morrer()

func morte_instantanea():
	if esta_morto: return
		
	print("Caiu nos espinhos! Vida zerada.")
	vida_atual = 0
	emit_signal("vida_atualizada", vida_atual)
	morrer()

func morrer():
	esta_morto = true # Trava os controles, a física e os danos
	emit_signal("jogador_morreu")
	
	# Zera a velocidade para ela não renascer escorregando ou voando
	velocity = Vector2.ZERO 
	
	# TELEPORTE SEGURO: espera o frame de física terminar antes de mover a personagem
	call_deferred("_renascer")

func _renascer():
	global_position = posicao_inicial
	vida_atual = vida_maxima
	emit_signal("vida_atualizada", vida_atual)
	
	esta_morto = false # Destrava o jogador para voltar a jogar
	print("Personagem renasceu com sucesso!")
