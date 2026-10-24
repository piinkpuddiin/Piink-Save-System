extends Window

signal pressed_notif

func _ready():
	hide()

# Inspird by Dialogic2 notification found in the example temlpate.
func pop_in(confirm_actions:Array, message:String = "", window_title:String = "Notification"):
	self.title = window_title
	
	if %buttons_hbox.get_child_count() >= 0:
		for i in %buttons_hbox.get_children():
			i.queue_free()
	
	%notification_text.text = message
	
	var button_confirm := Button.new()
	button_confirm.custom_minimum_size = Vector2(120,50)
	button_confirm.text = "Yes"
	button_confirm.theme = preload("res://theme/simple_menu.tres")
	for i in confirm_actions:
		button_confirm.pressed.connect(i, CONNECT_ONE_SHOT)
	button_confirm.pressed.connect(close, CONNECT_ONE_SHOT)
	%buttons_hbox.add_child(button_confirm)
	
	var button_close := Button.new()
	button_close.custom_minimum_size = Vector2(120,50)
	button_close.text = "No"
	button_close.theme = preload("res://theme/simple_menu.tres")
	button_close.pressed.connect(close, CONNECT_ONE_SHOT)
	%buttons_hbox.add_child(button_close)
	
	open()


func open() -> void:
	if visible:
		return
	self.visible = true
	show()

func close() -> void:
	self.visible = false
	hide()

func _on_close_requested() -> void:
	close()
