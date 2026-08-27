extends Area3D

@export var target_camera: Camera3D

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited) # NEW: Listen for when they leave

	if has_overlapping_bodies():
		for body in get_overlapping_bodies():
			if body.is_in_group("player"):
				target_camera.make_current()

func _on_body_entered(body):
	if body.is_in_group("player"):
		target_camera.make_current()

# NEW: The Failsafe Logic
func _on_body_exited(body):
	if body.is_in_group("player"):
		# call_deferred waits one frame. This gives the player time to 
		# step into an adjacent camera zone if they are overlapping.
		call_deferred("_check_fallback", body)

func _check_fallback(body):
	# If THIS camera is still the current one, it means no new zone took over
	if target_camera.current:
		# Fall back to the player's built-in camera so the engine doesn't crash
		body.fp_camera.make_current()
