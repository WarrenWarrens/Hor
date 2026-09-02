extends Node

var target_door_id: String = ""
var collected_world_items: Array[String] = []
var unlocked_doors: Array[String] = []

var last_room_path: String = ""
var player_position: Vector3 = Vector3.ZERO
var player_rotation_y: float = 0.0
var is_returning_from_battle: bool = false

var defeated_enemies: Array[String] = []

var enemy_type_to_spawn: String = ""
var current_enemy_id: String = ""
