extends Control
class_name LoadingScreen

# References
@onready var label = $VBoxContainer/Label

func show_loading():
	if visible: return
	set_status( "Loading" )
	show()
	
func hide_loading():
	if !visible: return
	hide()

func set_status( status: String ):
	label.text = status + "..."
	# This is where I'd put my loading screen witticisms.
	# IF I HAD ANY!!!
