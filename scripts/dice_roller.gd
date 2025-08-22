extends Node3D
class_name DiceRoller

# Variable
var rolling: bool = false
var multiple_rolls_left = false
var spawnlist: Array[ RollTextParser.SpawnlistEntry ]
var entry_spawns: Array[ Die ]

# Configurable
var min_velocity: float = 18.0
var max_velocity: float = 25.0
var min_angular_velocity: float = 1.0 # rotations/s
var max_angular_velocity: float = 5.0

# Constant
const max_simultaneous_rolls: int = 5
signal ready_to_count

# References
@onready var spawnable_dice: SpawnableDice = $spawnable_dice
@onready var active_dice: Node3D = $active_dice
@onready var roll_warmup_timer: Timer = $roll_warmup_timer
@onready var multiple_roll_timer: Timer = $multiple_roll_timer
@onready var roll_max_timer: Timer = $roll_max_timer

func remove_active_dice():
	for c in active_dice.get_children():
		c.queue_free()

func roll_die( to_spawn: Die ):
	var die: Die = to_spawn.duplicate()
	
	var velocity = randf_range( min_velocity, max_velocity )
	var angular_velocity := Vector3( randf(), randf(), randf() )
	angular_velocity *= randf_range(
		min_angular_velocity, max_angular_velocity
	)
	var rotation_axis = Vector3( randf(), randf(), randf() ).normalized()
	var rotation_angle = randf_range( 0, TAU )
	
	die.rotate( rotation_axis, rotation_angle )
	die.angular_velocity = angular_velocity * TAU
	die.apply_impulse( Vector3.FORWARD * velocity )
	
	active_dice.add_child( die )
	die.position = Vector3.ZERO

func roll_dice( new_spawnlist: Array[ RollTextParser.SpawnlistEntry ] ):
	spawnlist = new_spawnlist
	remove_active_dice()
	roll_warmup_timer.stop()
	roll_max_timer.stop()
	multiple_roll_timer.stop()
	
	rolling = true
	roll_entry()

func roll_entry():
	var entry: RollTextParser.SpawnlistEntry = spawnlist[0]
	entry_spawns = []
	for i in entry.count:
		entry_spawns.append( spawnable_dice.sides_to_die[ entry.sides ] )
	spawnlist.pop_front()
	roll_batch_of_dice()
	
func roll_batch_of_dice():
	for i in range( 0, entry_spawns.size() ):
		if i >= max_simultaneous_rolls:
			multiple_roll_timer.start()
			return
		roll_die( entry_spawns.pop_back() )
	if spawnlist.is_empty():
		finished_rolling()
	else:
		multiple_roll_timer.start()

func _on_multiple_roll_timeout():
	assert( !spawnlist.is_empty(), 
	"""We should never reach this point with an empty spawnlist,
	because it means we're waiting for multiple_roll_timer before
	we realize we're finished_rolling(), which wastes user's time.
	""" )
	if entry_spawns.is_empty():
		roll_entry()
	elif !entry_spawns.is_empty():
		roll_batch_of_dice()

func finished_rolling():
	roll_warmup_timer.start()
	roll_max_timer.start()

func _on_roll_max_timeout():
	get_ready_to_count()
	
func check_if_dice_settled() -> bool:
	var any_awake: bool = false
	for c: Die in active_dice.get_children():
		if !c.sleeping: any_awake = true
	return !any_awake

func get_ready_to_count():
	rolling = false
	roll_max_timer.stop()
	ready_to_count.emit()

func _physics_process( _delta: float ):
	if !rolling: return
	
	var dice_settled: bool = false
	if roll_warmup_timer.is_stopped():
		dice_settled = check_if_dice_settled()
	if dice_settled:
		get_ready_to_count()
