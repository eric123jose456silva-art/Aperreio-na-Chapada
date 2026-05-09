extends Control

# Este script controla as ações do menu principal

func _on_iniciar_pressed():
	# Substitua pelo nome do arquivo da sua primeira fase
	# get_tree().change_scene_to_file("res://fase_1.tscn")
	print("Botão INICIAR clicado!")

func _on_fases_pressed():
	print("Abrindo menu de FASES...")

func _on_sobre_pressed():
	print("Abrindo tela SOBRE...")

func _on_configuracoes_pressed():
	print("Abrindo CONFIGURAÇÕES...")
