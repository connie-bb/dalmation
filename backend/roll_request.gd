extends Object
class_name RollRequest

var die_counts: Dictionary[ Die.TYPES, int ] = {
	Die.TYPES.D4: 0,
	Die.TYPES.D6: 0,
	Die.TYPES.D8: 0,
	Die.TYPES.D10: 0,
	Die.TYPES.D12: 0,
	Die.TYPES.D20: 0,
	Die.TYPES.D100: 0,
}
var modifier: int = 0

static func from_roll_receipt( receipt: RollReceipt ) -> RollRequest:
	var result: RollRequest = RollRequest.new()
	for die: Die in receipt.die_list:
		result.add_die( die.die_type )
	result.modifier = receipt.modifier
	return result

func set_count( die_type: Die.TYPES, count: int ):
	if count == 0:
		die_counts.erase( die_type )
	else:
		die_counts[ die_type ] = count

func add_die( die_type: Die.TYPES ):
	if !die_counts.has( die_type ):
		die_counts[ die_type ] = 0
	die_counts[ die_type ] += 1
	die_counts[ die_type ] = min( die_counts[ die_type ], Settings.max_dice )

func subtract_die( die_type: Die.TYPES ):
	if !die_counts.has( die_type ): return
	die_counts[ die_type ] -= 1
	die_counts[ die_type ] = max( die_counts[ die_type ], 0 )
		
func remove_die( die_type: Die.TYPES ):
	die_counts[ die_type ] = 0

func increment_modifier():
	modifier += 1
	modifier = min( modifier, Settings.max_modifier )

func decrement_modifier():
	modifier -= 1
	modifier = max( modifier, -Settings.max_modifier )
	
func set_modifier( new_modifier: int ):
	modifier = new_modifier

func as_string() -> String:
	var result: String = ""
	
	for die_type: Die.TYPES in die_counts.keys():
		if die_counts[ die_type ] == 0: continue
		result += str( die_counts[ die_type ] )
		result += Utils.DIE_TYPE_TO_STRING[ die_type ]
		result += " + "
	# Cut off the last " + "
	result = result.substr( 0, result.length() - 3 )
	
	if modifier > 0:
		result += " + " + str( modifier )
	elif modifier < 0:
		result += " - " + str( abs( modifier ) )
		
	if result == "": result = "-"
	return result

func delete():
	free.call_deferred()
