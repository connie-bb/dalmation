extends Control
class_name VolumeSlider

# Variable
var value: float = default_value

# Configurable
@export var setting_name: StringName
const default_value: float = 0.5;
const step: float = 0.1
const min_value: float = 0.0
const max_value: float = 1.0

# References
@onready var value_label: Label = $HBoxContainer/value_label

# Constant
signal clicked # So we can play a noise as volume changes.

func update_label():
	value_label.text = str( String.num( value * 100.0, 0 ) ) + "%"

func set_value( new_value: float ):
	if new_value < min_value or new_value > max_value:
		push_error( "Tried to set VolumeSlider with value out of range." )
	value = new_value
	update_label()
	Settings.set( setting_name, value )

func _ready():
	Settings.settings_loaded.connect( _on_settings_loaded )
	
func _on_settings_loaded():
	var new_value = Settings.get( setting_name )
	value = new_value
	update_label()

func _on_left_button_pressed():
	clicked.emit()
	if value == min_value: return
	set_value( max( value - step, min_value ) )

func _on_right_button_pressed():
	clicked.emit()
	if value == max_value: return
	set_value( min( value + step, max_value ) )
