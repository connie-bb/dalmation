extends Panel
class_name HistoryPanel

# References
var row_resource: Resource = preload("res://gui/history_panel_row.tscn")
@onready var table = $VBoxContainer/ScrollContainer/table

# Constant
signal replay_pressed( roll: Roll )
signal delete_pressed( roll: Roll )

func _ready():
	# Remove placeholder rows
	for row in table.get_children():
		row.queue_free()

func add_row( roll: Roll ):
	var row: HistoryPanelRow = row_resource.instantiate()
	table.add_child( row )
	table.move_child( row, 0 )
	row.replay_pressed.connect( _on_row_replay_pressed )
	row.delete_pressed.connect( _on_row_delete_pressed )
	row.score_label.text = str( roll.score )
	row.roll_label.text = roll.string()
	row.roll = roll
	
# Rows delete themselves. remove_row() does not exist.

func _on_row_replay_pressed( roll: Roll ):
	replay_pressed.emit( roll )

func _on_row_delete_pressed( roll: Roll ):
	delete_pressed.emit( roll )
