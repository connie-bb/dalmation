extends Node3D
class_name DiceRoller

# Variable
var state: STATES = STATES.IDLE
var current_roll: Roll
var spawnlist_index: int = 0
var dice_group: DiceGroup
var group_spawnlist: Array[ Die ]

# Configurable
var min_velocity: float = 18.0
var max_velocity: float = 25.0
var min_angular_velocity: float = 1.0 # rotations/s
var max_angular_velocity: float = 5.0

# Constant
enum STATES { IDLE, ROLLING, SETTLED }
const MAX_SIMULTANEOUS_ROLLS: int = 5
signal settled( roll: Roll )
signal old_roll_done( roll: Roll )
signal die_toggled( roll: Roll )
signal error_with_roll( error: String )

# References
@onready var spawnable_dice: SpawnableDice = $spawnable_dice
@onready var active_dice: Node3D = $active_dice
@onready var roll_warmup_timer: Timer = $roll_warmup_timer
@onready var roll_handful_timer: Timer = $roll_handful_timer
@onready var roll_dice_group_timer: Timer = $roll_dice_group_timer
@onready var roll_max_timer: Timer = $roll_max_timer

func remove_active_dice():
	for group: DiceGroup in active_dice.get_children():
		for die in group.get_children():
			die.queue_free()
		# Preserve DiceGroups so the Roll can be passed to History.
		if active_dice.is_ancestor_of( group ):
			active_dice.remove_child( group )

func roll_die( to_spawn: Die ):
	var die: Die = to_spawn.duplicate()
	
	var velocity = randf_range( min_velocity, max_velocity )
	var angular_velocity := Vector3( randf(), randf(), randf() )
	angular_velocity *= randf_range( min_angular_velocity, \
		max_angular_velocity )
	var rotation_axis = Vector3( randf(), randf(), randf() ).normalized()
	var rotation_angle = randf_range( 0, TAU )
	
	die.rotate( rotation_axis, rotation_angle )
	die.angular_velocity = angular_velocity * TAU
	die.apply_impulse( Vector3.FORWARD * velocity )
	
	die.clicked.connect( _on_die_clicked )
	
	dice_group.add_child( die )
	die.position = Vector3.ZERO

func roll_dice( roll: Roll ):
	var total_dice: int = 0
	for group: DiceGroup in roll.spawnlist:
		total_dice += group.count
		#TODO: Special case for d100
	if total_dice == 0: return
	if total_dice > Settings.max_dice:
		error_with_roll.emit( "Max of " + str( Settings.max_dice ) \
			+ " dice at once." )
		return
	
	# --------------- No more early returns.
	
	if state == STATES.SETTLED:
		# A previous roll exists, and has finished.
		old_roll_done.emit( current_roll )
		
	if current_roll != null:
		remove_active_dice()
		
	current_roll = roll.dupe()
	
	var roll_string = roll.string()
	Debug.log( "Roll: " + roll_string, Debug.TAG.INFO )
		
	roll_warmup_timer.stop()
	roll_max_timer.stop()
	roll_handful_timer.stop()
	
	state = STATES.ROLLING
	
	spawnlist_index = 0
	roll_dice_group()

func roll_dice_group():
	dice_group = current_roll.spawnlist[ spawnlist_index ]
	active_dice.add_child( dice_group )
	group_spawnlist = []
	for i in dice_group.count:
		group_spawnlist.append( 
			spawnable_dice.die_type_to_die[ dice_group.die_type ] )
		if dice_group.die_type == Die.TYPES.D_PERCENTILE_10S:
			group_spawnlist.append(
				spawnable_dice.die_type_to_die[ Die.TYPES.D_PERCENTILE_1S ] )
			
	roll_handful_of_dice()
	spawnlist_index += 1
	
func roll_handful_of_dice():
	for i in range( 0, group_spawnlist.size() ):
		if i >= MAX_SIMULTANEOUS_ROLLS:
			roll_handful_timer.start()
			return
		else:
			roll_die( group_spawnlist.pop_back() )
	
	if spawnlist_index >= current_roll.spawnlist.size() - 1:
		finished_rolling()
	else:
		roll_dice_group_timer.start()

func _on_roll_handful_timeout():
	roll_handful_of_dice()
	
func _on_roll_dice_group_timeout():
	roll_dice_group()

func finished_rolling():
	roll_warmup_timer.start()
	roll_max_timer.start()

func _on_roll_max_timeout():
	settle()
	
func check_if_dice_settled() -> bool:
	for group: DiceGroup in active_dice.get_children():
		for die in group.get_children():
			if !die.sleeping: return false
	return true

func settle():
	state = STATES.SETTLED
	roll_max_timer.stop()
	settled.emit( current_roll )
	
func update_addend( addend: int ):
	current_roll.addend = addend
	if state == STATES.SETTLED:
		settle() # Re-count the score
		# If state != settled, score gets counted later anyway.

func _physics_process( _delta: float ):
	if state != STATES.ROLLING: return
	if roll_warmup_timer.is_stopped() and check_if_dice_settled():
		settle()

func _on_die_clicked( die: Die ):
	if state != STATES.SETTLED: return
	die.toggle_disabled()
	die_toggled.emit( current_roll )
	
func get_active_groups() -> Array[ DiceGroup ]:
	var result: Array[ DiceGroup ]
	for group_node in active_dice.get_children():
		result.append( group_node as DiceGroup )
	return result
