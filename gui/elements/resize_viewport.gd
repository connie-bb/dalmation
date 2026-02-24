extends SubViewportContainer

# So here's the jist of it...
# The project's display scaling mode is "canvas_items".
# Thus, all 2D items render at proper resolution as the window size changes.
# However, SubViewportContainer is also a 2D item...
# Therefore, whenever we resize the window to be larger,
# The SubViewport renders at its base resolution ( 360x360 as of writing),
# And is then scaled up with a bilinear filter to fit the window. UGLY!!!

# The solution goes like this:
# - Figure out the relative scale of all our shit (the 'scale ratio')
# - Set the pixel resolution of our SubViewportContainer, so that it renders
#	at appropriate resolution for the window size
# - Scale the SubViewportContainer to counter the canvas_item scaling

@onready var viewport: SubViewport = $SubViewport

func _ready() -> void:
	get_viewport().size_changed.connect( _root_viewport_resized )
	
func _root_viewport_resized() -> void:
	var window: Window = get_window()
	
	# How much is everything being scaled?
	var scale_ratio = Vector2( 
		float( window.size.x ) / float( window.content_scale_size.x ),
		float( window.size.y ) / float( window.content_scale_size.y ) )
	
	# Set pixel size
	size = Vector2(
		window.size.x,
		int( float( window.size.y ) / 2.0 ) )
	
	# And then scale
	var lesser_scale_ratio = min( scale_ratio.x, scale_ratio.y )
	scale = Vector2( 1 / lesser_scale_ratio, 1 / lesser_scale_ratio )
	pass
