extends Control
class_name GUI

# References
@export var score_label: Label
@export var error_panel: ErrorPanel
@export var roll_editor_panel: RollEditorPanel
@export var tooltip: Tooltip
@onready var help_menu: HelpMenu = $help_menu

func _ready():
	assert( score_label != null, "GUI has no assigned score_label" )
	assert( error_panel != null, "GUI has no assigned error_panel" )
	assert( roll_editor_panel != null, "GUI has no assigned RollEditorPanel" )
	assert( tooltip != null )
	TooltipManager.tooltip = tooltip
	
func display_score( score: int ):
	score_label.text = str( score ) 

func display_error( error: String ):
	error_panel.display_error( error )

func stop_displaying_error():
	error_panel.stop_displaying_error()

func _on_help_button_pressed():
	help_menu.open_help()
