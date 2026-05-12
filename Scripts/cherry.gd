extends EnemyBase


func _ready() -> void:
	anim.animation_finished.connect(kill_air_enemy)

func _physics_process(delta: float) -> void:
	apply_gravity(delta)
	movement(delta)
