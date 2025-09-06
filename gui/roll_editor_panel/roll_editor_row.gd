extends PanelContainer
class_name RollEditorRow

# Variable
var dice_group: DiceGroup

# References
@onready var type_label: Label = $HBoxContainer/type_label
@onready var count_spinbox: SpinBox = $HBoxContainer/count_spinbox

# Constant
signal count_changed( count: int, dice_group: DiceGroup )
signal deleted( dice_group: DiceGroup )

func _on_count_spinbox_value_changed( value ):
	count_changed.emit( value, dice_group )

func _on_delete_button_pressed():
	deleted.emit( dice_group )
	queue_free()
