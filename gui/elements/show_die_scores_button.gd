extends Button

# Variable
var shown: bool = false

# Configurable
@export var shown_icon: Texture2D
@export var hidden_icon: Texture2D

# References
@onready var texture_rect = $TypewriterButton/TextureRect/TextureRect2
# Remembering of course that typewriterbutton reparents TextureRect2.

func _pressed():
	shown = !shown
	if shown: texture_rect.texture = shown_icon
	else: texture_rect.texture = hidden_icon
