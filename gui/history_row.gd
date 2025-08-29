extends PanelContainer
class_name HistoryRow

# Constant
signal row_wants_replay( roll_text: String )

# References
@onready var roll_label: Label = $HBoxContainer/roll_label

func _on_delete_button_pressed():
	queue_free()

func _on_replay_button_pressed():
	row_wants_replay.emit( roll_label.text )
