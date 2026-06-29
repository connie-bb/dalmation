extends Control
class_name CosmeticPicker

# Configurable
@export var header: String = ""

# Constant
signal select_cosmetic( cosmetic_name: String )
signal close

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
	button.name = cosmetic.cosmetic_name
	button.pressed.connect( _on_button_pressed )

func _on_button_pressed( button: CosmeticButton ):
	# Pass it up the chain.
	select_cosmetic.emit( button.name )

func _on_cosmetic_selected( cosmetic_name: String ):
	# This gets called from the backend.
	for child in cosmetics_list.get_children():
		if !( child is CosmeticButton ): continue
		var button = child as CosmeticButton
		if button.name == cosmetic_name:
			button.show_selected()
		else:
			button.hide_selected()

func _on_close_button_pressed():
	close.emit()
