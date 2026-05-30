extends CharacterBody2D

# --- VARIÁVEIS DE MOVIMENTO ---
@export var SPEED = 100.0
@export var JUMP_VELOCITY = -400.0

# Obtém a gravidade das configurações do projeto para manter o padrão do motor
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# Referência ao nó AnimatedSprite2D (certifique-se de que o nome no seu painel seja este)
@onready var sprite = $AnimatedSprite2D

func _physics_process(delta):
	# 1. Aplica a gravidade se a personagem não estiver no chão
	if not is_on_floor():
		velocity.y += gravity * delta

	# 2. Gerencia o Pulo
	if input_event_jump() and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# 3. Obtém a direção do movimento (Esquerda / Direita)
	var direction = Input.get_axis("ui_left", "ui_right")
	
	if direction != 0:
		velocity.x = direction * SPEED
		# Inverte o sprite horizontalmente dependendo da direção
		sprite.flip_h = direction < 0
	else:
		# Desacelera suavemente quando o jogador solta o botão
		velocity.x = move_toward(velocity.x, 0, SPEED)

	# Aplica o movimento final
	move_and_slide()
	
	# 4. Controla as Animações
	_update_animations(direction)

# Função isolada para cuidar da lógica visual
func _update_animations(direction):
	if not is_on_floor():
		# Se estiver no ar, toca a animação de pulo
		sprite.play("Jump")
	elif direction != 0:
		# Se estiver no chão e se movendo, toca a animação de andar
		sprite.play("walk")
	else:
		# Se estiver parada no chão, toca a animação de repouso
		sprite.play("idle")

# Função auxiliar para detectar o input de pulo (Pode ser Espaço, Seta para cima, etc.)
func input_event_jump():
	return Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("ui_up")
