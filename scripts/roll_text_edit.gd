extends TextEdit
class_name RollTextEdit

func get_roll_text():
	sanitize_text()
	return text
	
func _on_text_changed():
	sanitize_text()

func sanitize_text():
	var final_text := text
	var caret_pos: int = get_caret_column()
	
	var reggie: RegEx = RegEx.new()
	var matches: Array[RegExMatch]
	
	reggie.compile( "[=, ]" )
	matches = reggie.search_all( final_text )
	for match in matches:
		final_text[ match.get_start() ] = "+"
		
	reggie.compile( "[abd0-9\\-\\+]" )
	matches = reggie.search_all( final_text )
	final_text = ""
	for match in matches:
		final_text += match.get_string()

	text = final_text
	set_caret_column( caret_pos )
	return
	
func _input( event: InputEvent ):
	if event.is_action_pressed( "roll" ):
		release_focus()
