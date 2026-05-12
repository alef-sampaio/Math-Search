extends CharacterBody2D
const box_pieces = preload("res://prefabs/box_pieces.tscn")
const coin_instace = preload("res://prefabs/coin_rigid.tscn")

@onready var spawn_coin := $spawn_coin as Marker2D
@onready var anim := $anim as AnimationPlayer
@export var pieces : PackedStringArray
@onready var hitblock_sfx: AudioStreamPlayer2D = $hitblock_sfx
@export var hitpoints := 3
var impulse := 200

func break_sprite():
	for piece in pieces.size():
		var piece_instance = box_pieces.instantiate()
		get_parent().add_child(piece_instance)
		piece_instance.get_node("texture").texture = load(pieces[piece])
		piece_instance.global_position = global_position
		piece_instance.apply_impulse(Vector2(randf_range(-impulse,impulse) , randf_range(-impulse,-impulse * 2)))
	queue_free()
func create_coin():
	var coin = coin_instace.instantiate()
	get_parent().call_deferred("add_child", coin)
	coin.global_position = spawn_coin.global_position
	coin.apply_impulse(Vector2(randi_range(-50,50), 150))
