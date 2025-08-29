extends Node

# Holds references to the most important logic objects and
# orchestrates their behaviour.

# Variables
var most_recent_roll_text: String = ""

# References
@export var dice_roller: DiceRoller
@export var score_counter: ScoreCounter
@export var roll_text_parser: RollTextParser
@export var roll_text_edit: RollTextEdit
@export var gui: GUI

func _ready():
	assert( score_counter != null \
		and dice_roller != null \
		and roll_text_parser != null \
		and roll_text_edit != null \
		and gui != null,
		"Please assign all exported variables in the conductor."
	)

func _on_roll_button_pressed():
	gui.stop_displaying_error()
	var text = roll_text_edit.get_roll_text()
	if text == "": return

	Debug.log( "Roll: " + text, Debug.TAG.INFO )

	roll_text_parser.reset()
	var error: int = roll_text_parser.parse( text )
	
	roll_text_parser.debug_text_spawnlist()
	Debug.log( "Sum of constants: " + str( roll_text_parser.constants_sum ) )
	
	if error != RollTextParser.ERROR.NONE:
		gui.display_error( RollTextParser.ERROR_TO_STRING[ error ] )
		Debug.log(
			"Parse error: " + RollTextParser.ERROR_TO_STRING[ error ],
			Debug.TAG.INFO
		)
	
	if error != roll_text_parser.ERROR.NONE: return
	if roll_text_parser.spawnlist.is_empty():
		_on_score_counted( 0 )
		return
	
	most_recent_roll_text = roll_text_edit.text
	dice_roller.roll_dice( roll_text_parser.spawnlist )

func _on_ready_to_count():
	score_counter.count_score( dice_roller.active_dice )

func _on_score_counted( score: int ):
	score += roll_text_parser.constants_sum
	Debug.log( "Score: " + str( score ), Debug.TAG.INFO )
	gui.display_score( score )
	gui.add_history( score, most_recent_roll_text )

func _on_replay_requested( roll_text: String ):
	roll_text_edit.text = roll_text
	_on_roll_button_pressed()
