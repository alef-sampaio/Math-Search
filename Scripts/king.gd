extends Area2D

signal dialogue_finished

var player_inside := false
var dialogue_started := false

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited", Callable(self, "_on_body_exited"))

func _on_body_entered(body):
	if body.is_in_group("player"):
		player_inside = true

func _on_body_exited(body):
	if body.is_in_group("player"):
		player_inside = false

func _process(delta):
	if player_inside and Input.is_action_just_pressed("interact") and not dialogue_started:
		dialogue_started = true
		start_dialogue()

func start_dialogue():
	# Aqui você chama sua caixa de diálogo
	get_node("res://prefabs/dialog_box.tscn").show_text([
		"Rei: Bem-vindo, aventureiro!",
        "Rei: Você pode seguir pelo castelo agora."
	], _on_dialogue_end)

func _on_dialogue_end():
	emit_signal("dialogue_finished")
