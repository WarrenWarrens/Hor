extends Area3D

@export var camera_offset: Vector3 = Vector3(0, 8, 6) # Height and distance from player
@export var follow_speed: float = 3.0

# Define the boundaries the camera is allowed to slide within (relative to the Area3D center)
@export var x_limits: Vector2 = Vector2(-5.0, 5.0) 
@export var z_limits: Vector2 = Vector2(-5.0, 5.0)

@onready var target_camera = $Camera3D

var player: Node3D = null
var is_active: bool = false
var initial_rotation: Vector3

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	initial_rotation = target_camera.rotation

func _on_body_entered(body):
	if body.is_in_group("player"):
		player = body
		is_active = true
		target_camera.make_current()

func _on_body_exited(body):
	if body.is_in_group("player"):
		is_active = false
		player = null
		call_deferred("_check_fallback", body)

func _check_fallback(body):
	if target_camera.current:
		body.trailing_camera.make_current() 

func _process(delta):
	if is_active and player:
		var target_pos = player.global_position + camera_offset
		
		# Clamp the camera so it cannot leave the designated box
		target_pos.x = clamp(target_pos.x, global_position.x + x_limits.x, global_position.x + x_limits.y)
		target_pos.z = clamp(target_pos.z, global_position.z + x_limits.x, global_position.z + z_limits.y)
		
		target_camera.global_position = target_camera.global_position.lerp(target_pos, delta * follow_speed)
		
		# Lock rotation so it doesn't accidentally drift
		target_camera.rotation = initial_rotation
