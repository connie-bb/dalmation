extends Label
class_name RollTextEdit
# Okay, it's not REALLY a TextEdit...
# But it behaves like one! Sort of.

func get_roll_text():
	#TODO: sanitize_text()
	return text

func parse_input( event: InputEvent ):
	if event.is_action_pressed( "edit_d" ):
		text += "d"
	if event.is_action_pressed( "edit_separator" ):
		text += "+"
	if event.is_action_pressed( "edit_backspace" ) and text != "":
		text = text.substr( 0, text.length() - 1 )
	parse_input_numbers( event )

func parse_input_numbers( event: InputEvent ):
	if !( event is InputEventKey ): return
	if !( event.is_pressed() ): return
	
	var number: int = 0
	if ( event.keycode >= KEY_0 and event.keycode <= KEY_9 ):
		number = event.keycode - KEY_0
	elif ( event.keycode >= KEY_KP_0 and event.keycode <= KEY_KP_9 ):
		number = event.keycode - KEY_KP_0
	else:
		return

	text += str( number )

func sanitize_text():
	# WIP function.
	var final_text := ""
	var reggie: RegEx = RegEx.new()
	reggie.compile( "[d0-9]" )
	var match = reggie.search_all( text )
	if !match: text = final_text; return
	for i in range( 0, match.size() ):
		final_text += match[i].get_string()
	text = final_text
	return

func _input( event: InputEvent ):
	parse_input( event )
