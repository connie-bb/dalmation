extends Node
class_name ScoreCounter

# Constant
signal score_counted( score: int )

func count_score( roll: Roll ):
	var total_score: int = 0
	total_score += roll.addend
	
	for group: DiceGroup in roll.spawnlist:
		if !group.is_inside_tree():
			push_error(
				"Tried to call count_score() on an uninstantiated roll." )
		for die: Die in group.get_children():
			die.update_score()
		total_score += count_group_score( group )
	
	roll.score = total_score
	Debug.log( "Score: " + str( total_score ), Debug.TAG.INFO )
	score_counted.emit( total_score )
	
func count_group_score( group: DiceGroup ) -> int:
	var group_score: int = 0
	for die: Die in group.get_children():
		group_score += die.get_score()
	
	return group_score
