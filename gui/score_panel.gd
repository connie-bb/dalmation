extends Panel
class_name ScorePanel

# References
@onready var score_label: Label = $VBoxContainer/score_label

func display( score: int ):
	score_label.text = str( score )
