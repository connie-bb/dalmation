extends Control

# Constant
signal clicked

func show_dimmer():
	visible = true
	
func hide_dimmer():
	visible = false

func _input( event: InputEvent ):
	if !visible: return
	if !( event is InputEventMouseButton ): return
	var mouse_event = event as InputEventMouseButton
	if mouse_event.is_pressed():
		clicked.emit()
		get_viewport().set_input_as_handled()
