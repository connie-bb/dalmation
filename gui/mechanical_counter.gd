extends Control
class_name MechanicalCounter

# Configurable
var duration: float = 0.25; # Seconds

# Variable
@onready var speed_factor: float = 1.0 / duration
var old_number: int = 0


# References
@onready var label_left: Label = $TextureRect2/Control/label_left
@onready var label_left_old: Label = $TextureRect2/Control/label_left_old
@onready var label_right: Label = $TextureRect2/Control/label_right
@onready var label_right_old: Label = $TextureRect2/Control/label_right_old
@onready var animation_player_left: AnimationPlayer = $animation_player_left
@onready var animation_player_right: AnimationPlayer = $animation_player_right

func set_number( new_number: int ):
	if abs( new_number ) > 99: return
	if new_number == old_number: return
	var increment: bool = new_number > old_number
	
	var old_number_left = min( abs( old_number / 10 ), 9 )
	var new_number_left = min( abs( new_number / 10 ), 9 )
	var old_number_right = abs( old_number ) % 10
	var new_number_right = abs( new_number ) % 10
	
	if old_number_left != new_number_left:
		label_left_old.text = label_left.text
		label_left.text = str( new_number_left )
		animation_player_left.stop()
		if increment:
			animation_player_left.play( "left_up", -1, speed_factor )
		else:
			animation_player_left.play( "left_down", -1, speed_factor )
		
	if old_number_right != new_number_right:
		label_right_old.text = label_right.text
		label_right.text = str( new_number_right )
		animation_player_right.stop()
		if increment:
			animation_player_right.play( "right_up", -1, speed_factor )
		else:
			animation_player_right.play( "right_down", -1, speed_factor )
	old_number = new_number
