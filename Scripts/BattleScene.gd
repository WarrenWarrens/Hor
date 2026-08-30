extends Control

@onready var button = $Button 

func _ready():
	print("A wild " + GameManager.enemy_type_to_spawn + " appeared!")
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	if button:
		if not button.pressed.is_connected(_on_button_pressed):
			button.pressed.connect(_on_button_pressed)
	else:
		print("ERROR: Button node not found! Check your spelling for $Button.")

func _on_button_pressed():
	print("BUTTON WAS CLICKED!")

	GameManager.defeated_enemies.append(GameManager.current_enemy_id)
	SceneTransition.transition_to_scene(GameManager.last_room_path)
