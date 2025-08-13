extends Node
class_name ScoreCounter

# Constant
signal score_counted( score: int )

# References
@export var dice_roller: DiceRoller

func _ready():
	assert( dice_roller != null, "score counter has no assigned DiceRoller" )
	dice_roller.ready_to_count.connect( _on_ready_to_count )

func count_score():
	var score: int = 0
	for c: Die in dice_roller.active_dice.get_children():
		score += c.get_score()
	
	score_counted.emit( score )
	
func _on_ready_to_count():
	count_score()
