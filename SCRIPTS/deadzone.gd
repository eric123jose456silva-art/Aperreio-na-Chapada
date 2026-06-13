extends Area2D

func _on_body_entered(body: Node2D) -> void:
	# Isso vai escrever no painel de saída da Godot tudo que encostar nos espinhos
	print("ALERTA: Algo bateu nos espinhos! Nome: ", body.name)
	
	if body.has_method("morte_instantanea"):
		print("É a personagem! Ativando morte instantânea...")
		body.morte_instantanea()
	else:
		print("ERRO: O objeto ", body.name, " não tem a função 'morte_instantanea' no script dele.")
