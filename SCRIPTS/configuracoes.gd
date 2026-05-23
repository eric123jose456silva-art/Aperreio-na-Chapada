extends Control

func _ready() -> void:
	# Adiciona as opções no seletor de idiomas
	var seletor = $VBoxContainer/HBoxIdioma/OptionButton
	seletor.add_item("Português", 0)
	seletor.add_item("English", 1)
	seletor.add_item("Caririense", 2)

func _on_option_button_item_selected(index: int) -> void:
	match index:
		0:
			TranslationServer.set_locale("pt")
			print("Mudou para Português")
		1:
			TranslationServer.set_locale("en")
			print("Mudou para Inglês")
		2:
			TranslationServer.set_locale("caririense") # O código que você definiu no CSV
			print("Agora o negócio ficou bom, tá no Caririense!")

func _on_btn_voltar_pressed() -> void:
	get_tree().change_scene_to_file("res://cenas/tela_inicial.tscn")
