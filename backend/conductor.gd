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
	if dice_roller.state == dice_roller.STATES.SETTLED:
		# A previous roll exists, and has finished.
		add_history()
	
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

func add_history():
	var addend = score_counter.stored_addend
	var score: int = score_counter.count_score(
		dice_roller.active_dice, addend
	)
	var roll_string = Utils.dice_groups_to_string(
		dice_roller.get_active_groups()
	)
	if addend > 0:
		roll_string += " + " + str( addend )
	elif addend < 0:
		roll_string += " - " + str( abs( addend ) )
	gui.history.new_row( score, roll_string )

func _on_dice_roller_settled():
	score_counter.update_die_scores( dice_roller.active_dice )
	score_counter.stored_addend = gui.get_addend()
	update_score()

func update_score():
	var addend = score_counter.stored_addend
	var score: int = score_counter.count_score(
		dice_roller.active_dice, addend
	)
	
	Debug.log( "Score: " + str( score ), Debug.TAG.INFO )
	gui.display_score( score )

#func _on_replay_requested( roll_text: String ):
	#roll_text_edit.text = roll_text
	#_on_roll_button_pressed()

func _on_roll_editor_panel_count_changed( count: int, dice_group: DiceGroup ):
	dice_group.count = count
	
func _on_roll_editor_panel_deleted( dice_group ):
	roll_editor.remove_group( dice_group )

func _on_dice_roller_die_toggled():
	update_score()

func _on_score_addend_edited():
	if dice_roller.state != DiceRoller.STATES.SETTLED: return
	score_counter.stored_addend = gui.get_addend()
	update_score()
