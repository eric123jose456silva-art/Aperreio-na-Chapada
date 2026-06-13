extends CharacterBody2D

# --- CONFIGURAÇÕES DE MOVIMENTO E DISTÂNCIAS ---
@export var velocidade_voo: float = 150.0
@export var velocidade_maxima: float = 300.0 # Velocidade extra se ficar muito para trás
@export var suavidade: float = 3.0

# Onde ele deve ficar em relação ao jogador (X = Atrás, Y = Acima)
@export var offset_alvo: Vector2 = Vector2(-60, -80) 

# --- CONTROLE DE DISTÂNCIAS ---
@export var distancia_parada: float = 15.0 # Distância para ele parar de acelerar e apenas flutuar
@export var distancia_aceleracao: float = 150.0 # Se ficar mais longe que isso, voa mais rápido
@export var distancia_teleporte: float = 600.0 # Se o jogador sumir/ficar muito longe, o oráculo se teletransporta

# --- VARIÁVEIS INTERNAS ---
var jogador: Node2D
@onready var animacao = $AnimatedSprite2D

var banco_de_dicas: Array[String] = [
	"A água desta nascente guarda antigas memórias...",
	"Cuidado onde pisa, a seca deixa o solo traiçoeiro.",
	"Siga o vento da Chapada, ele sempre mostra o caminho.",
	"Sinto uma energia estranha vindo daquela caverna."
]

func _ready():
	animacao.play("VOANDO")
	
	jogador = get_tree().get_first_node_in_group("player")
	if jogador == null:
		push_warning("Oráculo: Jogador não encontrado! Coloque o protagonista no grupo 'player'.")
	
	configurar_timer_de_dicas()

func _physics_process(delta):
	if jogador:
		seguir_jogador(delta)

func seguir_jogador(delta):
	# Calcula o ponto exato onde o oráculo quer chegar
	var posicao_desejada = jogador.global_position + offset_alvo
	
	# Calcula a distância real entre o oráculo e o JOGADOR (útil para o teleporte)
	var distancia_do_jogador = global_position.distance_to(jogador.global_position)
	
	# 1. SISTEMA DE SEGURANÇA: Teleporte
	if distancia_do_jogador > distancia_teleporte:
		global_position = posicao_desejada
		return # Interrompe a função aqui para ele não tentar mover no mesmo frame

	# Calcula a direção e a distância até o PONTO DESEJADO (offset)
	var direcao = global_position.direction_to(posicao_desejada)
	var distancia_do_alvo = global_position.distance_to(posicao_desejada)
	
	# 2. LÓGICA DE DISTÂNCIA E MOVIMENTO
	if distancia_do_alvo > distancia_parada:
		# Se ele estiver muito para trás, usa a velocidade máxima
		var velocidade_atual = velocidade_voo
		if distancia_do_alvo > distancia_aceleracao:
			velocidade_atual = velocidade_maxima
			
		velocity = velocity.lerp(direcao * velocidade_atual, suavidade * delta)
	else:
		# 3. PARADA: Chegou no ponto ideal, freia suavemente (evita tremedeira)
		velocity = velocity.lerp(Vector2.ZERO, suavidade * delta)
		
	move_and_slide()
	
	# 4. DIREÇÃO DO OLHAR: Sempre vira para o jogador
	if jogador.global_position.x > global_position.x:
		animacao.flip_h = false # Olha para a direita
		offset_alvo.x = -abs(offset_alvo.x) # Se posiciona à esquerda
	else:
		animacao.flip_h = true # Olha para a esquerda
		offset_alvo.x = abs(offset_alvo.x) # Se posiciona à direita

# --- LÓGICA DAS DICAS ---

func configurar_timer_de_dicas():
	var timer = Timer.new()
	timer.wait_time = 20.0 
	timer.autostart = true
	timer.timeout.connect(_tentar_dar_dica)
	add_child(timer)

func _tentar_dar_dica():
	if randf() <= 0.40:
		dar_dica()

func dar_dica():
	var dica_escolhida = banco_de_dicas.pick_random()
	print("Oráculo do Araripe: ", dica_escolhida)
