extends Area3D

@export var target_camera: Camera3D
@export var camera_path: Path3D
@export var path_follow: PathFollow3D

var player: Node3D = null
var is_active: bool = false

func _ready():
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
	if not body_exited.is_connected(_on_body_exited):
		body_exited.connect(_on_body_exited)
	
	if has_overlapping_bodies():
		for body in get_overlapping_bodies():
			if body.is_in_group("player"):
				_activate_camera(body)

func _on_body_entered(body):
	if body.is_in_group("player"):
		_activate_camera(body)

func _activate_camera(body):
	if target_camera:
		player = body
		is_active = true
		target_camera.make_current()
	else:
		print("ERROR: No Target Camera assigned in Inspector for zone: ", name)

func _on_body_exited(body):
	if body.is_in_group("player"):
		is_active = false
		player = null
		call_deferred("_check_fallback", body)

func _check_fallback(body):
	if target_camera and target_camera.current:
		body.fp_camera.make_current()

func _process(delta):
	if is_active and player and camera_path and path_follow and target_camera:
		var local_pos = camera_path.to_local(player.global_position)
		var closest_offset = camera_path.curve.get_closest_offset(local_pos)
		
		path_follow.progress = lerpf(path_follow.progress, closest_offset, delta * 3.0)
		target_camera.look_at(player.global_position + Vector3(0, 1, 0))
