extends EnemyBase
@onready var spaw_enemy: Marker2D = $"../spaw_enemy"

func _ready() -> void:
	spawn_instance = preload("res://Actors/cherry.tscn")
	spawn_instance_position = spaw_enemy
	can_spawn = true
	anim.animation_finished.connect(kill_air_enemy)
	
	

func _on_hitbox_body_entered(body: Node2D) -> void:
	anim.play("hurt")
