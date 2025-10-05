extends Panel
class_name RollHistoryPanel

# References
var row_resource: Resource = preload("res://gui/roll_history_panel_row.tscn")
@onready var table = $VBoxContainer/ScrollContainer/table

# Constant
signal replay_pressed( receipt: RollReceipt )
signal delete_pressed( receipt: RollReceipt )

func _ready():
	# Remove placeholder rows
	for row in table.get_children():
		row.queue_free()

func add_row( receipt: RollReceipt ):
	var row: RollHistoryPanelRow = row_resource.instantiate()
	table.add_child( row )
	table.move_child( row, 0 )
	row.replay_pressed.connect( _on_row_replay_pressed )
	row.delete_pressed.connect( _on_row_delete_pressed )
	row.score_label.text = str( receipt.score )
	row.roll_label.text = receipt.as_string()
	row.receipt = receipt
	
# Rows delete themselves. remove_row() does not exist.

func _on_row_replay_pressed( receipt: RollReceipt ):
	replay_pressed.emit( receipt )

func _on_row_delete_pressed( receipt: RollReceipt ):
	delete_pressed.emit( receipt )
