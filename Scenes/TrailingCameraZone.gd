extends Area3D

@export var follow_speed: float = 6.0
@export var rotation_speed: float = 3.0
@export var height_offset: float = 1.5 # Aim at the character's shoulders/head

@onready var spring_arm = $SpringArm3D
@onready var target_camera = $SpringArm3D/Camera3D

var player: Node3D = null
var is_active: bool = false

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	# Detach the arm from the Area3D so it can freely follow the player
	spring_arm.top_level = true 

func _on_body_entered(body):
	if body.is_in_group("player"):
		player = body
		is_active = true
		
		# Instantly snap the camera behind the player upon entering the zone
		spring_arm.global_position = player.global_position + Vector3(0, height_offset, 0)
		spring_arm.rotation.y = player.rotation.y
		
		target_camera.make_current()

func _on_body_exited(body):
	if body.is_in_group("player"):
		is_active = false
		player = null
		call_deferred("_check_fallback", body)

func _check_fallback(body):
	if target_camera.current:
		body.fp_camera.make_current()

func _process(delta):
	if is_active and player:
		# 1. Smoothly follow the player's physical position
		var target_pos = player.global_position + Vector3(0, height_offset, 0)
		spring_arm.global_position = spring_arm.global_position.lerp(target_pos, delta * follow_speed)
		
		# 2. Smoothly rotate the arm to trail behind the player's back
		# Using lerp_angle prevents the camera from violently spinning the wrong way around
		spring_arm.rotation.y = lerp_angle(spring_arm.rotation.y, player.rotation.y, delta * rotation_speed)
		
		# 3. Optional SH3 mechanic: Pressing sprint/aim instantly snaps camera behind player
		# if Input.is_action_just_pressed("aim"):
		#     spring_arm.rotation.y = player.rotation.y
