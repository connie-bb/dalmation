extends Control

func show_menu():
	visible = true
	mouse_filter = Control.MOUSE_FILTER_STOP
	
func hide_menu():
	visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE
