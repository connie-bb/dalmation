extends Object
class_name RollReceipt

var die_list: Array[ Die ] = []
var modifier: int = 0
var score: int = 0

static func from_roll( roll: Roll ) -> RollReceipt:
	var result: RollReceipt = RollReceipt.new()
	for die in roll.die_list:
		result.die_list.append( Die.from_physical_die( die ) )
	result.modifier = roll.modifier
	result.score = roll.score
	return result
	
func delete():
	for die in die_list:
		die.queue_free()
	free.call_deferred()

func as_string() -> String:
	# Hold my beer.
	var temp_request = RollRequest.from_roll_receipt( self )
	var result = temp_request.as_string()
	temp_request.delete()
	return result
