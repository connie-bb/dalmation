extends Node
class_name ScoreCounter

# Constant
signal score_counted( score: int )

func count_score( active_dice: Node ):
	var score: int = 0
	for c: Die in active_dice.get_children():
		score += c.get_score()
	
	score_counted.emit( score )
