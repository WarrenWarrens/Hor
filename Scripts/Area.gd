extends Area3D

@export var target_camera: Camera3D

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited) 

	if has_overlapping_bodies():
		for body in get_overlapping_bodies():
			if body.is_in_group("player"):
				target_camera.make_current()

func _on_body_entered(body):
	if body.is_in_group("player"):
		target_camera.make_current()

func _on_body_exited(body):
	if body.is_in_group("player"):
		
		call_deferred("_check_fallback", body)

func _check_fallback(body):
	if target_camera.current:
		body.fp_camera.make_current()
