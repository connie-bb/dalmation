extends Control
class_name ModifierButton

# References
@onready var label = get_node("Panel/Label")

# Constant
signal increment_pressed()
signal decrement_pressed()

func _gui_input( event: InputEvent ):
	if event is InputEventMouseButton:
		var mouse_event = event as InputEventMouseButton
		if mouse_event.is_pressed() \
		and mouse_event.button_index == MOUSE_BUTTON_LEFT:
			increment_pressed.emit()
		elif mouse_event.is_pressed() \
		and mouse_event.button_index == MOUSE_BUTTON_RIGHT:
			decrement_pressed.emit()
		
		elif mouse_event.is_pressed() \
		and mouse_event.button_index == MOUSE_BUTTON_WHEEL_UP:
			increment_pressed.emit()
		elif mouse_event.is_pressed() \
		and mouse_event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			decrement_pressed.emit()

func update( modifier ):
	var text: String = str( modifier )
	if modifier > 0:
		text = "+" + text
	# Minus for negative numbers done automatically in str()
	label.text = text
	
