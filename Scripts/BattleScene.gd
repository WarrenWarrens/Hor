extends Control

# This grabs the Button node directly. 
# Make sure the name inside the quotes exactly matches the name of your Button node in the scene tree!
@onready var button = $Button 

func _ready():
	print("A wild " + GameManager.enemy_type_to_spawn + " appeared!")

	# 1. Force the mouse cursor to be visible and usable just in case it got trapped
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	# 2. Forcefully connect the button via code to bypass the Godot Editor
	if button:
		if not button.pressed.is_connected(_on_button_pressed):
			button.pressed.connect(_on_button_pressed)
	else:
		print("ERROR: Button node not found! Check your spelling for $Button.")

func _on_button_pressed():
	print("BUTTON WAS CLICKED!")

	GameManager.defeated_enemies.append(GameManager.current_enemy_id)
	SceneTransition.transition_to_scene(GameManager.last_room_path)
