extends Node2D

@export var context_map: GUIDEMappingContext

func _ready() -> void:
	GUIDE.enable_mapping_context(context_map)
	pass
