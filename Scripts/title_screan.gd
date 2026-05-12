extends Control

@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	audio_stream_player_2d.play()
	Globals.coins = 0
	Globals.score = 0
	Globals.player_life = 3 





func _on_start_bnt_pressed() -> void:
	get_tree().change_scene_to_file("res://Cenas/castelo.tscn")


func _on_credits_bnt_pressed() -> void:
	get_tree().change_scene_to_file("res://Creditos/Creditos.tscn")


func _on_quit_bnt_pressed() -> void:
	get_tree().quit()
