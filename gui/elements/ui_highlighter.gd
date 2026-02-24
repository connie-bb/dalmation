extends ColorRect
class_name UIHighlighter

# Configurable
@export var target: Control
const border_width: int = 2

# References
var window: Window
var resized_delay: Timer

func _ready():
	resized_delay = Timer.new()
	resized_delay.one_shot = true
	resized_delay.wait_time = 0.1
	add_child( resized_delay )
	resized_delay.timeout.connect( _on_resized_delay_timeout )
	
	window = get_window()
	window.size_changed.connect( _on_window_resized )
	_on_window_resized()

func _on_window_resized():
	if target == null: return
	resized_delay.start()

func _on_resized_delay_timeout():
	highlight( target )

func highlight( new_target: Control ):
	target = new_target
	set_rect( target.get_global_rect() )

func set_rect( rect: Rect2i ):
	var shader_material = material as ShaderMaterial
	shader_material.set_shader_parameter( "top_left", rect.position )
	shader_material.set_shader_parameter( "bottom_right", rect.position + rect.size )
	shader_material.set_shader_parameter( "top_left_border", 
		rect.position - Vector2i( border_width, border_width ) )
	shader_material.set_shader_parameter( "bottom_right_border",
		rect.position + rect.size + Vector2i( border_width, border_width ) )
