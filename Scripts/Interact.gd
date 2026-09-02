extends Node3D

enum InteractType {ITEM, DOOR, LEVER, DEBUG, NPC}
@export var type: InteractType = InteractType.ITEM

#Item data
@export var item_id: String = ""
@export var item_name: String = ""
@export var item_amount: int = 1
@export var item_texture: Texture2D
@export var unique_world_id: String = ""

#Door
@export var target_scene: String = "" 
@export var target_door_id: String = ""
@export var is_locked: bool = false
@export var required_key_id: String = ""
@export var locked_message: String = "The door is firmly locked"
@export var prompt_text: String = "Interact"

#@export var interact_sound: AudioStream 
#@onready var sound_player = $InteractSound

@onready var sprite = $ItemSprite
var player_in_zone: CharacterBody3D = null

func _ready() -> void:
	if GameManager.unlocked_doors.has(unique_world_id):
		is_locked = false
	
	if item_texture:
		sprite.texture = item_texture
		sprite.show()
	#elif type != InteractType.ITEM:
		#sprite.hide()
	
	#if type == InteractType.ITEM:
		#if GameManager.collected_world_items.has(unique_world_id):
			#queue_free()
			#return
			#
		#if item_texture:
			#sprite.texture = item_texture
		#elif type !=InteractType.ITEM:
			#sprite.hide()
			

func _process(_delta: float) -> void:
	if player_in_zone and Input.is_action_just_pressed("interact"):
		_perform_interaction()

func _perform_interaction():
	match type:
		InteractType.ITEM:
			player_in_zone.set_indicator_visible(false)
			player_in_zone.hide_prompt()
			
			if unique_world_id != "":
				GameManager.collected_world_items.append(unique_world_id)
			else:
				print("WARNING: Item missing unique_world_id!")
				
				
			PlayerInventory.add_item(item_id, item_amount)
			
			var item_text = item_name
			if item_amount > 1:
				item_text = str(item_amount) + " x " + item_name
			var final_message = "Acquire: [color=darkblue]" + item_text + "[/color]"
			player_in_zone.show_pickup_message(final_message)
			queue_free()
			
		InteractType.DOOR:
			player_in_zone.hide_prompt()
			
			if is_locked:
				player_in_zone.show_pickup_message(locked_message)
				return
				
			#if interact_sound:
				#sound_player.stream = interact_sound
				#sound_player.play()
				#await sound_player.finished
			
			GameManager.target_door_id = target_door_id
			get_tree().change_scene_to_file(target_scene)
		InteractType.LEVER:
			print("Lever pulled!")
		InteractType.DEBUG:
			PlayerStats.change_health(-25)
			print("Took Damage!")
			

func _on_detect_zone_body_entered(body):
	if body.is_in_group("player"):
		body.set_indicator_visible(true)

func _on_detect_zone_body_exited(body):
	if body.is_in_group("player"):
		body.set_indicator_visible(false)

func _on_pickup_zone_body_entered(body):
	if body.is_in_group("player") and body.has_method("show_prompt"):
		player_in_zone = body
		body.current_interactable = self
		
		if type == InteractType.ITEM:
			body.show_prompt("Press E to pickup " + item_name)
		else:
			body.show_prompt("Press E to " + prompt_text)
		
func _on_pickup_zone_body_exited(body):
	if body.is_in_group("player"):
		if "current_interactable" in body and body.current_interactable == self:
			body.current_interactable = null
		
		player_in_zone = null
		if body.has_method("hide_prompt"):
			body.hide_prompt()
	
func unlock_door():
	is_locked = false
	if unique_world_id != "":
		GameManager.unlocked_doors.append(unique_world_id)
