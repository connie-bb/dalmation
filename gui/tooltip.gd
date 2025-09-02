extends Node2D
class_name Tooltip

const OFFSET: Vector2 = Vector2( 15.0, 15.0 )
const MAX_STR_LENGTH: int = 16
@onready var label: Label = $Label

func show_tooltip( text: String ):
	visible = true
	if text.length() > MAX_STR_LENGTH:
		var pos = text.find( "+", MAX_STR_LENGTH )
		text = text.insert( pos, "\n" )
	label.text = text

func hide_tooltip():
	visible = false

func _input( event: InputEvent ):
	if !( event is InputEventMouseMotion ): return
	event = event as InputEventMouseMotion
	position = event.position + OFFSET
