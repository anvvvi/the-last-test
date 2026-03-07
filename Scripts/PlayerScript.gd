extends CharacterBody2D
const SPEED = 300
const AIR_SPEED = 150        # Lower speed while airborne
const GRAVITY = 1100
const JUMP_FORCE = -300
const COYOTE_TIME = 0.12     
const JUMP_BUFFER_TIME = 0.12  
var coyote_timer = 0.0
var jump_buffer_timer = 0.0

func _physics_process(delta: float) -> void:
	var direction = Input.get_axis("playerLeft", "playerRight")
	
	# Use air speed when not on floor
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
