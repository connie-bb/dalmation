shader_type spatial;

group_uniforms Textures;
uniform sampler2D albedo_texture: source_color;
uniform sampler2D orm_texture;
uniform sampler2D normal_map_texture: hint_normal;
group_uniforms;

varying vec3 world_pos;

#include "res://shaders/dice/floor_ao.gdshaderinc"

void vertex() {
	world_pos = ( MODEL_MATRIX * vec4( VERTEX, 1.0 ) ).xyz;
}

void fragment() {
	vec3 albedo = texture( albedo_texture, UV ).rgb;
	ALBEDO = albedo;

	vec3 orm = texture( orm_texture, UV ).rgb;
	ROUGHNESS = orm.g;
	METALLIC = orm.b;

	vec3 normal_map = texture( normal_map_texture, UV ).rgb;
	NORMAL_MAP = normal_map;

	float ao = floor_ao(
		normal_map,
		world_pos,
		TANGENT, BINORMAL, NORMAL,
		VIEW_MATRIX,
		NODE_POSITION_WORLD );
	AO = ao;
}