extends Node
class_name ScoreCounter

# Variable
var stored_addend: int = 0

func update_die_scores( active_dice: Node ):
	for group: DiceGroup in active_dice.get_children():
		for die: Die in group.get_children():
			die.update_score()

func count_score( active_dice: Node, addend: int ) -> int:
	var total_score: int = addend
	for group: DiceGroup in active_dice.get_children():
		total_score += count_group_score( group )
	return total_score
	
func count_group_score( group: DiceGroup ) -> int:
	var group_score: int = 0
	for die: Die in group.get_children():
		group_score += die.get_score()
	
	return group_score
