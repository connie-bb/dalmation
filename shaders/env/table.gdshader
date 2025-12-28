shader_type spatial;
render_mode unshaded;

const int SHADOW_SOURCE_COUNT = 30;

group_uniforms textures;
uniform sampler2D table_albedo;
group_uniforms;

group_uniforms blob_shadows;
uniform float shadow_size: hint_range( 0.0, 10.0 ) = 2.0;
uniform float shadow_height: hint_range( 0.0, 10.0 ) = 7.5;
uniform sampler2D shadow_curve;
uniform float shadow_intensity: hint_range( 0.0, 1.0 ) = 1.0;
uniform vec3[ SHADOW_SOURCE_COUNT ] shadow_sources;
group_uniforms;

varying vec3 world_pos;

void vertex() {
	world_pos = ( MODEL_MATRIX * vec4( VERTEX, 1.0 ) ).xyz;
}

float screen( float a, float b ) {
	// the "screen" layer mixing mode from your fav image editor
	return 1.0 - ( ( 1.0 - a ) * ( 1.0 - b ) );
}

float blob_mask( vec3 source ) {
	vec3 xz_difference = ( world_pos - source ) * vec3(1,0,1);
	float xz_distance = length( xz_difference );
	float y_distance = length( world_pos.y - source.y );

	float mask = 1.0 - ( xz_distance / shadow_size );
	mask = clamp( mask, 0.0, 1.0 );
	float height_modulate = 1.0 - ( y_distance / shadow_height );
	height_modulate = clamp( height_modulate, 0.0, 1.0 );
	mask *= height_modulate;

	// So texture sampling stays in bounds
	mask *= 0.98;
	mask += 0.01;
	mask = texture( shadow_curve, vec2( mask ) ).r;
	mask *= shadow_intensity;

	return mask;
}

void fragment() {
	float combined_mask = 0.0;
	for ( int i = 0; i < SHADOW_SOURCE_COUNT; i++ ) {
		combined_mask = screen( combined_mask, blob_mask( shadow_sources[i] ) );
	}
	combined_mask = clamp( combined_mask, 0.0, 1.0 );

	vec3 albedo_sample = texture( table_albedo, UV ).rgb;
	ALBEDO = albedo_sample * ( 1.0 - combined_mask );
}