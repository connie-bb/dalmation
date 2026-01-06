extends Control
class_name RollReceiptViewer

# References
@onready var tree: Tree = get_node( "Panel/VBoxContainer/Tree" )
@export var disabled_icon: Texture2D
@export var locked_icon: Texture2D

func _input( event: InputEvent ):
	if !visible: return
	if event.is_action_pressed( "ui_exit" ):
		close_receipt()
		get_viewport().set_input_as_handled()
	elif event is InputEventKey:
		# Block it, block it all!
		# We assume mouse activity is blocked physically by this control
		# taking up the entire screen.
		get_viewport().set_input_as_handled()

func open_receipt( receipt: RollReceipt ):
	tree.clear()
	tree.create_item() # Create root
	tree.hide_root = true
	tree.set_column_title( 0, "Die" )
	tree.set_column_title( 1, "Score" )
	tree.set_column_expand( 2, false )
	tree.set_column_expand( 3, false )
	tree.set_column_custom_minimum_width( 2, 32 )
	tree.set_column_custom_minimum_width( 3, 32 )

	for die in receipt.die_list:
		var row = tree.create_item()
		row.set_text( 0, Utils.DIE_TYPE_TO_STRING[ die.die_type ] )
		row.set_text( 1, str( die.score ) )
		if die.disabled: row.set_icon( 2, disabled_icon )
		if die.is_holdover: row.set_icon( 3, locked_icon )
		
	var total_row = tree.create_item()
	total_row.set_text( 0, "Total" )
	total_row.set_text( 1, str( receipt.score ) )

	visible = true
	mouse_filter = MOUSE_FILTER_STOP

func close_receipt():
	visible = false
	mouse_filter = MOUSE_FILTER_IGNORE

func _on_exit_button_pressed():
	close_receipt()
