extends Control
class_name RollHistoryPanel

# References
var row_resource: Resource = preload("res://gui/elements/roll_history_panel_row.tscn")
@onready var table = $VBoxContainer/ScrollContainer/table

# Constant
signal replay_pressed( receipt: RollReceipt )
signal delete_pressed( receipt: RollReceipt )
signal expand_pressed( receipt: RollReceipt )
signal exit_pressed()
signal clear_pressed()

func _ready():
	# Remove placeholder rows
	for row in table.get_children():
		row.queue_free()
	hide_history()

func show_history():
	visible = true
	mouse_filter = MOUSE_FILTER_STOP
	
func hide_history():
	visible = false
	mouse_filter = MOUSE_FILTER_IGNORE

func add_row( receipt: RollReceipt ):
	var row: RollHistoryPanelRow = row_resource.instantiate()
	table.add_child( row )
	table.move_child( row, 0 )
	row.replay_pressed.connect( _on_row_replay_pressed )
	row.delete_pressed.connect( _on_row_delete_pressed )
	row.expand_pressed.connect( _on_row_expand_pressed )
	row.score_label.text = str( receipt.score )
	row.roll_label.text = receipt.as_string()
	row.receipt = receipt
	
# Rows delete themselves. remove_row() does not exist.

func _on_row_replay_pressed( receipt: RollReceipt ):
	replay_pressed.emit( receipt )

func _on_row_delete_pressed( receipt: RollReceipt ):
	delete_pressed.emit( receipt )

func _on_row_expand_pressed( receipt ):
	expand_pressed.emit( receipt )
	hide_history()

func _on_exit_button_pressed():
	exit_pressed.emit()

func _on_clear_button_pressed():
	for row in table.get_children():
		row.queue_free()
	clear_pressed.emit()
