extends PanelContainer
class_name RollEditorPanel

# References
@export var roll_editor: RollEditor
@onready var table: Control = $VBoxContainer/ScrollContainer/table
var row_resource: Resource = preload( "res://gui/roll_editor_panel/roll_editor_row.tscn" )
@onready var modifier_spinbox: SpinBox = $VBoxContainer/HBoxContainer/modifier_spinbox

# Constant
signal modifier_changed( modifier: int )
signal modifier_post_roll( modifier: int )
signal cleared

func _ready():
	if roll_editor == null:
		push_warning( "RollEditorPanel has no assigned RollEditor." )
	for row in table.get_children():
		row.queue_free()	# Remove placeholders

func add_row( die_type: Die.TYPES, count: int ):
	var row: RollEditorRow = row_resource.instantiate()
	table.add_child( row )
	
	row.die_type = die_type
	row.type_label.text = Utils.DIE_TYPE_TO_STRING[ die_type ]
	row.count_spinbox.value = count
	
	if roll_editor != null:
		row.count_changed.connect( roll_editor.set_count )
		row.delete_pressed.connect( roll_editor.remove_die )

func update( request: RollRequest ):
	for row: RollEditorRow in table.get_children():
		row.queue_free()
	for die_type: Die.TYPES in request.die_counts.keys():
		add_row( die_type, request.die_counts[ die_type ] )
	modifier_spinbox.value = request.modifier
	
func _on_clear_button_pressed():
	cleared.emit()
	
func _on_modifier_spinbox_value_changed( value ):
	modifier_changed.emit( value )

func _on_modifier_post_roll_button_pressed():
	modifier_post_roll.emit( roll_editor.request.modifier )
