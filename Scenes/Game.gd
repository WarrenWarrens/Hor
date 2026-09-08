extends Control

@onready var container = $SubViewportContainer
@onready var background = $ColorRect

var original_position: Vector2
var original_size: Vector2

func _ready():
	original_position = container.position
	original_size = container.size
	
	GameManager.toggle_fullscreen.connect(_on_fullscreen_toggled)

func _on_fullscreen_toggled(is_fullscreen: bool):
	if is_fullscreen:
		background.hide()
		
		container.set_anchors_preset(PRESET_FULL_RECT)
		container.offset_left = 0
		container.offset_top = 0
		container.offset_right = 0
		container.offset_bottom = 0
	else:
		background.show()
		
		container.set_anchors_preset(PRESET_TOP_LEFT)
		container.position = original_position
		container.size = original_size
