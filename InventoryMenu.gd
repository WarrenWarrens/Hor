extends CanvasLayer

@onready var item_rect = $MainSplit/RightMenu/ContentArea/ItemRect
@onready var weapon_rect = $MainSplit/RightMenu/ContentArea/WeaponRect
@onready var status_image = $MainSplit/RightMenu/RightLowerMenu/StatusImage


func _ready():
	hide()
	item_rect.hide()
	weapon_rect.hide()

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		if get_tree().paused:
			close_inventory()
		else:
			open_inventory()
			
func open_inventory():
	var current_frame = get_viewport().get_texture().get_image()
	var frame_texture = ImageTexture.create_from_image(current_frame)
	
	status_image.texture = frame_texture
	get_tree().paused = true
	show()

func close_inventory():
	get_tree().paused = false
	hide()
	
	item_rect.hide()
	weapon_rect.hide()
	

func _on_items_btn_pressed():
	item_rect.show()
	weapon_rect.hide()

func _on_weapons_btn_pressed():
	item_rect.hide()
	weapon_rect.show()
	
func _on_tools_btn_pressed() -> void:
	pass 

func _on_options_btn_pressed() -> void:
	pass 
