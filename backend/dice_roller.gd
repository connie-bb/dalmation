extends Node3D
class_name DiceRoller

# Variable
var state: STATES = STATES.IDLE
var current_roll: Roll
var spawnlist: Array[ Die.TYPES ]

# Configurable
var min_velocity: float = 18.0
var max_velocity: float = 25.0
var min_angular_velocity: float = 1.0 # rotations/s
var max_angular_velocity: float = 5.0

# Constant
enum STATES { IDLE, ROLLING, SETTLED }
const MAX_SIMULTANEOUS_ROLLS: int = 5
signal scoring_requested( roll: Roll )
signal old_roll_done( roll: Roll )
signal error_with_roll( error: String )

# References
@onready var spawnable_dice: SpawnableDice = $spawnable_dice
@onready var active_dice: Node3D = $active_dice
@onready var roll_warmup_timer: Timer = $roll_warmup_timer
@onready var roll_handful_timer: Timer = $roll_handful_timer
@onready var roll_max_timer: Timer = $roll_max_timer

func _physics_process( _delta: float ):
	if state != STATES.ROLLING: return
	if roll_warmup_timer.is_stopped() and check_if_dice_settled():
		settle()

func remove_active_dice():
	for die: PhysicalDie in active_dice.get_children():
		die.delete()

func roll_die( die_type: Die.TYPES ):
	var die: PhysicalDie = \
		spawnable_dice.die_type_to_die[ die_type ].duplicate()
	
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
	
	active_dice.add_child( die )
	die.position = Vector3.ZERO
	current_roll.die_list.append( die )

func roll_dice( request: RollRequest ):
	var total_dice: int = 0
	for die_type in request.die_counts.keys():
		total_dice += request.die_counts[ die_type ]
		if die_type == Die.TYPES.D_PERCENTILE_10S:
			total_dice += 1 # We'll spawn a D_PERCENTILE_1s in addition.
	if total_dice == 0: return
	if total_dice > Settings.max_dice:
		error_with_roll.emit( "Max of " + str( Settings.max_dice ) \
			+ " dice at once." )
		return
	
	# --------------- No early returns allowed past this point.
	
	if state == STATES.SETTLED:
		# A previous roll exists, and has finished.
		old_roll_done.emit( current_roll )
		
	if current_roll != null:
		remove_active_dice()
		
	current_roll = Roll.new()
	
	var roll_string = request.as_string()
	Debug.log( "Roll: " + roll_string, Debug.TAG.INFO )
		
	roll_warmup_timer.stop()
	roll_max_timer.stop()
	roll_handful_timer.stop()
	
	state = STATES.ROLLING
	
	for die_type in request.die_counts.keys():
		for i in request.die_counts[ die_type ]:
			spawnlist.append( die_type )
			if die_type == Die.TYPES.D_PERCENTILE_10S:
				spawnlist.append( Die.TYPES.D_PERCENTILE_1S )
	# I miss C style brackets...
	current_roll.modifier = request.modifier
	roll_handful_of_dice()
	
func roll_handful_of_dice():
	for i in range( 0, spawnlist.size() ):
		if i < MAX_SIMULTANEOUS_ROLLS:
			roll_die( spawnlist.pop_back() )
		else: # if i >= MAX_SIMULTANEOUS_ROLLS:
			roll_handful_timer.start()
			return

	assert( spawnlist.is_empty(), "Following code assumes spawnlist is empty.
		If this triggers clearly I was wrong. >_>;" )
	all_dice_spawned()

func _on_roll_handful_timeout():
	roll_handful_of_dice()

func all_dice_spawned():
	roll_warmup_timer.start()
	roll_max_timer.start()

func _on_roll_max_timeout():
	settle()
	
func check_if_dice_settled() -> bool:
	for die: PhysicalDie in active_dice.get_children():
		if !die.sleeping: return false
	return true

func settle():
	state = STATES.SETTLED
	roll_max_timer.stop()
	request_scoring()
	
func request_scoring():
	scoring_requested.emit( current_roll )
	
func update_modifier( modifier: int ):
	if current_roll == null: return
	current_roll.modifier = modifier
	if state == STATES.SETTLED:
		request_scoring()
		# If state != settled, score gets counted later anyway.

func _on_die_clicked( _die: Die ):
	if state == STATES.SETTLED:
		request_scoring()
		# If state != settled, score gets counted later anyway.
	
func get_active_dice() -> Array[ PhysicalDie ]:
	var result: Array[ PhysicalDie ]
	for die in active_dice.get_children():
		result.append( die as PhysicalDie )
	return result
