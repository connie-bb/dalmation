extends Node3D
class_name SpawnableDice

# Variable
var die_scene: Resource = preload( "res://dice/physical_die.tscn" )
var die_type_to_die: Dictionary[ Die.TYPES, PhysicalDie ]

# Constant
signal loading
signal finished
signal status_changed( status: String )

# References
@export var cosmetics_manager: CosmeticsManager 

func load_selected_dice_set():
	# If something goes wrong in here, we just crash via assertions.
	loading.emit()
	
	# Load collision / score meshes
	var collisions_resource = preload( "res://dice/collisions/dice.tscn" )
	var collisions = collisions_resource.instantiate()
	collisions.visible = false
	add_child( collisions )
	collisions.position = Vector3.ZERO
	
	status_changed.emit( "Loading dice set meshes" )
	# Load cosmetic meshes
	var cosmetic: Cosmetic = cosmetics_manager.get_cosmetic(
		cosmetics_manager.dice_sets, Settings.selected_dice_set )
	assert( cosmetic != null )
	var dice_set_resource = ResourceLoader.load(
		cosmetic.scene_filepath, "", ResourceLoader.CACHE_MODE_IGNORE )
	
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
		assert( model != null, "Couldn't find cosmetic model with name " \
			+ die_name )
		model.reparent( die )
		model.position = Vector3.ZERO
		
		die.freeze = true
		
		add_child( die )
		die_type_to_die[ die_type ] = die
	
	finished.emit()
