extends Node3D
class_name Die

# Variable
var die_type: TYPES
var disabled: bool = false
var locked: bool = false
var score: int

# Constant
enum TYPES { D4, D6, D8, D10, D12, D20, D_PERCENTILE_10S, D_PERCENTILE_1S }

static func from_physical_die( die: PhysicalDie ) -> Die:
	var result: Die = Die.new()
	result.die_type = die.die_type
	result.disabled = die.disabled
	result.score = die.score
	return result

func delete():
	queue_free()
