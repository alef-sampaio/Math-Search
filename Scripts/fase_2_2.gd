extends Area2D

@onready var transition: CanvasLayer = $"../transition"
@export var next_level: String = ""



func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		Globals.items_collected += 1
		print("Itens coletados:", Globals.items_collected)
		queue_free()  # remove o item da cena

		# Se o player pegou 2 itens, carrega a próxima fase
		if Globals.items_collected >= 2 and next_level != "":
			transition.change_scene(next_level)
		else:
			print("Player")
