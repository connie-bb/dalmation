extends Button
class_name DieSelectorButton

# Configurable
@export var type: Die.TYPES

# Constant
signal die_added( type: Die.TYPES )

func _on_pressed():
	die_added.emit( type )
