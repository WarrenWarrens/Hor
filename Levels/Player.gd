extends CharacterBody3D

var turn_strength: float = 0
var walk_strength: float = 0

func _process(delta):
	var right = Input.get_action_strength("right")
	var left = Input.get_action_strength("left")
	turn_strength = right - left
	
	var forward = Input.get_action_strength("up")
	var back = Input.get_action_strength("down")
	walk_strength = forward - back
	
func _physics_process(delta):
	rotate_y(turn_strength * delta)
	
	var basis = get_global_transform().basis
	var forward = basis.z
	
	velocity.x = forward.x * walk_strength
	velocity.z = forward.z * walk_strength
	velocity.y -= delta * 20
	
	move_and_slide()

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
