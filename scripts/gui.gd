extends Control
class_name GUI

# References
@export var score_label: Label
@export var error_panel: ErrorPanel

func _ready():
	assert( score_label != null, "GUI has no assigned score_label" )

func display_score( score: int ):
	score_label.text = str( score ) 

func display_error( error: String ):
	error_panel.display_error( error )

func stop_displaying_error():
	error_panel.stop_displaying_error()
