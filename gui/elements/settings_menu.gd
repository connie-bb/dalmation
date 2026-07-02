extends Control
class_name SettingsMenu

# References
@onready var settings_main: Control = $settings_main
@onready var dice_set_picker: CosmeticPicker = $dice_set_picker

# Constant
signal show_tutorial_pressed
signal select_dice_set( cosmetic: Cosmetic )
signal import_cosmetics
signal refresh_cosmetics

func open_settings():
	show()
	settings_main.show()
	
func close_settings():
	Settings.save_settings()
	hide()
	settings_main.hide()

func open_dice_set_picker():
	settings_main.hide()
	dice_set_picker.show()
	
func close_dice_set_picker():
	dice_set_picker.hide()
	settings_main.show()

func _input( event: InputEvent ):
	if !visible: return
	if event.is_action_pressed( "ui_exit" ):
		close_settings()

func _on_show_tutorial_pressed():
	close_settings()
	show_tutorial_pressed.emit()
	
func _on_dice_set_picker_select( cosmetic_name: String ):
	# Pass it up the chain.
	select_dice_set.emit( cosmetic_name )

func _on_dice_set_selected():
	# A dice set has been selected and loaded successfully.
	var cosmetic_name: String = Settings.selected_dice_set
	dice_set_picker.show_selected_cosmetic( cosmetic_name )

func _on_new_dice_sets( dice_sets: Array[ Cosmetic ] ):
	# CosmeticsManager has a new list of dice_sets for us.
	dice_set_picker.new_list( dice_sets )

func _on_import_cosmetics():
	# Pass it up the chain.
	import_cosmetics.emit()

func _on_refresh_cosmetics():
	# Pass it up the chain.
	refresh_cosmetics.emit()
