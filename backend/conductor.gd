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
	assert( roll_editor and score_counter and dice_roller and gui,
		"Please assign all exported variables in Conductor." )

func _on_roll_editor_changed():
	gui.update_roll_editor_panel( roll_editor.spawnlist )

func _on_roll_button_pressed():
	gui.stop_displaying_error()
	
	var total_dice: int = 0
	for group: DiceGroup in roll_editor.spawnlist:
		total_dice += group.count
	if total_dice == 0: return
	if total_dice > Settings.max_dice:
		gui.display_error( "Max of " + str( Settings.max_dice ) \
			+ " dice at once." )
		return
	
	if dice_roller.state == dice_roller.STATES.SETTLED:
		# A previous roll exists, and has finished.
		add_history()

	score_counter.stored_addend = gui.get_addend()
	
	var roll_string = Utils.dice_groups_to_string( roll_editor.spawnlist )
	roll_string += Utils.addend_to_string( score_counter.stored_addend )
	Debug.log( "Roll: " + roll_string, Debug.TAG.INFO )
	
	var spawnlist = DiceGroup.dupe_array( roll_editor.spawnlist )
	dice_roller.roll_dice( spawnlist )

func add_history():
	var addend = score_counter.stored_addend
	var score: int = score_counter.count_score(
		dice_roller.active_dice, addend )
	var active_groups = dice_roller.get_active_groups()
	var roll_string = Utils.dice_groups_to_string( active_groups )
	roll_string += Utils.addend_to_string( score_counter.stored_addend )
	gui.history.new_row( score, roll_string, \
		DiceGroup.dupe_array( active_groups ), score_counter.stored_addend )

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

func _on_history_replay_pressed( spawnlist: Array[ DiceGroup ], addend: int ):
	roll_editor.spawnlist = DiceGroup.dupe_array( spawnlist )
	gui.roll_editor_panel.addend_spinbox.value = addend
	gui.update_roll_editor_panel(
		DiceGroup.dupe_array( spawnlist )
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

func _on_roll_editor_panel_cleared():
	roll_editor.spawnlist = []
	gui.roll_editor_panel.addend_spinbox.value = 0
	gui.update_roll_editor_panel( [] )
