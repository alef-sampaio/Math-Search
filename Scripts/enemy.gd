extends CharacterBody2D
class_name EnemyBase

const SPEED = 700.0
const JUMP_VELOCITY = -400.0

@onready var anim := $anim
@export var enemy_score := 100
@onready var hit_enemy = preload("res://sounds/hit_enemy.tscn")

var can_spawn = false
var spawn_instance : PackedScene = null
var spawn_instance_position

var wall_detector 
var texture # Variável que causava o erro "Identifier 'texture' not declared"
var direction := -1


func _ready() -> void:
	# Conexão original, mas que deve ser movida para ground_enemy.gd ou _ready()
	# para evitar o erro de 'texture' ou 'anim_name'
	# Ex: anim.animation_finished.connect(kill_ground_enemy)
	
	# Inicialização de wall_detector e texture (causava erro se não declarado)
	wall_detector = $wall_detector
	# texture = $texture # Removida para evitar o erro de nó não encontrado
	pass


func flip_direction():
	# Lógica original, que usava a variável 'texture' que estava dando erro
	if wall_detector.is_colliding():
		direction *= -1
		wall_detector.scale.x *= -1
	# Assumindo que você substituiu 'texture' por 'anim' ou 'texture' em algum momento:
	if direction == -1:
		texture.flip_h = true
	else:
		texture.flip_h = false


func apply_gravity(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta


func movement(delta):
	velocity.x = direction * SPEED * delta
	move_and_slide()


func kill_ground_enemy(anim_name: StringName) -> void:
	# Esta função com argumento causava o erro 'Invalid access to property or key 'anim_name''
	kill_and_score()

func kill_air_enemy() -> void:

	kill_and_score()

func kill_and_score():
	Globals.score += enemy_score
	if can_spawn:
		spawn_new_enemy()
		get_parent().queue_free()
	else:
		queue_free()

func spawn_new_enemy():
	var instance_scene = spawn_instance.instantiate()
	get_tree().root.add_child(instance_scene)
	instance_scene.global_position = spawn_instance_position.global_position

func on_hitbox_body_entered(body):
	# A lógica de dano do Player (pisada) deve estar aqui
	anim.play("hurt")
