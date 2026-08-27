extends Area3D

@export var target_camera: Camera3D

func _ready():
	# 1. Connect the signal properly as soon as the scene loads
	body_entered.connect(_on_body_entered)

	# 2. Check if the player teleported directly inside this zone 
	# (This fixes the first-person camera bug when returning from battle)
	if has_overlapping_bodies():
		for body in get_overlapping_bodies():
			if body.is_in_group("player"):
				target_camera.make_current()

func _on_body_entered(body):
	# Make this zone's camera the active one when walked into
	if body.is_in_group("player"):
		target_camera.make_current()
