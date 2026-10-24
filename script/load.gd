extends Control

@onready var main: Node = $"../.."
@onready var slots = {}
@export var notification_win: Node


func _ready() -> void:
	generate_slots()
	# Checks once the game is booted up.
	check_buttons() 
	# Checks every time slot_saved is emitted.
	SaveLoad.slot_saved.connect(check_buttons) 


func _input(event: InputEvent) -> void:
	for i in %load_vbox.get_children():
		# Only delete if we are mousing over and press delete.
		if event.is_action_pressed("delete") and i.is_hovered():
			if SaveLoad.save_slot_exists(str(i.get_meta("save_slot"))):
				notification_win.pop_in([
					SaveLoad.delete_save.bind(str(i.get_meta("save_slot"))),
					SaveLoad.slot_saved.emit.bind(str(i.get_meta("save_slot")))],
					"You are about to delete save: " + str(i.get_meta("save_slot")) + ". Are you sure?",
					"Deleting Save"
				)

## Gets emitted when a button gets saved.
func check_buttons(_save: String=""):
	await get_tree().process_frame
	
	for i in %load_vbox.get_children():
		if SaveLoad.save_slot_exists(str(i.get_meta("save_slot"))):
			i.disabled = false
			i.find_child("slot_status").text = "[u]SAVED"
			i.find_child("slot_status").modulate = Color(1.0, 1.0, 1.0, 1.0)
			i.find_child("saved_time").modulate = Color(1.0, 1.0, 1.0, 1.0)
			i.find_child("time_label").modulate = Color(1.0, 1.0, 1.0, 1.0)
			i.find_child("saved_dialogue").modulate = Color(1.0, 1.0, 1.0, 1.0)
			i.find_child("dialogue_label").modulate = Color(1.0, 1.0, 1.0, 1.0)
			i.find_child("saved_time").text = SaveLoad.load(str(i.get_meta("save_slot"))).get('time')
			i.find_child("saved_dialogue").text = SaveLoad.load(str(i.get_meta("save_slot"))).get('dialogue_label')
			i.find_child("saved_progress").value = SaveLoad.load(str(i.get_meta("save_slot"))).get('story_progress')
			
			var stylebox_normal = StyleBoxFlat.new()
			stylebox_normal.bg_color = Color(0.0, 0.0, 0.0, 1.0)
			i.find_child("saved_progress").add_theme_stylebox_override("background", stylebox_normal)
			
			i.find_child("delete_bttn").disabled = false
			i.find_child("delete_bttn").pressed.connect(
				notification_win.pop_in.bind(
					[SaveLoad.delete_save.bind(str(i.get_meta("save_slot"))),
					SaveLoad.slot_saved.emit.bind(str(i.get_meta("save_slot")))],
					"You are about to delete save: " + str(i.get_meta("save_slot")) + ". Are you sure?",
					"Deleting Save"),
				CONNECT_REFERENCE_COUNTED
			)
		else:
			# Make the buttons which have nothing in them, distinct
			i.disabled = true
			i.find_child("delete_bttn").disabled = true
			
			i.find_child("slot_status").text = "EMPTY"
			i.find_child("slot_status").accessibility_name = "Empty"
			
			i.find_child("slot_status").modulate = Color(0.0, 0.0, 0.0, 0.271)
			i.find_child("saved_time").modulate = Color(0.0, 0.0, 0.0, 0.271)
			i.find_child("time_label").modulate = Color(0.0, 0.0, 0.0, 0.271)
			i.find_child("saved_dialogue").modulate = Color(0.0, 0.0, 0.0, 0.271)
			i.find_child("dialogue_label").modulate = Color(0.0, 0.0, 0.0, 0.271)
			i.find_child("saved_time").text = "--/--/--"
			i.find_child("saved_dialogue").text = "---"
			i.find_child("saved_progress").value = 0
			
			var stylebox_normal = StyleBoxFlat.new()
			stylebox_normal.bg_color = Color(0.094, 0.094, 0.094, 0.506)
			i.find_child("saved_progress").add_theme_stylebox_override("background", stylebox_normal)



## Generates all the saved slots with the theme.
func generate_slots():
	for i in range(1,16,1):
		var bttn = preload("res://scenes/saveload_slot.tscn").instantiate()
		bttn.add_to_group("Buttons")
		bttn.set_meta("save_slot", i)
		
		if %MainMenu.visible:
			bttn.pressed.connect(load_slot.bind(str(i)))
		else:
			bttn.pressed.connect(
					notification_win.pop_in.bind(
							[load_slot.bind(str(i))],
							"Unsaved progress will be lost. Do you wish to proceed?"),
					CONNECT_ONE_SHOT
				)
			
		%load_vbox.add_child(bttn)


func load_slot(slot = ""):
	SaveLoad.load(slot)
	SaveLoad.slot_loaded.emit(slot)
	print("Successfully loaded! Loaded: " + slot + ".")

func _on_back_bttn_pressed() -> void:
	main.hide_menu(self)
