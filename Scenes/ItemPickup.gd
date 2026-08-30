extends Node3D
enum PickupType { HEALTH, ARMOUR, AMMO, WEAPON, KEYCARD }

@export var type: PickupType = PickupType.WEAPON
#@export var item_name: String = "shotgun" 
@export var amount: int = 10

@export var item_name: String = "Green Herb"
var player_in_pickup_zone: CharacterBody3D = null

func _ready() -> void:
	#body_entered.connect(_on_body_entered)
	pass


func _process(delta: float) -> void:
	if player_in_pickup_zone and Input.is_action_just_pressed("interact"):
		_pickup_item()
	pass

func _pickup_item():
	player_in_pickup_zone.set_indicator_visible(false)
	player_in_pickup_zone.hide_prompt()
	player_in_pickup_zone.show_pickup_message("Aquired: " + item_name)
	
	queue_free()

func _on_detect_zone_body_entered(body):
	if body.is_in_group("player"):
		body.set_indicator_visible(true)
		
func _on_detect_zone_body_exited(body):
	if body.is_in_group("player"):
		body.set_indicator_visible(false)
		
func _on_pickup_zone_body_entered(body):
	if body.is_in_group("player"):
		player_in_pickup_zone = body
		body.show_prompt("Press E to pickup " + item_name)
		
func _on_pickup_zone_body_exited(body):
	if body.is_in_group("player"):
		player_in_pickup_zone = null
		body.hide_prompt()

#func _on_body_entered(body: Node3D) -> void:
	## Make sure this string exactly matches the group name on your Player node
	#if body.is_in_group("player"): 
		#var hud = body.get_node("HUD")
		#var picked_up = false
		#
		#match type:
			#PickupType.HEALTH:
				#PlayerStats.change_health(amount)
				#if hud and hud.has_method("add_message"):
					#hud.add_message("Picked up +" + str(amount) + " Health!")
				#picked_up = true
				#
			#PickupType.ARMOUR:
				#PlayerStats.pickup_armor(amount, is_megaarmor)
				#if hud and hud.has_method("add_message"):
					#var msg = "Megaarmor!" if is_megaarmor else "Picked up Armor!"
					#hud.add_message(msg)
				#picked_up = true
				#
			#PickupType.AMMO:
				## Route directly to your PlayerInventory singleton
				#PlayerInventory.change_ammo(item_name, amount)
				#if hud and hud.has_method("add_message"):
					#hud.add_message("Picked up " + str(amount) + " " + item_name.capitalize() + " ammo!")
				#picked_up = true
				#
			#PickupType.WEAPON:
				## Reach out to the player script to unlock the weapon
				#if body.has_method("unlock_weapon"):
					#body.unlock_weapon(item_name)
					#if hud and hud.has_method("add_message"):
						#hud.add_message("Acquired the " + item_name.capitalize() + "!")
					#picked_up = true
					#
			#PickupType.KEYCARD:
				## Route directly to your PlayerInventory singleton
				#PlayerInventory.add_key(item_name)
				#if hud and hud.has_method("add_message"):
					#hud.add_message("Picked up the " + item_name.capitalize() + " keycard!")
				#picked_up = true
#
		## If the item was successfully collected, delete it from the world
		#if picked_up:
			## You can play a global pickup sound effect right here before freeing
			#queue_free()
