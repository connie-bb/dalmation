extends Node3D
class_name SpawnableDice

var die_scene: Resource = preload( "res://dice/die.tscn" )
var die_type_to_die: Dictionary[ Die.TYPES, Die ]

func _ready():
	load_dice_set()

func load_dice_set():
	var dice_set_resource = preload( "res://dice/placeholder/dice.tscn" )
	var dice_set = dice_set_resource.instantiate()
	dice_set.visible = false
	add_child( dice_set )
	dice_set.position = Vector3.ZERO
	
	for i in range( Die.TYPES.size() ):
		var die_type = Die.TYPES.values()[i]
		var die_type_string = Die.TYPES.keys()[i]
		
		var die: Die = die_scene.instantiate()
		die.die_type = die_type
		
		var model_name: String = die_type_string.to_lower()
		var model: MeshInstance3D = dice_set.get_node( model_name )
		assert( model != null, "Couldn't find model with name " + model_name )
		die.score_mesh = model
		
		model.reparent( die )
		model.position = Vector3.ZERO
		add_child( die )
		die_type_to_die[ die_type ] = die
