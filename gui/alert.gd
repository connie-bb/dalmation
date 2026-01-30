extends Control

# References
@onready var label = $Panel/MarginContainer/alert_label

# Constant
signal alert_shown
signal alert_hidden

func show_alert( text: String ):
	visible = true
	label.text = text
	alert_shown.emit()
	
func hide_alert():
	visible = false
	alert_hidden.emit()
