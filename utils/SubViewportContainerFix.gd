# https://github.com/godotengine/godot/issues/77149
# Bandaid by BenLubar and OhiraKyou.

# Produces an unsuppressable warning which we don't care about.
class_name SubViewportContainerFix
extends SubViewportContainer

var _dont_recurse : bool

func _ready() -> void:
	resized.connect(_on_resized)
	_on_resized()

func _on_resized() -> void:
	if _dont_recurse:
		return

	assert( not stretch )

	var window := get_window()
	var viewport_size := Vector2(window.size)
	var reference_size := Vector2(window.content_scale_size)
	var viewport_scale := viewport_size / reference_size
	var size_scale := minf(viewport_scale.x, viewport_scale.y)

	@warning_ignore_start( "integer_division" )
	var scaled_size := Vector2i((size * scale * size_scale).round()) / stretch_shrink
	@warning_ignore_restore( "integer_division" )
	if Vector2i(size.round()) == scaled_size:
		return

	_dont_recurse = true
	# we need to set the container's size first or it'll get
	# resized by the viewport resize (ugh)
	scale = Vector2(1.0 / size_scale, 1.0 / size_scale)
	size = scaled_size
	
	for subviewport : SubViewport in find_children(
		"*", "SubViewport", false, false):
		# avoid reallocating textures we don't need to reallocate
		if subviewport.size != scaled_size:
			subviewport.size = scaled_size

	_dont_recurse = false
