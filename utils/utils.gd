extends Node
class_name Utils

const DIE_TYPE_TO_STRING: Dictionary[ Die.TYPES, String ] = {
	Die.TYPES.D4: "d4",
	Die.TYPES.D6: "d6",
	Die.TYPES.D8: "d8",
	Die.TYPES.D10: "d10",
	Die.TYPES.D12: "d12",
	Die.TYPES.D20: "d20",
	Die.TYPES.D_PERCENTILE_10S: "d100",
}

static func dice_groups_to_string( dice_groups: Array[ DiceGroup ] ) -> String:
	var result: String = ""
	
	for group in dice_groups:
		var group_string = ""
		group_string += str( group.count )
		group_string += DIE_TYPE_TO_STRING[ group.die_type ]
		result += group_string
		result += " + "
		
	result = result.substr( 0, result.length() - 3 )
	return result
	
static func addend_to_string( addend: int ) -> String:
	var result: String = ""
	if addend > 0:
		result += " + " + str( addend )
	elif addend < 0:
		result += " - " + str( abs( addend ) )
	return result
