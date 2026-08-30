extends CharacterBody3D

const WALK_SPEED: float = 3.0
const TURN_SPEED: float = 3.0

var turn_strength: float = 0
var walk_strength: float = 0

@onready var sprite = $AnimatedSprite3D 
@onready var head = $Head
@onready var fp_camera = $Head/Camera3D
@onready var indicator = $Head/Indicator
@onready var prompt_label = $HUD/PromptLabel
@onready var message_label = $HUD/MessageLabel
@onready var message_timer = $HUD/MessageTimer
@onready var flashlight = $Head/Camera3D/Flashlight

var is_in_first_person: bool = false
var previous_camera: Camera3D = null 

const MOUSE_SENSITIVITY: float = 0.003
const MAX_YAW: float = deg_to_rad(60)   
const MAX_PITCH: float = deg_to_rad(45)

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
		velocity.y -= delta * 20 
		move_and_slide()
		return 
	if abs(raw_walk) > 0:
		walk_strength = raw_walk * WALK_SPEED
		turn_strength = 0.0
	elif abs(raw_turn) > 0:
		turn_strength = raw_turn * TURN_SPEED
		walk_strength = 0.0
	else:
		walk_strength = 0.0
		turn_strength = 0.0

	rotate_y(turn_strength * delta)
	
	var player_basis = get_global_transform().basis
	var player_forward = -player_basis.z 
	
	velocity.x = player_forward.x * walk_strength
	velocity.z = player_forward.z * walk_strength
	velocity.y -= delta * 20 
	
	move_and_slide()
	update_sprite_direction()

func update_sprite_direction():
	var camera = get_viewport().get_camera_3d()
	if not camera:
		return
		
	var player_forward = global_transform.basis.z 
	var player_right = global_transform.basis.x
	var to_camera = (camera.global_position - global_position).normalized()
	
	player_forward.y = 0
	player_right.y = 0
	to_camera.y = 0
	
	var forward_dot = player_forward.normalized().dot(to_camera.normalized())
	var right_dot = player_right.normalized().dot(to_camera.normalized())
	
	var angle = atan2(right_dot, forward_dot)
	
	var sector = int(round(angle / (PI / 4.0)))
	
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

	previous_camera = get_viewport().get_camera_3d()
	fp_camera.make_current()

	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	current_yaw = 0.0
	current_pitch = 0.0
	head.rotation.y = 0.0
	fp_camera.rotation.x = 0.0

func exit_first_person():
	is_in_first_person = false

	if previous_camera:
		previous_camera.make_current()
		
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
func _unhandled_input(event):
	if event.is_action_pressed("flashlight"):
		flashlight.visible = not flashlight.visible
	if is_in_first_person and event is InputEventMouseMotion:
		current_yaw -= event.relative.x * MOUSE_SENSITIVITY
		current_pitch -= event.relative.y * MOUSE_SENSITIVITY

		current_yaw = clamp(current_yaw, -MAX_YAW, MAX_YAW)
		current_pitch = clamp(current_pitch, -MAX_PITCH, MAX_PITCH)

		head.rotation.y = current_yaw
		fp_camera.rotation.x = current_pitch
	

func _ready():
	message_timer.timeout.connect(_on_message_timeout)
	if GameManager.is_returning_from_battle:
		global_position = GameManager.player_position
		rotation.y = GameManager.player_rotation_y
		GameManager.is_returning_from_battle = false


func _on_message_timer_timeout() -> void:
	pass # Replace with function body.

func set_indicator_visible(is_visible: bool):
	indicator.visible = is_visible
	
func show_prompt(text: String):
	prompt_label.text = text
	prompt_label.show()
	
func hide_prompt():
	prompt_label.hide()
	
func show_pickup_message(text: String):
	message_label.text = text
	message_label.show()
	message_timer.start()

func _on_message_timeout():
	message_label.hide()
