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
	# TODO: Parse roll text
	dice_roller.roll_dice()

func _on_ready_to_count():
	score_counter.count_score( dice_roller.active_dice )

func _on_score_counted( score: int ):
	gui.display_score( score )
