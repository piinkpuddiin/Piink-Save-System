extends Node

# TODO: clean up code, and add more exports variables!
func _ready() -> void:
	SaveLoad.slot_loaded.connect(load_data)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("quick_save"):
		SaveLoad.quick_save()
	
	if event.is_action_pressed("quick_load"):
		SaveLoad.quick_load()

func load_data(save_name: String) -> void:
	GlobalVar.character_class = SaveLoad.load(save_name).get('character_class')
	GlobalVar.character_wisdom = SaveLoad.load(save_name).get('character_wisdom')
	GlobalVar.character_strength = SaveLoad.load(save_name).get('character_strength')
