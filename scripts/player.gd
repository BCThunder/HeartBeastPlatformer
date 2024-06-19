extends CharacterBody2D

@export var movement_data : PlayerMovementData

var air_jump = false
var just_wall_jumped = false
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var coyote_jump_timer = $CoyoteJumpTimer
@onready var starting_position = global_position


func _physics_process(delta):
	apply_gravity(delta)
	handle_wall_jump()
	handle_jump()
	
	var direction = Input.get_axis("MoveLeft", "MoveRight")
	handle_acceleration(direction, delta)
	handle_air_acceleration(direction, delta)
	apply_friction(direction, delta)
	apply_air_resistance(direction, delta)
	update_animations(direction)
		
	move_and_slide()
	
	var was_on_floor = is_on_floor()
	var just_left_ledge = was_on_floor and not is_on_floor() and velocity.y >= 0
	if just_left_ledge:
		coyote_jump_timer.start()
	just_wall_jumped = false
	
func apply_gravity(delta):
	# Add the gravity.
	if not is_on_floor():
		if is_on_wall() and velocity.y > 0:
			velocity.y += 0.25 * gravity * delta
		else:
			velocity.y += gravity * delta

func handle_wall_jump():
	if not is_on_wall_only(): return
	
	var wall_normal = get_wall_normal()
	if (Input.is_action_just_pressed("MoveLeft") and wall_normal == Vector2.LEFT) or \
	(Input.is_action_just_pressed("MoveRight") and wall_normal == Vector2.RIGHT):
		velocity.x = wall_normal.x * movement_data.speed
		velocity.y = movement_data.jump_velocity
		just_wall_jumped = true

func handle_jump():
	if is_on_floor():
		air_jump = true

	if is_on_floor() or coyote_jump_timer.time_left > 0.0:
		if Input.is_action_just_pressed("Jump"):
			velocity.y = movement_data.jump_velocity
	elif not is_on_floor():
		if Input.is_action_just_pressed("Jump") and velocity.y < movement_data.jump_velocity / 2:
			velocity.y = movement_data.jump_velocity / 2
			
		if Input.is_action_just_pressed("Jump") and air_jump and not just_wall_jumped:
			velocity.y = movement_data.jump_velocity * 0.8
			air_jump = false

func handle_acceleration(direction, delta):
	if not is_on_floor(): return
	if direction != 0:
		velocity.x = move_toward(velocity.x, movement_data.speed * direction, movement_data.acceleration * delta)

func handle_air_acceleration(direction, delta):
	if is_on_floor(): return
	if direction != 0:
		velocity.x = move_toward(velocity.x, movement_data.speed * direction, movement_data.air_acceleration * delta)

func apply_friction(direction, delta):
	if direction == 0 and is_on_floor():
		velocity.x = move_toward(velocity.x, 0, movement_data.friction * delta)

func apply_air_resistance(direction, delta):
	if direction == 0 and not is_on_floor():
		velocity.x = move_toward(velocity.x, 0, movement_data.air_resistance * delta)

func update_animations(direction):
	if direction != 0:
		animated_sprite_2d.flip_h = (direction < 0)
		animated_sprite_2d.play("run")
	else:
		animated_sprite_2d.play("idle")
		
	if not is_on_floor():
		animated_sprite_2d.play("jump")

func _on_hazard_detector_area_entered(area):
	global_position = starting_position
