group_uniforms FloorAO;
instance uniform float model_size = 1.0; // Height of the model in units.
uniform float ao_intensity: hint_range( 0.0, 1.0 ) = 1.0;
uniform float floor_y = 0.0;
group_uniforms;

const float AO_FADE_HEIGHT = 10.0;
// ^ Inferred by mucking about with raytracing in blender.
const float AO_GAMMA = 2.0;

float floor_ao(
	vec3 normal_map,
	vec3 frag_world_pos,
	vec3 tangent, vec3 binormal, vec3 normal,
	mat4 view_matrix,
	vec3 node_position_world,
) {
		//vec3 normal_map = texture( normal_texture, UV ).rgb - vec3( 0.5, 0.5, 1.0 );
	normal_map = normal_map - vec3( 0.5, 0.5, 1.0 ); // Obtain the deviation from straight up
	mat3 tangent_view_matrix = mat3( tangent, binormal, -normal );
	normal_map = tangent_view_matrix * normal_map;

	vec3 floor_normal = ( view_matrix * vec4(0,1,0,0) ).xyz;
	float ao = ( 1.0 + dot( normal_map, floor_normal )) / 2.0;

	float y_pos = node_position_world.y - floor_y;
	float half_model = model_size / 2.0;
	float floor_distance = ( y_pos - half_model ) / ( AO_FADE_HEIGHT - half_model );
	floor_distance = clamp( floor_distance, 0.0, 1.0 );
	floor_distance = pow( floor_distance, AO_GAMMA );

	float normalized_y_pos = ( frag_world_pos.y - node_position_world.y + 1.0 ) / model_size;
	ao = pow( ao, AO_GAMMA );
	ao *= normalized_y_pos; // Bottom of object is darker than top.
	ao = clamp( ao, 0.0, 1.0 );
	ao = mix( ao, 1.0, floor_distance );
	ao = 1.0 - ( ao_intensity * ( 1.0 - ao ) );

	return ao;
}