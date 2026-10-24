extends Control

@onready var main: Node = $"../.."
@onready var label: RichTextLabel = %label
@export var notification_win: Node

enum MODE{SAVE, LOAD}
@export var mode: MODE

@export var slots_amount:= 15
@export var filled_slot: Color = Color(1.0, 1.0, 1.0, 1.0)
@export var empty_slot: Color = Color(0.0, 0.0, 0.0, 0.271)


func _ready() -> void:
	generate_slots()
	check_buttons()
	self.visibility_changed.connect(grab_focus)
	# Checks every time a slot_saved is emitted.
	SaveLoad.slot_saved.connect(check_buttons)


func _input(event: InputEvent) -> void:
	for i in %slots_vbox.get_children():
		# Only delete if we are mousing over and pressing delete.
		if event.is_action_pressed("delete") and i.is_hovered():
			if SaveLoad.save_slot_exists(str(i.get_meta("save_slot"))):
				notification_win.pop_in(
					[SaveLoad.delete_save.bind(str(i.get_meta("save_slot")))],
					"You are about to delete save: " + str(i.get_meta("save_slot")) + ". Are you sure?",
					"Deleting Save"
				)

## Generates the save slots
func generate_slots():
	for i in range(1,slots_amount+1,1):
		var button = preload("res://scenes/saveload_slot.tscn").instantiate()
		button.add_to_group("save_button")
		button.set_meta("save_slot", i)
		
		%slots_vbox.add_child(button)

	var quick_button = preload("res://scenes/saveload_quick_slot.tscn").instantiate()
	quick_button.add_to_group("save_button")
	quick_button.set_meta("save_slot", "quick")
	
	%quick_slots_vbox.add_child(quick_button)
	%quick_slots_vbox.move_child(quick_button, 0)


## Emitted every time when a button gets saved or deleted.
func check_buttons(_save: String=""):
	await get_tree().process_frame
	
	for i in %slots_vbox.get_children():
		# Disconnects all the signal to add them back in later.
		for x in i.get_signal_connection_list("pressed"):
			if i.is_connected("pressed", notification_win.pop_in):
				i.disconnect("pressed",notification_win.pop_in)
				
			if i.is_connected("pressed", SaveLoad.save):
				i.disconnect("pressed", SaveLoad.save)
			
			if i.find_child("delete_button").is_connected("pressed", notification_win.pop_in):
				i.find_child("delete_button").disconnect("pressed", notification_win.pop_in)
				
		# The buttons have a meta "save_slot"
		if mode == MODE.SAVE:
			check_saves(i)
		
		elif mode == MODE.LOAD:
			check_loads(i)
	
	for i in %quick_slots_vbox.get_children():
		# Disconnects all the signal to add them back in later.
		for x in i.get_signal_connection_list("pressed"):
			if i.is_connected("pressed", notification_win.pop_in):
				i.disconnect("pressed",notification_win.pop_in)
				
			if i.is_connected("pressed", SaveLoad.save):
				i.disconnect("pressed", SaveLoad.save)
			
			if i.find_child("delete_button").is_connected("pressed", notification_win.pop_in):
				i.find_child("delete_button").disconnect("pressed", notification_win.pop_in)
				
		# The buttons have a meta "save_slot"
		if mode == MODE.SAVE:
			check_saves(i, "QUICK")
			i.disabled = true
			i.find_child("delete_button").disabled = true
			
		
		elif mode == MODE.LOAD:
			check_loads(i, "QUICK")


func check_saves(node, empty_text = "EMPTY"):
	var stylebox_normal = StyleBoxFlat.new()
	stylebox_normal.bg_color = Color("040404cf")
	var progress_bar_normal = StyleBoxFlat.new()
	progress_bar_normal.bg_color = Color("000000ff")
	node.add_theme_stylebox_override("normal", stylebox_normal)
	node.find_child("saved_progress").add_theme_stylebox_override("background", progress_bar_normal)
	
	node.find_child("delete_button").disabled = false
	node.find_child("delete_button").pressed.connect(
		notification_win.pop_in.bind(
			[SaveLoad.delete_save.bind(str(node.get_meta("save_slot")))],
			"You are about to delete save: " + str(node.get_meta("save_slot")) + ". Are you sure?",
			"Deleting Save"),
		CONNECT_PERSIST
	)
	
	if SaveLoad.save_slot_exists(str(node.get_meta("save_slot"))):
		node.pressed.connect(
			notification_win.pop_in.bind(
				[SaveLoad.save.bind(str(node.get_meta("save_slot")))],
				"Do you wish to overwrite this save?",
				"Overwriting Save")
		)
		node.find_child("slot_status").modulate = filled_slot
		node.find_child("time_label").modulate = filled_slot
		node.find_child("saved_time").modulate = filled_slot
		node.find_child("dialogue_label").modulate = filled_slot
		node.find_child("saved_dialogue").modulate = filled_slot
		node.find_child("slot_status").text = "[u]SAVED"
		node.find_child("slot_status").accessibility_name = "Saved"
		node.find_child("saved_time").text = SaveLoad.load(str(node.get_meta("save_slot"))).get('time')
	#node.find_child("saved_dialogue").text = SaveLoad.load(str(node.get_meta("save_slot"))).get('dialogue_label')
	#node.find_child("saved_progress").value = SaveLoad.load(str(node.get_meta("save_slot"))).get('story_progress')
	
	# The empty saveable slots.
	if !SaveLoad.save_slot_exists(str(node.get_meta("save_slot"))):
		# Make a new save.
		node.pressed.connect(
			SaveLoad.save.bind(str(node.get_meta("save_slot")))
			)
		# Make the buttons which have nothing in them, distinct
		node.find_child("delete_button").disabled = true
		
		node.find_child("slot_status").text = empty_text
		node.find_child("slot_status").modulate = empty_slot
		node.find_child("time_label").modulate = empty_slot
		node.find_child("saved_time").modulate = empty_slot
		node.find_child("dialogue_label").modulate = empty_slot
		node.find_child("saved_dialogue").modulate = empty_slot
		node.find_child("saved_time").text = "--/--/--"
		
		stylebox_normal.bg_color = Color(0.094, 0.094, 0.094, 0.506)
		node.find_child("saved_progress").add_theme_stylebox_override("background", stylebox_normal)
		

func check_loads(node, empty_text = "EMPTY"):
	if SaveLoad.save_slot_exists(str(node.get_meta("save_slot"))):
		# SAVED
		node.disabled = false
		node.find_child("slot_status").text = "[u]SAVED"
		node.find_child("slot_status").modulate = filled_slot
		node.find_child("saved_time").modulate = filled_slot
		node.find_child("time_label").modulate = filled_slot
		node.find_child("saved_dialogue").modulate = filled_slot
		node.find_child("dialogue_label").modulate = filled_slot
		node.find_child("saved_time").text = SaveLoad.load(str(node.get_meta("save_slot"))).get('time')
		#node.find_child("saved_dialogue").text = SaveLoad.load(str(node.get_meta("save_slot"))).get('dialogue_label')
		#node.find_child("saved_progress").value = SaveLoad.load(str(node.get_meta("save_slot"))).get('story_progress')
		
		var stylebox_normal = StyleBoxFlat.new()
		stylebox_normal.bg_color = Color(0.0, 0.0, 0.0, 1.0)
		node.find_child("saved_progress").add_theme_stylebox_override("background", stylebox_normal)
		
		node.find_child("delete_button").disabled = false
		node.find_child("delete_button").pressed.connect(
			notification_win.pop_in.bind(
				[SaveLoad.delete_save.bind(str(node.get_meta("save_slot")))],
				"You are about to delete save: " + str(node.get_meta("save_slot")) + ". Are you sure?",
				"Deleting Save"),
			CONNECT_REFERENCE_COUNTED
		)
		
		node.pressed.connect(
				notification_win.pop_in.bind(
						[load_slot.bind(str(node.get_meta("save_slot")))],
						"Unsaved progress will be lost. Do you wish to load this save?",
						"Unsaved Progress"),
				CONNECT_REFERENCE_COUNTED
		)
	else:
		# EMPTY SLOTS
		# Make the buttons which have nothing in them, distinct
		node.disabled = true
		node.find_child("delete_button").disabled = true
		
		node.find_child("slot_status").text = empty_text
		
		node.find_child("slot_status").modulate = empty_slot
		node.find_child("saved_time").modulate = empty_slot
		node.find_child("time_label").modulate = empty_slot
		node.find_child("saved_dialogue").modulate = empty_slot
		node.find_child("dialogue_label").modulate = empty_slot
		node.find_child("saved_time").text = "--/--/--"
		node.find_child("saved_dialogue").text = "---"
		node.find_child("saved_progress").value = 0
		
		var stylebox_normal = StyleBoxFlat.new()
		stylebox_normal.bg_color = Color(0.094, 0.094, 0.094, 0.506)
		node.find_child("saved_progress").add_theme_stylebox_override("background", stylebox_normal)


func load_slot(slot = ""):
	SaveLoad.load(slot)
	SaveLoad.slot_loaded.emit(slot)


func _on_save_button_toggled(toggled_on: bool) -> void:
	if %Save.visible:
		%Save.visible = false
		%save_bttn.button_pressed = false
	%Load.visible = toggled_on

func _on_load_button_toggled(toggled_on: bool) -> void:
	if %Load.visible:
		%Load.visible = false
		%load_bttn.button_pressed = false
	%Save.visible = toggled_on
