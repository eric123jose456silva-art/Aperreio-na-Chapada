extends CharacterBody2D

# --- STATUS DA ONÇA ---
@export var velocidade: float = 60.0
@export var dano_ataque: int = 20 

var gravidade = ProjectSettings.get_setting("physics/2d/default_gravity")
var direcao: int = -1 # -1 = Esquerda, 1 = Direita
var atacando: bool = false
var jogador_na_area: Node2D = null

# --- REFERÊNCIAS ---
@onready var anim = $AnimatedSprite2D
@onready var detector_chao = $DetectorChao
@onready var detector_parede = $DetectorParede
@onready var zona_ataque = $ZonaDeAtaque

func _physics_process(delta):
	# Se estiver dando o bote, ela para de andar
	if atacando:
		velocity.x = 0
		move_and_slide()
		return
		
	# 1. Aplica a gravidade
	if not is_on_floor():
		velocity.y += gravidade * delta
		
	# 2. Inteligência de Patrulha (Bate-e-Volta)
	if detector_parede.is_colliding() or not detector_chao.is_colliding():
		if is_on_floor(): 
			_virar()
			
	# 3. Movimento
	velocity.x = direcao * velocidade
	
	# Toca a animação de andar (que você nomeou como IDLE)
	anim.play("IDLE")
	
	move_and_slide()

func _virar():
	direcao *= -1
	
	# Vira o desenho
	anim.flip_h = direcao > 0 
	
	# Vira os detectores para a nova direção
	detector_chao.position.x = abs(detector_chao.position.x) * direcao
	detector_parede.target_position.x = abs(detector_parede.target_position.x) * direcao
	
	# Vira a área de ataque
	zona_ataque.scale.x = -1 if direcao > 0 else 1

# ==========================================
# SISTEMA DE COMBATE (ATAQUE) - À PROVA DE BUGS
# ==========================================

func _on_zona_de_ataque_body_entered(body):
	# Verifica o grupo Player (com P maiúsculo)
	if body.is_in_group("Player"):
		jogador_na_area = body
		_iniciar_ataque()

func _on_zona_de_ataque_body_exited(body):
	if body == jogador_na_area:
		jogador_na_area = null

func _iniciar_ataque():
	# TRAVA DE SEGURANÇA 1: Se já tá atacando, não tem jogador, ou o jogador já morreu, pare!
	if atacando or jogador_na_area == null or jogador_na_area.esta_morto:
		atacando = false
		return
		
	atacando = true
	anim.play("attack")
	
	# Espera um tempo para a patada "acertar" no visual
	await get_tree().create_timer(0.4).timeout
	
	# TRAVA DE SEGURANÇA 2: Confere se o jogador ainda existe, não morreu e tá na área antes de bater
	if jogador_na_area != null and is_instance_valid(jogador_na_area):
		if not jogador_na_area.esta_morto and jogador_na_area.has_method("tomar_dano"):
			jogador_na_area.tomar_dano(dano_ataque)
		
	# Espera a animação terminar completamente
	await anim.animation_finished
	
	atacando = false
	
	# Se a Maria continuar na área e ainda estiver viva, dá outra patada
	if jogador_na_area != null and is_instance_valid(jogador_na_area) and not jogador_na_area.esta_morto:
		_iniciar_ataque()
	else:
		# Se não, limpa o alvo e volta a andar
		jogador_na_area = null
		anim.play("IDLE")
