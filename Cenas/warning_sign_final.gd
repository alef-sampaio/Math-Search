extends Node2D
@onready var texture: Sprite2D = $texture
@onready var area_sign: Area2D = $area_sign

const lines : Array[String] = [
	"Parabéns, jovem aventureiro!",
"Você percorreu todos os cantos do reino em busca dos números primos.",
"Agora chegou ao Território do Frio Algébrico, onde o último número primo está escondido.",
"Este número guarda o segredo final da matemática e a vitória sobre os enigmas do reino.",
"Use toda sua sabedoria para encontrá-lo e completar sua jornada!",
"Boa sorte, e que os números primos estejam sempre ao seu lado!"

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
