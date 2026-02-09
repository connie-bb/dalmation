extends Control

# Configurable
@export var steps: Array[ TutorialStep ]

# Variable
var current_step_index = -1		# -1 means no current step yet.

# References
@onready var ui_highlighter: UIHighlighter = $ui_highlighter

func _ready():
	Settings.settings_loaded.connect( first_time_check )
	
func first_time_check():
	if !Settings.tutorial_played:
		start()
		Settings.tutorial_played = true
		Settings.save_settings()

func start():
	show()
	show_next_step()
	
func _input( event: InputEvent ):
	if !visible: return
	if event is InputEventMouseButton:
		get_window().set_input_as_handled()
		var mouse_event = event as InputEventMouseButton
		
		if mouse_event.is_pressed():
			show_next_step()

func show_next_step():
	if current_step_index >= 0:
		# A previous step must be hidden.
		steps[ current_step_index ].hide()
		
	current_step_index += 1
	if current_step_index >= steps.size():
		stop()
		return
	steps[ current_step_index ].show()
	ui_highlighter.highlight( steps[ current_step_index ].highlight_target )

func stop():
	current_step_index = -1
	hide()
