extends Panel
class_name History

# References
var row_resource: Resource = preload("res://gui/history_row.tscn")
@onready var table = $VBoxContainer/ScrollContainer/table

# Constant
signal replay_requested( roll_text: String )

func _ready():
	# Remove placeholder rows
	for row in table.get_children():
		row.queue_free()

func new_row( score: int, roll: String ):
	var row: HistoryRow = row_resource.instantiate()
	table.add_child( row )
	table.move_child( row, 0 )
	row.row_wants_replay.connect( _on_row_wants_replay )
	row.get_node( "HBoxContainer/score_label" ).text = str( score )
	row.get_node( "HBoxContainer/roll_label" ).text = roll

func remove_row( row: Node ):
	row.queue_free()

func _on_row_wants_replay( roll_text: String ):
	replay_requested.emit( roll_text )
