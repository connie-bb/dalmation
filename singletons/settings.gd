extends Node

# Configurable
const default_dice_set: String = "Faithful"
const save_path: String = "user://settings.save"

# Variable
var tutorial_played: bool = false
var sfx_volume: float = 0.5:
	set( value ):
		sfx_volume_changed.emit( value )
		sfx_volume = value
var max_dice: int = 30 
var max_modifier: int = 99
var d10_count_0_as_10: bool = true
var long_press_duration: float = 0.25
var long_press_repeat_interval: float = 0.15
var modifier_long_press_repeat_interval: float = 0.1
var selected_dice_set: String = default_dice_set

# Constant
signal save_load_error( error: String )
signal settings_loaded
signal sfx_volume_changed( value: float )

func _ready():
	# Give scene tree a chance to load, so it can
	# receive the 'settings_loaded' signal.
	load_settings.call_deferred()

func serialize():
	var save_dictionary = {
		"tutorial_played": tutorial_played,
		"sfx_volume": sfx_volume,
		"max_dice": max_dice,
		"max_modifier": max_modifier,
		"d10_count_0_as_10": d10_count_0_as_10,
		"long_press_duration": long_press_duration,
		"long_press_repeat_interval": long_press_repeat_interval,
		"modifier_long_press_repeat_interval": modifier_long_press_repeat_interval,
		"selected_dice_set": selected_dice_set,
	}
	return save_dictionary
	
func deserialize( data: Dictionary ):
	for var_name in data.keys():
		set( var_name, data[ var_name ] )

func save_settings():
	var save_file = FileAccess.open( save_path, FileAccess.WRITE )
	if save_file == null:
		var err_string = "Error saving settings: " \
			+ error_string( FileAccess.get_open_error() )
		save_load_error.emit( err_string )
		Debug.log( err_string, Debug.TAG.ERROR )
		return
	var json_string = JSON.stringify( serialize() )
	save_file.store_line( json_string )
	save_file.close()
	Debug.log( "Settings saved successfully.", Debug.TAG.INFO )
	
func load_settings():
	if not FileAccess.file_exists( save_path ):
		settings_loaded.emit()
		return
		
	var load_file = FileAccess.open( save_path, FileAccess.READ )
	if load_file == null:
		var err_string = "Error loading settings: " \
			+ error_string( FileAccess.get_open_error() )
		save_load_error.emit( err_string )
		Debug.log( err_string, Debug.TAG.ERROR )
		return
	
	var json_string = load_file.get_line()
	var json = JSON.new()
	var err = json.parse( json_string )
	if err != Error.OK:
		var err_string = "JSON parse error while loading settings: " \
			+ error_string( err )
		save_load_error.emit( err_string )
		Debug.log( err_string, Debug.TAG.ERROR )
		return
	Debug.log( "Settings loaded successfully.", Debug.TAG.INFO )
	deserialize( json.data )
	settings_loaded.emit()
