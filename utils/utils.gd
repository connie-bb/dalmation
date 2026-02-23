extends Node
class_name Utils

const DIE_TYPE_TO_STRING: Dictionary[ Die.TYPES, String ] = {
	Die.TYPES.D4: "d4",
	Die.TYPES.D6: "d6",
	Die.TYPES.D8: "d8",
	Die.TYPES.D10: "d10",
	Die.TYPES.D12: "d12",
	Die.TYPES.D20: "d20",
	Die.TYPES.D100: "d100",
}

static func plus_me( number: int ):
	if number > 0:
		return "+" + str( number )
	else:
		return str( number )
