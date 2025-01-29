class_name RadarIconConfig
extends Resource

signal base_size_updated(base_size: float)
signal scale_updated(scale: float)
signal aspect_updated(aspect: float)

@export var texture: Texture2D
@export var color: Color = Color(1.0, 0.1, 0.3)
@export var base_size: float = 8.0: set = _update_size
@export var scale: float = 1.0: set = _update_scale
@export var aspect: float = 1.0: set = _update_aspect
@export var dynamic_scale: bool = false
@export var use_real_size: bool = false
@export var free_rotation: bool = true
@export var unique: bool = false

func _update_size(value: float) -> void:
	base_size = value
	base_size_updated.emit(value)

func _update_scale(value: float) -> void:
	scale = value
	scale_updated.emit(value)

func _update_aspect(value: float) -> void:
	aspect = value
	aspect_updated.emit(value)
