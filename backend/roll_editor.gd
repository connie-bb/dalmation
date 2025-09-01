extends Node
class_name RollEditor

# Variable
var spawnlist: Dictionary[ Die.TYPES, DiceGroup]

# References
@export var die_selector: Control

# Constant
signal changed
const MAX_DICE: int = 30

func _ready():
	connect_die_selector()
	
func connect_die_selector():
	if die_selector == null:
		push_warning( "roll_editor has no assigned die_selector." )
		return
	for button: DieSelectorButton in die_selector.get_child(0).get_children():
		button.die_selected.connect( _on_die_selected )

func _on_die_selected( type: Die.TYPES, remove: bool ):
	if remove:
		remove_die( type )
	else:
		add_die( type )
	changed.emit()

func add_die( type: Die.TYPES ):
	var group = spawnlist.get_or_add( type, DiceGroup.new() )
	if group.count >= MAX_DICE: return
	group.die_type = type
	group.count += 1

func remove_die( type: Die.TYPES ):
	if !spawnlist.has( type ): return
	var group = spawnlist[ type ]
	group.count -= 1
	if group.count <= 0:
		spawnlist.erase( type )

func remove_group( group: DiceGroup ):
	spawnlist.erase( spawnlist.find_key( group ) )

func duplicate_spawnlist() -> Dictionary[ Die.TYPES, DiceGroup ]:
	var new_spawnlist: Dictionary[ Die.TYPES, DiceGroup ]
	for type in spawnlist.keys():
		new_spawnlist[ type ] = DiceGroup.new()
		new_spawnlist[ type ].count = spawnlist[ type ].count
		new_spawnlist[ type ].die_type = spawnlist[ type ].die_type
	return new_spawnlist
