extends Control

@onready var container = $SubViewportContainer
@onready var bg_container = $BackgroundContainer

var target_pos: Vector2
var target_scale: Vector2
var tween: Tween

var current_overlay_scene: Node = null

# Define all your custom layouts here
func _ready():
	GameManager.toggle_fullscreen.connect(_on_fullscreen_toggled)
	GameManager.change_overlay.connect(_apply_layout)
	GameManager.change_overlay.emit("res://Scenes/Overlay/PurpleOverlay.tscn")

func _apply_layout(scene_path: String):
	# 1. Remove the old overlay
	if current_overlay_scene:
		current_overlay_scene.queue_free()
		
	# 2. Load and add the new overlay
	var new_overlay = load(scene_path).instantiate()
	bg_container.add_child(new_overlay)
	current_overlay_scene = new_overlay
	
	# 3. Find the placeholder slot in the new scene
	var slot = new_overlay.get_node("GameSlot")
	
	# 4. Calculate the scale based on the slot's visual size vs the 320x240 viewport
	var target_scale = slot.size / Vector2(320, 240)
	
	if container.position != Vector2.ZERO: # Don't shrink if currently fullscreen
		_animate_viewport(slot.global_position, target_scale)

func _on_fullscreen_toggled(is_fullscreen: bool):
	GameManager.is_fullscreen = is_fullscreen
	if is_fullscreen:
		var screen_size = get_viewport_rect().size
		var full_scale = screen_size / Vector2(320, 240)
		_animate_viewport(Vector2.ZERO, full_scale)
		tween.tween_callback(bg_container.hide)

	else:
		bg_container.show() 
		var slot = current_overlay_scene.get_node("GameSlot")
		var target_scale = slot.size / Vector2(320, 240)
		_animate_viewport(slot.global_position, target_scale)

func _animate_viewport(new_pos: Vector2, new_scale: Vector2):
	if tween and tween.is_running():
		tween.kill()
	tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(container, "position", new_pos, 0.5)
	tween.tween_property(container, "scale", new_scale, 0.5)
