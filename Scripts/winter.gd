extends Node2D

@onready var player := $Player as CharacterBody2D
@onready var camera := $camera as Camera2D
@onready var control = $HUD/Control
@onready var player_scene = preload("res://Actors/player.tscn")
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Globals.items_collected = 0
	Globals.player_start_position = $player_start
	Globals.player = player
	Globals.player.follow_camera(camera)
	Globals.player.player_has_died.connect(game_over)
	control.time_is_up.connect(game_over)
	



func _process(delta):
	if player != null and is_instance_valid(player):
		audio_stream_player_2d.global_position = player.global_position


func reload_game():
	await get_tree().create_timer(1.0).timeout
	audio_stream_player_2d.stop()
	audio_stream_player_2d.play()
	player = player_scene.instantiate()
	add_child(player)
	control.reset_clock_timer()
	Globals.player = player
	Globals.player.follow_camera(camera)
	Globals.player.player_has_died.connect(game_over)
	Globals.coins = 0
	Globals.score = 0
	Globals.player_life = 3 
	Globals.respawn_player()
	



func game_over():
	get_tree().change_scene_to_file("res://Cenas/game_over.tscn")
