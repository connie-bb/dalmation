extends Node3D
class_name DiceRoller

# Variable
var rolling: bool = false
var multiple_rolls_left = false
var spawnlist: Array[Die]

# Configurable
var min_velocity: float = 18.0
var max_velocity: float = 25.0
var min_angular_velocity: float = 1.0 # rotations/s
var max_angular_velocity: float = 5.0

# Constant
const max_simultaneous_rolls: int = 5
signal ready_to_count

# References
@onready var spawnable_dice: Node3D = $spawnable_dice
@onready var active_dice: Node3D = $active_dice
@onready var roll_warmup_timer: Timer = $roll_warmup_timer
@onready var multiple_roll_timer: Timer = $multiple_roll_timer
@onready var roll_max_timer: Timer = $roll_max_timer

func _input( event ):
	if !( event is InputEventKey ):
		return
	if !( event.is_action_pressed( "roll" ) ):
		return
	roll_dice()

func remove_active_dice():
	for c in active_dice.get_children():
		c.queue_free()

func roll_die( to_spawn: Die ):
	var die: Die = to_spawn.duplicate()
	die.position = global_position
	
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

func roll_dice():
	remove_active_dice()
	spawnlist = []
	multiple_roll_timer.stop()
	
	roll_warmup_timer.start()
	rolling = true
	
	for c: Die in spawnable_dice.get_children():
		spawnlist.append( c )
		spawnlist.append( c )
		spawnlist.append( c )
		spawnlist.append( c )
		spawnlist.append( c )
		spawnlist.append( c )
		spawnlist.append( c )
		spawnlist.append( c )
		spawnlist.append( c )
		spawnlist.append( c )
		
	roll_batch_of_dice()

func _on_multiple_roll_timeout():
	roll_batch_of_dice()

func roll_batch_of_dice():
	for i in range( 0, spawnlist.size() ):
		if i >= max_simultaneous_rolls:
			multiple_roll_timer.start()
			return
		roll_die( spawnlist.pop_back() )
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
	var score_total: int = 0
	for c: Die in active_dice.get_children():
		score_total += c.get_score()
	ready_to_count.emit()

func _physics_process( _delta: float ):
	if !rolling: return
	
	var dice_settled: bool = false
	if roll_warmup_timer.is_stopped():
		dice_settled = check_if_dice_settled()
	if dice_settled:
		get_ready_to_count()
