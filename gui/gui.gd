extends Control
class_name GUI

# References
@export var score_label: Label
@export var error_panel: ErrorPanel
@export var history: History
@export var roll_editor_panel: RollEditorPanel
@export var tooltip: Tooltip
@onready var help_menu: HelpMenu = $help_menu

func _ready():
	assert( score_label != null, "GUI has no assigned score_label" )
	assert( error_panel != null, "GUI has no assigned error_panel" )
	assert( history != null, "GUI has no assigned History" )
	assert( roll_editor_panel != null, "GUI has no assigned RollEditorPanel" )
	assert( tooltip != null )
	TooltipManager.tooltip = tooltip

func get_addend() -> int:
	return roll_editor_panel.addend

func update_roll_editor_panel( spawnlist: Array[ DiceGroup ] ):
	roll_editor_panel.update( spawnlist )

func display_score( score: int ):
	score_label.text = str( score ) 

func display_error( error: String ):
	error_panel.display_error( error )

func stop_displaying_error():
	error_panel.stop_displaying_error()

func _on_help_button_pressed():
	help_menu.open_help()
