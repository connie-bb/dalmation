extends Node3D
class_name Die

# Variable
enum TYPES { D4, D6, D8, D10, D12, D20, D_PERCENTILE_10S, D_PERCENTILE_1S }
@export var die_type: TYPES
var disabled: bool = false
var score: int

static func from_physical_die( die: PhysicalDie ) -> Die:
	var result: Die = Die.new()
	result.die_type = die.die_type
	result.disabled = die.disabled
	result.score = die.score
	return result

func get_score() -> int:
	if disabled: return 0
	else: return score

func toggle_disabled():
	if disabled: enable()
	else: disable()
	
func disable():
	print( "Disabled from Die")
	disabled = true
	
func enable():
	print( "Enabled from Die")
	disabled = false

func delete():
	queue_free()
