extends Node

## Emits every time a slot is loaded
signal save_loaded
## Emits every time a slot is saved
signal slot_saved
## Emits every time a quick save slot is saved.
signal quick_saved
## The amount of quick saves p[ossible before they start
## overwriting themselves.
@export var quick_save_amount:= 3
@export var quick_save_slot:= 0


@onready var config:= ConfigFile.new()
@export var password: String 
const SAVE_PATH:= "user://saves/"
const FILE_PATH:= "_save.ini"

func _ready():
	var dir = DirAccess.open("user://")
	if !dir.dir_exists("saves"):
		dir.make_dir("saves")
	
	var time := Time.get_datetime_dict_from_system()
	GlobalVar.saved_time = "%02d:%02d - %s/%s/%s" % [time.hour, time.minute, time.day, time.month, time.year]


func save(save_name: String):
	var config_file := ConfigFile.new()
	
	# Save the scripts values 1 by 1.
	## GENERAL
	config_file.set_value("General", "time", GlobalVar.saved_time)
	
	var saved_dialogue = Dialogic.get_full_state()
	config_file.set_value("Dialogue", "saved_timeline", saved_dialogue)
	
	# Save all the scripts values.
	# https://www.reddit.com/r/godot/comments/kdvg8i/is_there_a_way_to_get_all_of_a_scripts_variables/
	var global_script: GDScript = GlobalVar.get_script()
	#print('Properties of "%s":' % [ global_script.resource_path ])
	for property_info in global_script.get_script_property_list():
		var property_name: String = property_info.name
		var property_value = GlobalVar.get(property_name)
		#print('  %s = %s' % [ property_name, property_value ])
		config_file.set_value("GlobalVar", property_name, property_value)
	
	var error := config_file.save(SAVE_PATH + save_name + FILE_PATH)
	if error:
		print("An error happened while saving data: ", error)
	print("Succesfully saved! Save: " + save_name + ".")
	
	SaveLoad.slot_saved.emit()


func load(save_name: String):
	var config_file := ConfigFile.new()
	var load_data = {}
	var error := config_file.load(SAVE_PATH + save_name + FILE_PATH)
	
	if error:
		print("An error happened while loading data: ", error)
		return
	
	# Load all the scripts data 1 by 1.
	## GENERAL
	var saved_time = config_file.get_value("General", "time", "12:00")
	load_data['time'] = saved_time
	
	var saved_timeline = config_file.get_value("Dialogue", "saved_timeline", {})
	load_data['timeline_saved'] = saved_timeline
	
	# Load all the scripts data.
	for i in config_file.get_sections():
		for x in config_file.get_section_keys(i):
			print("The section ",i, ". The key: ",x,".")
			load_data[x] = config_file.get_value(i, x)
	
	print("The load data: ", load_data)
	return load_data

#region QUICK SAVE
## Save a quick save.
func quick_save():
	SaveLoad.quick_saved.emit("quick")
	SaveLoad.save("quick")

## Load the most recent save. Useful for a continue button on the main menu.
func quick_load():
	if !saves_exists():
		return
	
	var recent_saves_arr = DirAccess.get_files_at(SAVE_PATH)
	print(recent_saves_arr)
	
	var most_recent:= "1"
	var recent_files:= {}
	# Going through all the saves
	for i in recent_saves_arr: 
		var file_time
		file_time = FileAccess.get_modified_time(SAVE_PATH + str(i))
		# Add the saves to the dict, makes sure to give them their number
		recent_files[i] = file_time 
	
	print("Recent files: ", recent_files)
	
	# Look for the highest value in the dict
	var most_recent_value = recent_files.values().max()
	# Look for the values, dict key and assign it to most recent
	most_recent = str(recent_files.find_key(most_recent_value)).trim_suffix("_save.ini")
	print("Most recent save: ", most_recent)
	
	SaveLoad.load(most_recent)
#endregion

#region HELPER functions
## Check if the folder has any saves.
func saves_exists():
	var dir
	dir = DirAccess.open(SAVE_PATH)
	print("There are saved files in here!")
	if dir.get_files().size() > 0:
		return true

## Checks if the save exists.
func save_slot_exists(save_name: String):
	var dir = DirAccess.open("user://")
	if dir.file_exists(SAVE_PATH + save_name + FILE_PATH):
		return true

## Delete a specified save.
func delete_save(save_name: String):
	SaveLoad.slot_saved.emit()
	var dir = DirAccess.open(SAVE_PATH)
	if dir.file_exists(SAVE_PATH + save_name + FILE_PATH):
		dir.remove(SAVE_PATH + save_name + FILE_PATH)
		print("Successfully deleted save: ", save_name, ".")

## Delete all saves.
func delete_all():
	SaveLoad.slot_saved.emit()
	var dir = DirAccess.open(SAVE_PATH)
	for i in dir.get_files():
		dir.remove(SAVE_PATH + i)
	print("Successfully deleted all saves.")
#endregion
