class_name ViewportRadarManager
extends Node

@onready var radar_item: RadarItem = %RadarItem
@onready var camera: Camera2D = owner

func _process(_delta: float) -> void:
	# FIXME: Camera radar rect does not work
	var view := camera.get_viewport_rect().size / camera.zoom
	radar_item.icon.config.base_size = view.x
	radar_item.icon.config.aspect = view.y / view.x
