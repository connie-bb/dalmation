extends Control
class_name HelpMenu


func _input( event: InputEvent ):
	if !visible: return
	if event.is_action_pressed( "ui_exit" ):
		close_help()
		get_viewport().set_input_as_handled()
	elif event is InputEventKey:
		# Block it, block it all!
		# We assume mouse activity is blocked physically by this control
		# taking up the entire screen.
		get_viewport().set_input_as_handled()

func _on_exit_button_pressed():
	close_help()

func open_help():
	visible = true

func close_help():
	visible = false
