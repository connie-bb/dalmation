extends Node
class_name RollEditor

# Variable
var spawnlist: Array[ DiceGroup ]

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
	var group: DiceGroup = null
	
	for existing_group in spawnlist:
		if existing_group.die_type == type:
			group = existing_group
			break
	if group == null:
		group = DiceGroup.new()
		group.die_type = type
		spawnlist.append( group )
	
	if group.count >= MAX_DICE: return
	group.count += 1

func remove_die( type: Die.TYPES ):
	var group: DiceGroup = null
	for existing_group in spawnlist:
		if existing_group.die_type == type:
			group = existing_group
			break
	if group == null:
		return
		
	group.count -= 1
	if group.count <= 0:
		remove_group( group )

func remove_group( group: DiceGroup ):
	group.queue_free()
	spawnlist.erase( group )
