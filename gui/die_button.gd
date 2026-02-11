extends Control
class_name DieButton

# Configurable
@export var die_type: Die.TYPES

# References
@onready var label = $Label
@onready var long_press_button: LongPressButton = $LongPressButton
@onready var mechanical_counter: MechanicalCounter = $mechanical_counter

# Constant
signal increment_pressed( die_type: Die.TYPES )
signal decrement_pressed( die_type: Die.TYPES )

func _ready():
	assert( die_type != null, "DieButton has no assigned die_type." )
	long_press_button.long_press_duration = Settings.long_press_duration
		# When settings are implemented, this node will be responsible
		# for receiving the appropriate signals.
	long_press_button.long_press_repeat_interval = \
		Settings.long_press_repeat_interval

func update( count: int ):
	mechanical_counter.set_number( count )

func _on_long_press():
	decrement_pressed.emit( die_type )

func _on_short_press():
	increment_pressed.emit( die_type )

func _on_scrolled_down():
	decrement_pressed.emit( die_type )

func _on_scrolled_up():
	increment_pressed.emit( die_type )
