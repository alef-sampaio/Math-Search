extends Node2D

@onready var platform := $platform as AnimatableBody2D

@export var move_speed := 3.0
@export var distance := 192
@export var move_horizontal := true
@export var start_from_left := true  
@export var wait_time := 1.0     # TEMPO PARADA CONFIGURÁVEL

var follow := Vector2.ZERO
var platform_center := 16


func move_platform():
	# direção base
	var move_direction := Vector2.RIGHT * distance if move_horizontal else Vector2.UP * distance

	# inverter direção inicial
	if not start_from_left:
		move_direction *= -1

	# calcular tempo de movimento
	var duration = move_direction.length() / float(move_speed * platform_center)

	var platform_tween = create_tween().set_loops().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)

	# ir até o ponto final, esperar
	platform_tween.tween_property(self, "follow", move_direction, duration).set_delay(wait_time)

	# voltar para o ponto inicial, esperar
	platform_tween.tween_property(self, "follow", Vector2.ZERO, duration).set_delay(duration + wait_time * 2)


func _physics_process(delta: float) -> void:
	platform.position = platform.position.lerp(follow, 0.5)


func _ready() -> void:
	move_platform()
