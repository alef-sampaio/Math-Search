extends CharacterBody2D

const SPEED = 200.0
const JUMP_FORCE = -400.0
var is_jumping := false
var is_hurted := false
var knokback_vector := Vector2.ZERO
var direction
var last_state := ""

signal player_has_died()

@onready var jump_sfx: AudioStreamPlayer2D = $jump_sfx
@onready var animation: AnimatedSprite2D = $anim as AnimatedSprite2D
@onready var remote := $remote as RemoteTransform2D
@onready var ray_right := $ray_right as RayCast2D
@onready var ray_left := $ray_left as RayCast2D
@onready var hurtbox: Area2D = $hurtbox
@onready var head_colider: Area2D = $head_colider
@onready var destroy_sfx = preload("res://sounds/destroy_sfx.tscn")
@onready var hurt_sfx: AudioStreamPlayer2D = $hurt_sfx

# ----------------- GELO -----------------
var is_on_ice := false
func set_on_ice(value: bool) -> void:
	is_on_ice = value
# ----------------------------------------

func _ready():
	add_to_group("player")  # garante que o item reconheça o player


func _physics_process(delta: float) -> void:
	# gravidade
	if not is_on_floor():
		velocity.y += get_gravity().y * delta

	# se estiver sendo atacado / knockback
	if is_hurted:
		if knokback_vector != Vector2.ZERO:
			velocity.x = knokback_vector.x
			velocity.y = knokback_vector.y
		_set_state()
		move_and_slide()
		return

	# pulo
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_FORCE
		is_jumping = true
		jump_sfx.play()
	elif is_on_floor():
		is_jumping = false

	# entrada horizontal
	direction = Input.get_axis("ui_left", "ui_right")

	if direction != 0:
		animation.scale.x = direction

	# --- MOVIMENTO NO CHÃO COM SUPORTE A GELO ---
	if is_on_floor():
		if is_on_ice:
			# comportamento de deslize no gelo
			if direction != 0:
				# acelera suavemente até a velocidade alvo
				velocity.x = lerp(velocity.x, direction * SPEED, 0.08)
			else:
				# sem input permanece deslizando (atrito fraco)
				velocity.x *= 0.98
		else:
			# comportamento normal
			if direction != 0:
				velocity.x = direction * SPEED
			else:
				velocity.x = move_toward(velocity.x, 0, SPEED)
	else:
		# no ar: manter comportamento anterior (um pouco de controle no ar)
		velocity.x = move_toward(velocity.x, direction * SPEED, SPEED * 0.15)

	# override de knockback (se aplicado)
	if knokback_vector != Vector2.ZERO:
		velocity.x = knokback_vector.x

	_set_state()
	move_and_slide()


func take_damage(knockback_force := Vector2.ZERO, duration := 0.25) -> void:
	# Esta é a versão da função que não checa "is_hurted" no início, 
	# mas faz a checagem no código interno.
	Globals.player_life -= 1

	is_hurted = true
	animation.play("hurt")
	hurt_sfx.play()
	last_state = "hurt"

	animation.modulate = Color(1, 0, 0)

	if knockback_force != Vector2.ZERO:
		knokback_vector = knockback_force
		var t := get_tree().create_tween()
		
		t.tween_property(self, "knokback_vector", Vector2.ZERO, duration)
		t.parallel().tween_property(animation, "modulate", Color(1,1,1), duration)
		
		await t.finished
	else:
		await get_tree().create_timer(duration).timeout

	knokback_vector = Vector2.ZERO
	is_hurted = false
	animation.modulate = Color(1,1,1)


func _on_hurtbox_body_entered(body: Node2D) -> void:
	# Lógica original que causava problemas de detecção com RayCast2D:
	if Globals.player_life <= 0:
		queue_free()
		emit_signal("player_has_died")
	else:
		if ray_right.is_colliding():
			take_damage(Vector2(-200,-200))
		elif ray_left.is_colliding():
			take_damage(Vector2(200,-200))


func follow_camera(camera):
	if remote:
		remote.remote_path = camera.get_path()


func _set_state():
	var state := ""

	if is_hurted:
		state = "hurt"
	elif !is_on_floor():
		state = "jump"
	elif direction != 0:
		state = "Walk"
	else:
		state = "idle"

	if state != last_state:
		animation.play(state)
		last_state = state
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider and collider.has_method("has_colided_with"):
			collider.has_colided_with(collision, self)


func _on_head_colider_body_entered(body: Node2D) -> void:
	if body.has_method("break_sprite"):
		body.hitpoints -= 1
		if body.hitpoints < 0:
			body.break_sprite()
			play_destroy_sfx()
		else:
			body.get_node("anim").play("hit")
			body.hitblock_sfx.play()
			body.create_coin()


func play_destroy_sfx():
	var sound_sfx = destroy_sfx.instantiate()
	get_parent().add_child(sound_sfx)
	sound_sfx.play()
	await sound_sfx.finished
	sound_sfx.queue_free()


func handle_death_zone():
	if Globals.player_life > 0:
		Globals.player_life -= 1
		visible = false
		set_physics_process(false)
		
		await get_tree().create_timer(1.0).timeout
		Globals.respawn_player()
		visible = true
		set_physics_process(true)
	else:
		visible = false
		await get_tree().create_timer(0.5).timeout
		player_has_died.emit()
