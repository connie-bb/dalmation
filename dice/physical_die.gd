extends RigidBody3D
class_name PhysicalDie

# References
@export var score_mesh: MeshInstance3D
# We use a concave mesh to get the score of faces,
# because only concave meshes can have their backfaces detected
# by raycasts. [sic]
# However, collisions between two concave shapes are not supported,
# so we use a separate mesh for physics.
@onready var score_collision: CollisionShape3D = $score_area/score_collision
@onready var physics_collision: CollisionShape3D = $physics_collision
@onready var disabled_sprite: Sprite3D = $disabled_sprite
@onready var locked_sprite: Sprite3D = $locked_sprite
var mesh_data_tool: MeshDataTool

# Variable
var die_type: Die.TYPES
var disabled: bool = false
var locked: bool = false
var score: int

# Constant
signal disable_toggled( die: PhysicalDie )
signal lock_toggled( die: PhysicalDie )

func _ready():
	assert( score_mesh != null, "No score mesh assigned to die.gd" )
	
	var mesh: ArrayMesh = score_mesh.mesh
	var collision_trimesh = mesh.create_trimesh_shape()
	collision_trimesh.backface_collision = true
	score_collision.shape = collision_trimesh
	
	var collision_convex = mesh.create_convex_shape()
	physics_collision.shape = collision_convex
	
	mesh_data_tool = MeshDataTool.new()
	mesh_data_tool.create_from_surface( mesh, 0 )


func toggle_disabled():
	if disabled: enable()
	else: disable()
	
func disable():
	disabled = true
	disabled_sprite.visible = true
	
func enable():
	disabled = false
	disabled_sprite.visible = false

func toggle_locked():
	if locked: unlock()
	else: lock()

func lock():
	locked = true
	locked_sprite.visible = true
	freeze = true
	sleeping = true

func unlock():
	locked = false
	locked_sprite.visible = false

func update_score():
	var ray_distance = 5.0
	var ray_direction = Vector3.UP
	var ray_origin = global_position
	var ray_end = global_position + ( ray_direction * ray_distance )
	
	var space_state = get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create( ray_origin, ray_end )
	query.hit_from_inside = true
	query.hit_back_faces = true
	query.collide_with_areas = true
	query.collide_with_bodies = false
	query.collision_mask = 0b100 # Layer 3 only
	var hit := space_state.intersect_ray( query )
	if !hit:
		push_warning( "die.gd was unable to detect a raycast hit." )
		return -1
		
	# We store a face's score in its vertex color.
	# 0.05 = 1, 	0.10 = 2, 	0.15 = 3 ... 0.95 = 19, 	1.0 = 20
	var score_rgb: Color = mesh_data_tool.get_vertex_color(
		mesh_data_tool.get_face_vertex( hit.face_index, 0 ) )
	score = snapped( score_rgb.r, 0.05 ) * 20
	
	if die_type == Die.TYPES.D_PERCENTILE_10S:
		if score == 10: score = 0	# It's a '00'
		score *= 10
	elif die_type == Die.TYPES.D_PERCENTILE_1S:
		if score == 10: score = 0	# it's a '0'
	
func delete():
	queue_free()
	
func _on_score_area_input_event( _a, event: InputEvent, _b, _c, _d ):
	if !( event is InputEventMouseButton ): return
	var mouse_event: InputEventMouseButton = event
	
	if mouse_event.button_index == MOUSE_BUTTON_LEFT \
	and mouse_event.pressed:
		toggle_disabled()
		disable_toggled.emit( self )
	elif mouse_event.button_index == MOUSE_BUTTON_RIGHT \
	and mouse_event.pressed:
		toggle_locked()
		lock_toggled.emit( self )
