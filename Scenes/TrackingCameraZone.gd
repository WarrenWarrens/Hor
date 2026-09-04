extends Area3D

@export var camera_offset: Vector3 = Vector3(0, 8, 6) 
@export var follow_speed: float = 3.0

@onready var limit_a = $LimitA
@onready var limit_b = $LimitB
@onready var target_camera = $SpringArm3D/Camera3D

var player: Node3D = null
var is_active: bool = false
var initial_rotation: Vector3

func _ready():
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

func _physics_process(delta):
	if is_active and player:
		var target_pos = player.global_position + camera_offset
		var min_x = min(limit_a.global_position.x, limit_b.global_position.x)
		var max_x = max(limit_a.global_position.x, limit_b.global_position.x)
		var min_z = min(limit_a.global_position.z, limit_b.global_position.z)
		var max_z = max(limit_a.global_position.z, limit_b.global_position.z)

		target_pos.x = clamp(target_pos.x, min_x, max_x)
		target_pos.z = clamp(target_pos.z, min_z, max_z)

		target_camera.global_position = target_camera.global_position.lerp(target_pos, delta * follow_speed)
		target_camera.rotation = initial_rotation
