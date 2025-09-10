extends PanelContainer
class_name HistoryRow

# Variable
var spawnlist: Array[ DiceGroup ]
var addend: int

# Constant
signal replay_pressed( spawnlist: Array[ DiceGroup ], addend: int )

# References
@onready var roll_label: Label = $HBoxContainer/roll_label

func _on_delete_button_pressed():
	queue_free()

func _on_replay_button_pressed():
	replay_pressed.emit( spawnlist, addend )

func _on_roll_label_mouse_entered():
	TooltipManager.show_tooltip( roll_label.text )

func _on_roll_label_mouse_exited():
	TooltipManager.hide_tooltip()
