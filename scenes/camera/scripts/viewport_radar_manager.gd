class_name ViewportRadarManager
extends Node

@onready var radar_item: RadarItem = %RadarItem
@onready var camera: Camera2D = owner

func _process(_delta: float) -> void:
	# TODO: incapsulate this logic into CameraController and use it here instead
	var view := camera.get_viewport_rect().size / camera.zoom
	radar_item.icon.config.base_size = view.x
	radar_item.icon.config.aspect = view.y / view.x
