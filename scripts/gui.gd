extends Control

@onready var score_label: Label = $Panel/score_label

func display_score( score: int ):
	score_label.text = "score: " + str( score ) 

func _on_score_counted( score: int ):
	display_score( score )
