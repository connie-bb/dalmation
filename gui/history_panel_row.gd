extends PanelContainer
class_name HistoryPanelRow

# Variable
var roll: Roll

# Constant
signal replay_pressed( roll: Roll )
signal delete_pressed( roll: Roll )

# References
@onready var roll_label: Label = $HBoxContainer/roll_label
@onready var score_label: Label = $HBoxContainer/score_label

func _on_delete_button_pressed():
	delete_pressed.emit( roll )
	queue_free()

func _on_replay_button_pressed():
	replay_pressed.emit( roll )

func _on_roll_label_mouse_entered():
	TooltipManager.show_tooltip( roll_label.text )

func _on_roll_label_mouse_exited():
	TooltipManager.hide_tooltip()
