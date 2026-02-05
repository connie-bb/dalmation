shader_type canvas_item;

uniform vec4 dark_color: source_color = vec4( 0.0, 0.0, 0.0, 0.5 );
uniform vec2 top_left = vec2( 10, 10 );
uniform vec2 bottom_right = vec2( 100, 10 );
uniform vec2 top_left_border = vec2( 5, 5 );
uniform vec2 bottom_right_border = vec2( 105, 105 );

const vec4 border_color = vec4( 1.0, 1.0, 1.0, 1.0 );
const vec4 trans = vec4( 0.0, 0.0, 0.0, 0.0 );


varying vec2 model_coord;

void vertex() {
	model_coord = ( MODEL_MATRIX * vec4( VERTEX, 0.0, 1.0 ) ).xy;
}

void fragment() {
	float border = 0.0;
	float highlight = 0.0;
	
	vec4 color = dark_color;
	
	border = step( top_left_border.x, model_coord.x ) 
			* step( top_left_border.y , model_coord.y )
			* step( model_coord.x, bottom_right_border.x )
			* step( model_coord.y, bottom_right_border.y );
	color = mix( color, border_color, border );
	
	highlight = step( top_left.x, model_coord.x ) 
				* step( top_left.y , model_coord.y )
				* step( model_coord.x, bottom_right.x )
				* step( model_coord.y, bottom_right.y );
	color = mix( color, trans, highlight );
	COLOR = color;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
