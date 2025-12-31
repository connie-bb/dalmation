extends Node3D
class_name SpawnableDice

var die_scene: Resource = preload( "res://dice/physical_die.tscn" )
var die_type_to_die: Dictionary[ Die.TYPES, PhysicalDie ]

func _ready():
	load_dice_set()

func load_dice_set():
	# Load collision / score meshes
	var collisions_resource = preload( "res://dice/placeholder/dice.tscn" )
	var collisions = collisions_resource.instantiate()
	collisions.visible = false
	add_child( collisions )
	collisions.position = Vector3.ZERO
	
	# Load cosmetic meshes
	var dice_set_resource = preload( "res://dice/faithful/faithful.tscn" )
	var dice_set = dice_set_resource.instantiate()
	dice_set.visible = false
	add_child( dice_set )
	dice_set.position = Vector3.ZERO
	
	for i in range( Die.TYPES.size() ):
		# Create a dupeable die for each die type
		var die_type = Die.TYPES.values()[i]
		var die_name = Die.TYPES.keys()[i].to_lower()
		
		var die: PhysicalDie = die_scene.instantiate()
		die.die_type = die_type
		
		# Add collision model
		var collision: MeshInstance3D = collisions.get_node( die_name )
		assert( collision != null, 
			"Couldn't find collision model with name " + die_name )
		die.score_mesh = collision
		
		# Add cosmetic model
		var model: MeshInstance3D = dice_set.get_node( die_name )
		assert( model != null, "Couldn't find model with name " + die_name )
		model.reparent( die )
		model.position = Vector3.ZERO
		
		add_child( die )
		die_type_to_die[ die_type ] = die
