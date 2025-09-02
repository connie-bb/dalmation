extends Node
class_name ScoreCounter

# Constant
signal score_counted( score: int )

func update_die_scores( active_dice: Node ):
	for group: DiceGroup in active_dice.get_children():
		for die: Die in group.get_children():
			die.update_score()

func count_score( active_dice: Node, addend: int ):
	var total_score: int = addend
	for group: DiceGroup in active_dice.get_children():
		total_score += count_group_score( group )
	score_counted.emit( total_score )
	
func count_group_score( group: DiceGroup ) -> int:
	var group_score: int = 0
	var die_scores: Array[int] = []
	
	for die: Die in group.get_children():
		die_scores.append( die.get_score() )
	die_scores.sort()
	
	if group.advantage > 0:
		for i in range( group.count - group.advantage ):
			die_scores.pop_front()
	if group.disadvantage > 0:
		for i in range( group.count - group.disadvantage ):
			die_scores.pop_back()
	
	group_score = die_scores.reduce( func( a, b ): return a + b, 0 )
	
	if group.subtract: group_score *= -1
	
	return group_score
