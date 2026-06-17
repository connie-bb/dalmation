extends Node

# Add as a child of GUI.
# Wire in the die_rolled signal from dice_roller.

# Measures the initial rotation of dice and if they're facing 'up' or 'down'.
# Then we do some eyeball statistical analysis.

# Variable
var coin_flips: Array[bool] = []
var rolls: int = 0

# References
@onready var debug_label: Label = $Panel/VBoxContainer/debug_label

func _on_dice_roller_die_rolled( die: PhysicalDie ):
	const comparison_axis: Vector3 = Vector3.UP
	var is_heads: bool = comparison_axis.dot(
		die.basis * Vector3.UP ) > 0.0
	coin_flips.append( is_heads )
	rolls += 1
	update_stats()
	
func update_stats():
	var heads_weight: float = float( coin_flips.count( true ) ) \
		/ float( coin_flips.size() )
	var tails_weight: float = float( coin_flips.count( false ) ) \
		/ float( coin_flips.size() )
	heads_weight = snappedf( heads_weight, 0.0001 )
	tails_weight = snappedf( tails_weight, 0.0001 )
	
	var heads_string: String = str( heads_weight ).pad_decimals( 4 )
	var tails_string: String = str( tails_weight ).pad_decimals( 4 )

	debug_label.text = "Heads: " + heads_string \
		+ "\nTails: " + tails_string \
		+ "\nRolls: " + str(rolls)
