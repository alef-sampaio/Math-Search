extends Area2D

# Nome da próxima cena a ser carregada
var next_scene = "res://Cenas/Grassland_level.tscn"  # Altere para o caminho correto da sua cena

# Função chamada quando algo entra na área da porta
func _on_Area2D_body_entered(body):
	# Verifica se o objeto que entrou é o jogador
	if body.is_in_group("player"):
		# Carrega a próxima cena
		get_tree().change_scene(next_scene)



func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		# Carrega a próxima cena
		get_tree().change_scene_to_file(next_scene)
