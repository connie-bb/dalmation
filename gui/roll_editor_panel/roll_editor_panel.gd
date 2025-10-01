extends PanelContainer
class_name RollEditorPanel

# References
@export var roll_editor: RollEditor
@onready var table: Control = $VBoxContainer/ScrollContainer/table
var row_resource: Resource = preload( "res://gui/roll_editor_panel/roll_editor_row.tscn" )
@onready var addend_spinbox: SpinBox = $VBoxContainer/HBoxContainer/addend_spinbox

# Constant
signal addend_changed( addend: int )
signal current_roll_addend_edited( addend: int )
signal cleared

func _ready():
	if roll_editor == null:
		push_warning( "RollEditorPanel has no assigned RollEditor." )
	for row in table.get_children():
		row.queue_free()	# Remove placeholders

func add_row( dice_group: DiceGroup ):
	var row: RollEditorRow = row_resource.instantiate()
	table.add_child( row )
	row.dice_group = dice_group
	row.type_label.text = Utils.DIE_TYPE_TO_STRING[ dice_group.die_type ]
	row.count_spinbox.value = dice_group.count
	
	if roll_editor != null:
		row.count_changed.connect( roll_editor.set_group_count )
		row.deleted.connect( roll_editor.remove_group )

func update( roll: Roll ):
	for row in table.get_children():
		row.queue_free()
	for dice_group in roll.spawnlist:
		add_row( dice_group )
	addend_spinbox.value = roll.addend

func _on_edit_score_addend_button_pressed():
	current_roll_addend_edited.emit( addend_spinbox.value )

func _on_clear_button_pressed():
	cleared.emit()
	
func _on_addend_spinbox_value_changed( value ):
	addend_changed.emit( value )
