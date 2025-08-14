extends RigidBody3D
class_name Die

# References
@export var mesh_instance: MeshInstance3D
# We use a concave mesh to get the score of faces,
# because only concave meshes can have their backfaces detected
# by raycasts. [sic]
# However, collisions between two concave shapes are not supported,
# so we use a separate mesh for physics.
@onready var score_collision: CollisionShape3D = $score_area/score_collision
var mdt: MeshDataTool

func _ready():
	assert( mesh_instance != null, "No MeshInstance3D assigned to die.gd" )
	assert( score_collision != null, "die.gd couldn't find child of type CollisionShape3D")
	
	var mesh: ArrayMesh = mesh_instance.mesh
	var collision_trimesh = mesh.create_trimesh_shape()
	collision_trimesh.backface_collision = true
	score_collision.shape = collision_trimesh
	
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
	var hit: = space_state.intersect_ray( query )
	if !hit:
		push_warning( "die.gd was unable to detect a raycast hit." )
		return -1

	var score_rgb: Color = mdt.get_vertex_color( mdt.get_face_vertex( hit.face_index, 0 ) )
	var score: int = snapped( score_rgb.r, 0.05 ) * 20

	return score
