extends StaticBody2D

@export var gelo_friction := 0.05
@export var normal_friction := 1.0

var ice_material: PhysicsMaterial

func _ready():
	ice_material = PhysicsMaterial.new()
	ice_material.friction = normal_friction
	ice_material.bounce = 0.5
	physics_material_override = ice_material

extends Area2D

func _on_area_entered(area):
	if area.get_parent().has_method("set"):
		if area.get_parent().has_variable("is_on_ice"):
			area.get_parent().is_on_ice = true

func _on_area_exited(area):
	if area.get_parent().has_variable("is_on_ice"):
		area.get_parent().is_on_ice = false
