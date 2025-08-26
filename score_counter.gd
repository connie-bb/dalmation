extends Node
class_name ScoreCounter

# Constant
signal score_counted( score: int )

func count_score( active_dice: Node ):
	var total_score: int = 0
	for group: DiceGroup in active_dice.get_children():
		for die: Die in group.get_children():
			var die_score = die.get_score()
			total_score += die_score
	
	score_counted.emit( total_score )
