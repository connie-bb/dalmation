extends PanelContainer
class_name DieSelector

# References
@export var roll_editor: RollEditor

func _ready():
	if roll_editor == null:
		push_warning( "DieSelector has no assigned RollEditor." )
	else:
		for button: DieSelectorButton in get_child(0).get_children():
			button.die_added.connect( roll_editor.add_die )
