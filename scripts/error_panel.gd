extends Panel
class_name ErrorPanel

# References
@onready var display_timer = $display_timer
@onready var label = $Label

func display_error( error: String ):
	label.text = error
	visible = true
	display_timer.start()
	
func stop_displaying_error():
	visible = false
	display_timer.stop()

func _on_display_timeout():
	stop_displaying_error()
