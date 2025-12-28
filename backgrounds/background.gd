extends Node3D
class_name Background

# Configurable
@export var blob_shadows_enabled: bool

# References
@export var table_material: ShaderMaterial

func _process( _delta: float ):
	update_blob_shadows()

func update_blob_shadows():
	if !blob_shadows_enabled: return
	table_material.set_shader_parameter( "shadow_sources", VFXManager.die_positions )
