extends Panel
class_name History

# References
var row_resource: Resource = preload("res://gui/history_row.tscn")
@onready var table = $VBoxContainer/ScrollContainer/table

# Constant
signal replay_pressed( spawnlist: Array[ DiceGroup ], addend: int )

func _ready():
	# Remove placeholder rows
	for row in table.get_children():
		row.queue_free()

func new_row( score: int, roll_string: String, spawnlist: Array[ DiceGroup ], \
	addend: int ):
	var row: HistoryRow = row_resource.instantiate()
	table.add_child( row )
	table.move_child( row, 0 )
	row.replay_pressed.connect( _on_row_replay_pressed )
	row.get_node( "HBoxContainer/score_label" ).text = str( score )
	row.get_node( "HBoxContainer/roll_label" ).text = roll_string
	row.spawnlist = DiceGroup.dupe_array( spawnlist )
	row.addend = addend

func remove_row( row: Node ):
	row.queue_free()

func _on_row_replay_pressed( spawnlist: Array[ DiceGroup ], addend: int ):
	replay_pressed.emit( spawnlist, addend )
