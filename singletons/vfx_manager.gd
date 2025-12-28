extends Node

var dice_roller: DiceRoller
var die_positions: Array[ Vector3 ]

func _ready():
	die_positions.resize( 30 )
	# ^ Hardcoded because shader array size cannot change at runtime.

func _process( _delta: float ):
	if dice_roller == null: return
	die_positions.fill( Vector3( 1000, 0, 0 ) ) # nice and far offscreen
	var die_count = min( dice_roller.current_roll.die_list.size(), 30 )
	for die_idx in die_count:
		var die: PhysicalDie = dice_roller.current_roll.die_list[ die_idx ]
		die_positions[ die_idx ] = die.global_position
