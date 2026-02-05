shader_type canvas_item;

uniform vec4 dark_color: source_color = vec4( 0.0, 0.0, 0.0, 0.5 );
uniform ivec2 top_left = ivec2( 10, 10 );
uniform ivec2 bottom_right = ivec2( 100, 100 );

const vec4 trans = vec4( 0.0, 0.0, 0.0, 0.0 );

varying vec2 model_coord;

void vertex() {
	model_coord = ( MODEL_MATRIX * vec4( VERTEX, 0.0, 1.0 ) ).xy;
}

void fragment() {
	float highlight = 0.0;
	
	highlight = step( float( top_left.x ), model_coord.x ) 
				* step( float( top_left.y ), model_coord.y )
				* step( model_coord.x, float( bottom_right.x ) )
				* step( model_coord.y, float( bottom_right.y ) );
	vec4 color = mix( dark_color, trans, highlight );
	COLOR = color;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
