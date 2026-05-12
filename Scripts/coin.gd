extends Area2D


@onready var coin_sfx: AudioStreamPlayer2D = $coin_sfx
var coins := 1

func _on_body_entered(body: Node2D) -> void:
	$anim.play("colect")
	coin_sfx.play()
	await $Colision.call_deferred("queue_free")
	Globals.coins += coins
	


func _on_anim_animation_finished() -> void:
	queue_free()
