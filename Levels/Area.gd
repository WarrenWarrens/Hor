extends Area3D

# This allows you to select the corresponding Camera3D in the Godot Inspector
@export var target_camera: Camera3D

func _ready():
	# Connect the body_entered signal via code (or do it via the Node menu)
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	# Check if the object entering the zone is the player
	if body.is_in_group("player"):
		# Make this zone's camera the active one
		target_camera.make_current()
