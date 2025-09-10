extends Node3D
class_name DiceRoller

# Variable
var state: STATES = STATES.IDLE
var spawnlist: Array[ DiceGroup ]
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
signal settled
signal die_toggled

# References
@onready var spawnable_dice: SpawnableDice = $spawnable_dice
@onready var active_dice: Node3D = $active_dice
@onready var roll_warmup_timer: Timer = $roll_warmup_timer
@onready var roll_handful_timer: Timer = $roll_handful_timer
@onready var roll_dice_group_timer: Timer = $roll_dice_group_timer
@onready var roll_max_timer: Timer = $roll_max_timer

func remove_active_dice():
	for c in active_dice.get_children():
		c.queue_free()

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

func roll_dice( new_spawnlist: Array[ DiceGroup ] ):
	spawnlist = new_spawnlist
	remove_active_dice()
	roll_warmup_timer.stop()
	roll_max_timer.stop()
	roll_handful_timer.stop()
	
	state = STATES.ROLLING
	roll_dice_group()

func roll_dice_group():
	dice_group = spawnlist.pop_front()
	active_dice.add_child( dice_group )
	group_spawnlist = []
	for i in dice_group.count:
		group_spawnlist.append( 
			spawnable_dice.die_type_to_die[ dice_group.die_type ] )
		if dice_group.die_type == Die.TYPES.D_PERCENTILE_10S:
			group_spawnlist.append(
				spawnable_dice.die_type_to_die[ Die.TYPES.D_PERCENTILE_1S ] )
			
	roll_handful_of_dice()
	
func roll_handful_of_dice():
	for i in range( 0, group_spawnlist.size() ):
		if i >= MAX_SIMULTANEOUS_ROLLS:
			roll_handful_timer.start()
			return
		else:
			roll_die( group_spawnlist.pop_back() )
			
	assert( group_spawnlist.is_empty(), 
		"The following logic assumes we never reached this point 
		with anything left in group_spawnlist.
		If this assertion fails, clearly I was wrong. >_>;" )
	
	if spawnlist.is_empty():
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
	settled.emit()

func _physics_process( _delta: float ):
	if state != STATES.ROLLING: return
	if roll_warmup_timer.is_stopped() and check_if_dice_settled():
		settle()

func _on_die_clicked( die: Die ):
	if state != STATES.SETTLED: return
	die.toggle_disabled()
	die_toggled.emit()
	
func get_active_groups() -> Array[ DiceGroup ]:
	var result: Array[ DiceGroup ]
	for group_node in active_dice.get_children():
		result.append( group_node as DiceGroup )
	return result
