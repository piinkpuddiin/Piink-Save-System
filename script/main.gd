extends Node

# TODO: clean up code, and add more exports variables!

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("quick_save"):
		SaveLoad.quick_save()
	
	if event.is_action_pressed("quick_load"):
		SaveLoad.quick_load()
