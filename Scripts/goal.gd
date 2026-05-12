extends Area2D

@onready var transition: CanvasLayer = $"../transition"
@export var next_level: String = ""



func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player" and !next_level == "":
		transition.change_scene(next_level)
	else:
		print("Player")
