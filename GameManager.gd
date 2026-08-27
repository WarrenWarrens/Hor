extends Node

# Player Memory
var last_room_path: String = ""
var player_position: Vector3 = Vector3.ZERO
var player_rotation_y: float = 0.0
var is_returning_from_battle: bool = false

# Persistence Memory (Who have we killed?)
var defeated_enemies: Array[String] = []

# Battle Transition Data (For the modular scene)
var enemy_type_to_spawn: String = ""
var current_enemy_id: String = ""
