extends Node3D
class_name SpawnableDice

var die_scene: Resource = preload( "res://dice/die.tscn" )
var sides_to_die: Dictionary[ Die.SIDES, Die ]

func _ready():
	load_dice_set()

func load_dice_set():
	var dice_set_resource = preload( "res://dice/placeholder/dice.tscn" )
	var dice_set = dice_set_resource.instantiate()
	dice_set.position = Vector3.ZERO
	add_child( dice_set )
	dice_set.visible = false
	
	for sides_name: String in Die.SIDES.keys():
		var sides = Die.SIDES[ sides_name ]
		var die: Die = die_scene.instantiate()
		die.sides = sides
		
		var model: MeshInstance3D = dice_set.get_node( sides_name.to_lower() )
		assert( model != null, "Couldn't find model with name " + sides_name.to_lower() )
		die.score_mesh = model
		model.reparent( die )
		model.position = Vector3.ZERO
		add_child( die )
		sides_to_die[ sides ] = die
