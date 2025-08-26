extends RigidBody3D
class_name Die

# Variable
enum TYPES { D4, D6, D8, D10, D12, D20, D_PERCENTILE_10S, D_PERCENTILE_1S }
@export var die_type: TYPES

# References
@export var score_mesh: MeshInstance3D
# We use a concave mesh to get the score of faces,
# because only concave meshes can have their backfaces detected
# by raycasts. [sic]
# However, collisions between two concave shapes are not supported,
# so we use a separate mesh for physics.
@onready var score_collision: CollisionShape3D = $score_area/score_collision
@onready var physics_collision: CollisionShape3D = $physics_collision
var mdt: MeshDataTool

func _ready():
	assert( score_mesh != null, "No score mesh assigned to die.gd" )
	
	var mesh: ArrayMesh = score_mesh.mesh
	var collision_trimesh = mesh.create_trimesh_shape()
	collision_trimesh.backface_collision = true
	score_collision.shape = collision_trimesh
	
	var collision_convex = mesh.create_convex_shape()
	physics_collision.shape = collision_convex
	
	mdt = MeshDataTool.new()
	mdt.create_from_surface( mesh, 0 )
	
func get_score() -> int:
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
	print(hit.collider.get_children()[0].shape)
	# We store a face's score in its vertex color.
	# 0.05 = 1, 0.10 = 2, 0.15 = 3 ... 0.95 = 19, 1.0 = 20
	var score_rgb: Color = mdt.get_vertex_color( mdt.get_face_vertex( hit.face_index, 0 ) )
	var score: int = snapped( score_rgb.r, 0.05 ) * 20
	
	if die_type == TYPES.D_PERCENTILE_10S:
		if score == 10: score = 0	# It's a '00'
		score *= 10
	elif die_type == TYPES.D_PERCENTILE_1S:
		if score == 10: score = 0	# it's a '0'

	return score
