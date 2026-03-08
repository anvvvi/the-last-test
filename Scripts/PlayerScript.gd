extends CharacterBody2D

const SPEED = 300
const AIR_SPEED = 150
const GRAVITY = 1100
const JUMP_FORCE = -400
const COYOTE_TIME = 0.12
const JUMP_BUFFER_TIME = 0.12

var coyote_timer = 0.0
var jump_buffer_timer = 0.0
var top_down = false  # set to true from the dungeon generator

@export var animated_sprite: AnimatedSprite2D  # Drag your node here in the Inspector

func _physics_process(delta: float) -> void:
	if top_down:
		var dir_x = Input.get_axis("playerLeft", "playerRight")
		var dir_y = Input.get_axis("playerUp", "playerDown")
		velocity.x = SPEED * dir_x
		velocity.y = SPEED * dir_y
		move_and_slide()
		_update_animation(dir_x)
		return

	# Normal platformer below
	var direction = Input.get_axis("playerLeft", "playerRight")

	if is_on_floor():
		velocity.x = SPEED * direction
	else:
		velocity.x = AIR_SPEED * direction

	coyote_timer -= delta
	jump_buffer_timer -= delta

	if is_on_floor():
		coyote_timer = COYOTE_TIME

	if Input.is_action_just_pressed("playerJump"):
		jump_buffer_timer = JUMP_BUFFER_TIME

	if not is_on_floor():
		velocity.y += GRAVITY * delta

	if jump_buffer_timer > 0 and coyote_timer > 0:
		velocity.y = JUMP_FORCE
		jump_buffer_timer = 0
		coyote_timer = 0

	move_and_slide()
	_update_animation(direction)

func _update_animation(direction: float) -> void:
	if not animated_sprite:
		return
	if direction != 0:
		animated_sprite.play("walk")
		animated_sprite.flip_h = direction < 0
	else:
		animated_sprite.play("idle")
