extends Node
class_name CosmeticsManager

# Welcome to the CosmeticsManager. 
# Here we do the following:
# 	1. load resource packs from user://cosmetics
# 	2. search res://dice_sets and res://backgrounds for folders
#	   which may be imported as a Cosmetic (the class)
# 	3. Parse the folders to turn them into Cosmetics
#	4. Put Cosmetics into the 'dice_sets' and 'backgrounds' arrays
#
# SpawnableDice handles the actual instantiation of dice sets.
# See the Cosmetic class for further info.

# Variable
var dice_sets: Array[ Cosmetic ]
var backgrounds: Array[ Cosmetic ]

# Constant
signal loading
signal finished
signal status_changed( status: String )
signal new_dice_sets( dice_sets: Array[ Cosmetic ] )
signal dice_set_selected()

# References
@export var alert: Alert

func _ready():
	# Make cosmetics directory if it doesn't exist.
	var path = ProjectSettings.globalize_path( "user://cosmetics" )
	var err: Error = Error.OK
	if !DirAccess.dir_exists_absolute( path ):
		err = DirAccess.make_dir_absolute( path )
	if err != Error.OK:
		Debug.log( "Failed to create user://cosmetics: " \
		+ error_string( err ) )
	
	# Give settings + scene tree a chance to load.
	refresh_cosmetics.call_deferred()
	
func refresh_cosmetics():
	loading.emit()
	status_changed.emit( "Loading user resource packs" )
	load_user_packs()
	
	status_changed.emit( "Searching for dice sets" )
	dice_sets = search_for_cosmetics( "res://dice_sets/" )
	new_dice_sets.emit( dice_sets )
	
	status_changed.emit( "Searching for backgrounds" )
	backgrounds = search_for_cosmetics( "res://backgrounds/" )
	
	await check_missing()
	dice_set_selected.emit()
	finished.emit()

func load_user_packs():
	Debug.log( "Loading user resource packs", Debug.TAG.INFO )
	var dir = DirAccess.open( "user://cosmetics" )
	if !dir:
		var err_string = "Error opening user://cosmetics: " \
			+ error_string( DirAccess.get_open_error() )
		Debug.log( err_string, Debug.TAG.ERROR )
		get_tree().quit( 1 )
	
	for file: String in dir.get_files():
		if !( file.ends_with( ".pck" ) or file.ends_with( ".zip" ) ): 
			continue
		load_pack( "user://cosmetics/" + file )
			
func load_pack( path: String ):
	var success: bool = ProjectSettings.load_resource_pack( path )
	if !success:
		var err_string = "Failed to load resource pack '" \
			+ path + "'."
		Debug.log( err_string, Debug.TAG.ERROR )
		get_tree().quit( 1 )
	else:
		Debug.log( "Loaded resource pack '" + path + "'." )
			
func search_for_cosmetics( path: String ) -> Array[ Cosmetic ]:
	Debug.log( "Searching for cosmetics in " + path, Debug.TAG.INFO )
	var cosmetics: Array[ Cosmetic ] = []
	var dirs: PackedStringArray = ResourceLoader.list_directory( path )
	for file: String in dirs:
		if !file.ends_with( "/" ): continue # Is not a directory
		var cosmetic = check_cosmetic( path + file )
		if cosmetic == null: continue
		cosmetics.append( cosmetic )
		Debug.log( "Found cosmetic: " + cosmetic.cosmetic_name,
			Debug.TAG.INFO )
	Debug.log( "Found " + str( cosmetics.size() ) + " cosmetics.", Debug.TAG.INFO )
	return cosmetics
	
func check_cosmetic( path: String ) -> Cosmetic:
	var cosmetic: Cosmetic = Cosmetic.new()
	var err_prefix = "Error: '" + path + "' is not a cosmetic: "
	
	var dirs: PackedStringArray = ResourceLoader.list_directory( path )
	if !dirs.has( "metadata.json" ):
		var err_string = err_prefix + "No metadata.json found."
		Debug.log( err_string, Debug.TAG.ERROR )
		return null
	cosmetic = parse_metadata( path + "metadata.json" )
	if cosmetic == null: return null # JSON parse error
	
	if !dirs.has( "cosmetic.tscn" ):
		var err_string = err_prefix + "No cosmetic.tscn found."
		Debug.log( err_string, Debug.TAG.ERROR )
		return null
	cosmetic.scene_filepath = path + "cosmetic.tscn"
	
	if !dirs.has( "thumbnail.png" ):
		# We'll let this one slide...
		var warn_string = path + " has no thumbnail.png."
		Debug.log( warn_string, Debug.TAG.WARN )
	else:
		var image: Image = load( path + "thumbnail.png" ) as Image
		var texture: Texture2D = ImageTexture.create_from_image( image )
		cosmetic.thumbnail = texture
	return cosmetic
	
func parse_metadata( path: String ) -> Cosmetic:
	var cosmetic: Cosmetic = Cosmetic.new()
	
	var file_access = FileAccess.open( path, FileAccess.READ )
	if file_access == null:
		var err_string = "Error opening '" + path + "': " \
			+ error_string( FileAccess.get_open_error() )
		Debug.log( err_string, Debug.TAG.ERROR )
		return null

	var raw_text: String = file_access.get_as_text()
	var json = JSON.new()
	var json_err = json.parse( raw_text )
	if json_err != Error.OK:
		var err_string = "Error parsing '" + path + "': " \
			+ error_string( json_err )
		Debug.log( err_string, Debug.TAG.ERROR )
		return null
	
	var data = json.data as Dictionary 
	
	# The layman's deserialization.
	if data.has( "cosmetic_name" ):
		cosmetic.cosmetic_name = data[ "cosmetic_name" ]
	if data.has( "author" ):
		cosmetic.author = data[ "author" ]
	if data.has( "made_for_version" ):
		cosmetic.made_for_version = data[ "made_for_version" ]
	if data.has( "is_dice_set" ):
		cosmetic.is_dice_set = data[ "is_dice_set" ]
	return cosmetic

func has_cosmetic(
	array: Array[ Cosmetic ], cosmetic_name: String
)-> bool:
	# Returns whether an array contains the given cosmetic, by name.
	for cosmetic in array:
		if cosmetic.cosmetic_name == cosmetic_name: return true
	return false

func get_cosmetic( array: Array[ Cosmetic ], cosmetic_name: String ) -> Cosmetic:
	# Searches the array for a given cosmetic, by name.
	# Returns null if none found.
	for cosmetic: Cosmetic in array:
		if cosmetic.cosmetic_name == cosmetic_name: return cosmetic
	return null

func check_missing():
	var err_string: String = ""
	var have_selected: bool = has_cosmetic( 
		dice_sets, Settings.selected_dice_set )
	var have_default: bool = has_cosmetic(
		dice_sets, Settings.default_dice_set )
	
	if have_selected:
		return
	else:
		err_string =  "Error: Selected dice set '" \
			+ Settings.selected_dice_set \
			+ "' not found. Falling back to default set."
		Debug.log( err_string, Debug.TAG.ERROR )
		alert.show_alert( err_string )
		await alert.clicked
		alert.hide_alert()
		Settings.selected_dice_set = Settings.default_dice_set
		Settings.save_settings()
		
	if have_default:
		return
	else:
		err_string = "Fatal error: Default dice set '" \
			+ Settings.default_dice_set \
			+ "' not found."
		Debug.log( err_string, Debug.TAG.ERROR )
		alert.show_alert( err_string )
		await alert.clicked
		get_tree().quit( 1 )

func select_dice_set( cosmetic_name: String ):
	assert( has_cosmetic( dice_sets, cosmetic_name ),
		"Attempted to load non-extant dice set '" + cosmetic_name + "'."
	)
	Settings.selected_dice_set = cosmetic_name
	dice_set_selected.emit()
	# Here we kind of assume SpawnableDice won't have any trouble
	# actually loading / parsing the scene. So if something goes wrong
	# let's crash out before saving the settings.
	Settings.save_settings.call_deferred()

func open_file_dialog():
	var downloads: String = OS.get_system_dir( OS.SYSTEM_DIR_DOWNLOADS )
	DisplayServer.file_dialog_show(
		"Import Cosmetic Files",
		downloads,
		"",
		false,
		DisplayServer.FILE_DIALOG_MODE_OPEN_FILES,
		["*.pck,*.zip;Cosmetic files (*.pck, *.zip);application/octet-stream,application/zip"],
		_on_files_chosen
	)

func _on_files_chosen( status: bool, selected_paths: PackedStringArray, _idx ):
	if !status: return
	for path in selected_paths:
		Debug.log( "Copying '" + path + "'", Debug.TAG.INFO )
		var destination = "user://cosmetics/" + path.get_file()
		var err = DirAccess.copy_absolute( path, destination )
		if err != Error.OK:
			var err_string = error_string( err )
			Debug.log( "Failed to copy '" + path + "': " \
				+ err_string, Debug.TAG.ERROR )
	refresh_cosmetics()
