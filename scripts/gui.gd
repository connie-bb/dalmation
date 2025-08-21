extends Control
class_name GUI

# References
@export var score_label: Label

func _ready():
	assert( score_label != null, "GUI has no assigned score_label" )

func display_score( score: int ):
	score_label.text = str( score ) 
