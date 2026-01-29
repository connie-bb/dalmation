extends Control
class_name DieButton

# Configurable
@export var die_type: Die.TYPES

# References
@onready var label = get_node("Label")

# Constant
signal increment_pressed( die_type: Die.TYPES )
signal decrement_pressed( die_type: Die.TYPES )
signal clear_pressed( die_type: Die.TYPES )

func _ready():
	assert( die_type != null, "DieButton has no assigned die_type." )

func _gui_input( event: InputEvent ):
	if event is InputEventMouseButton:
		var mouse_event = event as InputEventMouseButton
		
		if mouse_event.is_pressed() \
		and mouse_event.button_index == MOUSE_BUTTON_LEFT:
			increment_pressed.emit( die_type )
		elif mouse_event.is_pressed() \
		and mouse_event.button_index == MOUSE_BUTTON_RIGHT:
			decrement_pressed.emit( die_type )
		
		elif mouse_event.is_pressed() \
		and mouse_event.button_index == MOUSE_BUTTON_WHEEL_UP:
			increment_pressed.emit( die_type )
		elif mouse_event.is_pressed() \
		and mouse_event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			decrement_pressed.emit( die_type )

func update( count: int ):
	label.text = str( count )
