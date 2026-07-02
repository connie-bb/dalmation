extends Control
class_name CosmeticPicker

# Configurable
@export var header: String = ""

# Constant
signal select_cosmetic( cosmetic_name: String )
signal close
signal import_cosmetics
signal refresh_cosmetics

# References
@onready var cosmetics_list: Control = $VBoxContainer/ScrollContainer/MarginContainer/cosmetics_list
@onready var cosmetic_button_res: PackedScene = preload(
	"res://gui/elements/cosmetic_button.tscn" )

func new_list( cosmetics: Array[ Cosmetic ] ):
	for child in cosmetics_list.get_children():
		if !( child is CosmeticButton ): continue
		var button = child as CosmeticButton
		button.delete() # Bye-bye!
	
	for cosmetic: Cosmetic in cosmetics:
		create_button( cosmetic )
		
func create_button( cosmetic: Cosmetic ):
	var button: CosmeticButton = cosmetic_button_res.instantiate()
	cosmetics_list.add_child( button )
	button.create_for_cosmetic( cosmetic )
	button.pressed.connect( _on_button_pressed )

func _on_button_pressed( button: CosmeticButton ):
	# Pass it up the chain.
	select_cosmetic.emit( button.cosmetic_name )

func show_selected_cosmetic( cosmetic_name: String ):
	# This gets called from the backend.
	for child in cosmetics_list.get_children():
		if !( child is CosmeticButton ): continue
		var button = child as CosmeticButton
		if button.cosmetic_name == cosmetic_name:
			button.show_selected()
		else:
			button.hide_selected()

func _on_close_button_pressed():
	close.emit()

func _on_import_button_pressed():
	import_cosmetics.emit()
	
func _on_folder_button_pressed():
	var path = ProjectSettings.globalize_path( "user://cosmetics" )
	OS.shell_show_in_file_manager( path )

func _on_refresh_button_pressed():
	refresh_cosmetics.emit()
