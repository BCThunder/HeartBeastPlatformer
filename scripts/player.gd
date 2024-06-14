extends CharacterBody2D


const SPEED = 150
const JUMP_VELOCITY = -300.0
const ACCELERATION = 400
const FRICTION = 5000

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var animated_sprite_2d = $AnimatedSprite2D


func _physics_process(delta):
	apply_gravity(delta)
	handle_jump()
	
	var direction = Input.get_axis("MoveLeft", "MoveRight")
	handle_acceleration(direction, delta)
	handle_friction(direction, delta)
	update_animations(direction)

	move_and_slide()
	
func apply_gravity(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta


func handle_jump():
	# Handle jump.
	if is_on_floor():
		if Input.is_action_just_pressed("Jump"):
			velocity.y = JUMP_VELOCITY
	else:
		if Input.is_action_just_pressed("Jump") and velocity.y < JUMP_VELOCITY / 2:
			velocity.y = JUMP_VELOCITY / 2


func handle_acceleration(direction, delta):
	if direction != 0:
		velocity.x = move_toward(velocity.x, SPEED * direction, ACCELERATION * delta)


func handle_friction(direction, delta):
	if direction == 0:
		velocity.x = move_toward(velocity.x, 0, FRICTION * delta)


func update_animations(direction):
	if direction != 0:
		animated_sprite_2d.flip_h = (direction < 0)
		animated_sprite_2d.play("run")
	else:
		animated_sprite_2d.play("idle")
		
	if not is_on_floor():
		animated_sprite_2d.play("jump")
