extends CharacterBody2D

# --- SINAIS (Para conectar com a Interface/Barra de Vida no futuro) ---
signal vida_atualizada(nova_vida)
signal jogador_morreu()

# --- STATUS DO JOGADOR ---
@export var vida_maxima: int = 100
var vida_atual: int = 100
var posicao_inicial: Vector2

# --- MOVIMENTO ---
@export var SPEED: float = 150.0
@export var JUMP_VELOCITY: float = -400.0

# Obtém a gravidade padrão do projeto
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# --- REFERÊNCIAS ---
@onready var sprite = $AnimatedSprite2D

# --- VARIÁVEIS DE SEGURANÇA (Anti-Bugs) ---
var esta_morto: bool = false

func _ready():
	# 1. AUTO-CONFIGURAÇÃO: Garante que o Oráculo consiga achar a personagem
	add_to_group("player")
	
	# 2. Salva o ponto seguro onde a fase começou
	posicao_inicial = global_position
	vida_atual = vida_maxima
	
	# 3. Inicia a animação padrão
	if sprite:
		sprite.play("idle")

func _physics_process(delta):
	# TRAVA ANTI-BUG: Se estiver morta, ignora qualquer comando do jogador
	if esta_morto:
		return

	# 1. GRAVIDADE
	if not is_on_floor():
		velocity.y += gravity * delta

	# 2. PULO
	if input_event_jump() and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# 3. MOVIMENTO HORIZONTAL
	var direction = Input.get_axis("ui_left", "ui_right")
	
	if direction != 0:
		velocity.x = direction * SPEED
		sprite.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	# 4. APLICA O MOVIMENTO
	move_and_slide()
	
	# 5. CONTROLA AS ANIMAÇÕES
	_update_animations(direction)

func _update_animations(direction):
	# Evita crash caso o nó AnimatedSprite2D seja deletado ou renomeado por engano
	if sprite == null: 
		return
		
	if not is_on_floor():
		sprite.play("Jump")
	elif direction != 0:
		sprite.play("walk")
	else:
		sprite.play("idle")

func input_event_jump() -> bool:
	return Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("ui_up")

# ==========================================
# SISTEMA DE VIDA E MORTE À PROVA DE BUGS
# ==========================================

func tomar_dano(quantidade: int):
	# Se já está morta, ignora danos adicionais
	if esta_morto: 
		return 
		
	vida_atual -= quantidade
	vida_atual = clampi(vida_atual, 0, vida_maxima) # Impede que a vida fique negativa
	
	emit_signal("vida_atualizada", vida_atual) # Avisa a barra de vida para diminuir
	print("Sofreu dano! Vida atual: ", vida_atual)
	
	if vida_atual <= 0:
		morrer()

func morte_instantanea():
	if esta_morto: 
		return
		
	print("Caiu nos espinhos! Vida zerada.")
	vida_atual = 0
	emit_signal("vida_atualizada", vida_atual)
	morrer()

func morrer():
	esta_morto = true # Trava os controles e a física
	emit_signal("jogador_morreu")
	
	# Zera a velocidade para ela não continuar escorregando ou caindo
	velocity = Vector2.ZERO 
	
	# TELEPORTE SEGURO: call_deferred espera o frame de física terminar antes de mover.
	# Isso previne o erro "Can't change this state while flushing queries" na Godot 4.
	call_deferred("_renascer")

func _renascer():
	global_position = posicao_inicial
	vida_atual = vida_maxima
	emit_signal("vida_atualizada", vida_atual)
	
	# Destrava o estado para o jogador voltar a controlar
	esta_morto = false 
	print("Personagem renasceu com sucesso!")
