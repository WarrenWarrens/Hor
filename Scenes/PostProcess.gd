#extends CanvasLayer
#
#@onready var color_rect = $Buck
#
#func _ready():
	## Example: Connect to a hypothetical health signal
	#PlayerStats.health_changed.connect(_on_health_changed)
	#pass
#
#func _on_health_changed(current_health: int, max_health: int):
	#var material = color_rect.material as ShaderMaterial
	#
	#if current_health <= 25:
		## The string must exactly match the uniform name inside your shader code
		#material.set_shader_parameter("crt_distortion", 2.5)
		#material.set_shader_parameter("vignette_darkness", 0.8)
	#else:
		#material.set_shader_parameter("crt_distortion", 1.0)
		#material.set_shader_parameter("vignette_darkness", 0.2)
