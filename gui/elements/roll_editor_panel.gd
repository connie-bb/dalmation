extends Control
class_name RollEditorPanel

# References
@export var roll_editor: RollEditor
@onready var modifier_button: ModifierButton = $modifier_button

@export var die_buttons: Dictionary[ Die.TYPES, DieButton ]

# Constant
signal clear_pressed

func _ready():
	if roll_editor == null:
		push_warning( "RollEditorPanel has no assigned RollEditor." )
	assert( die_buttons.size() == 7, "RollEditorPanel must have 7 DieButtons assigned." )
	
	if roll_editor == null: return
	for die_type in Die.TYPES.values():
		die_buttons[ die_type ].increment_pressed.connect( roll_editor.add_die )
		die_buttons[ die_type ].decrement_pressed.connect( roll_editor.subtract_die )

func update( request: RollRequest ):
	for die_type: Die.TYPES in request.die_counts.keys():
		die_buttons[ die_type ].update( request.die_counts[ die_type ] )
	modifier_button.update( request.modifier )		

func _on_clear_button_pressed():
	clear_pressed.emit()
