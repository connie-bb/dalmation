extends Control
class_name ModSpinwheel

# Configurable
const duration: float = 0.5	# Seconds

# Variable
@onready var speed_factor = 1.0 / duration
var old_number = 0

# References
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var label: Label = $Label

func set_number( new_number: int ):
	if abs( new_number ) > Settings.max_modifier: return
	if new_number == old_number: return
	
	if new_number > old_number:
		animation_player.stop()
		animation_player.play( "spin_ccw", -1, speed_factor )
	else:
		animation_player.stop()
		animation_player.play( "spin_cw", -1, speed_factor )
	
	label.text = Utils.plus_me( new_number )
	
	old_number = new_number
