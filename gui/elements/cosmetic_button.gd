extends Control
class_name CosmeticButton

# Constant
signal pressed( from: CosmeticButton )

# Variable
var cosmetic_name: String = ""

# References
@onready var thumbnail_rect: TextureRect = $Button/VBoxContainer/thumbnail_rect
@onready var name_label: Label = $Button/VBoxContainer/thumbnail_rect/name_label
@onready var author_label: Label = $Button/VBoxContainer/HBoxContainer/author_label
@onready var version_label: Label = $Button/VBoxContainer/HBoxContainer/version_label
@onready var selected_icon: TextureRect = $Button/VBoxContainer/thumbnail_rect/selected_icon

func create_for_cosmetic( for_cosmetic: Cosmetic ):
	cosmetic_name = for_cosmetic.cosmetic_name
	thumbnail_rect.texture = for_cosmetic.thumbnail
	name_label.text = for_cosmetic.cosmetic_name
	author_label.text = for_cosmetic.author
	version_label.text = "for v" + for_cosmetic.made_for_version

func delete():
	queue_free()
	
func show_selected():
	if selected_icon.visible: return
	selected_icon.show()
	
func hide_selected():
	if !selected_icon.visible: return
	selected_icon.hide()

func _on_button_pressed():
	pressed.emit( self )
