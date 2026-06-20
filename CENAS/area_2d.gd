extends Area2D

func _on_zona_de_morte_body_entered(body):
	# Essa linha vai imprimir um texto na aba Saída do Godot
	print("Algo encostou na zona de morte! Foi: ", body.name) 
	
	if body.is_in_group("Player"):
		print("É a Maria! Reiniciando a fase...")
		get_tree().reload_current_scene()
