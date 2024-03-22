extends Node

@onready var radar_item: RadarItem = %RadarItem
@onready var camera: Camera2D = owner

var _base_size: Vector2

func _ready():
	_base_size = radar_item.texture.get_size()

func _process(_delta):
	var view := camera.get_viewport_rect().size / camera.zoom
	radar_item.icon_scale = view.x
	radar_item.icon_aspect = view.y / view.x
