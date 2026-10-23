extends Control

@export var save_menu: Control
@export var load_menu: Control

func _on_save_bttn_toggled(toggled_on: bool) -> void:
	if load_menu.visible:
		load_menu.visible = false
		%load_button.button_pressed = false
	save_menu.visible = toggled_on


func _on_load_bttn_toggled(toggled_on: bool) -> void:
	if save_menu.visible:
		save_menu.visible = false
		%save_button.button_pressed = false
	load_menu.visible = toggled_on
