extends Object
class_name Roll

var die_list: Array[ PhysicalDie ] = []
var modifier: int = 0
var score: int = 0

# from_roll_request() does not exist. DiceRoller does all the hard work.

func delete():
	for die in die_list:
		die.delete()
	free.call_deferred()
	
func is_empty() -> bool:
	return die_list.is_empty()
