extends CanvasLayer


@onready var weapons_btn = $MainSplit/LeftMenu/WeaponsBtn
@onready var supplies_btn = $MainSplit/LeftMenu/SuppliesBtn
@onready var tools_btn = $MainSplit/LeftMenu/ToolsBtn
@onready var options_btn = $MainSplit/LeftMenu/OptionsBtn

@onready var supplies_rect = $MainSplit/RightMenu/ContentArea/SuppliesRect
@onready var weapon_rect = $MainSplit/RightMenu/ContentArea/WeaponRect
@onready var status_image = $MainSplit/RightMenu/RightLowerMenu/StatusImage
@onready var health_overlay = $MainSplit/RightMenu/RightLowerMenu/StatusImage/HealthOverlay

@onready var weapon_list = $MainSplit/RightMenu/ContentArea/WeaponRect/WeaponScroll/WeaponList
@onready var weapon_details = $MainSplit/RightMenu/ContentArea/WeaponRect/WeaponDetails
@onready var name_label1 = $MainSplit/RightMenu/ContentArea/WeaponRect/WeaponDetails/HeaderBox/HeaderVBox/NameLabel
@onready var desc_label1 = $MainSplit/RightMenu/ContentArea/WeaponRect/WeaponDetails/HeaderBox/HeaderVBox/DescLabel
@onready var action_buttons_container1 = $MainSplit/RightMenu/ContentArea/WeaponRect/WeaponDetails/ActionButtons

@onready var supplies_list = $MainSplit/RightMenu/ContentArea/SuppliesRect/SuppliesScroll/SuppliesList
@onready var supplies_details = $MainSplit/RightMenu/ContentArea/SuppliesRect/SuppliesDetails
@onready var name_label2 = $MainSplit/RightMenu/ContentArea/SuppliesRect/SuppliesDetails/HeaderBox/HeaderVBox/NameLabel
@onready var desc_label2 = $MainSplit/RightMenu/ContentArea/SuppliesRect/SuppliesDetails/HeaderBox/HeaderVBox/DescLabel
@onready var action_buttons_container2 = $MainSplit/RightMenu/ContentArea/SuppliesRect/SuppliesDetails/ActionButtons

@onready var ui_sound_player = $UISoundPlayer

var item_slot_scene = preload("res://Scenes/ItemSlot.tscn")

func _ready():
	hide()
	supplies_rect.hide()
	weapon_rect.hide()
	weapon_details.hide()

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		if get_tree().paused:
			close_inventory()
		else:
			open_inventory()
			
func open_inventory():
	await RenderingServer.frame_post_draw
	
	var current_frame = get_viewport().get_texture().get_image()
	var frame_texture = ImageTexture.create_from_image(current_frame)
	status_image.texture = frame_texture
	
	update_health_colour()
	
	get_tree().paused = true
	show()

func close_inventory():
	get_tree().paused = false
	hide()
	
	weapons_btn.remove_theme_color_override("font_color")
	supplies_btn.remove_theme_color_override("font_color")

	supplies_rect.hide()
	weapon_rect.hide()
	
func update_health_colour():
	var current_health = int(PlayerStats.get_health())
	
	if current_health > 70:
		health_overlay.modulate = Color(0.2,0.8,0.2,0.6)
	elif current_health > 50:
		health_overlay.modulate = Color(0.8,0.8,0.2,0.6)
	else:
		health_overlay.modulate = Color(0.8,0.2,0.2,0.6)
			

func _on_weapons_btn_pressed():
	if weapon_rect.visible:
		weapon_rect.hide()
		weapon_details.hide()
		weapons_btn.remove_theme_color_override("font_color")
	else:
		supplies_rect.hide()
		supplies_details.hide()
		supplies_btn.remove_theme_color_override("font_color")
		
		weapon_rect.show()
		weapon_details.hide()
		weapons_btn.add_theme_color_override("font_color", Color(0.8,0.8,0.2))
		build_weapon_list()
		
	
func _on_supplies_btn_pressed():
	if supplies_rect.visible:
		supplies_rect.hide()
		supplies_details.hide()
		supplies_btn.remove_theme_color_override("font_color")
	else:
		weapon_rect.hide()
		weapon_details.hide()
		weapons_btn.remove_theme_color_override("font_color")
		
		supplies_rect.show()
		supplies_details.hide()
		supplies_btn.add_theme_color_override("font_color", Color(0.8,0.8,0.2))
		build_supplies_list()
	
	
func build_weapon_list():
	for child in weapon_list.get_children():
		child.queue_free()
	
	for item in PlayerInventory.items:
		if item["type"] == "weapon" or item["type"] =="ammo":
			var slot = item_slot_scene.instantiate()
			weapon_list.add_child(slot)
			
			var icon_node = slot.get_node("TextureRect") 
			if item.has("icon"):
				icon_node.texture = load(item["icon"])
			
			var qty_label = slot.get_node("Label")
			if item["quantity"] > 1:
				qty_label.text = "x" + str(item["quantity"])
				qty_label.show()
			else:
				qty_label.hide()
			
			slot.pressed.connect(func(): _on_item_slot_pressed(item))
			
func _on_item_slot_pressed(item_data: Dictionary):
	if item_data["type"] == "weapon" or item_data["type"] == "ammo":
		weapon_details.show()
		name_label1.text = item_data["name"]
		desc_label1.text = item_data["description"]
		for child in action_buttons_container1.get_children():
			child.queue_free()
			
		for action in item_data["actions"]:
			var btn = Button.new()
			btn.text = action
			action_buttons_container1.add_child(btn)
			
			btn.pressed.connect(func(): print("Preformed " + action + " on " + item_data["name"]))
	elif item_data["type"] == "heal" or item_data["type"] =="key":
		supplies_details.show()
		
		name_label2.text = item_data["name"]
		desc_label2.text = item_data["description"]
		for child in action_buttons_container2.get_children():
			child.queue_free()
		
		for action in item_data["actions"]:
			var btn = Button.new()
			btn.text = action
			action_buttons_container2.add_child(btn)
			btn.pressed.connect(func(): print("Preformed " + action + " on " + item_data["name"]))
	
	
	
	

	
		

func _on_tools_btn_pressed() -> void:
	pass 

func _on_options_btn_pressed() -> void:
	pass 



	
func build_supplies_list():
	for child in supplies_list.get_children():
		child.queue_free()
	
	for item in PlayerInventory.items:
		if item["type"] == "heal" or item["type"] =="key":
			var slot = item_slot_scene.instantiate()
			supplies_list.add_child(slot)
			
			var icon_node = slot.get_node("TextureRect") 
			if item.has("icon"):
				icon_node.texture = load(item["icon"])
			
			var qty_label = slot.get_node("Label")
			if item["quantity"] > 1:
				qty_label.text = "x" + str(item["quantity"])
				qty_label.show()
			else:
				qty_label.hide()
			
			slot.pressed.connect(func(): _on_item_slot_pressed(item))
			
