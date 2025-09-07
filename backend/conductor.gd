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
	gui.update_roll_editor_panel( roll_editor.spawnlist )

func _on_roll_button_pressed():
	var total_dice: int = 0
	for group: DiceGroup in roll_editor.spawnlist:
		total_dice += group.count
	if total_dice > 30:	#TODO don't hardcode this value and error string
		gui.display_error( "Max of 30 dice at once." )
		return
	
	score_counter.stored_addend = gui.get_addend()
	
	if dice_roller.state == dice_roller.STATES.SETTLED:
		# A previous roll exists, and has finished.
		add_history()
	
	var roll_string = Utils.dice_groups_to_string( roll_editor.spawnlist )
	roll_string += Utils.addend_to_string( score_counter.stored_addend )
	Debug.log( "Roll: " + roll_string, Debug.TAG.INFO )
	
	gui.stop_displaying_error()
	if roll_editor.spawnlist.is_empty():
		push_warning( "Roll editor spawnlist is empty." )
		return
	var spawnlist = DiceGroup.dupe_array( roll_editor.spawnlist )
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
	var active_groups = dice_roller.get_active_groups()
	var roll_string = Utils.dice_groups_to_string( active_groups )
	roll_string += Utils.addend_to_string( score_counter.stored_addend )
	gui.history.new_row(
		score, roll_string, DiceGroup.dupe_array( active_groups )
	)

func _on_dice_roller_settled():
	score_counter.update_die_scores( dice_roller.active_dice )
	update_score()

func update_score():
	var addend = score_counter.stored_addend
	var score: int = score_counter.count_score(
		dice_roller.active_dice, addend
	)
	
	Debug.log( "Score: " + str( score ), Debug.TAG.INFO )
	gui.display_score( score )

func _on_history_replay_pressed( spawnlist: Array[ DiceGroup ] ):
	roll_editor.spawnlist = spawnlist
	gui.update_roll_editor_panel(
		DiceGroup.dupe_array( roll_editor.spawnlist )
	)
	_on_roll_button_pressed()

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
