extends Control

# Função chamada quando o botão Iniciar é clicado
func _on_btn_iniciar_pressed():
	get_tree().change_scene_to_file("res://cenas/Fase1.tscn")

# Função para abrir configurações
func _on_btn_config_pressed():
	# Aqui você pode instanciar uma cena de pop-up ou trocar de cena
	get_tree().change_scene_to_file("res://cenas/Configuracoes.tscn")

# Função para abrir sobre
func _on_btn_sobre_pressed():
	print("Mostrando créditos dos alunos...")

# Função para sair do jogo
func _on_btn_sair_pressed():
	get_tree().quit()


func _on_iniciar_a_aventura_pressed() -> void:
	pass # Replace with function body.


func _on_fases_pressed() -> void:
	pass # Replace with function body.


func _on_configurações_pressed() -> void:
	pass # Replace with function body.


func _on_sobre_o_jogo_pressed() -> void:
	pass # Replace with function body.
