extends Object
class_name Roll

var spawnlist: Array[ DiceGroup ] = []
var addend: int = 0
var score: int = 0

func dupe():
	var roll: Roll = Roll.new()
	roll.spawnlist = DiceGroup.dupe_array( spawnlist )
	roll.addend = addend
	return roll

func delete():
	for group in spawnlist:
		group.queue_free()
	free.call_deferred()

func string() -> String:
	var result: String = ""
	if spawnlist.is_empty():
		if addend == 0: return "-"
		else: return str( addend )
	else:
		for group: DiceGroup in spawnlist:
			var group_string = ""
			group_string += str( group.count )
			group_string += Utils.DIE_TYPE_TO_STRING[ group.die_type ]
			result += group_string
			result += " + "
		result = result.substr( 0, result.length() - 3 )
		if addend > 0:
			result += " + " + str( addend )
		elif addend < 0:
			result += " - " + str( abs( addend ) )
	return result
