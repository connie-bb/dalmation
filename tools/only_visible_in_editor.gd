@tool
extends Node3D

@export var show_in_game: bool = false

func _ready():
	if show_in_game: return
	visible = Engine.is_editor_hint()
