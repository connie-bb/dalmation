extends Control
class_name LongPressButton

# Configurable
var long_press_duration = 1.0
var long_press_repeat_interval = 1.0

# Variable
var long_press: bool = false

# References
var long_press_timer: Timer

# Constant
signal short_pressed
signal long_pressed
signal scrolled_up
signal scrolled_down

func _ready():
	long_press_timer = Timer.new()
	long_press_timer.one_shot = true
	add_child( long_press_timer )
	long_press_timer.timeout.connect( _on_long_press_timeout )

func _gui_input( event: InputEvent ):
	if event is InputEventMouseButton:
		var mouse_event = event as InputEventMouseButton
		
		if mouse_event.button_index == MOUSE_BUTTON_LEFT \
		and mouse_event.is_pressed():
			long_press_timer.start( long_press_duration )
			
		elif mouse_event.button_index == MOUSE_BUTTON_LEFT \
		and mouse_event.is_released() \
		and long_press:
			long_press_timer.stop()
			long_press = false
		
		elif mouse_event.button_index == MOUSE_BUTTON_LEFT \
		and mouse_event.is_released() \
		and !long_press:
			short_pressed.emit()
			
		elif mouse_event.is_released() \
		and mouse_event.button_index == MOUSE_BUTTON_RIGHT:
			long_pressed.emit()
			
		# \/ We can externalize these two jesters later if need be. \/
		elif mouse_event.button_index == MOUSE_BUTTON_WHEEL_UP \
		and mouse_event.is_released():
			scrolled_up.emit()
			
		elif mouse_event.button_index == MOUSE_BUTTON_WHEEL_DOWN \
		and mouse_event.is_released():
			scrolled_down.emit()


func _on_long_press_timeout():
	# Just in case we don't get the 'release' signal:
	if !Input.is_mouse_button_pressed( MOUSE_BUTTON_LEFT ):
		long_press = false
		return
	# ---
	
	long_press = true
	long_press_timer.start( long_press_repeat_interval )
	long_pressed.emit()
