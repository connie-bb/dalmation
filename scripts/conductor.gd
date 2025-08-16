extends Node

# Holds references to the most important logic objects and
# orchestrates their behaviour.

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
	# Debugging for demonstration. You can wipe this.
	var text = "d6+2d10-15+2d100+4+5+6+7"
	print( "text to parse: " + text )
	var errors: int = roll_text_parser.parse( text )
	print( "errors: ", String.num_int64( errors, 2 ) )
	roll_text_parser.debug_text_spawnlist()
	#-------

	dice_roller.roll_dice()

func _on_ready_to_count():
	score_counter.count_score( dice_roller.active_dice )

func _on_score_counted( score: int ):
	gui.display_score( score )
