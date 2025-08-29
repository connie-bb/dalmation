extends Panel
class_name History

# References
var row_resource: Resource = preload("res://gui/history_row.tscn")
@onready var history_table = $VBoxContainer/ScrollContainer/history_table

# Constant
signal replay_requested( roll_text: String )

func _ready():
	# Remove placeholder row
	remove( history_table.get_children()[0] )

func add( score: int, roll: String ):
	var row: HistoryRow = row_resource.instantiate()
	row.get_node( "HBoxContainer/score_label" ).text = str( score )
	row.get_node( "HBoxContainer/roll_label" ).text = roll
	history_table.add_child( row )
	history_table.move_child( row, 0 )
	row.row_wants_replay.connect( _on_row_wants_replay )

func remove( row: Node ):
	row.queue_free()

func _on_row_wants_replay( roll_text: String ):
	replay_requested.emit( roll_text )
