extends Control
class_name TypewriterButton

# Configurable
const duration: float = 0.05;
const speed_factor = 1.0 / duration;
@export var normal_texture: Texture2D;
@export var pressed_texture: Texture2D;

# References
@onready var texture_rect: TextureRect = $TextureRect
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready():
	# We can add children that move with the button,
	# Without editing this instance
	for child in get_children():
		if child == texture_rect or child == animation_player: continue
		child.reparent( texture_rect )

func press():
	texture_rect.texture = pressed_texture
	animation_player.play( "press", -1, speed_factor );

func release():
	texture_rect.texture = normal_texture
	animation_player.play( "release", -1, speed_factor );
