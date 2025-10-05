extends Node
class_name ScoreCounter

# Constant
signal score_counted( score: int )

func count_score( roll: Roll ):
	var total_score: int = 0
	total_score += roll.modifier
	
	for die: PhysicalDie in roll.die_list:
		die.update_score()
		if !die.disabled:
			total_score += die.score
	
	roll.score = total_score
	Debug.log( "Score: " + str( total_score ), Debug.TAG.INFO )
	score_counted.emit( total_score )
