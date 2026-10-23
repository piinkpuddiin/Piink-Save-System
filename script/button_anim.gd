@tool
class_name ButtonAnim extends Button

var tween:Tween

@export var tween_ease:= Tween.EASE_OUT
@export var tween_trans:= Tween.TRANS_ELASTIC

func _ready():
	# set pivot on bottom center
	pivot_offset = size * Vector2(0.5, 0.5)
	
	button_down.connect(_on_button_down)
	button_up.connect(_on_button_up)

func _on_button_down():
	# ensures the tween is not running
	if tween: tween.kill()
	
	# scale down to give a pressed look
	scale = Vector2(0.9, 0.8)

func _on_button_up():
	tween = create_tween()
	tween.set_ease(tween_ease)
	tween.set_trans(tween_trans)
	
	# restores the scale smoothly in 0.25 seconds
	tween.tween_property(self, "scale", Vector2(1,1), 0.25)
