extends CanvasLayer

@onready var animation_player = $AnimationPlayer

func transition_to_scene(target_path: String):
	# Fade to black
	animation_player.play("fade_to_black")

	# Wait for the animation to finish
	await animation_player.animation_finished

	# Swap the scenes while the screen is black
	get_tree().change_scene_to_file(target_path)

	# Fade back in
	animation_player.play_backwards("fade_to_black")
