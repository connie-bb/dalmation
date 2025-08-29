extends Control
class_name GUI

# References
@export var score_label: Label
@export var error_panel: ErrorPanel
@export var history: History
@onready var help_menu: HelpMenu = $help_menu

func _ready():
	assert( score_label != null, "GUI has no assigned score_label" )
	assert( error_panel != null, "GUI has no assigned error_panel" )
	assert( history != null, "GUI has no assigned History" )

func add_history( score: int, roll: String ):
	history.add( score, roll )

func display_score( score: int ):
	score_label.text = str( score ) 

func display_error( error: String ):
	error_panel.display_error( error )

func stop_displaying_error():
	error_panel.stop_displaying_error()

func _on_help_button_pressed():
	help_menu.open_help()
