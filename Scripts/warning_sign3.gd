extends Node2D
@onready var texture: Sprite2D = $texture
@onready var area_sign: Area2D = $area_sign

const lines : Array[String] = [
	"Olá, aventureiro.",
"Você sabe o que é um número primo?",
"Um número primo é aquele que só pode ser dividido por 1 e por ele mesmo.",
"Por exemplo: 2, 3, 5, 7 são números primos.",
"Existem infinitos números primos espalhados pelo reino da matemática!",
"O número 7 decidiu se separar em 3 e 4, tentando se esconder.",
"Para seguir para o próximo número, você precisará juntar o 7 novamente.",
"Use sua astúcia para reuni-lo e continuar a aventura pelos números primos!"


]

func _unhandled_input(event: InputEvent) -> void:
	if area_sign.get_overlapping_bodies().size() > 0:
		texture.show()
		if event.is_action_pressed("interact") && !DialogManager.is_message_active:
			texture.hide()
			DialogManager.start_message(global_position, lines)
	else:
		texture.hide()
		if DialogManager.dialog_box != null:
			DialogManager.dialog_box.queue_free()
			DialogManager.is_message_active = false
