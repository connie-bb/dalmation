extends Node3D
class_name DiceGroup

var count: int = 0
var die_type: Die.TYPES

func dupe() -> DiceGroup:
	# To differentiate from "duplicate()". Yeah, I know...
	var group: DiceGroup = DiceGroup.new()
	group.count = count
	group.die_type = die_type
	return group

static func dupe_array( arr: Array[ DiceGroup ] ) -> Array[ DiceGroup ]:
	var result: Array[ DiceGroup ] = []
	result.resize( arr.size() )
	for i in range( arr.size() ):
		result[ i ] = arr[ i ].dupe()
	return result
