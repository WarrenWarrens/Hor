extends Node

var health = 90
var max_health = 100

var action = true

func reset():
	health = 100
	action = true

func game_over():
	reset()
	get_tree().reload_crrent_scene()
	
func take_damage(amount: int):
	change_health(-amount)
	if health <= 0: 
		game_over()
	
func change_health(amount: int):
	health = clamp(health + amount, 0, max_health)
	
func change_action(value: int):
	action = (value == 1)
	
func get_health() -> String:
	return str(health)
	
func get_action() ->String:
	return str(action)
	
