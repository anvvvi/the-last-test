extends CharacterBody2D

const SPEED = 400
const GRAVITY = 900
const JUMP_FORCE = -300

func _physics_process(delta: float) -> void:
	var direction = 0
	direction = Input.get_axis("playerLeft","playerRight")
	velocity.x = SPEED * direction
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	elif Input.is_action_just_pressed("playerJump"):
		velocity.y = JUMP_FORCE
	move_and_slide()
