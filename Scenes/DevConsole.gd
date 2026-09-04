extends CanvasLayer

@onready var output_log = $Panel/VBoxContainer/OutputLog
@onready var input_line = $Panel/VBoxContainer/InputLine

func _ready():
	hide()
	# Connect the Godot signal for pressing Enter in a LineEdit
	input_line.text_submitted.connect(_on_text_submitted)

func _input(event):
	# KEY_ASCIITILDE or KEY_QUOTELEFT is the `~` key above Tab

	if event.is_action_pressed("dev"):
	#if event is InputEventKey and event.pressed and event.keycode == KEY_QUOTELEFT:
		toggle_console()
		# Consume the input so it doesn't type a backtick into the text box
		get_viewport().set_input_as_handled() 

func toggle_console():
	visible = !visible
	if visible:
		get_tree().paused = true
		input_line.grab_focus()
		input_line.clear()
		GameManager.can_open_inventory = false

	else:
		get_tree().paused = false
		input_line.release_focus()
		GameManager.can_open_inventory = true


func print_log(text: String):
	output_log.text += text + "\n"

func _on_text_submitted(new_text: String):
	input_line.clear()
	
	# Strip extra spaces and ignore empty submits
	var clean_text = new_text.strip_edges()
	if clean_text == "":
		return
		
	print_log("> " + clean_text)
	
	# Split the string by spaces. 
	# Example: "give green_herb 2" -> ["give", "green_herb", "2"]
	var parts = clean_text.split(" ")
	var command = parts[0].to_lower()
	
	# Slice the array to get everything except the first word
	var args = parts.slice(1) 
	
	_process_command(command, args)
	
	# Keep focus on the line edit so you can type multiple commands rapidly
	input_line.grab_focus()

func _process_command(command: String, args: PackedStringArray):
	match command:
		"heal":
			# Assuming PlayerStats has a change_health function
			PlayerStats.change_health(100)
			print_log("Player fully healed.")
			
		"give":
			# Requires 2 arguments: ID and Amount
			if args.size() >= 2:
				var item_id = args[0]
				var amount = args[1].to_int() # Convert string to integer

				PlayerInventory.add_item(item_id, amount)
				print_log("Added " + str(amount) + "x " + item_id + " to inventory.")
			else:
				print_log("Error: Usage is 'give [item_id] [amount]'")
				
		"noclip":
			# Find the player in the scene tree to toggle their collision
			var player = get_tree().get_first_node_in_group("player")
			if player and player.has_method("toggle_noclip"):
				player.toggle_noclip()
				print_log("Noclip toggled.")
			else:
				print_log("Error: Could not find player node.")
				
		"god":
			GameManager.god_mode = !GameManager.god_mode
			print_log("God mode: " + str(GameManager.god_mode))
			
		"map":
			if args.size() >= 1:
				toggle_console() # Close terminal before switching scenes
				SceneTransition.transition_to_scene("res://Levels/" + args[0] + ".tscn")
			else:
				print_log("Error: Usage is 'map [scene_name]'")
				
		"clear":
			output_log.text = ""
			
		_:
			print_log("Unknown command: '" + command + "'")
