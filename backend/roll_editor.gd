extends Node
class_name RollEditor

# Variable
var roll: Roll = Roll.new()

# Constant
signal changed( roll: Roll )
signal finalized( roll: Roll )

func clear():
	roll.delete()
	roll = Roll.new()
	changed.emit( roll )

func add_die( type: Die.TYPES ):
	var group: DiceGroup = null
	
	for existing_group in roll.spawnlist:
		if existing_group.die_type == type:
			group = existing_group
			break
	if group == null:
		group = DiceGroup.new()
		group.die_type = type
		roll.spawnlist.append( group )
	
	if group.count >= Settings.max_dice: return
	group.count += 1
	changed.emit( roll )

func remove_die( type: Die.TYPES ):
	var group: DiceGroup = null
	for existing_group in roll.spawnlist:
		if existing_group.die_type == type:
			group = existing_group
			break
	if group == null:
		return
		
	group.count -= 1
	if group.count <= 0:
		remove_group( group )
	
	changed.emit( roll )

func set_group_count( count: int, group: DiceGroup ):
	group.count = count
	changed.emit( roll )

func remove_group( group: DiceGroup ):
	group.queue_free()
	roll.spawnlist.erase( group )
	changed.emit( roll )

func set_addend( addend: int ):
	roll.addend = addend
	changed.emit( roll )

func replay_roll( new_roll: Roll ):
	roll.delete()
	roll = new_roll.dupe()
	changed.emit( roll )
	finalize()

func finalize():
	finalized.emit( roll )
