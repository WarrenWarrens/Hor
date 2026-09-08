extends Control

@onready var container = $SubViewportContainer
@onready var background = $ColorRect

var target_pos: Vector2
var target_scale: Vector2
var tween: Tween

# Define all your custom layouts here
var layouts = {
	"purple_top_right": {
		"color": Color(0.4, 0.1, 0.4, 1.0), 
		"pos": Vector2(600, 50),       
		"scale": Vector2(2, 2) # 640x480      
	},
	"blue_middle": {
		"color": Color(0.1, 0.2, 0.5, 1.0), 
		"pos": Vector2(320, 200),      
		"scale": Vector2(3, 3) # 960x720        
	}
}

func _ready():
	GameManager.toggle_fullscreen.connect(_on_fullscreen_toggled)
	GameManager.change_overlay.connect(_apply_layout)
	
	# Set the starting layout
	_apply_layout("blue_middle")

func _apply_layout(layout_name: String):
	if not layouts.has(layout_name):
		return
		
	var data = layouts[layout_name]
	target_pos = data["pos"]
	target_scale = data["scale"]
	
	# Use a tween to smoothly change the background color
	var bg_tween = create_tween()
	bg_tween.tween_property(background, "color", data["color"], 0.5)
	
	# If we are not currently fullscreen, immediately animate the game box to the new spot
	if container.position != Vector2.ZERO:
		_animate_viewport(target_pos, target_scale, 1.0)

func _on_fullscreen_toggled(is_fullscreen: bool):
	if is_fullscreen:
		# Calculate exactly how much we need to scale the 320x240 box to fill the monitor
		var screen_size = get_viewport_rect().size
		var full_scale = screen_size / Vector2(320, 240)
		
		_animate_viewport(Vector2.ZERO, full_scale, 0.0) # Fade background out
	else:
		_animate_viewport(target_pos, target_scale, 1.0) # Fade background in

func _animate_viewport(new_pos: Vector2, new_scale: Vector2, bg_alpha: float):
	# Kill any currently running animation so it doesn't glitch if you spam the button
	if tween and tween.is_running():
		tween.kill()
		
	tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	tween.tween_property(container, "position", new_pos, 0.5)
	tween.tween_property(container, "scale", new_scale, 0.5)
	tween.tween_property(background, "modulate:a", bg_alpha, 0.5)
