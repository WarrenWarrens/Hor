extends CharacterBody3D

const SPEED: float = 4.0

var player: Node3D = null
var is_chasing: bool = false
var in_battle: bool = false
@export var enemy_id: String = "unique_enemy_name"
@export var enemy_type: String = "zombie" 

var battle_scene_template = preload("res://Scenes/BattleScene.tscn")

func _ready():
	if GameManager.defeated_enemies.has(enemy_id):
		queue_free()
		
func _physics_process(delta):
	if in_battle:
		return
		
	velocity.y -= delta * 20
	
	if is_chasing and player:
		var direction = global_position.direction_to(player.global_position)
		direction.y = 0 
		direction = direction.normalized()
		
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		
		look_at(player.global_position, Vector3.UP) 
	else:
		velocity.x = 0
		velocity.z = 0
		
	move_and_slide()

# Connected from DetectionZone Area3D
func _on_detection_zone_body_entered(body):
	if body.is_in_group("player") and not in_battle:
		player = body
		is_chasing = true
		print("Player spotted!")

func _on_attack_zone_body_entered(body):
	if body.is_in_group("player") and not in_battle:
		call_deferred("start_battle")
		
	

func start_battle():
	# 1. Save the player's exact state
	PlayerStats.change_health(-50)
	GameManager.last_room_path = get_tree().current_scene.scene_file_path
	GameManager.player_position = player.global_position
	GameManager.player_rotation_y = player.rotation.y
	GameManager.is_returning_from_battle = true
	
	GameManager.enemy_type_to_spawn = enemy_type
	GameManager.current_enemy_id = enemy_id
	
	SceneTransition.transition_to_scene("res://Scenes/BattleScene.tscn")

func _on_battle_won():
	get_tree().paused = false
	
	queue_free()


func _on_detection_zone_area_entered(area: Area3D) -> void:
	pass
