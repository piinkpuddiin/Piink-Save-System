extends Control

@export var class_options: OptionButton
@export var strength_spin_box: SpinBox
@export var wisdom_spin_box: SpinBox

func _ready() -> void:
	generate_options()
	SaveLoad.slot_loaded.connect(load_data)


func load_data(save_name: String) -> void:
	class_options.selected = GlobalVar.playable_classes.keys().find(SaveLoad.load(save_name).get('character_class'))
	strength_spin_box.value = SaveLoad.load(save_name).get('character_strength')
	wisdom_spin_box.value = SaveLoad.load(save_name).get('character_wisdom')


func generate_options() -> void:
	for i in GlobalVar.playable_classes:
		class_options.add_item(i)
	class_options.selected = 0


func _on_class_options_item_selected(index: int) -> void:
	print("Old strength: ", GlobalVar.character_class)
	GlobalVar.character_class = GlobalVar.playable_classes.keys()[index]
	print("New strength: ", GlobalVar.character_class)


func _on_strength_spin_box_value_changed(value: float) -> void:
	print("Old strength: ", GlobalVar.character_strength)
	GlobalVar.character_strength = int(value)
	print("New strength: ", GlobalVar.character_strength)


func _on_wisdom_spin_box_value_changed(value: float) -> void:
	print("Old wisdom: ", GlobalVar.character_wisdom)
	GlobalVar.character_wisdom = int(value)
	print("New wisdom: ", GlobalVar.character_wisdom)
