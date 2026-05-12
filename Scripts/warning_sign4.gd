extends Node2D
@onready var texture: Sprite2D = $texture
@onready var area_sign: Area2D = $area_sign

const lines : Array[String] = [
	"Jovem aventureiro, tenho uma nova missão para você.",
"Desta vez, você deve ir até a Floresta das Subtrações.",
"Lá, dois números estão escondidos.",
"Se você subtrair um do outro, eles resultarão no número primo 3.",
"Use sua inteligência para encontrá-los e sguir para o próximo!",
"Boa sorte, e que o rei Calculus guie seu caminho!"



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
