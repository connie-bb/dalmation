extends Control
class_name Alert

# Constant
signal clicked

# References
@onready var label: Label = $Panel/MarginContainer/alert_label

func _ready():
	Settings.save_load_error.connect( show_alert )

func show_alert( text: String ):
	visible = true
	label.text = text
	
func hide_alert():
	visible = false

func _input( event: InputEvent ):
	if !visible: return
	if !( event is InputEventMouseButton ): return
	var mouse_event = event as InputEventMouseButton
	if mouse_event.is_pressed():
		clicked.emit()
		get_viewport().set_input_as_handled()
