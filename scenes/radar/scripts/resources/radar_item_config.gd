class_name RadarItemConfig
extends Resource

signal radius_updated(radius: float)

@export var radius: float = 64.0: set = _set_radius
@export var icon: RadarIconConfig
@export var selection_icon: RadarIconConfig

func _set_radius(value: float):
	if radius == value: return
	radius = value
	radius_updated.emit(radius)
