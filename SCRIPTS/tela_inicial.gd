extends Control

# Script para a Tela Inicial - Aperreio na Chapada

func _on_iniciar_a_aventura_pressed() -> void:
	print("Botão INICIAR clicado: Carregando a Chapada do Araripe...")
	# Verifica se a cena existe antes de tentar mudar para não dar erro
	if ResourceLoader.exists("res://CENAS/oxente_aonde_eu_to.tscn"):
		get_tree().change_scene_to_file("res://CENAS/oxente_aonde_eu_to.tscn")
	else:
		print("AVISO: A cena res://cenas/Fase1.tscn ainda não foi criada!")

func _on_fases_pressed() -> void:
	print("Botão FASES clicado: Abrindo mapa de seleção de fases...")
	# Quando criar a cena, use: get_tree().change_scene_to_file("res://cenas/SelecaoFases.tscn")

func _on_configurações_pressed() -> void:
	print("Botão CONFIGURAÇÕES clicado: Abrindo menu de som e controles...")
	if ResourceLoader.exists("res://cenas/Configuracoes.tscn"):
		get_tree().change_scene_to_file("res://CENAS/configuracoes.tscn")
	else:
		print("AVISO: A cena de Configuracoes ainda não existe!")

func _on_sobre_o_jogo_pressed() -> void:
	print("--- CRÉDITOS ---")
	print("Jogo: Aperreio na Chapada")
	print("Desenvolvido por: Alunos do Cariri")
	print("Estética: Cordel e Xilogravura")
	print("-----------------")

# Caso você decida adicionar um botão de sair
func _on_sair_pressed() -> void:
	print("Saindo do jogo... Até a próxima, oxente!")
	get_tree().quit()
