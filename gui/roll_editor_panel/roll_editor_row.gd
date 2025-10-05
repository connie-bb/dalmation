extends PanelContainer
class_name RollEditorRow

# Variable
var die_type: Die.TYPES

# References
@onready var type_label: Label = $HBoxContainer/type_label
@onready var count_spinbox: SpinBox = $HBoxContainer/count_spinbox

# Constant
signal count_changed( die_type: Die.TYPES, count: int )
signal delete_pressed( die_type: Die.TYPES )

func _on_count_spinbox_value_changed( value ):
	count_changed.emit( die_type, value )

func _on_delete_button_pressed():
	delete_pressed.emit( die_type )
	queue_free()
