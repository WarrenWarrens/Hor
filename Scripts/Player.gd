extends CharacterBody3D

const WALK_SPEED: float = 3.0
const TURN_SPEED: float = 3.0

var turn_strength: float = 0
var walk_strength: float = 0

@onready var sprite = $AnimatedSprite3D 
@onready var head = $Head
@onready var fp_camera = $Head/Camera3D

var is_in_first_person: bool = false
var previous_camera: Camera3D = null # Remembers your fixed camera

const MOUSE_SENSITIVITY: float = 0.003
const MAX_YAW: float = deg_to_rad(60)   # Max left/right turn (60 degrees)
const MAX_PITCH: float = deg_to_rad(45) # Max up/down tilt (45 degrees)

var current_yaw: float = 0.0
var current_pitch: float = 0.0

func _process(_delta):
	var wants_first_person = Input.is_action_pressed("sprint")

	if wants_first_person and not is_in_first_person:
		enter_first_person()
	elif not wants_first_person and is_in_first_person:
		exit_first_person()
		

func _physics_process(delta):
	var right = Input.get_action_strength("right")
	var left = Input.get_action_strength("left")
	var forward = Input.get_action_strength("up")
	var back = Input.get_action_strength("down")
	
	var raw_turn = right - left
	var raw_walk = forward - back
	
	if is_in_first_person:
		velocity = Vector3.ZERO
		velocity.y -= delta * 20 # Keep gravity active
		move_and_slide()
		return # Skip the rest of the movement code
	# Prioritize walking over turning
	if abs(raw_walk) > 0:
		walk_strength = raw_walk * WALK_SPEED
		turn_strength = 0.0
	elif abs(raw_turn) > 0:
		turn_strength = raw_turn * TURN_SPEED
		walk_strength = 0.0
	else:
		walk_strength = 0.0
		turn_strength = 0.0

	# Apply rotation
	rotate_y(turn_strength * delta)
	
	# Note: In Godot, -Z is usually forward. If your character moves backwards, 
	# change this to -basis.z
	var player_basis = get_global_transform().basis
	var player_forward = -player_basis.z 
	
	velocity.x = player_forward.x * walk_strength
	velocity.z = player_forward.z * walk_strength
	velocity.y -= delta * 20 # Gravity
	
	move_and_slide()
	update_sprite_direction()

func update_sprite_direction():
	var camera = get_viewport().get_camera_3d()
	if not camera:
		return
		
	# Get directions on the horizontal plane (ignoring Y height)
	var player_forward = global_transform.basis.z # Use -basis.z if your character faces that way
	var player_right = global_transform.basis.x
	var to_camera = (camera.global_position - global_position).normalized()
	
	player_forward.y = 0
	player_right.y = 0
	to_camera.y = 0
	
	# Calculate the angle between where the player is facing and where the camera is
	var forward_dot = player_forward.normalized().dot(to_camera.normalized())
	var right_dot = player_right.normalized().dot(to_camera.normalized())
	
	# atan2 gives us an angle from -PI to PI
	var angle = atan2(right_dot, forward_dot)
	
	# Divide the circle into 8 slices (PI / 4 is 45 degrees)
	var sector = int(round(angle / (PI / 4.0)))
	
	# Map the sector to your animation names
	match sector:
		0: sprite.play("Front")
		1: sprite.play("FrontRight")
		2: sprite.play("Right")
		3: sprite.play("BackRight")
		4, -4: sprite.play("Back")
		-3: sprite.play("BackLeft")
		-2: sprite.play("Left")
		-1: sprite.play("FrontLeft")

func enter_first_person():
	is_in_first_person = true

	# Save the current fixed camera before switching
	previous_camera = get_viewport().get_camera_3d()
	fp_camera.make_current()

	# Lock and hide the mouse to the center of the screen
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	# Reset head rotation each time we enter the mode
	current_yaw = 0.0
	current_pitch = 0.0
	head.rotation.y = 0.0
	fp_camera.rotation.x = 0.0

func exit_first_person():
	is_in_first_person = false

	# Switch back to the room's fixed camera
	if previous_camera:
		previous_camera.make_current()
		
	# Free the mouse cursor
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
func _unhandled_input(event):
	if is_in_first_person and event is InputEventMouseMotion:
		# Subtract the relative mouse movement to our current angles
		current_yaw -= event.relative.x * MOUSE_SENSITIVITY
		current_pitch -= event.relative.y * MOUSE_SENSITIVITY

		# Clamp the angles so the player can't turn their head too far
		current_yaw = clamp(current_yaw, -MAX_YAW, MAX_YAW)
		current_pitch = clamp(current_pitch, -MAX_PITCH, MAX_PITCH)

		# Apply the clamped rotations
		head.rotation.y = current_yaw
		fp_camera.rotation.x = current_pitch

func _ready():
	# Check if we just finished a battle
	if GameManager.is_returning_from_battle:
		# Teleport to the saved position and rotation
		global_position = GameManager.player_position
		rotation.y = GameManager.player_rotation_y

		# Reset the flag so we don't teleport accidentally later
		GameManager.is_returning_from_battle = false
#extends CharacterBody3D
#
#var turn_strength: float = 0
#var walk_strength: float = 10
#
#func _process(delta):
	#var right = Input.get_action_strength("right")
	#var left = Input.get_action_strength("left")
	#turn_strength = right - left
	#
	#var forward = Input.get_action_strength("up")
	#var back = Input.get_action_strength("down")
	#walk_strength = forward - back
	#
#func _physics_process(delta):
	#rotate_y(turn_strength * delta)
	#
	#var basis = get_global_transform().basis
	#var forward = basis.z
	#
	#velocity.x = forward.x * walk_strength
	#velocity.z = forward.z * walk_strength
	#velocity.y -= delta * 20
	#
	#move_and_slide()

#const SPEED = 5.0
#const JUMP_VELOCITY = 4.5
#
#
#func _physics_process(delta: float) -> void:
	## Add the gravity.
	#if not is_on_floor():
		#velocity += get_gravity() * delta
#
	## Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		#velocity.y = JUMP_VELOCITY
#
	## Get the input direction and handle the movement/deceleration.
	## As good practice, you should replace UI actions with custom gameplay actions.
	#var input_dir := Input.get_vector("left", "right", "up", "down")
	#var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	#if direction:
		#velocity.x = direction.x * SPEED
		#velocity.z = direction.z * SPEED
	#else:
		#velocity.x = move_toward(velocity.x, 0, SPEED)
		#velocity.z = move_toward(velocity.z, 0, SPEED)
#
	#move_and_slide()
