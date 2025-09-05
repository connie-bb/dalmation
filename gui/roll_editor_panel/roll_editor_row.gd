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

func _input( event: InputEvent ):
	if !( event is InputEventMouseButton ): return
	if !event.is_pressed(): return
	var rect: Rect2 = Rect2( Vector2.ZERO, count_spinbox.size )
	if !rect.has_point( count_spinbox.get_local_mouse_position() ):
		return
	var event_mouse: InputEventMouseButton = event as InputEventMouseButton
	if !( event_mouse.button_index == MOUSE_BUTTON_WHEEL_UP \
		or event_mouse.button_index == MOUSE_BUTTON_WHEEL_DOWN ):
		return
	accept_event()
	
	if event_mouse.button_index == MOUSE_BUTTON_WHEEL_UP:
		count_spinbox.value += 1
	elif event_mouse.button_index == MOUSE_BUTTON_WHEEL_DOWN:
		count_spinbox.value -= 1
