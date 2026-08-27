extends CharacterBody3D

const SPEED: float = 4.0

var player: Node3D = null
var is_chasing: bool = false
var in_battle: bool = false
@export var enemy_id: String = "unique_enemy_name"
@export var enemy_type: String = "zombie" # Tells the battle scene what to spawn

# Load the battle scene into memory so it's ready to instance
var battle_scene_template = preload("res://Scenes/BattleScene.tscn")

func _ready():
	# As soon as the room loads, the enemy checks if it's already dead.
	if GameManager.defeated_enemies.has(enemy_id):
		queue_free() # Delete self before the player even sees it
		
func _physics_process(delta):
	# Stop moving if we are in battle or gravity is pulling us down
	if in_battle:
		return
		
	velocity.y -= delta * 20 # Gravity
	
	if is_chasing and player:
		# Calculate direction to the player
		var direction = global_position.direction_to(player.global_position)
		direction.y = 0 # Keep movement flat on the floor
		direction = direction.normalized()
		
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		
		# Make the enemy sprite look at the player (optional)
		# look_at(player.global_position, Vector3.UP) 
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

# Connected from AttackZone Area3D
func _on_attack_zone_body_entered(body):
	if body.is_in_group("player") and not in_battle:
		# call_deferred tells Godot "Wait until it's safe, then run start_battle"
		call_deferred("start_battle")
		
	#if body.is_in_group("player") and not in_battle:
		#start_battle()

func start_battle():
	# 1. Save the player's exact state
	GameManager.last_room_path = get_tree().current_scene.scene_file_path
	GameManager.player_position = player.global_position
	GameManager.player_rotation_y = player.rotation.y
	GameManager.is_returning_from_battle = true
	
	# 2. Tell the battle scene what to load
	GameManager.enemy_type_to_spawn = enemy_type
	GameManager.current_enemy_id = enemy_id
	
	# 3. Actually load the battle scene
	SceneTransition.transition_to_scene("res://Scenes/BattleScene.tscn")

func _on_battle_won():
	# 1. Unpause the 3D world so the player can move again
	get_tree().paused = false
	
	# 2. Destroy the enemy (since they were defeated)
	queue_free()


func _on_detection_zone_area_entered(area: Area3D) -> void:
	pass # Replace with function body.
