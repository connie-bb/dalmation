extends Node

# Configurable
var roll_sound_delay: float = 0.35
@onready var sounds: Dictionary[ StringName, AudioStreamPlayer ] = {
	"ROLL_PLASTIC_SINGLE": $players/ROLL_PLASTIC_SINGLE,
	"ROLL_PLASTIC_COUPLE": $players/ROLL_PLASTIC_COUPLE,
	"ROLL_PLASTIC_SEVERAL": $players/ROLL_PLASTIC_SEVERAL,
}

# References
@onready var roll_single_delay: Timer = $roll_single_delay
@onready var roll_couple_delay: Timer = $roll_couple_delay
@onready var roll_several_delay: Timer = $roll_several_delay

func _ready():
	Settings.sfx_volume_changed.connect( _on_sfx_volume_changed )

func _on_sfx_volume_changed( value: float ):
	AudioServer.set_bus_volume_linear( 1, value )
	
# For decoupling purposes.
func play( sound: StringName ):
	var player = sounds[ sound ]
	player.play()

func play_roll_single():
	roll_single_delay.start( roll_sound_delay )

func play_roll_couple():
	roll_couple_delay.start( roll_sound_delay )
	
func play_roll_several():
	roll_several_delay.start( roll_sound_delay )

func _on_roll_single_delay_timeout():
	play( "ROLL_PLASTIC_SINGLE" )

func _on_roll_couple_delay_timeout():
	play( "ROLL_PLASTIC_COUPLE" )

func _on_roll_several_delay_timeout():
	play( "ROLL_PLASTIC_SEVERAL" )
