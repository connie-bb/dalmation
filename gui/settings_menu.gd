extends Control

# References
@onready var settings_main: Control = $settings_main

# Constant
signal show_tutorial_pressed

func open_settings():
	show()
	settings_main.show()
	
func close_settings():
	hide()
	settings_main.hide()

func _input( event: InputEvent ):
	if !visible: return
	if event.is_action_pressed( "ui_exit" ):
		close_settings()

func _on_show_tutorial_pressed():
	close_settings()
	show_tutorial_pressed.emit()
