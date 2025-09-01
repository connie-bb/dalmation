extends Node

# Holds references to the most important logic objects and
# orchestrates their behaviour.

# Variables
var most_recent_roll_text: String = ""

# References
@export var roll_editor: RollEditor
@export var dice_roller: DiceRoller
@export var score_counter: ScoreCounter
@export var gui: GUI

func _ready():
	assert( roll_editor != null \
		and score_counter != null \
		and dice_roller != null \
		and gui != null,
		"Please assign all exported variables in the conductor."
	)

func _on_roll_editor_changed():
	gui.update_roll_editor_panel( roll_editor.spawnlist.values() )

func _on_roll_button_pressed():
	gui.stop_displaying_error()
	if roll_editor.spawnlist.is_empty():
		return
	var spawnlist = roll_editor.duplicate_spawnlist().values()
	dice_roller.roll_dice( spawnlist )

	#Debug.log( "Roll: " + text, Debug.TAG.INFO )
	#roll_text_parser.debug_text_spawnlist()

	#if error != RollTextParser.ERROR.NONE:
		#gui.display_error( RollTextParser.ERROR_TO_STRING[ error ] )
		#Debug.log(
			#"Parse error: " + RollTextParser.ERROR_TO_STRING[ error ],
			#Debug.TAG.INFO
		#)
	#if error != roll_text_parser.ERROR.NONE: return

func _on_ready_to_count():
	score_counter.count_score( dice_roller.active_dice )

func _on_score_counted( score: int ):
	Debug.log( "Score: " + str( score ), Debug.TAG.INFO )
	gui.display_score( score )
	gui.add_history( score, "le place holder" )

#func _on_replay_requested( roll_text: String ):
	#roll_text_edit.text = roll_text
	#_on_roll_button_pressed()

func _on_roll_editor_panel_count_changed( count: int, dice_group: DiceGroup ):
	dice_group.count = count
	
func _on_roll_editor_panel_deleted( dice_group ):
	roll_editor.remove_group( dice_group )
