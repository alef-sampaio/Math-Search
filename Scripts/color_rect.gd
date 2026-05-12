extends ColorRect

var threshold = 0.0

func _process(delta: float) -> void:
	material.set("shader_parameter/threshold",threshold)
