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
		
static func random_quaternion() -> Quaternion:
	# Go wayback on http://planning.cs.uiuc.edu/node198.html
	# Formula described by Steven M. LaValle, 2012, Cambridge Uni Press
	# I don't even know what to say. Quats are black magic.
	var u1 = randf()
	var TAUu2 = randf() * TAU
	var TAUu3 = randf() * TAU
	
	var sqrt_inv_u1 = sqrt( 1.0 - u1 )
	var sqrt_u1 = sqrt( u1 )
	var X = sqrt_inv_u1 * sin( TAUu2 )
	var Y = sqrt_inv_u1 * cos( TAUu2 )
	var Z = sqrt_u1 * sin( TAUu3 )
	var W = sqrt_u1 * cos( TAUu3 )
	
	return Quaternion( X, Y, Z, W )
