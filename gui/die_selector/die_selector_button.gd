extends Button
class_name DieSelectorButton

signal die_selected( type: Die.TYPES, remove: bool )
@export var type: Die.TYPES

func _on_pressed():
	die_selected.emit( type, false )
