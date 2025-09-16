extends PanelContainer
class_name RollEditorPanel

# Variable
var addend: int = 0

# References
@onready var table: Control = $VBoxContainer/ScrollContainer/table
var row_resource: Resource = preload( "res://gui/roll_editor_panel/roll_editor_row.tscn" )
@onready var addend_spinbox: SpinBox = $VBoxContainer/HBoxContainer/addend_spinbox

# Constant
signal count_changed( count: int, dice_group: DiceGroup )
signal deleted( dice_group: DiceGroup )
signal score_addend_edited
signal cleared

func _ready():
	for row in table.get_children():
		row.queue_free()	# Remove placeholders

func add_row( dice_group: DiceGroup ):
	var row: RollEditorRow = row_resource.instantiate()
	table.add_child( row )
	row.dice_group = dice_group
	row.type_label.text = Utils.DIE_TYPE_TO_STRING[ dice_group.die_type ]
	row.count_spinbox.value = dice_group.count
	row.count_changed.connect( _on_row_count_changed )
	row.deleted.connect( _on_row_deleted )
	
func _on_row_count_changed( count: int, dice_group: DiceGroup ):
	count_changed.emit( count, dice_group )

func _on_row_deleted( dice_group: DiceGroup ):
	deleted.emit( dice_group )

func update( spawnlist: Array[ DiceGroup ] ):
	for row in table.get_children():
		row.queue_free()
	for dice_group in spawnlist:
		add_row( dice_group )

func _on_addend_spinbox_value_changed( value ):
	addend = value

func _on_edit_score_addend_button_pressed():
	score_addend_edited.emit()

func _on_clear_button_pressed():
	cleared.emit()
