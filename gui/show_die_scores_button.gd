extends Button

var shown: bool = false
@export var shown_icon: Texture2D
@export var hidden_icon: Texture2D

func _pressed():
	shown = !shown
	if shown: icon = shown_icon
	else: icon = hidden_icon
