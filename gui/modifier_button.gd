extends Control
class_name ModifierButton

# References
@onready var label = $HBoxContainer/Panel/Label
@onready var minus_button: LongPressButton = $HBoxContainer2/LongPressButtonMinus
@onready var plus_button: LongPressButton = $HBoxContainer2/LongPressButtonPlus

# Constant
signal increment_pressed()
signal decrement_pressed()

func _ready():
	minus_button.long_press_duration = Settings.long_press_duration
	minus_button.long_press_repeat_interval = \
		Settings.modifier_long_press_repeat_interval
	plus_button.long_press_duration = Settings.long_press_duration
	plus_button.long_press_repeat_interval = \
		Settings.modifier_long_press_repeat_interval

func update( modifier ):
	var text: String = str( modifier )
	if modifier > 0:
		text = "+" + text
	# Minus for negative numbers done automatically in str()
	label.text = text

# Seperate so we can do like. Motor stuff on mobile.
func _on_long_press_minus():
	decrement_pressed.emit()

func _on_short_press_minus():
	decrement_pressed.emit()

func _on_long_press_plus():
	increment_pressed.emit()
	
func _on_short_press_plus():
	increment_pressed.emit()
	
func _on_scrolled_down():
	decrement_pressed.emit()
	
func _on_scrolled_up():
	increment_pressed.emit()
